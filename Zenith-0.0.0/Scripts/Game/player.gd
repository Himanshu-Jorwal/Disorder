extends CharacterBody2D

const BASE_SPEED = 200.0
const INVINCIBILITY_DURATION = 1.0
const FLASH_RATE = 0.1

var speed_multiplier = 1.0
var fire_rate_multiplier = 1.0
var damage_multiplier = 1.0

var hp = 100
var max_hp = 100
var xp = 0
var level = 1
var xp_to_next_level = 50
var score = 0
var time_alive = 0.0

var upgrade_menu = null
var is_invincible = false
var invincibility_timer = 0.0
var flash_timer = 0.0
var is_visible = true

var character_name = "Zaire"
var character_color = Color(0.6, 0.3, 1.0)
var attack1_name = "Crossbow"
var attack2_name = "Lance"
var absolute_name = "Absolute1"

var attack1_cooldown = 0.0
var attack2_cooldown = 0.0
var absolute_cooldown = 0.0
const ATTACK1_MAX_COOLDOWN = 0.25
const ATTACK2_MAX_COOLDOWN = 1.0
const ABSOLUTE_MAX_COOLDOWN = 30.0

func _draw():
	if is_visible:
		draw_circle(Vector2.ZERO, 28, Color(character_color.r, character_color.g, character_color.b, 0.03))
		draw_circle(Vector2.ZERO, 24, Color(character_color.r, character_color.g, character_color.b, 0.06))
		draw_circle(Vector2.ZERO, 20, Color(character_color.r, character_color.g, character_color.b, 0.1))
		draw_circle(Vector2.ZERO, 16, character_color)
		draw_circle(Vector2.ZERO, 8, Color(1, 1, 1, 0.8))

func _ready():
	add_to_group("player")
	var data = GameState.get_character()
	character_name = data.name
	character_color = data.color
	attack1_name = data.attack1
	attack2_name = data.attack2
	absolute_name = data.absolute

func _physics_process(delta):
	time_alive += delta
	score = int(time_alive * 10) + (level * 100)

	attack1_cooldown = max(0.0, attack1_cooldown - delta)
	attack2_cooldown = max(0.0, attack2_cooldown - delta)
	absolute_cooldown = max(0.0, absolute_cooldown - delta)

	if is_invincible:
		invincibility_timer -= delta
		flash_timer -= delta
		if flash_timer <= 0.0:
			is_visible = !is_visible
			flash_timer = FLASH_RATE
			queue_redraw()
		if invincibility_timer <= 0.0:
			is_invincible = false
			is_visible = true
			queue_redraw()

	var direction = Vector2.ZERO
	if Input.is_key_pressed(KEY_D): direction.x += 1
	if Input.is_key_pressed(KEY_A): direction.x -= 1
	if Input.is_key_pressed(KEY_S): direction.y += 1
	if Input.is_key_pressed(KEY_W): direction.y -= 1
	direction = direction.normalized()
	velocity = direction * BASE_SPEED * speed_multiplier
	move_and_slide()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and attack1_cooldown <= 0.0:
		use_attack1()
		attack1_cooldown = ATTACK1_MAX_COOLDOWN

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and attack2_cooldown <= 0.0:
		use_attack2()
		attack2_cooldown = ATTACK2_MAX_COOLDOWN

	if Input.is_key_pressed(KEY_X) and absolute_cooldown <= 0.0:
		use_absolute()
		absolute_cooldown = ABSOLUTE_MAX_COOLDOWN

func use_attack1():
	match character_name:
		"Zaire": _zaire_crossbow()
		"Daggers": _daggers_shard()
		"Milano": _milano_chime()

func use_attack2():
	match character_name:
		"Zaire": _zaire_lance()
		"Daggers": _daggers_mirror()
		"Milano": _milano_rift()

func use_absolute():
	match character_name:
		"Zaire": _zaire_absolute()
		"Daggers": _daggers_absolute()
		"Milano": _milano_absolute()

# --- ZAIRE ---
func _zaire_crossbow():
	var mouse_pos = get_global_mouse_position()
	var base_dir = (mouse_pos - global_position).normalized()
	# 3 bolts, tighter spread, star shaped visually
	var spread_angles = [-12.0, 0.0, 12.0]
	for angle in spread_angles:
		var dir = base_dir.rotated(deg_to_rad(angle))
		_spawn_star_bullet(global_position, dir, 12, Color(0.8, 0.4, 1.0))

func _zaire_lance():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	_spawn_piercing_bullet(global_position, dir, 35, Color(0.9, 0.6, 1.0))

func _zaire_absolute():
	# Nova burst — 24 star bolts in all directions
	for i in range(24):
		var angle = TAU * i / 24
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_star_bullet(global_position, dir, 20, Color(1.0, 0.8, 1.0))

# --- DAGGERS ---
func _daggers_shard():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	# Fire 2 shards slightly offset for visual interest
	var perp = dir.rotated(PI / 2)
	_spawn_shard_bullet(global_position + perp * 5, dir, 15, Color(0.2, 0.9, 0.8))
	_spawn_shard_bullet(global_position - perp * 5, dir, 15, Color(0.2, 0.9, 0.8))

func _daggers_mirror():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	# 8 directions for more impactful feel
	for i in range(8):
		var angle = TAU * i / 8
		var d = Vector2(cos(angle), sin(angle))
		_spawn_shard_bullet(global_position, d, 18, Color(0.3, 1.0, 0.9))

func _daggers_absolute():
	# 16 returning shards
	for i in range(16):
		var angle = TAU * i / 16
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_returning_shard(global_position, dir, 20, Color(0.4, 1.0, 0.9))

# --- MILANO ---
func _milano_chime():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	# Single slow heavy orb — hits very hard
	_spawn_heavy_bullet(global_position, dir, 50, Color(1.0, 0.6, 0.1))

func _milano_rift():
	var mouse_pos = get_global_mouse_position()
	_spawn_rift(mouse_pos)

func _milano_absolute():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	_spawn_beam(global_position, dir)

# --- SPAWNERS ---
func _spawn_bullet(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, false, false, false, "normal")

func _spawn_star_bullet(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, false, false, false, "star")

func _spawn_shard_bullet(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, false, false, false, "shard")

func _spawn_returning_shard(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, false, true, self, "shard")

func _spawn_piercing_bullet(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, true, false, false, "lance")

func _spawn_heavy_bullet(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, false, false, false, "heavy")
	bullet.speed = 200.0

func _spawn_rift(pos):
	var rift = preload("res://Scenes/Game/rift.tscn").instantiate()
	get_parent().add_child(rift)
	rift.setup(pos)

func _spawn_beam(pos, dir):
	var beam = preload("res://Scenes/Game/beam.tscn").instantiate()
	get_parent().add_child(beam)
	beam.setup(pos, dir)

func take_damage(amount):
	if is_invincible:
		return
	hp -= amount
	is_invincible = true
	invincibility_timer = INVINCIBILITY_DURATION
	flash_timer = FLASH_RATE
	if hp <= 0:
		die()

func die():
	get_tree().paused = true
	var game_over = get_parent().get_node("GameOver")
	game_over.show_game_over(score)

func gain_xp(amount):
	xp += amount
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	xp = 0
	xp_to_next_level = int(xp_to_next_level * 1.4)
	if upgrade_menu:
		upgrade_menu.show_upgrades(self)
