extends CharacterBody2D

const XP_VALUE = 500
const CONTACT_DAMAGE = 40

var player = null
var hp = 3000
var max_hp = 3000
var damage_cooldown = 0.0
var current_phase = 0
var difficulty = 1.0
var time = 0.0
var world_ref = null

enum BossPhase { INTRO, PHASE1, PHASE2, PHASE3, DEAD }
var boss_phase = BossPhase.INTRO

# Intro
var intro_timer = 0.0
const INTRO_DURATION = 4.0
var intro_scale = 0.0

# Phase 1
var spiral_timer = 0.0
const SPIRAL_INTERVAL = 12.0
var summon_timer = 0.0
const SUMMON_INTERVAL = 20.0
var wren_timer = 0.0
const WREN_INTERVAL = 6.0
var orbit_angle = 0.0

# Phase 2
var dash_timer = 0.0
const DASH_INTERVAL = 2.5
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_speed = 550.0
var dash_distance = 0.0
var dash_count = 0
const MAX_DASHES = 3
var twin_ring_timer = 0.0
const TWIN_RING_INTERVAL = 8.0

# Phase 3
var death_spiral_timer = 0.0
const DEATH_SPIRAL_INTERVAL = 6.0
var chaos_timer = 0.0
const CHAOS_INTERVAL = 8.0
var rotating_angle = 0.0

func _ready():
	add_to_group("enemies")
	add_to_group("bosses")
	_update_collision()

func _update_collision():
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = 90.0

func _draw():
	var pulse = (sin(time * 1.5) + 1.0) / 2.0
	var fast_pulse = (sin(time * 5.0) + 1.0) / 2.0

	match boss_phase:
		BossPhase.INTRO:
			_draw_lilith_body(intro_scale, Color(0.5, 0.0, 0.8), pulse, fast_pulse)
		BossPhase.PHASE1:
			_draw_phase1_effects(pulse, fast_pulse)
			_draw_lilith_body(1.0, Color(0.5, 0.0, 0.8), pulse, fast_pulse)
		BossPhase.PHASE2:
			_draw_phase2_effects(pulse, fast_pulse)
			_draw_lilith_body(1.0, Color(0.8, 0.0, 0.5), pulse, fast_pulse)
		BossPhase.PHASE3:
			_draw_phase3_effects(pulse, fast_pulse)
			_draw_lilith_body(1.0, Color(0.9, 0.0, 0.2), pulse, fast_pulse)

	if boss_phase != BossPhase.INTRO:
		_draw_hp_bar()

