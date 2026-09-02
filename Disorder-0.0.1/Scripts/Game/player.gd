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
var camera = null

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
const ABSOLUTE_MAX_COOLDOWN = 10.0

var milano_charging = false
var milano_charge_timer = 0.0
const MILANO_CHARGE_TIME = 1.5
var milano_beam_active = false
var milano_beam_timer = 0.0
const MILANO_BEAM_DURATION = 3.0
var milano_beam_angle = 0.0

func _draw():
	if is_visible:
		draw_circle(Vector2.ZERO, 28, Color(character_color.r, character_color.g, character_color.b, 0.03))
		draw_circle(Vector2.ZERO, 24, Color(character_color.r, character_color.g, character_color.b, 0.06))
		draw_circle(Vector2.ZERO, 20, Color(character_color.r, character_color.g, character_color.b, 0.1))
		draw_circle(Vector2.ZERO, 16, character_color)
		draw_circle(Vector2.ZERO, 8, Color(1, 1, 1, 0.8))

	# Milano beam
	if milano_beam_active:
		var beam_dir = Vector2(cos(milano_beam_angle), sin(milano_beam_angle))
		var beam_length = 1800.0
		var t = milano_beam_timer / MILANO_BEAM_DURATION
		var segments = 30
		var beam_width = 14.0
		var perp = beam_dir.rotated(PI / 2)

		for i in range(segments - 1):
			var t0 = float(i) / segments
			var t1 = float(i + 1) / segments
			var p0 = beam_dir * (30.0 + beam_length * t0)
			var p1 = beam_dir * (30.0 + beam_length * t1)

			# Animated wave texture along beam
			var wave0 = sin(t0 * TAU * 8.0 + milano_beam_timer * 12.0) * 3.0
			var wave1 = sin(t1 * TAU * 8.0 + milano_beam_timer * 12.0) * 3.0
			var wp0 = p0 + perp * wave0
			var wp1 = p1 + perp * wave1

			# Fade at tip
			var tip_fade = 1.0 - pow(t0, 2.0)

			# Outer void dark halo
			draw_line(p0, p1, Color(0.0, 0.05, 0.1, tip_fade * 0.4), beam_width + 22)
			# Deep blue outer glow
			draw_line(p0, p1, Color(0.0, 0.2, 0.5, tip_fade * 0.35), beam_width + 14)
			# Cyan mid glow
			draw_line(p0, p1, Color(0.0, 0.5, 0.8, tip_fade * 0.4), beam_width + 7)
			# Core beam — electric blue white
			draw_line(wp0, wp1, Color(0.1, 0.7, 1.0, tip_fade * 0.9), beam_width)
			# Inner bright core
			draw_line(wp0, wp1, Color(0.6, 0.95, 1.0, tip_fade * 0.8), beam_width * 0.5)
			draw_line(wp0, wp1, Color(1, 1, 1, tip_fade * 0.6), beam_width * 0.2)

			# Energy tendrils branching off beam
			if i % 3 == 0:
				var ring_radius_perp = randf_range(10.0, 20.0)
				var ring_radius_depth = ring_radius_perp * 0.25
				var ring_center = p0
				var steps = 16
				var oval_points_outer = PackedVector2Array()
				var oval_points_inner = PackedVector2Array()
				for s in range(steps + 1):
					var a = TAU * s / steps
					var oval_pos = ring_center + perp * cos(a) * ring_radius_perp + beam_dir * sin(a) * ring_radius_depth
					oval_points_outer.append(oval_pos)
					var oval_pos_inner = ring_center + perp * cos(a) * (ring_radius_perp - 3) + beam_dir * sin(a) * (ring_radius_depth - 1)
					oval_points_inner.append(oval_pos_inner)
				# Outer glow
				draw_polyline(oval_points_outer, Color(0.0, 0.4, 0.8, tip_fade * 0.25), 5.0)
				# Main ring
				draw_polyline(oval_points_outer, Color(0.3, 0.8, 1.0, tip_fade * 0.75), 2.0)
				# Inner bright
				draw_polyline(oval_points_inner, Color(0.8, 1.0, 1.0, tip_fade * 0.4), 1.0)

		# Origin blast point
		draw_circle(beam_dir * 30.0, 18, Color(0.0, 0.4, 0.8, 0.9))
		draw_circle(beam_dir * 30.0, 10, Color(0.5, 0.9, 1.0, 0.95))
		draw_circle(beam_dir * 30.0, 5, Color(1, 1, 1, 1.0))

	# Charge visual — concave mirror energy particles
	if milano_charging or milano_beam_active:
		var progress = milano_charge_timer / MILANO_CHARGE_TIME if milano_charging else 1.0
		var mouse_pos = get_global_mouse_position()
		var charge_dir = Vector2(cos(milano_beam_angle), sin(milano_beam_angle)) if milano_beam_active else (mouse_pos - global_position).normalized()
		var perp = charge_dir.rotated(PI / 2)

		# Charge arc progress
		draw_arc(Vector2.ZERO, 24, -PI / 2, -PI / 2 + TAU * progress, 32, Color(1.0, 0.7, 0.2, 0.9), 3.0)

		# Concave mirror — curved arc of particles in front of player
		var mirror_points = []
		var mirror_count = 20
		for i in range(mirror_count):
			var t_arc = float(i) / (mirror_count - 1)
			var arc_angle = lerp(-PI / 2.2, PI / 2.2, t_arc)
			# Concave — particles curve inward toward focal point
			var base_dist = 55.0 * progress
			var curve = cos(arc_angle) * base_dist
			var side = sin(arc_angle) * 45.0 * progress
			var particle_pos = charge_dir * curve + perp * side
			mirror_points.append(particle_pos)
			var particle_size = lerp(1.5, 4.0, progress) * (1.0 - abs(arc_angle) / (PI / 2.2) * 0.4)
			draw_circle(particle_pos, particle_size + 2, Color(0.0, 0.3, 0.6, progress * 0.3))
			draw_circle(particle_pos, particle_size, Color(0.1, 0.6, 0.9, 0.7 + progress * 0.2))
			draw_circle(particle_pos, particle_size * 0.35, Color(0.8, 1.0, 1.0, 0.85))

		# Connect particles with lines to show mirror curve
		for i in range(mirror_points.size() - 1):
			draw_line(mirror_points[i], mirror_points[i+1], Color(0.1, 0.5, 0.9, progress * 0.6), 1.5)

		# Focal point glow — where beam will emerge
		var focal = charge_dir * 30.0 * progress
		draw_circle(focal, lerp(3.0, 10.0, progress), Color(0.2, 0.7, 1.0, progress * 0.9))
		draw_circle(focal, lerp(1.5, 5.0, progress), Color(1, 1, 1, progress))

		# Energy gathering lines
		if progress > 0.5:
			for i in range(8):
				var rand_angle = TAU * i / 8
				var far_pos = Vector2(cos(rand_angle), sin(rand_angle)) * lerp(40.0, 20.0, progress)
				draw_line(far_pos, focal, Color(1.0, 0.6, 0.1, (progress - 0.5) * 0.5), 1.2)

