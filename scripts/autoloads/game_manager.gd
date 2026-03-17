extends Node


var player: Player
var map_generator: MapGenerator

var _connect_success_callback = null
var _connect_failure_callback = null


# These signals can be connected to by a UI lobby scene or the battle scene.
signal player_connected(peer_id: int, player_info)
signal player_disconnected(peer_id: int)
signal server_disconnected()
signal ident_processed(success: bool)
signal create_private_room_processed(success: bool)
signal join_private_room_processed(success: bool)
signal start_battle_processed(success: bool)

func initialize_client() -> void:
	# wire up networking signals on client, make sure theres no duplicate connections
	multiplayer.peer_connected.connect(handle_peer_connected)
	multiplayer.peer_disconnected.connect(handle_peer_disconnected)
	
	multiplayer.connected_to_server.connect(handle_connect_success)
	multiplayer.connection_failed.connect(handle_connect_failure)
	multiplayer.server_disconnected.connect(handle_server_disconnected)


func handle_identify_player_processed(success: bool, _player: Player):
	if success:
		print("[CLIENT] Identifying player succeded: ", _player)
		player = _player
	else:
		print("[CLIENT] Identifying player failed.")
	ident_processed.emit(success)

func handle_create_private_room_processed(success: bool, battle: Battle):
	if success:
		print("[CLIENT] Create private room succeded: ", battle)
		BattleManager.set_battle(battle)
		SceneManager.page_transition_to("private_lobby_admin")
	else:
		print("[CLIENT] Create private room failed.")
	
	create_private_room_processed.emit(success)
	
func handle_join_private_room_processed(success: bool, battle: Battle):
	if success:
		print("[CLIENT] Join private room succeded: ", battle)
		BattleManager.set_battle(battle)
		SceneManager.page_transition_to("private_lobby_joined")
	else:
		print("[CLIENT] Join private room failed.")
	
	join_private_room_processed.emit(success)


### Multiplayer event handlers ###

func handle_peer_connected(id):
	if id != multiplayer.get_unique_id() and id != 1:
		print("Another peer connected.")

func handle_peer_disconnected(id):
	#TODO: handle player exit smooth on all other peers
	if id != multiplayer.get_unique_id() and id != 1:
		print("Another peer disconnected.")
		#players.erase(id)
		player_disconnected.emit(id) # TODO self disconnected???

func handle_connect_success():
	print("Connected to server!")
	if _connect_success_callback:
		_connect_success_callback.call()
		_connect_success_callback = null

func handle_connect_failure():
	print("Failed to connect to server")
	if _connect_failure_callback:
		_connect_failure_callback.call()
		_connect_failure_callback = null

func handle_server_disconnected():
	multiplayer.multiplayer_peer = null
	print("Server disconnected. Trying to reconnect...")
	
	_connect_success_callback = func(): print("Successfully reconnected!")
	_connect_failure_callback = func(): print("Failed to reconnect!")
	GlobalNetworking.connect_to_server() #TODO: maybe different callbacks?
