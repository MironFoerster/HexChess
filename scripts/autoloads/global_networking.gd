extends Node


var server_ip = "192.168.2.126"#131.159.216.137"#"192.168.68.102"
var port = 3000
var max_connected_peers = 20

# runs at startup on the instance that is run as server, see main.gd
func start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.set_bind_ip("0.0.0.0")
	var err = peer.create_server(port, max_connected_peers
)
	if err != OK:
		print("Failed to start server: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)
	ServerManager.initialize_server()

# runs once user decides to use online features, creates a client on the users instance
func connect_to_server():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, port)
	if err != OK:
		push_error("Failed to create client: %d" % err)
		return
	print("Connecting to server...")
	multiplayer.multiplayer_peer = peer







### BASE COMMUNICATION METHODS ###

func send_to_server(type: String, data: Dictionary) -> bool: # client request
	print("[CLIENT-SENT] Type: ", type)
	print("[CLIENT-SENT] Data: ", data)
	
	var payload = {"type": type, "data": data}
	
	if _connected_to_server():
		print("[CLIENT] Connected. Calling RPC.")
		# call _handle_on_server rpc on server
		_handle_on_server.rpc_id(1, payload)
		return true
	else:
		print("[CLIENT] Not connected. Aborting RPC.")
		return false

@rpc("any_peer", "call_remote", "reliable")  # server handler
func _handle_on_server(payload: Dictionary):
	print("[SERVER-RECEIVED] Payload: ", payload)
	var sender_id = multiplayer.get_remote_sender_id()
	
	server_handlers[payload.type].call(sender_id, payload.data)

func send_to_clients(receiver_ids: Array[int], type: String, data: Dictionary): # server response/broadcast
	print("[SERVER-SENT] Type: ", type)
	print("[SERVER-SENT] Data: ", data)
	print("[SERVER-SENT] To: ", receiver_ids)
	
	var payload = {"type": type, "data": data}
	
	for receiver_id in receiver_ids:
		_handle_on_client.rpc_id(receiver_id, payload)

@rpc("authority", "call_remote", "reliable")  # client handler
func _handle_on_client(payload: Dictionary):
	print("[CLIENT-RECEIVED] Payload: ", payload)
	
	client_handlers[payload.type].call(payload.data)








### REQUEST-RESPONSE METHODS ###

### NICKNAME ###
func nickname_player(nickname: String):
	send_to_server("nickname_player", {
		"nickname": nickname
	})

func handle_nickname_player(sender_id: int, data: Dictionary):
	ServerManager.handle_nickname_player(sender_id, data.nickname)


### LOGIN ###
func login_player(username: String, password: String):
	send_to_server("login_player", {
		"username": username,
		"password": password,
	})

func handle_login_player(sender_id: int, data: Dictionary):
	ServerManager.handle_login_player(sender_id, data.username, data.password)

### REGISTER ###
func register_player(username: String, password: String):
	send_to_server("register_player", {
		"username": username,
		"password": password,
	})

func handle_register_player(sender_id: int, data: Dictionary):
	ServerManager.handle_register_player(sender_id, data.username, data.password)


### IDENTIFICATION PROCESSED ### (nickname/login/register)
func identify_player_processed(to: Array[int], success: bool, player: Player = null):
	send_to_clients(to, "identify_player_processed", {
		"success": success,
		"player_dict": player.to_dict() if player != null else {}
	})
	
func handle_identify_player_processed(data: Dictionary):
	GameManager.handle_identify_player_processed(data.success, Player.from_dict(data.player_dict))


### CREATE PRIVATE ROOM ###
func create_private_room():
	send_to_server("create_private_room", {})

func handle_create_private_room(sender_id: int, data: Dictionary):
	ServerManager.handle_create_private_room(sender_id)

func create_private_room_processed(to: Array[int], success: bool, battle: Battle = null):
	send_to_clients(to, "create_private_room_processed", {
		"success": success,
		"battle_dict": battle.to_dict() if battle != null else {}
	})
	
func handle_create_private_room_processed(data: Dictionary):
	GameManager.handle_create_private_room_processed(data.success, Battle.from_dict(data.battle_dict))