func _ready():
	add_to_group("player")
	var data = GameState.get_character()
	character_name = data.name
	character_color = data.color
	attack1_name = data.attack1
	attack2_name = data.attack2
	absolute_name = data.absolute
	camera = $Camera2D

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

	# Milano charge and beam
	if milano_charging:
		milano_charge_timer += delta
		queue_redraw()
		if milano_charge_timer >= MILANO_CHARGE_TIME:
			milano_charging = false
			milano_beam_active = true
			milano_beam_timer = 0.0
			var mouse_pos = get_global_mouse_position()
			milano_beam_angle = (mouse_pos - global_position).angle()

	if milano_beam_active:
		milano_beam_timer += delta
		queue_redraw()
	
		# Follow mouse smoothly with small arc
		var mouse_pos = get_global_mouse_position()
		var target_angle = (mouse_pos - global_position).angle()
		milano_beam_angle = lerp_angle(milano_beam_angle, target_angle, delta * 2.0)
	
		var beam_dir = Vector2(cos(milano_beam_angle), sin(milano_beam_angle))
	
		# Damage enemies in beam cone
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var to_enemy = enemy.global_position - (global_position + beam_dir * 30.0)
			var angle_diff = abs(angle_difference(to_enemy.angle(), milano_beam_angle))
			var dist = to_enemy.length()
			if angle_diff < 0.08 and dist < 1800:
				enemy.take_damage(int(5 * damage_multiplier))
				var push = beam_dir * 80.0 * delta
				enemy.global_position += push
	
		if milano_beam_timer >= MILANO_BEAM_DURATION:
			milano_beam_active = false
			queue_redraw()