func _draw_lilith_body(scale, col, pulse, fast_pulse):
	var s = scale

	# Outermost dark void
	draw_circle(Vector2.ZERO, 140 * s, Color(0.1, 0.0, 0.15, 0.08 + pulse * 0.04))
	draw_circle(Vector2.ZERO, 120 * s, Color(col.r * 0.3, col.g, col.b * 0.4, 0.1 + pulse * 0.05))

	# Outer rotating ring
	draw_arc(Vector2.ZERO, 100 * s, time * 0.5, time * 0.5 + TAU * 0.75, 64, Color(col.r, col.g, col.b, 0.3 + pulse * 0.2), 3.0)
	draw_arc(Vector2.ZERO, 100 * s, time * 0.5 + PI, time * 0.5 + PI + TAU * 0.75, 64, Color(col.r, col.g, col.b, 0.3 + pulse * 0.2), 3.0)

	# Outer shell — 12 sided
	var outer_points = PackedVector2Array()
	for i in range(12):
		var angle = TAU * i / 12 + time * 0.1
		var r = (90.0 + sin(time * 2.0 + i * 0.8) * 5.0) * s
		outer_points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(outer_points, Color(col.r * 0.2, col.g * 0.05, col.b * 0.3, 1.0))

	# Mid shell — 8 sided counter rotating
	var mid_points = PackedVector2Array()
	for i in range(8):
		var angle = TAU * i / 8 - time * 0.15
		mid_points.append(Vector2(cos(angle), sin(angle)) * 70.0 * s)
	draw_colored_polygon(mid_points, Color(col.r * 0.4, col.g * 0.05, col.b * 0.5, 1.0))

	# Inner shell — 6 sided
	var inner_points = PackedVector2Array()
	for i in range(6):
		var angle = TAU * i / 6 + time * 0.2
		var r = (55.0 + sin(time * 3.0 + i) * 3.0) * s
		inner_points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(inner_points, Color(col.r * 0.6, col.g * 0.05, col.b * 0.7, 1.0))

	# Detail lines on outer shell
	for i in range(12):
		var angle = TAU * i / 12 + time * 0.1
		var inner_v = Vector2(cos(angle), sin(angle)) * 55.0 * s
		var outer_v = Vector2(cos(angle), sin(angle)) * 90.0 * s
		draw_line(inner_v, outer_v, Color(col.r * 0.5, col.g, col.b * 0.6, 0.4), 1.5)

	# Orbiting energy orbs
	for i in range(4):
		var angle = TAU * i / 4 + time * 1.2
		var orbit_pos = Vector2(cos(angle), sin(angle)) * 95.0 * s
		draw_circle(orbit_pos, (8 + pulse * 4) * s, Color(col.r + 0.3, col.g + 0.2, col.b + 0.1, 0.9))
		draw_circle(orbit_pos, (4 + pulse * 2) * s, Color(1, 1, 1, 0.9))
		# Trail
		for j in range(3):
			var trail_angle = angle - j * 0.2
			var trail_pos = Vector2(cos(trail_angle), sin(trail_angle)) * 95.0 * s
			draw_circle(trail_pos, (5 - j) * s, Color(col.r + 0.2, col.g, col.b + 0.1, 0.4 - j * 0.1))

	# Core glow
	draw_circle(Vector2.ZERO, 28 * s, Color(col.r + 0.2, col.g + 0.1, col.b + 0.1, 0.9))
	draw_circle(Vector2.ZERO, 16 * s, Color(1, 0.8, 1, 0.95))
	draw_circle(Vector2.ZERO, 7 * s, Color(1, 1, 1, 1.0))

	# Name
	if s > 0.7:
		var font = ThemeDB.fallback_font
		var name_text = "LILITH"
		var name_size = font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		draw_string(font, Vector2(-name_size.x / 2 + 1, -115), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0, 0, 0, 0.9))
		draw_string(font, Vector2(-name_size.x / 2, -116), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(col.r + 0.3, col.g + 0.2, col.b + 0.1, 1.0))

func _draw_phase1_effects(pulse, fast_pulse):
	# Summoning circles orbiting
	for i in range(3):
		var angle = TAU * i / 3 + time * 0.6
		var orbit = Vector2(cos(angle), sin(angle)) * 120.0
		draw_circle(orbit, 10 + pulse * 4, Color(0.7, 0.2, 1.0, 0.7))
		draw_arc(orbit, 18, 0, TAU, 16, Color(0.7, 0.2, 1.0, 0.4), 2.0)
		draw_arc(orbit, 25, time * 2.0, time * 2.0 + TAU * 0.6, 16, Color(0.8, 0.4, 1.0, 0.3), 1.5)

func _draw_phase2_effects(pulse, fast_pulse):
	# Aggressive red aura
	draw_circle(Vector2.ZERO, 115 + fast_pulse * 10, Color(0.8, 0.0, 0.3, 0.08 + fast_pulse * 0.05))
	if is_dashing:
		for i in range(4):
			var offset = -dash_direction * i * 20.0
			draw_circle(offset, 90 - i * 15, Color(0.8, 0.0, 0.5, 0.25 - i * 0.05))

func _draw_phase3_effects(pulse, fast_pulse):
	# Chaotic flickering aura
	var chaos_col = Color(
		0.6 + sin(time * 9.0) * 0.3,
		0.0,
		0.4 + cos(time * 7.0) * 0.3
	)
	draw_circle(Vector2.ZERO, 120 + fast_pulse * 15, Color(chaos_col.r, chaos_col.g, chaos_col.b, 0.1))
	# Rotating chaos lines
	for i in range(6):
		var angle = rotating_angle + TAU * i / 6
		var end = Vector2(cos(angle), sin(angle)) * 110.0
		draw_line(Vector2.ZERO, end, Color(chaos_col.r, chaos_col.g, chaos_col.b, 0.2 + fast_pulse * 0.1), 2.0)

