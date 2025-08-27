extends Node

var max_players = 2
var port = 12345
var players = []
var current_turn = 0
var game_state = {}

func _ready():
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_players)
	if err != OK:
		push_error("Failed to start server: %d" % err)
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % port)

func _process(delta):
	pass  # Not needed for turn-based updates

@rpc("authority")
func make_move(player_id: int, move_data: Dictionary) -> void:
	if players.size() == 0 or players[current_turn] != player_id:
		print("Not this player's turn!")
		return
	if not is_valid_move(move_data):
		print("Invalid move")
		return
	apply_move(move_data)
	print("Player %d made move: %s" % [player_id, str(move_data)])
	current_turn = (current_turn + 1) % players.size()
	rpc("update_turn", current_turn)
	rpc("update_state", game_state)

func is_valid_move(move_data: Dictionary) -> bool:
	return true  # Replace with actual validation

func apply_move(move_data: Dictionary) -> void:
	game_state = move_data  # Simplified example

@rpc("authority")
func register_player(player_id: int) -> void:
	if player_id in players:
		return
	players.append(player_id)
	rpc_id(player_id, "update_state", game_state)
	rpc("update_turn", current_turn)
	print("Player %d joined" % player_id)
