extends Node2D

const WREN_SCENE = preload("res://Scenes/Game/Mobs/wren.tscn")
const FEIND_SCENE = preload("res://Scenes/Game/Mobs/feind.tscn")
const MORI_SCENE = preload("res://Scenes/Game/Mobs/mori.tscn")
const LARK_SCENE = preload("res://Scenes/Game/Mobs/lark.tscn")
const KAEL_SCENE = preload("res://Scenes/Game/Mobs/kael.tscn")
const GRAVEN_SCENE = preload("res://Scenes/Game/Mobs/graven.tscn")
const MALAKAR_SCENE = preload("res://Scenes/Game/Mobs/malakar.tscn")
const LILITH_SCENE = preload("res://Scenes/Game/Mobs/lilith.tscn")

var base_spawn_interval = 2.0
var spawn_interval = 2.0
var spawn_radius = 500.0

var spawn_timer = 0.0
var scale_timer = 0.0
var difficulty = 1.0

var player = null
var hud = null
var moon = null
var current_phase = 0
var pause_menu = null

var graven_spawned = false
var malakar_spawned = false
var lilith_spawned = false
var boss_active = false

func _ready():
	player = $Player
	hud = $HUD
	moon = $MoonPhaseManager
	pause_menu = $PauseMenu
	player.upgrade_menu = $UpgradeMenu
	moon.phase_changed.connect(_on_phase_changed)
	moon.cycle_completed.connect(_on_cycle_completed)
	hud.update_moon(moon.get_phase_name())
	$WorldBorder.player = player

func _process(delta):
	spawn_timer += delta
	scale_timer += delta

	if scale_timer >= 30.0:
		scale_timer = 0.0
		difficulty += 0.15
		base_spawn_interval = max(0.4, base_spawn_interval - 0.1)

	if spawn_timer >= spawn_interval and not boss_active:
		spawn_enemy()
		spawn_timer = 0.0

	hud.update(
		player.hp, player.max_hp,
		player.xp, player.xp_to_next_level, player.level,
		player.attack1_cooldown, player.ATTACK1_MAX_COOLDOWN,
		player.attack2_cooldown, player.ATTACK2_MAX_COOLDOWN,
		player.absolute_cooldown, player.ABSOLUTE_MAX_COOLDOWN,
		player.attack1_name, player.attack2_name, player.absolute_name
	)

func spawn_enemy():
	var roll = randf()
	var enemy
	if roll < 0.45:
		enemy = WREN_SCENE.instantiate()
	elif roll < 0.63:
		enemy = FEIND_SCENE.instantiate()
	elif roll < 0.77:
		enemy = MORI_SCENE.instantiate()
	elif roll < 0.90:
		enemy = LARK_SCENE.instantiate()
	else:
		enemy = KAEL_SCENE.instantiate()

	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
	spawn_pos.x = clamp(spawn_pos.x, -1450, 1450)
	spawn_pos.y = clamp(spawn_pos.y, -950, 950)
	enemy.position = spawn_pos
	enemy.player = player
	enemy.apply_phase(current_phase)
	enemy.apply_difficulty(difficulty)
	add_child(enemy)

func _on_phase_changed(phase):
	current_phase = phase
	apply_phase_effects(phase)
	hud.update_moon(moon.get_phase_name())
	update_existing_enemies(phase)
	$HUD.get_node("Moon").set_phase(phase)

	if phase == 2 and not graven_spawned:
		graven_spawned = true
		_spawn_graven()
	if phase != 2:
		graven_spawned = false

	if phase == 3 and not malakar_spawned:
		malakar_spawned = true
		_spawn_malakar()
	if phase != 3:
		malakar_spawned = false

func apply_phase_effects(phase):
	if boss_active:
		return
	match phase:
		0: spawn_interval = base_spawn_interval
		1: spawn_interval = base_spawn_interval * 0.8
		2: spawn_interval = base_spawn_interval * 0.5
		3: spawn_interval = base_spawn_interval * 0.4
		4: spawn_interval = base_spawn_interval * 1.5
		5: spawn_interval = base_spawn_interval

func update_existing_enemies(phase):
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.apply_phase(phase)

func _spawn_graven():
	var graven = GRAVEN_SCENE.instantiate()
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * 400.0
	spawn_pos.x = clamp(spawn_pos.x, -1450, 1450)
	spawn_pos.y = clamp(spawn_pos.y, -950, 950)
	graven.position = spawn_pos
	graven.player = player
	graven.apply_phase(current_phase)
	graven.apply_difficulty(difficulty)
	add_child(graven)

func _spawn_malakar():
	var malakar = MALAKAR_SCENE.instantiate()
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * 400.0
	spawn_pos.x = clamp(spawn_pos.x, -1450, 1450)
	spawn_pos.y = clamp(spawn_pos.y, -950, 950)
	malakar.position = spawn_pos
	malakar.player = player
	malakar.apply_phase(current_phase)
	malakar.apply_difficulty(difficulty)
	add_child(malakar)

func _on_cycle_completed(cycle_number):
	print("Cycle completed: ", cycle_number)
	if not boss_active:
		_spawn_lilith()

func _spawn_lilith():
	boss_active = true
	spawn_timer = 0.0
	spawn_interval = 9999.0
	moon.paused = true
	$HUD.get_node("Moon").visible = false
	var lilith = LILITH_SCENE.instantiate()
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * 500.0
	spawn_pos.x = clamp(spawn_pos.x, -1450, 1450)
	spawn_pos.y = clamp(spawn_pos.y, -950, 950)
	lilith.setup(spawn_pos, player, self)
	lilith.apply_difficulty(difficulty)
	add_child(lilith)

func lilith_defeated():
	boss_active = false
	spawn_interval = base_spawn_interval
	moon.paused = false
	$HUD.get_node("Moon").visible = true