func _draw_hp_bar():
	var bar_width = 200.0
	var bar_height = 12.0
	var col = Color(0.6, 0.0, 0.9)
	match boss_phase:
		BossPhase.PHASE2: col = Color(0.8, 0.0, 0.5)
		BossPhase.PHASE3: col = Color(0.9, 0.0, 0.2)
	draw_rect(Rect2(-bar_width / 2, -125, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, -125, bar_width * (float(hp) / float(max_hp)), bar_height), col)
	draw_rect(Rect2(-bar_width / 2, -125, bar_width, bar_height), Color(col.r * 0.5, col.g * 0.2, col.b * 0.5, 0.5), false, 1.5)
	# Phase markers
	draw_line(Vector2(-bar_width / 2 + bar_width * 0.33, -125), Vector2(-bar_width / 2 + bar_width * 0.33, -125 + bar_height), Color(1, 1, 1, 0.6), 2.0)
	draw_line(Vector2(-bar_width / 2 + bar_width * 0.66, -125), Vector2(-bar_width / 2 + bar_width * 0.66, -125 + bar_height), Color(1, 1, 1, 0.6), 2.0)

func _physics_process(delta):
	if player == null:
		return
	time += delta
	rotating_angle += delta * 1.5
	queue_redraw()

	match boss_phase:
		BossPhase.INTRO: _handle_intro(delta)
		BossPhase.PHASE1: _handle_phase1(delta)
		BossPhase.PHASE2: _handle_phase2(delta)
		BossPhase.PHASE3: _handle_phase3(delta)

	if boss_phase == BossPhase.PHASE1 and float(hp) / float(max_hp) <= 0.66:
		_transition_to_phase2()
	elif boss_phase == BossPhase.PHASE2 and float(hp) / float(max_hp) <= 0.33:
		_transition_to_phase3()

	_check_bullet_hits()
	
func _check_bullet_hits():
	for bullet in get_tree().get_nodes_in_group("bullets"):
		if not is_instance_valid(bullet):
			continue
		var dist = global_position.distance_to(bullet.global_position)
		if dist < 90:
			take_damage(bullet.damage)
			bullet.queue_free()

func _handle_intro(delta):
	intro_timer += delta
	intro_scale = clamp(intro_timer / INTRO_DURATION, 0.0, 1.0)
	velocity = Vector2.ZERO
	move_and_slide()
	if intro_timer >= INTRO_DURATION:
		boss_phase = BossPhase.PHASE1
		player.trigger_shake(20.0, 0.8)

func _handle_phase1(delta):
	# Orbit player at distance
	var dist = global_position.distance_to(player.global_position)
	var to_player = (player.global_position - global_position).normalized()
	orbit_angle += delta * 0.8
	var orbit_dir = to_player.rotated(PI / 2)
	if dist < 350:
		velocity = (-to_player + orbit_dir).normalized() * 80.0
	elif dist > 500:
		velocity = (to_player + orbit_dir).normalized() * 80.0
	else:
		velocity = orbit_dir * 80.0
	move_and_slide()

	# Lunar spiral
	spiral_timer += delta
	if spiral_timer >= SPIRAL_INTERVAL:
		spiral_timer = 0.0
		_release_lunar_spiral(24, 0.3)

	# Summon mini boss
	summon_timer += delta
	if summon_timer >= SUMMON_INTERVAL:
		summon_timer = 0.0
		if randf() > 0.5:
			_spawn_mob("res://Scenes/Game/Mobs/graven.tscn")
		else:
			_spawn_mob("res://Scenes/Game/Mobs/malakar.tscn")

	# Occasional Wren
	wren_timer += delta
	if wren_timer >= WREN_INTERVAL:
		wren_timer = 0.0
		_spawn_mob("res://Scenes/Game/Mobs/wren.tscn")

	_check_contact_damage(delta)

func _handle_phase2(delta):
	if is_dashing:
		velocity = dash_direction * dash_speed
		move_and_slide()
		dash_distance += dash_speed * delta
		var dist = global_position.distance_to(player.global_position)
		if dist < 70 or dash_distance > 500:
			is_dashing = false
			dash_distance = 0.0
			# Ring after each dash
			_release_twin_rings()
			dash_count += 1
			if dist >= 70:
				_spawn_mob("res://Scenes/Game/Mobs/feind.tscn")
			if dash_count >= MAX_DASHES:
				dash_count = 0
				dash_timer = 0.0
			if dist < 70:
				player.take_damage(CONTACT_DAMAGE)
				player.trigger_shake(18.0, 0.5)
	else:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * 140.0
		move_and_slide()
		dash_timer += delta
		if dash_timer >= DASH_INTERVAL:
			dash_timer = 0.0
			dash_direction = (player.global_position - global_position).normalized()
			is_dashing = true
			dash_distance = 0.0

	_check_contact_damage(delta)

func _handle_phase3(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * 180.0
	move_and_slide()

	death_spiral_timer += delta
	if death_spiral_timer >= DEATH_SPIRAL_INTERVAL:
		death_spiral_timer = 0.0
		_release_lunar_spiral(36, 0.15)

	chaos_timer += delta
	if chaos_timer >= CHAOS_INTERVAL:
		chaos_timer = 0.0
		_spawn_mob("res://Scenes/Game/Mobs/kael.tscn")
		_release_twin_rings()

	_check_contact_damage(delta)

func _check_contact_damage(delta):
	damage_cooldown -= delta
	var dist = global_position.distance_to(player.global_position)
	if dist < 100 and damage_cooldown <= 0:
		player.take_damage(CONTACT_DAMAGE)
		damage_cooldown = 1.0
		player.trigger_shake(14.0, 0.4)

func _release_lunar_spiral(count, speed_variance):
	for i in range(count):
		var angle = TAU * i / count
		var proj = LunarSpiralProjectile.new()
		proj.position = global_position
		proj.base_angle = angle
		proj.speed = 200.0 + randf_range(-speed_variance * 100, speed_variance * 100)
		proj.player_ref = player
		proj.color = Color(0.7, 0.2, 1.0) if boss_phase == BossPhase.PHASE1 else Color(0.9, 0.1, 0.5)
		get_parent().add_child(proj)

func _release_twin_rings():
	# Inner ring
	var inner = ExpandingRing.new()
	inner.position = global_position
	inner.player_ref = player
	inner.max_radius = 200.0
	inner.color = Color(0.8, 0.0, 0.5)
	inner.damage = 20
	get_parent().add_child(inner)
	# Outer ring — delayed
	var outer = ExpandingRing.new()
	outer.position = global_position
	outer.player_ref = player
	outer.max_radius = 350.0
	outer.color = Color(0.6, 0.0, 0.8)
	outer.damage = 20
	outer.delay = 0.4
	get_parent().add_child(outer)

func _transition_to_phase2():
	boss_phase = BossPhase.PHASE2
	var flash = TransitionFlash.new()
	flash.position = global_position
	flash.color = Color(0.8, 0.0, 0.5)
	get_parent().add_child(flash)
	player.trigger_shake(22.0, 0.8)

func _transition_to_phase3():
	boss_phase = BossPhase.PHASE3
	var flash = TransitionFlash.new()
	flash.position = global_position
	flash.color = Color(0.9, 0.0, 0.2)
	get_parent().add_child(flash)
	player.trigger_shake(22.0, 0.8)

func _spawn_mob(scene_path):
	var mob = load(scene_path).instantiate()
	var angle = randf() * TAU
	var spawn_pos = global_position + Vector2(cos(angle), sin(angle)) * 150.0
	spawn_pos.x = clamp(spawn_pos.x, -1450, 1450)
	spawn_pos.y = clamp(spawn_pos.y, -950, 950)
	mob.position = spawn_pos
	mob.player = player
	mob.apply_phase(current_phase)
	mob.apply_difficulty(difficulty)
	get_parent().add_child(mob)

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	boss_phase = BossPhase.DEAD
	player.gain_xp(XP_VALUE)
	if world_ref:
		world_ref.lilith_defeated()
	for i in range(20):
		var angle = TAU * i / 20
		var effect = DeathParticle.new()
		effect.position = global_position
		effect.direction = Vector2(cos(angle), sin(angle))
		effect.color = Color(0.6, 0.0, 0.9)
		get_parent().add_child(effect)
	queue_free()

func setup(pos, p, w):
	position = pos
	player = p
	world_ref = w

func apply_phase(phase):
	current_phase = phase

func apply_difficulty(d):
	difficulty = d
	max_hp = int(max_hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp

class LunarSpiralProjectile extends Node2D:
	var base_angle = 0.0
	var speed = 200.0
	var lifetime = 2.5
	var elapsed = 0.0
	var player_ref = null
	var hit_player = false
	var color = Color(0.7, 0.2, 1.0)
	var spin_speed = 1.2

	func _process(delta):
		elapsed += delta
		lifetime -= delta
		base_angle += spin_speed * delta
		var direction = Vector2(cos(base_angle), sin(base_angle))
		position += direction * speed * delta
		queue_redraw()
		if player_ref != null and not hit_player:
			var dist = global_position.distance_to(player_ref.global_position)
			if dist < 20:
				hit_player = true
				player_ref.take_damage(20)
				player_ref.trigger_shake(10.0, 0.25)
				queue_free()
				return
		if lifetime <= 0:
			queue_free()

	func _draw():
		var t = elapsed / (elapsed + lifetime)
		var alpha = 1.0 - t * 0.5
		var forward = Vector2(cos(base_angle), sin(base_angle))
		var perp = forward.rotated(PI / 2)
		var points = PackedVector2Array([
			forward * 10.0,
			perp * 4.0,
			-forward * 5.0,
			-perp * 4.0
		])
		draw_colored_polygon(points, Color(color.r, color.g, color.b, alpha))
		draw_circle(Vector2.ZERO, 6, Color(color.r + 0.2, color.g + 0.1, color.b + 0.1, alpha * 0.6))
		draw_circle(Vector2.ZERO, 3, Color(1, 1, 1, alpha * 0.8))

class ExpandingRing extends Node2D:
	var lifetime = 1.8
	var elapsed = 0.0
	var player_ref = null
	var hit_player = false
	var max_radius = 300.0
	var color = Color(0.8, 0.0, 0.5)
	var damage = 20
	var delay = 0.0

	func _process(delta):
		if delay > 0:
			delay -= delta
			return
		elapsed += delta
		queue_redraw()
		if player_ref != null and not hit_player:
			var dist = global_position.distance_to(player_ref.global_position)
			var current_radius = lerp(0.0, max_radius, elapsed / lifetime)
			if dist < current_radius + 22 and dist > current_radius - 22:
				hit_player = true
				player_ref.take_damage(damage)
				player_ref.trigger_shake(12.0, 0.3)
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		if delay > 0:
			return
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var current_radius = lerp(0.0, max_radius, t)
		var width = lerp(24.0, 5.0, t)
		draw_arc(Vector2.ZERO, current_radius + width, 0, TAU, 64, Color(color.r, color.g, color.b, alpha * 0.2), width * 2.0)
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, Color(color.r, color.g, color.b, alpha * 0.9), width)
		draw_arc(Vector2.ZERO, current_radius - width * 0.3, 0, TAU, 64, Color(1, 0.8, 1, alpha * 0.5), width * 0.4)

class TransitionFlash extends Node2D:
	var lifetime = 1.0
	var elapsed = 0.0
	var color = Color(0.8, 0.0, 0.5)

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var radius = lerp(90.0, 600.0, t)
		draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, alpha * 0.12))
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(color.r, color.g, color.b, alpha * 0.7), 5.0)

class DeathParticle extends Node2D:
	var direction = Vector2.ZERO
	var speed = 350.0
	var lifetime = 1.2
	var elapsed = 0.0
	var color = Color(0.6, 0.0, 0.9)

	func _process(delta):
		elapsed += delta
		position += direction * speed * delta
		speed *= 0.91
		queue_redraw()
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		draw_circle(Vector2.ZERO, lerp(14.0, 2.0, t), Color(color.r, color.g, color.b, alpha))
		draw_circle(Vector2.ZERO, lerp(7.0, 1.0, t), Color(1, 0.8, 1, alpha * 0.8))
		
