extends Node2D

const ENEMY_SCENE = preload("res://Scenes/Game/enemy.tscn")

var base_spawn_interval = 2.0
var spawn_interval = 2.0
var spawn_radius = 500.0

var spawn_timer = 0.0
var player = null
var hud = null
var moon = null
var current_phase = 0
var pause_menu = null

func _ready():
	player = $Player
	hud = $HUD
	moon = $MoonPhaseManager
	pause_menu = $PauseMenu
	player.upgrade_menu = $UpgradeMenu
	moon.phase_changed.connect(_on_phase_changed)
	hud.update_moon(moon.get_phase_name())
	$WorldBorder.player = player

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0
	hud.update(player.hp, player.xp, player.xp_to_next_level, player.level)

func spawn_enemy():
	var enemy = ENEMY_SCENE.instantiate()
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
	spawn_pos.x = clamp(spawn_pos.x, -1450, 1450)
	spawn_pos.y = clamp(spawn_pos.y, -950, 950)
	enemy.position = spawn_pos
	enemy.player = player
	enemy.apply_phase(current_phase)
	add_child(enemy)

func _on_phase_changed(phase):
	current_phase = phase
	apply_phase_effects(phase)
	hud.update_moon(moon.get_phase_name())
	update_existing_enemies(phase)
	$HUD.get_node("Moon").set_phase(phase)

func apply_phase_effects(phase):
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
