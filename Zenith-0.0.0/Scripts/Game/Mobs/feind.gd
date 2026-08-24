extends CharacterBody2D

const BASE_SPEED = 90.0
const DASH_SPEED = 600.0
const XP_VALUE = 15
const CONTACT_DAMAGE = 20

var player = null
var hp = 25
var max_hp = 25
var damage_cooldown = 0.0
var current_phase = 0
var difficulty = 1.0

enum State { CHASE, TELEGRAPH, DASH, RECOVER }
var state = State.CHASE
var state_timer = 0.0
var dash_direction = Vector2.ZERO
var dash_distance = 0.0

const TELEGRAPH_TIME = 0.8
const RECOVER_TIME = 0.6
const DASH_RANGE = 250.0

func _ready():
	add_to_group("enemies")

func _draw():
	var col = Color(1.0, 0.3, 0.1)
	match state:
		State.CHASE:
			draw_circle(Vector2.ZERO, 16, col)
			draw_circle(Vector2.ZERO, 8, Color(1, 1, 1, 0.5))
		State.TELEGRAPH:
			# Glowing eyes effect — pulsing
			draw_circle(Vector2.ZERO, 18, Color(1.0, 0.1, 0.0, 0.3))
			draw_circle(Vector2.ZERO, 16, col)
			draw_circle(Vector2.ZERO, 5, Color(1, 0.8, 0, 1.0))
		State.DASH:
			# Stretched look during dash
			var forward = dash_direction
			var perp = forward.rotated(PI / 2)
			var points = PackedVector2Array([
				forward * 22.0,
				perp * 10.0,
				-forward * 10.0,
				-perp * 10.0
			])
			draw_colored_polygon(points, col)
			draw_colored_polygon(points, Color(1, 0.5, 0.2, 0.4))
		State.RECOVER:
			draw_circle(Vector2.ZERO, 16, Color(col.r * 0.5, col.g * 0.5, col.b * 0.5, 0.8))

	# HP bar
	var bar_width = 32.0
	var bar_height = 4.0
	draw_rect(Rect2(-bar_width / 2, -28, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, -28, bar_width * (float(hp) / float(max_hp)), bar_height), Color(1.0, 0.3, 0.1))

func _physics_process(delta):
	if player == null:
		return
	queue_redraw()

	damage_cooldown -= delta
	var dist = global_position.distance_to(player.global_position)

	match state:
		State.CHASE:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * BASE_SPEED
			move_and_slide()
			# Check contact damage
			if dist < 32 and damage_cooldown <= 0:
				player.take_damage(CONTACT_DAMAGE)
				damage_cooldown = 1.0
			# Telegraph when in range
			if dist < DASH_RANGE:
				state = State.TELEGRAPH
				state_timer = TELEGRAPH_TIME
				velocity = Vector2.ZERO

		State.TELEGRAPH:
			velocity = Vector2.ZERO
			state_timer -= delta
			if state_timer <= 0:
				dash_direction = (player.global_position - global_position).normalized()
				state = State.DASH
				dash_distance = 0.0

		State.DASH:
			velocity = dash_direction * DASH_SPEED
			move_and_slide()
			dash_distance += DASH_SPEED * delta
			# Check contact damage during dash
			if dist < 32 and damage_cooldown <= 0:
				player.take_damage(CONTACT_DAMAGE * 1.5)
				damage_cooldown = 1.0
				state = State.RECOVER
				state_timer = RECOVER_TIME
			# Stop dash after distance or hitting wall
			if dash_distance > 300 or velocity.length() < 10:
				state = State.RECOVER
				state_timer = RECOVER_TIME
				velocity = Vector2.ZERO

		State.RECOVER:
			velocity = Vector2.ZERO
			state_timer -= delta
			if state_timer <= 0:
				state = State.CHASE

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	player.gain_xp(XP_VALUE)
	queue_free()

func apply_phase(phase):
	current_phase = phase

func apply_difficulty(d):
	difficulty = d
	max_hp = int(max_hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp
