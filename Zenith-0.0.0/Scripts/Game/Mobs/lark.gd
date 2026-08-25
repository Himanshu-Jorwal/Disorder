extends CharacterBody2D

const XP_VALUE = 18
const CONTACT_DAMAGE = 25

var chase_speed = 160.0
var player = null
var hp = 35
var max_hp = 35
var damage_cooldown = 0.0
var current_phase = 0
var difficulty = 1.0
var time = 0.0
var is_blue_moon = false
var shoot_timer = 0.0
var shoot_interval = 3.5

const FLEE_THRESHOLD = 180.0
const CHASE_THRESHOLD = 280.0

func _ready():
	add_to_group("enemies")

func _draw():
	var col = Color(0.2, 0.7, 0.9) if not is_blue_moon else Color(0.2, 0.4, 1.0)
	var pulse = (sin(time * 3.0) + 1.0) / 2.0

	var points = PackedVector2Array()
	var steps = 6
	for i in range(steps):
		var angle = TAU * i / steps + time * 0.5
		points.append(Vector2(cos(angle), sin(angle)) * 16.0)
	draw_colored_polygon(points, col)

	var inner_points = PackedVector2Array()
	for i in range(steps):
		var angle = TAU * i / steps + time * 0.5 + PI / steps
		inner_points.append(Vector2(cos(angle), sin(angle)) * 8.0)
	draw_colored_polygon(inner_points, Color(1, 1, 1, 0.4 + pulse * 0.3))

	draw_circle(Vector2.ZERO, 20, Color(col.r, col.g, col.b, 0.1 + pulse * 0.05))

	if is_blue_moon:
		draw_circle(Vector2.ZERO, 26, Color(0.3, 0.5, 1.0, 0.15 + pulse * 0.1))

	var bar_width = 32.0
	var bar_height = 4.0
	draw_rect(Rect2(-bar_width / 2, -28, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, -28, bar_width * (float(hp) / float(max_hp)), bar_height), col)

func _physics_process(delta):
	if player == null:
		return
	time += delta
	queue_redraw()

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var direction = to_player.normalized()

	var current_flee_speed = player.BASE_SPEED * player.speed_multiplier + 20.0
	if is_blue_moon:
		current_flee_speed += 40.0
		chase_speed = 200.0
		shoot_interval = 2.0
	else:
		chase_speed = 160.0
		shoot_interval = 3.5

	if dist > CHASE_THRESHOLD:
		velocity = direction * chase_speed
	elif dist < FLEE_THRESHOLD:
		var flee_dir = -direction
		var erratic_strength = 0.3 if not is_blue_moon else 0.5
		var erratic = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		var final_dir = (flee_dir * (1.0 - erratic_strength) + erratic * erratic_strength).normalized()
		velocity = final_dir * current_flee_speed
	else:
		var orbit_dir = direction.rotated(PI / 2)
		var erratic = Vector2(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3))
		velocity = (orbit_dir + erratic).normalized() * (chase_speed * 0.6)

	move_and_slide()

	damage_cooldown -= delta
	if dist < 32 and damage_cooldown <= 0:
		player.take_damage(CONTACT_DAMAGE)
		damage_cooldown = 1.0

	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		_shoot_at_player()

func _shoot_at_player():
	if player == null:
		return
	var projectile = LarkProjectile.new()
	projectile.position = global_position
	projectile.direction = (player.global_position - global_position).normalized()
	projectile.is_blue_moon = is_blue_moon
	projectile.player_ref = player
	get_parent().add_child(projectile)

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	player.gain_xp(XP_VALUE)
	queue_free()

func apply_phase(phase):
	current_phase = phase
	is_blue_moon = (phase == 4)

func apply_difficulty(d):
	difficulty = d
	max_hp = int(max_hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp

class LarkProjectile extends Node2D:
	var direction = Vector2.ZERO
	var speed = 180.0
	var lifetime = 3.0
	var is_blue_moon = false
	var player_ref = null
	var time = 0.0

	func _draw():
		var col = Color(0.2, 0.7, 0.9) if not is_blue_moon else Color(0.2, 0.4, 1.0)
		var forward = direction.normalized()
		var perp = forward.rotated(PI / 2)
		var points = PackedVector2Array([
			forward * 8.0,
			perp * 4.0,
			-forward * 4.0,
			-perp * 4.0
		])
		draw_colored_polygon(points, col)
		draw_circle(Vector2.ZERO, 6, Color(col.r, col.g, col.b, 0.2))

	func _process(delta):
		time += delta
		lifetime -= delta
		if is_blue_moon:
			speed = 220.0
		position += direction * speed * delta
		queue_redraw()
		if lifetime <= 0:
			queue_free()
			return
		if player_ref != null:
			var dist = global_position.distance_to(player_ref.global_position)
			if dist < 20:
				player_ref.trigger_shake(12.0, 0.4)
				queue_free()
				
func apply_roar_boost():
	chase_speed *= 1.5
	await get_tree().create_timer(5.0).timeout
	chase_speed /= 1.5