### JOIN PRIVATE ROOM ###
func join_private_room(code: int):
	send_to_server("join_private_room", {
		"code": code,
	})

func handle_join_private_room(sender_id: int, data: Dictionary):
	ServerManager.handle_join_private_room(sender_id, data.code)

func join_private_room_processed(to: Array[int], success: bool, battle: Battle = null):
	send_to_clients(to, "join_private_room_processed", {
		"success": success,
		"battle_dict": battle.to_dict() if battle != null else {}
	})
	
func handle_join_private_room_processed(data: Dictionary):
	GameManager.handle_join_private_room_processed(data.success, Battle.from_dict(data.battle_dict))

### START BATTLE ###
func start_battle(code: int):
	send_to_server("start_battle", {})

func handle_start_battle(sender_id: int, data: Dictionary):
	ServerManager.handle_start_battle(sender_id)

func start_battle_processed(to: Array[int], success: bool):
	send_to_clients(to, "start_battle_processed", {
		"success": success,
	})

func handle_start_battle_processed(data: Dictionary):
	pass
	
### SUBMIT COMMAND ###
func submit_command(command: Command):
	send_to_server("submit_command", {
		"command_dict": command.to_dict(),
	})

func handle_submit_command(sender_id: int, data: Dictionary):
	ServerManager.handle_submit_command(sender_id, Command.from_dict(data.command_dict))

func submit_command_processed(to: Array[int], success: bool):
	send_to_clients(to, "submit_command_processed", {
		"success": success,
	})
	
func handle_submit_command_processed(data: Dictionary):
	pass

### END TURN ###
func end_turn():
	send_to_server("end_turn", {})

func handle_end_turn(sender_id: int, data: Dictionary):
	ServerManager.handle_end_turn(sender_id)





### SERVER TO CLIENT UPDATE METHODS ###
### Used by the server to directly update a clients battle, calls update methods on the client battle

### ADD PLAYER ###
func battle__add_player(to: Array[int], player_id: int, player: Player = null):
	send_to_clients(to, "battle__add_player", {
		"player_id": player_id,
		"player_dict": player.to_dict() if player != null else {}
	})
	
func handle_battle__add_player(data: Dictionary):
	BattleManager.add_player(data.player_id, Player.from_dict(data.player_dict))

### START BATTLE ###
func battle__start(to: Array[int]):
	send_to_clients(to, "battle__start", {})
	
func handle_battle__start(data: Dictionary):
	BattleManager.start_battle()

### SET MAP ###
func battle__set_map(to: Array[int], map: Map = null):
	send_to_clients(to, "battle__set_map", {
		"map_dict": map.to_dict() if map != null else {}
	})
	
func handle_battle__set_map(data: Dictionary):
	BattleManager.set_map(Map.from_dict(data.map_dict))

### EXECUTE COMMAND ###
func battle__execute_command(to: Array[int], command: Command = null):
	send_to_clients(to, "battle__execute_command", {
		"command_dict": command.to_dict() if command != null else {}
	})
	
func handle_battle__execute_command(data: Dictionary):
	BattleManager.execute_command(Command.from_dict(data.command_dict))






### HANDLER REGISTRIES ###

var server_handlers: Dictionary[StringName, Callable] = {
	"nickname_player": handle_nickname_player,
	"login_player": handle_login_player,
	"register_player": handle_register_player,
	"create_private_room": handle_create_private_room,
	"join_private_room": handle_join_private_room,
	"start_battle": handle_start_battle,
	"submit_command": handle_submit_command,
	"end_turn": handle_end_turn,
}
var client_handlers: Dictionary[StringName, Callable] = {
	"identify_player_processed": handle_identify_player_processed,
	"create_private_room_processed": handle_create_private_room_processed,
	"join_private_room_processed": handle_join_private_room_processed,
	"start_battle_processed": handle_start_battle_processed,
	"submit_command_processed": handle_submit_command_processed,
	"battle__add_player": handle_battle__add_player,
	"battle__start": handle_battle__start,
	"battle__set_map": handle_battle__set_map,
	"battle__execute_command": handle_battle__execute_command,
}


## UTILS
func _connected_to_server() -> bool:
	return multiplayer.multiplayer_peer is ENetMultiplayerPeer and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
