extends CharacterBody2D

const XP_VALUE = 150
const CONTACT_DAMAGE = 25
const DEVOUR_RANGE = 80.0
const DEVOUR_HEAL = 40.0
const SURGE_INTERVAL = 8.0
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

	draw_circle(Vector2.ZERO, 55 + pulse * 8, Color(col.r, col.g, col.b, 0.08))
	draw_circle(Vector2.ZERO, 48 + pulse * 6, Color(col.r, col.g, col.b, 0.14))

	if is_surging:
		var charge_progress = surge_charge / SURGE_CHARGE_TIME
		draw_circle(Vector2.ZERO, 55 + charge_progress * 20, Color(0.8, 0.0, 0.0, charge_progress * 0.2))
		draw_arc(Vector2.ZERO, 50, -PI / 2, -PI / 2 + TAU * charge_progress, 64, Color(0.9, 0.1, 0.1, 0.8), 3.0)

	var points = PackedVector2Array()
	var steps = 20
	for i in range(steps):
		var angle = TAU * i / steps
		var wobble = sin(time * 2.0 + angle * 3.0) * 5.0
		var r = 40.0 + wobble
		points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, col)

	var inner_points = PackedVector2Array()
	for i in range(steps):
		var angle = TAU * i / steps
		var wobble = sin(time * 2.0 + angle * 3.0) * 3.0
		var r = 26.0 + wobble
		inner_points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(inner_points, Color(col.r + 0.2, col.g, col.b, 1.0))

	for i in range(stored_devours):
		var angle = TAU * i / max(stored_devours, 1) + time * 1.5
		var orbit_pos = Vector2(cos(angle), sin(angle)) * 48.0
		draw_circle(orbit_pos, 6.0, Color(1.0, 0.3, 0.3, 0.9))
		draw_circle(orbit_pos, 3.0, Color(1.0, 0.8, 0.8, 0.9))

	draw_circle(Vector2.ZERO, 14, Color(0.8, 0.1, 0.1, 0.9))
	draw_circle(Vector2.ZERO, 7, Color(1.0, 0.3, 0.3, 0.9))
	draw_circle(Vector2.ZERO, 3, Color(1, 1, 1, 0.9))

	if enraged:
		var enrage_pulse = (sin(time * 8.0) + 1.0) / 2.0
		draw_circle(Vector2.ZERO, 50 + enrage_pulse * 10, Color(1.0, 0.0, 0.0, 0.15))

	var bar_width = 100.0
	var bar_height = 8.0
	draw_rect(Rect2(-bar_width / 2, -65, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, -65, bar_width * (float(hp) / float(max_hp)), bar_height), Color(0.8, 0.0, 0.0))
	draw_rect(Rect2(-bar_width / 2, -65, bar_width, bar_height), Color(0.5, 0.0, 0.0, 0.5), false, 1.5)

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

	if not enraged and float(hp) / float(max_hp) <= ENRAGE_THRESHOLD:
		_enrage()

	if is_surging:
		velocity = Vector2.ZERO
		move_and_slide()
		surge_charge += delta
		if surge_charge >= SURGE_CHARGE_TIME:
			is_surging = false
			_release_surge()
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	damage_cooldown -= delta
	var dist = global_position.distance_to(player.global_position)
	if dist < 55 and damage_cooldown <= 0:
		player.take_damage(CONTACT_DAMAGE)
		damage_cooldown = 1.0
		player.trigger_shake(10.0, 0.25)

	devour_cooldown -= delta
	if devour_cooldown <= 0 and not enraged:
		_try_devour()

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
			var pull = DevourPull.new()
			pull.position = enemy.global_position
			pull.target = global_position
			get_parent().add_child(pull)
			hp = min(hp + DEVOUR_HEAL, max_hp)
			stored_devours = min(stored_devours + 1, 8)
			speed = min(speed + 5.0, 110.0)
			enemy.queue_free()
			devour_cooldown = 3.0
			break

func _release_surge():
	var ring = BloodRing.new()
	ring.position = global_position
	ring.player_ref = player
	ring.enraged = enraged
	get_parent().add_child(ring)
	stored_devours = 0
	player.trigger_shake(10.0, 0.3)

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

class BloodRing extends Node2D:
	var lifetime = 1.5
	var elapsed = 0.0
	var player_ref = null
	var hit_player = false
	var enraged = false
	var max_radius = 300.0

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if player_ref != null and not hit_player:
			var dist = global_position.distance_to(player_ref.global_position)
			var current_radius = lerp(0.0, max_radius, elapsed / lifetime)
			if dist < current_radius + 20 and dist > current_radius - 20:
				hit_player = true
				player_ref.take_damage(20)
				player_ref.trigger_shake(12.0, 0.3)
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var current_radius = lerp(0.0, max_radius, t)
		var width = lerp(20.0, 4.0, t)
		draw_arc(Vector2.ZERO, current_radius + width, 0, TAU, 64, Color(0.6, 0.0, 0.0, alpha * 0.2), width * 2)
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, Color(0.9, 0.0, 0.0, alpha * 0.8), width)
		draw_arc(Vector2.ZERO, current_radius - width * 0.3, 0, TAU, 64, Color(1.0, 0.3, 0.3, alpha * 0.5), width * 0.5)

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
