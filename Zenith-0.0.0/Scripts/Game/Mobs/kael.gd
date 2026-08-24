extends CharacterBody2D

const XP_VALUE = 25
const REPULSION_RADIUS = 180.0
const CORRUPT_DAMAGE = 20
const CORRUPT_DURATION = 30.0
const EXPIRE_TIME = 20.0

var player = null
var hp = 35
var max_hp = 35
var current_phase = 0
var difficulty = 1.0
var time = 0.0
var exploded = false

func _ready():
	add_to_group("enemies")

func _draw():
	var dist = global_position.distance_to(player.global_position) if player else 999
	var proximity = clamp(1.0 - dist / REPULSION_RADIUS, 0.0, 1.0)
	var pulse = (sin(time * 3.0) + 1.0) / 2.0
	var col = Color(1.0, lerp(0.6, 0.1, proximity), 0.0)

	# Repulsion field rings
	draw_circle(Vector2.ZERO, REPULSION_RADIUS, Color(1.0, 0.4, 0.0, 0.06 + pulse * 0.04))
	draw_circle(Vector2.ZERO, REPULSION_RADIUS * 0.6, Color(1.0, 0.5, 0.0, 0.04 + pulse * 0.03))
	draw_arc(Vector2.ZERO, REPULSION_RADIUS, 0, TAU, 64, Color(1.0, 0.4, 0.0, 0.3 + pulse * 0.2), 2.5)
	draw_arc(Vector2.ZERO, REPULSION_RADIUS * 0.85, 0, TAU, 64, Color(1.0, 0.5, 0.0, 0.15), 1.0)

	# Core
	draw_circle(Vector2.ZERO, 36 + pulse * 4, Color(col.r, col.g, col.b, 0.2))
	draw_circle(Vector2.ZERO, 36, col)
	draw_circle(Vector2.ZERO, 18, Color(1, 0.8, 0.2, 0.6 + pulse * 0.4))
	draw_circle(Vector2.ZERO, 8, Color(1, 1, 1, 0.8))

	# HP bar
	var bar_width = 50.0
	var bar_height = 4.0
	draw_rect(Rect2(-bar_width / 2, -48, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, -48, bar_width * (float(hp) / float(max_hp)), bar_height), col)

func _physics_process(delta):
	if player == null or exploded:
		return
	time += delta
	queue_redraw()

	velocity = Vector2.ZERO
	move_and_slide()

	# Force field — directly push player position
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	if dist < REPULSION_RADIUS:
		var push_dir = to_player.normalized()
		# How deep inside the field
		var overlap = REPULSION_RADIUS - dist
		# Directly move player out
		player.global_position += push_dir * (overlap * 0.3 + 3.0)

	if time >= EXPIRE_TIME:
		_leave_corruption()
		player.gain_xp(XP_VALUE)
		exploded = true
		queue_free()

func _leave_corruption():
	var corrupt = CorruptZone.new()
	corrupt.position = global_position
	corrupt.player_ref = player
	corrupt.radius = REPULSION_RADIUS * 0.8
	get_parent().add_child(corrupt)

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	if exploded:
		return
	exploded = true
	_leave_corruption()
	player.gain_xp(XP_VALUE)
	queue_free()

func apply_phase(phase):
	current_phase = phase

func apply_difficulty(d):
	difficulty = d
	max_hp = int(max_hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp

class CorruptZone extends Node2D:
	var lifetime = 30.0
	var elapsed = 0.0
	var radius = 144.0
	var player_ref = null
	var damage_cooldown = 0.0
	var cracks = []

	func _ready():
		# Generate random crack positions once
		for i in range(12):
			var angle = randf() * TAU
			var dist = randf_range(radius * 0.1, radius * 0.85)
			var length = randf_range(radius * 0.1, radius * 0.3)
			var crack_angle = randf() * TAU
			cracks.append({
				"start": Vector2(cos(angle), sin(angle)) * dist,
				"angle": crack_angle,
				"length": length,
				"width": randf_range(1.5, 3.5)
			})

	func _process(delta):
		elapsed += delta
		damage_cooldown -= delta
		queue_redraw()

		if player_ref != null:
			var dist = global_position.distance_to(player_ref.global_position)
			if dist < radius and damage_cooldown <= 0:
				player_ref.take_damage(20)
				damage_cooldown = 1.0

		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = lerp(0.5, 0.05, t)

		# Dark base ground
		draw_circle(Vector2.ZERO, radius, Color(0.15, 0.0, 0.0, alpha * 0.9))
		draw_circle(Vector2.ZERO, radius * 0.75, Color(0.25, 0.02, 0.0, alpha * 0.7))
		draw_circle(Vector2.ZERO, radius * 0.5, Color(0.35, 0.05, 0.0, alpha * 0.5))
		draw_circle(Vector2.ZERO, radius * 0.25, Color(0.5, 0.08, 0.0, alpha * 0.4))

		# Glowing ember center
		draw_circle(Vector2.ZERO, radius * 0.15, Color(0.8, 0.3, 0.0, alpha * 0.6))
		draw_circle(Vector2.ZERO, radius * 0.08, Color(1.0, 0.6, 0.0, alpha * 0.8))

		# Border
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(0.8, 0.2, 0.0, alpha * 1.2), 2.0)

		# Cracks
		for crack in cracks:
			var crack_end = crack.start + Vector2(cos(crack.angle), sin(crack.angle)) * crack.length
			draw_line(crack.start, crack_end, Color(0.9, 0.3, 0.0, alpha * 1.5), crack.width)
			# Branch
			var branch_angle = crack.angle + randf_range(-0.5, 0.5)
			var branch_end = crack_end + Vector2(cos(branch_angle), sin(branch_angle)) * crack.length * 0.4
			draw_line(crack_end, branch_end, Color(0.7, 0.2, 0.0, alpha * 1.2), crack.width * 0.6)

		# Ember particles — random glowing dots
		for i in range(8):
			var angle = TAU * i / 8 + elapsed * 0.3
			var r = radius * randf_range(0.2, 0.7)
			var ember_pos = Vector2(cos(angle), sin(angle)) * r
			draw_circle(ember_pos, 2.5, Color(1.0, 0.5, 0.0, alpha * 0.8))
