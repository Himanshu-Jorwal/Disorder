extends Node

const SFX = {
	"footstep": "res://Assets/Audio/SFX/footstep.ogg",
	"player_hurt": "res://Assets/Audio/SFX/player_hurt.ogg",
	"player_death": "res://Assets/Audio/SFX/player_death.ogg",
	"level_up": "res://Assets/Audio/SFX/level_up.ogg",
	"moon_phase": "res://Assets/Audio/SFX/moon_phase.ogg",
	"graven_spawn": "res://Assets/Audio/SFX/graven_spawn.ogg",
	"malakar_spawn": "res://Assets/Audio/SFX/malakar_spawn.ogg",
	"lilith_spawn": "res://Assets/Audio/SFX/lilith_spawn.ogg",
	"zaire_crossbow": "res://Assets/Audio/SFX/zaire_crossbow.ogg",
	"zaire_lance": "res://Assets/Audio/SFX/zaire_lance.ogg",
	"zaire_absolute": "res://Assets/Audio/SFX/zaire_absolute.ogg",
	"daggers_shard": "res://Assets/Audio/SFX/daggers_shard.ogg",
	"daggers_mirror": "res://Assets/Audio/SFX/daggers_mirror.ogg",
	"daggers_absolute": "res://Assets/Audio/SFX/daggers_absolute.ogg",
	"milano_chime": "res://Assets/Audio/SFX/milano_chime.ogg",
	"milano_rift": "res://Assets/Audio/SFX/milano_rift.ogg",
	"milano_absolute_charge": "res://Assets/Audio/SFX/milano_absolute_charge.ogg",
	"milano_absolute_fire": "res://Assets/Audio/SFX/milano_absolute_fire.ogg",
}

const MUSIC = {
	"lilith_theme": "res://Assets/Audio/Music/lilith_theme.ogg",
}

const POOL_SIZE = 10

var sfx_pool = []
var pool_index = 0
var music_player = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		sfx_pool.append(p)

	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)

# Plays a one-shot sound by name. Cycles through a pool so overlapping
# sounds (e.g. several hits at once) don't cut each other off.
# Does nothing if the sound isn't registered or the file doesn't exist yet.
func play_sfx(sound_name, volume_db = 0.0):
	if not SFX.has(sound_name):
		return
	var path = SFX[sound_name]
	if not ResourceLoader.exists(path):
		return
	var stream = load(path)
	var player = sfx_pool[pool_index]
	pool_index = (pool_index + 1) % POOL_SIZE
	player.stream = stream
	player.volume_db = volume_db
	player.play()

# Starts a looping track with a fade-in. Used for the Lilith fight.
func play_music(music_name, fade_time = 1.5):
	if not MUSIC.has(music_name):
		return
	var path = MUSIC[music_name]
	if not ResourceLoader.exists(path):
		return
	music_player.stream = load(path)
	music_player.volume_db = -80.0
	music_player.play()
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, fade_time)

# Fades out and stops whatever music is currently playing.
func stop_music(fade_time = 1.5):
	if not music_player.playing:
		return
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_time)
	tween.tween_callback(music_player.stop)
