extends Node

var active_players: Array
var music_player = AudioStreamPlayer.new()

const SOUND_DIR: String = "res://assets/sounds"
# Dictionary to hold loaded sounds
var sounds: Dictionary = {}
const musics: Dictionary = {
	"home": preload("res://assets/music/precious_memories.mp3"),
	"game": preload("res://assets/music/echoes_of_time.mp3")
	}
var current_music: String = "home"
var sounds_enabled: bool = true
var music_enabled: bool = true

func _ready():
	add_child(music_player)
	music_player.stream = musics["home"]
	_fade_in(music_player, 0.5)
	music_player.play()
	
func switch_music_to(new_music):
	if music_enabled and current_music != new_music:
		if musics.has(new_music):
			await _fade_out(music_player, 1).finished
			music_player.stream = musics[new_music]
			music_player.play()
			current_music = new_music
			_fade_in(music_player, 1)
		
		
func toggle_music(toggle_on: bool):
	music_player.stream_paused = not toggle_on
	music_enabled = toggle_on

func _fade_in(player: AudioStreamPlayer, duration: float = 1.0, target_volume_db: float = 0.0) -> Tween:
	# Set initial volume to silent
	player.volume_db = -80.0
	var tween = create_tween()

	# Use a Tween to fade in the volume
	tween.tween_property(
		player,  # Object to tween
		"volume_db",   # Property to tween
		target_volume_db,  # End value
		duration)
	
	return tween

func _fade_out(player: AudioStreamPlayer, duration: float = 1.0) -> Tween:
	var tween = create_tween()
	tween.tween_property(
		player,  # Object to tween
		"volume_db",   # Property to tween
		-80.0,         # End value (silent)
		duration # Duration
	)

	return tween

# Function to play a sound
func play_sound(sound_name: String, fade: float = 0.0, volume: float = 0.0):
	if not sounds_enabled:
		return
		
	if sound_name not in sounds:
		# lazy load the sound
		var sound_path = SOUND_DIR + "/" + sound_name + ".wav"
		var sound = load(sound_path)
		if sound == null:
			print('failed to load sound ' + sound_name)
			return

		sounds[sound_name] = sound


	var player = AudioStreamPlayer.new()

	# Configure the audio stream
	player.stream = sounds[sound_name]

	# Add the player to the scene and start playback
	add_child(player)	
	_fade_in(player, fade, volume)
	player.play()

	# Store the player to prevent garbage collection
	active_players.append(player)

# Function to stop a sound
func stop_sound(sound_name: String, fade: float = 0.0):
	for player in active_players:
		if player.stream == sounds.get(sound_name):
			# Use a Tween to fade out the volume
			if fade >= 0:
				await _fade_out(player, fade).finished
			player.stop()
			active_players.erase(player)
			player.queue_free()

# Function to pause a sound
func pause_sound(sound_name: String):
	for player in active_players:
		if player.stream == sounds.get(sound_name):
			player.stream_paused = true

# Function to resume a sound
func resume_sound(sound_name: String):
	for player in active_players:
		if player.stream == sounds.get(sound_name):
			player.stream_paused = false
			
func is_playing(sound_name: String):
	for player in active_players:
		if player.stream == sounds.get(sound_name):
			return true
	return false
