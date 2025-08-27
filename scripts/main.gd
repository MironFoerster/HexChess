extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var server_ip = "172.20.32.1"
var port = 3000
var max_players = 2
var player_id = -1
var current_turn = -1
var game_state = {}

@export var TileScene: PackedScene
var map_radius: int = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# signals for server and clients
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	# signals only for clients
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if OS.has_feature("server"):  # or check CLI args
		_start_server()
	else:
		pass
		#start intro sequence
	
func _start_server():
	var peer = ENetMultiplayerPeer.new()
	peer.set_bind_ip("0.0.0.0")
	var err = peer.create_server(port, max_players)
	if err != OK:
		push_error("Failed to start server: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	#players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_connected(id):
	pass#_register_player.rpc_id(id, player_info)

func _on_player_disconnected(id):
	#players.erase(id)
	player_disconnected.emit(id)

func _on_connected():
	print("Connected to server!")
	player_id = multiplayer.get_unique_id()
	#rpc_id(1, "register_player", player_id)  # Server peer ID is 1

func _on_connection_failed():
	print("Failed to connect to server")
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	#players.clear()
	server_disconnected.emit()

func send_move(move_data: Dictionary) -> void:
	if current_turn != player_id:
		print("Not your turn!")
		return
	rpc_id(1, "make_move", player_id, move_data)

@rpc("call_remote")
func update_state(new_state: Dictionary) -> void:
	game_state = new_state
	print("Game state updated: %s" % str(game_state))

@rpc("call_remote")
func update_turn(turn_player_id: int) -> void:
	current_turn = turn_player_id
	if current_turn == player_id:
		print("Your turn!")
	else:
		print("Player %d's turn" % current_turn)


func ripple (tile: Node3D) -> void:
	for distance in range(map_radius*2 +1):
		for t in $Tiles.get_children():
			if t.coordinates.distance_to(tile.coordinates) == distance:
				t.toggle_highlight()
				#t.get_node("AnimationPlayer").play("bump")
		await get_tree().create_timer(0.06).timeout

func generate_map(radius: int):
	if TileScene:
		for q in range(-radius, radius+1):
			for r in range(-radius, radius+1):
				for s in range(-radius, radius+1):
					if q + r + s == 0:
						var tile_instance = TileScene.instantiate()
						tile_instance.call_deferred("set_name", "Tile")
						$Tiles.add_child(tile_instance)
						tile_instance.initialize(CubeCoordinates.new(q, r, s))
	else:
		print("Tile scene is not assigned!")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_connect_to_server_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_ip, port)
	if err != OK:
		push_error("Failed to start server: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("Connecting to server...")
