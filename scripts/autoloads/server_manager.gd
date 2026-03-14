extends Node


var database: Database

var active_players: Dictionary[int, Player] = {}
var reconnecting_peers: Dictionary[int, float] = {} 
var map_generator: MapGenerator
var active_battles: Array[Battle] = [] # Battle.new("private", 3, {3: Player.new("bob")}, 123456, "Session2")


func _process(_delta):
	var now = Time.get_unix_time_from_system()

	for peer_id in reconnecting_peers.keys():
		if now > reconnecting_peers[peer_id]:
			active_players.erase(peer_id)
			reconnecting_peers.erase(peer_id)

func initialize_server():
	# wire up networking signals on server, make sure theres no duplicate connections
	multiplayer.peer_connected.connect(handle_peer_connected)
	multiplayer.peer_disconnected.connect(handle_peer_disconnected)
	
	database = Database.new()
	map_generator = MapGenerator.new()

### HANDLERS ###
func handle_nickname_player(sender_id: int, nickname: String):
	print("[SERVER] Nicknaming player: ", nickname)

	var player = Player.new(nickname, true)
	active_players[sender_id] = player
	
	GlobalNetworking.identify_player_processed([sender_id], true, player)

func handle_login_player(sender_id: int, username: String, password: String):
	print("[SERVER] Logging in player: ", username)

	if database.validate_password(username, password):
		var player = load_player_from_database(username)
		
		active_players[sender_id] = player
		
		GlobalNetworking.identify_player_processed([sender_id], true, player)
	else:
		GlobalNetworking.identify_player_processed([sender_id], false)


func handle_register_player(sender_id: int, username: String, password: String):
	print("[SERVER] Registering player: ", username)
	
	database.add_user(username, password)
	var player = load_player_from_database(username)
	
	active_players[sender_id] = player
	GlobalNetworking.identify_player_processed([sender_id], true, player)


func handle_create_private_room(sender_id: int):
	print("[SERVER] Creating private room.")
	var game_code = 123456
	print(active_players)
	var battle = Battle.new("private", sender_id, {sender_id: active_players[sender_id]}, game_code)
	
	active_battles.append(battle)
	GlobalNetworking.create_private_room_processed([sender_id], true, battle)


func handle_join_private_room(joined_id: int, code: int):
	for battle in active_battles:
		if code == battle.game_code:
			var joined_player = active_players[joined_id]
			
			var success = true
			GlobalNetworking.join_private_room_processed([joined_id], success, battle)
			
			# update battle on server
			battle.add_player(joined_id, joined_player)
			# update battle on all clients
			if success:
				GlobalNetworking.battle__add_player(battle.players.keys(), joined_id, joined_player)
			break

func handle_start_battle(sender_id):
	for battle in active_battles:
		if sender_id == battle.admin_id:
			GlobalNetworking.start_battle_processed([sender_id], true)
			
			# start game on server
			battle.start_game()
			
			# start game on all player clients
			GlobalNetworking.battle__start(battle.players.keys())

			
			var generated_map: Map = map_generator.generate()

			# set_map on server
			battle.set_map(generated_map)
			
			# set_map on all player clients
			GlobalNetworking.battle__set_map(battle.players.keys(), generated_map)
		else:
			GlobalNetworking.start_battle_processed([sender_id], false)

func handle_submit_command(sender_id: int, command: Command):
	for battle in active_battles:
		if sender_id in battle.players.keys():
			if sender_id == battle.player_turn:
				GlobalNetworking.submit_command_processed([sender_id], true)
				
				# execute command on server
				battle.execute_command(command)
				
				# execute command on all players
				GlobalNetworking.battle__execute_command(battle.players.keys(), command)
				break
		else:
			break
			
func handle_end_turn(sender_id: int):
	pass#TODO

func handle_peer_connected(peer_id: int):
	print("A client connected.")
	active_players[peer_id] = Player.new() # TODO what about reconnects

func handle_peer_disconnected(peer_id: int):
	print("A client disconnected.")
	var player = active_players[peer_id]
	if player == null:
		return
		
		# peer has 10 seconds to reconnect before player object is removed

	reconnecting_peers[peer_id] = Time.get_unix_time_from_system() + 10


### HELPERS ###
func load_player_from_database(username: String) -> Player:
	return Player.new(username, false, database.get_user_rank(username))
	
