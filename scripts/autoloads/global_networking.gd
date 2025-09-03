extends Node

var database_class := preload("res://scripts/server/database_controller.gd")
var database: Database

var local_player: PlayerData

# only for server
var connected_players: Array[int] = [3]
var identified_players: Dictionary[int, PlayerData] = {3: PlayerData.new("bob")}

# contains max one session on clients
var sessions: Array[SessionData] = [SessionData.new("Session2", "private", 3, [3,4,5,6], {}, "123456")]

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id: int, player_info)
signal player_disconnected(peer_id: int)
signal server_disconnected
signal ident_processed(success: bool)

var server_ip = "192.168.68.100"
var port = 3000
var max_connected_players = 20


var _connect_success_callback = null
var _connect_failure_callback = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# signals for server and clients
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	# signals only for clients
	multiplayer.connected_to_server.connect(_on_connect_success)
	multiplayer.connection_failed.connect(_on_connect_failure)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.set_bind_ip("0.0.0.0")
	var err = peer.create_server(port, max_connected_players)
	if err != OK:
		print("Failed to start server: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)
	database = database_class.new()

	
func _connect_to_server(on_success: Callable, on_failure: Callable):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, port)
	if err != OK:
		push_error("Failed to create client: %d" % err)
		return
	print("Connecting to server...")
	multiplayer.multiplayer_peer = peer
	_connect_success_callback = on_success
	_connect_failure_callback = on_failure


### LOGIN ###
func login_user(username: String, password: String):
	if multiplayer.multiplayer_peer: #TODO: make sure is set to null on disconnect
		# call _login_user rpc on server
		_login_user.rpc_id(1, username, password)
	else:
		# first connect to server before rpc call
		_connect_to_server(func(): _login_user.rpc_id(1, username, password),
						func(): ident_processed.emit(false))

@rpc("any_peer", "call_remote", "reliable")  # server
func _login_user(username: String, password: String):
	var sender_id = multiplayer.get_remote_sender_id()
	if database.validate_password(username, password):
		var player = PlayerData.new(username, false, database.get_user_rank(username))
		
		identified_players[sender_id] = player
		_login_processed.rpc_id(sender_id, true, player.serialize())
	else:
		_login_processed.rpc_id(sender_id, false)
		
@rpc("authority", "call_remote", "reliable")  # client
func _login_processed(success: bool, serialized_player: Dictionary[String, Variant] = {}):
	local_player = PlayerData.deserialize(serialized_player)
	ident_processed.emit(success)


### NICKNAME ###
func nickname_user(nickname: String):
	if multiplayer.multiplayer_peer: #TODO: make sure is set to null on disconnect
		# call _nickname_user rpc on server
		_nickname_user.rpc_id(1, nickname)
	else:
		# first connect to server before rpc call
		_connect_to_server(func(): _nickname_user.rpc_id(1, nickname),
						func(): ident_processed.emit(false))

@rpc("any_peer", "call_remote", "reliable")  # server
func _nickname_user(nickname: String):
	var sender_id = multiplayer.get_remote_sender_id()
	var player = PlayerData.new(nickname, true)
	
	identified_players[sender_id] = player
	_nickname_processed.rpc_id(sender_id, true, player.serialize())


@rpc("authority", "call_remote", "reliable")  # client
func _nickname_processed(success: bool, serialized_player: Dictionary[String, Variant] = {}):
	local_player = PlayerData.deserialize(serialized_player)
	ident_processed.emit(success)


### REGISTER ###
func register_user(username: String, password: String):
	if multiplayer.multiplayer_peer: #TODO: make sure is set to null on disconnect
		# call _register_user rpc on server
		_register_user.rpc_id(1, username, password)
	else:
		# first connect to server before rpc call
		_connect_to_server(func(): _register_user.rpc_id(1, username, password),
						func(): ident_processed.emit(false))

@rpc("any_peer", "call_remote", "reliable")  # server
func _register_user(username: String, password: String):
	var sender_id = multiplayer.get_remote_sender_id()
	database.add_user(username, password)
	var player = PlayerData.new(username, false, database.get_user_rank(username))
	
	identified_players[sender_id] = player
	_register_processed.rpc_id(sender_id, true, player.serialize())

@rpc("authority", "call_remote", "reliable")  # client
func _register_processed(success: bool, serialized_player: Dictionary[String, Variant] = {}):
	local_player = PlayerData.deserialize(serialized_player)
	ident_processed.emit(success)


### JOIN PARTY ###
func check_join_code(code: String):
	_check_join_code.rpc_id(1, code)

# server
@rpc("any_peer", "call_remote", "reliable")
func _check_join_code(code: String):
	for session in sessions:
		if code == session.game_code:
			#TODO
			pass
			#_player_joined.rpc(connected_players.find(func(p): return p.id == multiplayer.get_remote_sender_id()))
	
#@rpc("any_peer", "call_remote", "reliable")
#func _player_joined(player: PlayerData):
	##TODO handle self sifferently than others
	#joined_players[multiplayer.get_remote_sender_id()] = player






### MULTIPLAYER API HANDLERS ###
func _on_player_connected(id):
	if multiplayer.is_server():
		print("A client connected.")
		connected_players.append(id)
	else:
		print("Another player connected.")

func _on_player_disconnected(id):
	#TODO
	if multiplayer.is_server():
		print("A client disconnected.")
		connected_players.erase(id)
		identified_players.erase(id)
	else:
		print("Another player disconnected.")
	#players.erase(id)
	player_disconnected.emit(id)

func _on_connect_success():
	print("Connected to server!")
	if _connect_success_callback:
		_connect_success_callback.call()
		_connect_success_callback = null

func _on_connect_failure():
	print("Failed to connect to server")
	if _connect_failure_callback:
		_connect_failure_callback.call()
		_connect_failure_callback = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	print("Server disconnected...trying to reconnect...")
	server_disconnected.emit() #TODO: make sure every place that listenes to networking signals is never instanciated on the server
	_connect_to_server(_connect_success_callback, _connect_failure_callback) #TODO: maybe different callbacks?


## LEFTOVERS ##

#@rpc("any_peer", "reliable")
#func _register_player(new_player_info):
	#var new_player_id = multiplayer.get_remote_sender_id()
	##players[new_player_id] = new_player_info
	#player_connected.emit(new_player_id, new_player_info)
#
#func send_move(move_data: Dictionary) -> void:
	#if current_turn != player_id:
		#print("Not your turn!")
		#return
	#rpc_id(1, "make_move", player_id, move_data)
#
#@rpc("call_remote")
#func update_state(new_state: Dictionary) -> void:
	#game_state = new_state
	#print("Game state updated: %s" % str(game_state))
#
#@rpc("call_remote")
#func update_turn(turn_player_id: int) -> void:
	#current_turn = turn_player_id
	#if current_turn == player_id:
		#print("Your turn!")
	#else:
		#print("Player %d's turn" % current_turn)
