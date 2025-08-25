extends Node

var server_ip = "127.0.0.1"
var port = 12345
var player_id = -1
var current_turn = -1
var game_state = {}

@export var TileScene: PackedScene
var map_radius: int = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_map(map_radius)
	
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


func connect_to_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	print("Connecting to server...")

func _on_connected():
	print("Connected to server!")
	player_id = multiplayer.get_unique_id()
	rpc_id(1, "register_player", player_id)  # Server peer ID is 1

func _on_connection_failed():
	print("Failed to connect to server")

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
