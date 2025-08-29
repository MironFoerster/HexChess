extends Node

# players relevant to the server
var connected_players: Array[PlayerData] = [PlayerData.new(3, "bob")]
#{
	#"id": 3,
	#"nickname": "bob"
#}

# players relevant to the client
var joined_players: Array[PlayerData] = [PlayerData.new(3, "bob")]

var sessions: Array[SessionData] = [SessionData.new("Session2", "private", 4, [3,4,5,6], "123456")]
#{
	#"node_name": "Session2",
	#"type": "private", # / "public"
	#"admin_id": 4,
	#"player_ids": [3,4,5,6],
	#"game_code": "123456",
#}

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var server_ip = "172.20.32.1"
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

	
func connect_to_server(ip, port, on_success: Callable, on_failure: Callable):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, port)
	if err != OK:
		push_error("Failed to create client: %d" % err)
		return
	print("Connecting to server...")
	multiplayer.multiplayer_peer = peer
	_connect_success_callback = on_success
	_connect_failure_callback = on_failure

func _on_player_connected(id):
	if multiplayer.is_server():
		print("A client connected.")
	else:
		print("Another player connected.")

func _on_player_disconnected(id):
	#TODO
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
	joined_players.clear()
	server_disconnected.emit()


func check_join_code(code: String):
	_check_join_code.rpc_id(1, code)
	
@rpc("any_peer", "call_remote", "reliable")
func _check_join_code(code: String):
	for session in sessions:
		if code == session.game_code:
			_player_joined.rpc(connected_players.find(func(p): return p.id == multiplayer.get_remote_sender_id()))
	#multiplayer.get_remote_sender_id()
	
@rpc("any_peer", "call_remote", "reliable")
func _player_joined(player: PlayerData):
	#TODO handle self sifferently than others
	joined_players.append(player)





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
