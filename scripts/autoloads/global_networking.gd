extends Node

# variables only used by the server instance
var database: Database
var map_generator: MapGenerator
var connected_players: Dictionary[int, Player] = {} # 3: Player.new("bob")
var sessions: Array[Session] = [] # Session.new("private", 3, {3: Player.new("bob")}, 123456, "Session2")

# variables only used by the client instance
var local_player: Player = null
var session: Session = null

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id: int, player_info)
signal player_disconnected(peer_id: int)
signal server_disconnected
signal ident_processed(success: bool)
signal session_set()
signal create_private_room_processed(success: bool)
signal join_private_room_processed(success: bool)
signal start_session_game_processed(success: bool)

var ip_config := preload("res://scripts/database_controller.gd")
var server_ip = "192.168.68.102"
var port = 3000
var max_connected_players = 20


var _connect_success_callback = null
var _connect_failure_callback = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void: # runs on both client and server
	# signals for server and clients
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	# signals only for clients
	multiplayer.connected_to_server.connect(_on_connect_success)
	multiplayer.connection_failed.connect(_on_connect_failure)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# runs at startup on the instance that is run as server, see main.gd
func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.set_bind_ip("0.0.0.0")
	var err = peer.create_server(port, max_connected_players)
	if err != OK:
		print("Failed to start server: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)
	database = Database.new()
	map_generator = MapGenerator.new()

# runs once user decides to use online features, creates a client on the users instance
func _connect_to_server(on_success: Callable, on_failure: Callable): # 
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, port)
	if err != OK:
		push_error("Failed to create client: %d" % err)
		return
	print("Connecting to server...")
	multiplayer.multiplayer_peer = peer
	_connect_success_callback = on_success
	_connect_failure_callback = on_failure




### NICKNAME ###
func request_nickname_user(nickname: String): # client request
	print("[CLIENT] Start nicknaming player: ", nickname)
	if _connected_to_server():
		print("[CLIENT] Already connected.")
		# call _nickname_user rpc on server
		_nickname_user.rpc_id(1, nickname)
	else:
		# first connect to server before rpc call
		_connect_to_server(func(): _nickname_user.rpc_id(1, nickname),
						func(): ident_processed.emit(false))

@rpc("any_peer", "call_remote", "reliable")  # server handler
func _nickname_user(nickname: String):
	print("[SERVER] Nicknaming client: ", nickname)
	var sender_id = multiplayer.get_remote_sender_id()
	var player = Player.new(nickname, true)
	
	connected_players[sender_id] = player
	_nickname_processed.rpc_id(sender_id, true, player.to_dict())


@rpc("authority", "call_remote", "reliable")  # client callback
func _nickname_processed(success: bool, player_dict: Dictionary[StringName, Variant] = {}):
	if success:
		print("[CLIENT] Nicknaming player succeded: ", player_dict)
		local_player = Player.from_dict(player_dict)
	else:
		print("[CLIENT] Nicknaming player failed.")
		local_player = null
	
	ident_processed.emit(success)




### LOGIN ###
func request_login_user(username: String, password: String): # client request
	print("[CLIENT] Start logging in player: ", username)
	if _connected_to_server():
		print("[CLIENT] Already connected.")
		# call _login_user rpc on server
		_login_user.rpc_id(1, username, password)
	else:
		# first connect to server before rpc call
		_connect_to_server(func(): _login_user.rpc_id(1, username, password),
						func(): ident_processed.emit(false))

@rpc("any_peer", "call_remote", "reliable")  # server handler
func _login_user(username: String, password: String):
	print("[SERVER] Logging in client: ", username)
	var sender_id = multiplayer.get_remote_sender_id()
	if database.validate_password(username, password):
		var player = Player.new(username, false, database.get_user_rank(username))
		
		connected_players[sender_id] = player
		_login_processed.rpc_id(sender_id, true, player.to_dict())
	else:
		_login_processed.rpc_id(sender_id, false)
		
@rpc("authority", "call_remote", "reliable")  # client callback
func _login_processed(success: bool, player_dict: Dictionary[StringName, Variant] = {}):
	if success:
		print("[CLIENT] Logging in player succeded: ", player_dict)
		local_player = Player.from_dict(player_dict)
	else:
		print("[CLIENT] Logging in player failed.")
		local_player = null
	
	ident_processed.emit(success)




### REGISTER ###
func request_register_user(username: String, password: String): # client request
	print("[CLIENT] Start registering player: ", username)
	if _connected_to_server():
		print("[CLIENT] Already connected.")
		# call _register_user rpc on server
		_register_user.rpc_id(1, username, password)
	else:
		# first connect to server before rpc call
		_connect_to_server(func(): _register_user.rpc_id(1, username, password),
						func(): ident_processed.emit(false))

@rpc("any_peer", "call_remote", "reliable")  # server handler
func _register_user(username: String, password: String):
	print("[SERVER] Registering client: ", username)
	var sender_id = multiplayer.get_remote_sender_id()
	database.add_user(username, password)
	var player = Player.new(username, false, database.get_user_rank(username))
	
	connected_players[sender_id] = player
	_register_processed.rpc_id(sender_id, true, player.to_dict())

@rpc("authority", "call_remote", "reliable")  # client callback
func _register_processed(success: bool, player_dict: Dictionary[StringName, Variant] = {}):
	if success:
		print("[CLIENT] Registering player succeded: ", player_dict)
		local_player = Player.from_dict(player_dict)
	else:
		print("[CLIENT] Registering player failed.")
		local_player = null
	
	ident_processed.emit(success)