func trigger_shake(amount, duration):
	if camera:
		var tween = create_tween()
		for i in range(10):
			tween.tween_property(camera, "offset",
				Vector2(randf_range(-amount, amount), randf_range(-amount, amount)),
				duration / 10.0)
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

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
	var spread_angles = [-12.0, 0.0, 12.0]
	for angle in spread_angles:
		var dir = base_dir.rotated(deg_to_rad(angle))
		_spawn_star_bullet(global_position, dir, 20, Color(0.85, 0.95, 1.0))

func _zaire_lance():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	_spawn_piercing_bullet(global_position, dir, 50, Color(0.6, 0.9, 1.0))

func _zaire_absolute():
	for i in range(24):
		var angle = TAU * i / 24
		var dir = Vector2(cos(angle), sin(angle))
		_spawn_tracking_bullet(global_position, dir, 15, Color(1.0, 0.95, 0.7))

# --- DAGGERS ---
func _daggers_shard():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	_spawn_splitting_shard(global_position, dir, 20, Color(0.2, 0.9, 0.8))

func _daggers_mirror():
	var clone = preload("res://Scenes/Game/daggers_shadow.tscn").instantiate()
	clone.position = global_position
	clone.player_ref = self
	get_parent().add_child(clone)

func _daggers_absolute():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	var start_pos = global_position
	var end_pos = global_position + dir * 750.0
	end_pos.x = clamp(end_pos.x, -1450, 1450)
	end_pos.y = clamp(end_pos.y, -950, 950)

	# Invulnerable during dash
	is_invincible = true
	invincibility_timer = 0.3
	flash_timer = 0.05

	# Damage enemies in path
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_pos = enemy.global_position
		var ab = end_pos - start_pos
		var t = clamp((enemy_pos - start_pos).dot(ab) / ab.dot(ab), 0.0, 1.0)
		var closest = start_pos + ab * t
		var dist = enemy_pos.distance_to(closest)
		if dist < 40:
			enemy.take_damage(int(80 * damage_multiplier))
			var sideways = dir.rotated(PI / 2)
			if enemy_pos.dot(sideways) < global_position.dot(sideways):
				sideways = -sideways
			enemy.global_position += sideways * 150.0

	# Trail visual
	var slash = preload("res://Scenes/Game/daggers_press.tscn").instantiate()
	slash.start = start_pos
	slash.end = end_pos
	get_parent().add_child(slash)

	# Smooth dash using tween
	var tween = create_tween()
	tween.tween_property(self, "global_position", end_pos, 0.08)
	trigger_shake(6.0, 0.15)

# --- MILANO ---
func _milano_chime():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	_spawn_heavy_bullet(global_position, dir, 50, Color(1.0, 0.6, 0.1))

func _milano_rift():
	var mouse_pos = get_global_mouse_position()
	_spawn_rift(mouse_pos)

func _milano_absolute():
	if milano_charging or milano_beam_active:
		return
	milano_charging = true
	milano_charge_timer = 0.0

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
	
func _spawn_tracking_bullet(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, false, false, false, "tracking")	

func _spawn_splitting_shard(pos, dir, dmg, col):
	var bullet = preload("res://Scenes/Game/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.setup(pos, dir, int(dmg * damage_multiplier), col, false, false, false, "splitting_shard")

func take_damage(amount):
	if is_invincible:
		return
	hp -= amount
	is_invincible = true
	invincibility_timer = INVINCIBILITY_DURATION
	flash_timer = FLASH_RATE
	trigger_shake(16.0, 0.3)
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
