extends CharacterBody2D

const XP_VALUE = 150
const CONTACT_DAMAGE = 25
const DEVOUR_RANGE = 80.0
const DEVOUR_HEAL = 40.0
const SURGE_INTERVAL = 8.0
const SURGE_PROJECTILE_COUNT = 12
const ENRAGE_THRESHOLD = 0.3

var speed = 70.0
var player = null
var hp = 400
var max_hp = 400
var damage_cooldown = 0.0
var current_phase = 0
var difficulty = 1.0
var time = 0.0
var surge_timer = 0.0
var enraged = false
var devour_cooldown = 0.0
var stored_devours = 0
var is_surging = false
var surge_charge = 0.0
const SURGE_CHARGE_TIME = 1.2

func _ready():
	add_to_group("enemies")
	add_to_group("bosses")
	_update_collision()

func _update_collision():
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = 40.0

func _draw():
	var pulse = (sin(time * 2.5) + 1.0) / 2.0
	var col = Color(0.5, 0.0, 0.0) if not enraged else Color(0.9, 0.0, 0.0)

	# Outer aura
	draw_circle(Vector2.ZERO, 55 + pulse * 8, Color(col.r, col.g, col.b, 0.08))
	draw_circle(Vector2.ZERO, 48 + pulse * 6, Color(col.r, col.g, col.b, 0.14))

	# Surge charge indicator
	if is_surging:
		var charge_progress = surge_charge / SURGE_CHARGE_TIME
		draw_circle(Vector2.ZERO, 55 + charge_progress * 20, Color(0.8, 0.0, 0.0, charge_progress * 0.2))
		draw_arc(Vector2.ZERO, 50, -PI / 2, -PI / 2 + TAU * charge_progress, 64, Color(0.9, 0.1, 0.1, 0.8), 3.0)

	# Body — irregular blob
	var points = PackedVector2Array()
	var steps = 20
	for i in range(steps):
		var angle = TAU * i / steps
		var wobble = sin(time * 2.0 + angle * 3.0) * 5.0
		var r = 40.0 + wobble
		points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, col)

	# Inner lighter layer
	var inner_points = PackedVector2Array()
	for i in range(steps):
		var angle = TAU * i / steps
		var wobble = sin(time * 2.0 + angle * 3.0) * 3.0
		var r = 26.0 + wobble
		inner_points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(inner_points, Color(col.r + 0.2, col.g, col.b, 1.0))

	# Stored devours indicator — glowing orbs orbiting body
	for i in range(stored_devours):
		var angle = TAU * i / max(stored_devours, 1) + time * 1.5
		var orbit_pos = Vector2(cos(angle), sin(angle)) * 48.0
		draw_circle(orbit_pos, 6.0, Color(1.0, 0.3, 0.3, 0.9))
		draw_circle(orbit_pos, 3.0, Color(1.0, 0.8, 0.8, 0.9))

	# Core
	draw_circle(Vector2.ZERO, 14, Color(0.8, 0.1, 0.1, 0.9))
	draw_circle(Vector2.ZERO, 7, Color(1.0, 0.3, 0.3, 0.9))
	draw_circle(Vector2.ZERO, 3, Color(1, 1, 1, 0.9))

	# Enrage effect
	if enraged:
		var enrage_pulse = (sin(time * 8.0) + 1.0) / 2.0
		draw_circle(Vector2.ZERO, 50 + enrage_pulse * 10, Color(1.0, 0.0, 0.0, 0.15))

	# HP bar
	var bar_width = 100.0
	var bar_height = 8.0
	draw_rect(Rect2(-bar_width / 2, -65, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, -65, bar_width * (float(hp) / float(max_hp)), bar_height), Color(0.8, 0.0, 0.0))
	draw_rect(Rect2(-bar_width / 2, -65, bar_width, bar_height), Color(0.5, 0.0, 0.0, 0.5), false, 1.5)

	# Name
	var font = ThemeDB.fallback_font
	var name_text = "MALAKAR"
	var name_size = font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(font, Vector2(-name_size.x / 2 + 1, -73), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(-name_size.x / 2, -74), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.9, 0.2, 0.2, 1.0))