### CREATE PRIVATE ROOM ###
func request_create_private_room(): # client request
	print("[CLIENT] Start creating private room: ")
	if _connected_to_server():
		_create_private_room.rpc_id(1)
	else:
		print("[CLIENT] Abort: not connected to server.")

@rpc("any_peer", "call_remote", "reliable")  # server handler
func _create_private_room():
	print("[SERVER] Creating private room.")
	var sender_id = multiplayer.get_remote_sender_id()
	var game_code = 123456
	var sess = Session.new("private", sender_id, {sender_id: connected_players[sender_id]}, game_code)
	
	sessions.append(sess)
	_create_private_room_processed.rpc_id(sender_id, true, sess.to_dict())

@rpc("authority", "call_remote", "reliable")  # client callback
func _create_private_room_processed(success: bool, session_dict: Dictionary[StringName, Variant] = {}):
	if success:
		print("[CLIENT] Creating private room succeded: ", session_dict)
		session = Session.from_dict(session_dict)
		session_set.emit()
	else:
		print("[CLIENT] Creating private room failed.")
		session = null
	
	create_private_room_processed.emit(success)




### JOIN PRIVATE ROOM ###
func request_join_private_room(code: int): # client request
	print("[CLIENT] Start joining private room with code: ", code)
	if _connected_to_server():
		_join_private_room.rpc_id(1, code)
	else:
		print("[CLIENT] Abort: not connected to server.")

@rpc("any_peer", "call_remote", "reliable") # server handler
func _join_private_room(code: int):
	for sess in sessions:
		if code == sess.game_code:
			var joined_player_id = multiplayer.get_remote_sender_id()
			var joined_player = connected_players[joined_player_id]
			
			var success = true
			_join_private_room_processed.rpc_id(joined_player_id, success, sess.to_dict())
			
			# update session on server
			sess.add_player(joined_player_id, joined_player)
			# update session on all clients
			if success:
				for player_id in sess.players.keys():
					_session__add_player.rpc_id(player_id, joined_player_id, joined_player.to_dict())
			break
					
@rpc("authority", "call_remote", "reliable") # client callback
func _join_private_room_processed(success: bool, session_dict: Dictionary[StringName, Variant]):
	if success:
		print("[CLIENT] Joining private room succeded: ", session_dict)
		session = Session.from_dict(session_dict)
	else:
		print("[CLIENT] Joining private room failed.")
		session = null
		
	join_private_room_processed.emit(success)

# TODO: make all server rpcs "failable"
@rpc("authority", "call_remote", "reliable") # client callback
func _request_processed(request_name: String, success: bool, handler: Callable, handler_args: Array, processed_signal: Signal):
	if success:
		print("[CLIENT] "+request_name+" succeded: ", handler_args)
	else:
		print("[CLIENT] "+request_name+" failed.")
	if handler:
		handler.callv(handler_args)
		
	processed_signal.emit(success)

### Start SESSION GAME ###
func request_start_session_game(mode_name: String = ""): # client request
	print("[CLIENT] Start session game.")
	if mode_name != "":
		session.mode_name = mode_name
	
	if session.type == "local":
		session.start_game()
	elif _connected_to_server(): # type == private online/public online
		_start_session_game.rpc_id(1)
	else:
		print("[CLIENT] Abort: online session but not connected to server.")

@rpc("any_peer", "call_remote", "reliable") # server handler
func _start_session_game():
	var sender_id = multiplayer.get_remote_sender_id()
	for sess in sessions:
		if sender_id == sess.admin_id:
			var success = true
			_start_session_game_processed.rpc_id(sender_id, success)
			
			# start game on server
			sess.start_game()
			
			# start game on all player clients
			for player_id in sess.players.keys():
				_session__start_game.rpc_id(player_id)
			
			var generated_map: Map = map_generator.generate()

			# set_map on server
			sess.set_map(generated_map)
			
			# set_map on all player clients
			for player_id in sess.players.keys():
				_session__set_map.rpc_id(player_id, generated_map.to_dict())

@rpc("authority", "call_remote", "reliable") # client callback
func _start_session_game_processed(success: bool, session_dict: Dictionary[StringName, Variant]):
	if success:
		print("[CLIENT] Starting session game succeded.")
	else:
		print("[CLIENT] Starting session game failed.")
		
	start_session_game_processed.emit(success)



### RPC-WRAPPERS FOR UPDATE-METHODS OF THE CLIENT-SESSION ###
### Used by the server to directly update a clients session, calls update methods on the client session
@rpc("authority", "call_remote", "reliable") # other room clients
func _session__add_player(id: int, player_dict: Dictionary[StringName, Variant]):
		session.add_player(id, Player.from_dict(player_dict))
		
@rpc("authority", "call_remote", "reliable") # other room clients
func _session__start_game():
		session.start_game()

@rpc("authority", "call_remote", "reliable") # other room clients
func _session__set_map(map: Map):
		session.set_map(map)

@rpc("authority", "call_remote", "reliable") # other room clients
func _session__perform_unit_action(unit_id: int, action: Action):
		session.perform_unit_action(unit_id, action)



### HANDLERS FOR MULTIPLAYER EVENTS ###
func _on_player_connected(id):
	if multiplayer.is_server():
		print("A client connected.")
	elif id != multiplayer.get_unique_id():
		print("Another peer connected.")

func _on_player_disconnected(id):
	#TODO: handle player exit smooth on all other peers
	if multiplayer.is_server():
		print("A client disconnected.")
		connected_players.erase(id)
	else:
		print("Another peer disconnected.")
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


## UTILS
func _connected_to_server() -> bool:
	return multiplayer.multiplayer_peer is ENetMultiplayerPeer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