func _physics_process(delta):
	if player == null:
		return
	time += delta
	queue_redraw()

	# Check enrage
	if not enraged and float(hp) / float(max_hp) <= ENRAGE_THRESHOLD:
		_enrage()

	# Surge charging
	if is_surging:
		velocity = Vector2.ZERO
		move_and_slide()
		surge_charge += delta
		if surge_charge >= SURGE_CHARGE_TIME:
			is_surging = false
			_release_surge()
		return

	# Movement
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Contact damage
	damage_cooldown -= delta
	var dist = global_position.distance_to(player.global_position)
	if dist < 55 and damage_cooldown <= 0:
		player.take_damage(CONTACT_DAMAGE)
		damage_cooldown = 1.0
		player.trigger_shake(10.0, 0.25)

	# Devour nearby normal enemies
	devour_cooldown -= delta
	if devour_cooldown <= 0 and not enraged:
		_try_devour()

	# Surge timer
	surge_timer += delta
	if surge_timer >= SURGE_INTERVAL:
		surge_timer = 0.0
		is_surging = true
		surge_charge = 0.0

func _try_devour():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		if enemy.is_in_group("bosses"):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < DEVOUR_RANGE:
			# Pull effect then devour
			var pull = DevourPull.new()
			pull.position = enemy.global_position
			pull.target = global_position
			get_parent().add_child(pull)
			# Heal
			hp = min(hp + DEVOUR_HEAL, max_hp)
			stored_devours = min(stored_devours + 1, 8)
			speed = min(speed + 5.0, 110.0)
			enemy.queue_free()
			devour_cooldown = 1.5
			break

func _release_surge():
	var count = SURGE_PROJECTILE_COUNT + stored_devours * 2
	for i in range(count):
		var angle = TAU * i / count
		var proj = BloodProjectile.new()
		proj.position = global_position
		proj.direction = Vector2(cos(angle), sin(angle))
		proj.player_ref = player
		proj.speed = 150.0 if not enraged else 220.0
		get_parent().add_child(proj)
	stored_devours = 0

func _enrage():
	enraged = true
	speed = 110.0
	surge_timer = 0.0
	is_surging = true
	surge_charge = 0.0

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	player.gain_xp(XP_VALUE)
	# Death nova
	for i in range(16):
		var angle = TAU * i / 16
		var proj = BloodProjectile.new()
		proj.position = global_position
		proj.direction = Vector2(cos(angle), sin(angle))
		proj.player_ref = player
		proj.speed = 200.0
		get_parent().add_child(proj)
	for i in range(8):
		var angle = TAU * i / 8
		var effect = BloodParticle.new()
		effect.position = global_position
		effect.direction = Vector2(cos(angle), sin(angle))
		get_parent().add_child(effect)
	queue_free()

func apply_roar_boost():
	speed *= 1.3
	await get_tree().create_timer(5.0).timeout
	speed /= 1.3

func apply_phase(phase):
	current_phase = phase

func apply_difficulty(d):
	difficulty = d
	max_hp = int(max_hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp

class DevourPull extends Node2D:
	var target = Vector2.ZERO
	var lifetime = 0.3
	var elapsed = 0.0

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var to_target = target - global_position
		draw_line(Vector2.ZERO, to_target * t, Color(0.9, 0.1, 0.1, alpha), 3.0)
		draw_circle(Vector2.ZERO, lerp(8.0, 2.0, t), Color(1.0, 0.2, 0.2, alpha))

class BloodProjectile extends Node2D:
	var direction = Vector2.ZERO
	var speed = 150.0
	var lifetime = 2.5
	var elapsed = 0.0
	var player_ref = null
	var hit = false

	func _process(delta):
		elapsed += delta
		lifetime -= delta
		position += direction * speed * delta
		queue_redraw()
		if lifetime <= 0:
			queue_free()
			return
		if player_ref != null and not hit:
			var dist = global_position.distance_to(player_ref.global_position)
			if dist < 18:
				hit = true
				player_ref.take_damage(20)
				player_ref.trigger_shake(10.0, 0.25)
				queue_free()

	func _draw():
		var t = elapsed / (elapsed + lifetime)
		var alpha = 1.0 - t * 0.5
		var forward = direction.normalized()
		var perp = forward.rotated(PI / 2)
		var points = PackedVector2Array([
			forward * 10.0,
			perp * 5.0,
			-forward * 5.0,
			-perp * 5.0
		])
		draw_colored_polygon(points, Color(0.8, 0.0, 0.0, alpha))
		draw_circle(Vector2.ZERO, 4, Color(1.0, 0.3, 0.3, alpha * 0.8))

class BloodParticle extends Node2D:
	var direction = Vector2.ZERO
	var speed = 200.0
	var lifetime = 0.6
	var elapsed = 0.0

	func _process(delta):
		elapsed += delta
		position += direction * speed * delta
		speed *= 0.92
		queue_redraw()
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		draw_circle(Vector2.ZERO, lerp(8.0, 2.0, t), Color(0.8, 0.0, 0.0, alpha))
		draw_circle(Vector2.ZERO, lerp(4.0, 1.0, t), Color(1.0, 0.2, 0.2, alpha * 0.8))
