extends CharacterBody2D

const XP_VALUE = 150
const CONTACT_DAMAGE = 30

var speed = 55.0
var player = null
var hp = 500
var max_hp = 500
var damage_cooldown = 0.0
var current_phase = 0
var difficulty = 1.0
var time = 0.0
var enraged = false
var summon_timer = 0.0
var summon_interval = 8.0
var slam_timer = 0.0
var slam_interval = 10.0
var roar_timer = 0.0
var roar_interval = 15.0
var is_slamming = false
var slam_charge = 0.0
var slam_charge_time = 1.5
var is_roaring = false
var roar_charge = 0.0
var roar_charge_time = 1.0

const ENRAGE_THRESHOLD = 0.5

func _ready():
	add_to_group("enemies")
	add_to_group("bosses")
	_update_collision()

func _update_collision():
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = 64.0

func _draw():
	var pulse = (sin(time * 2.0) + 1.0) / 2.0
	var enrage_pulse = (sin(time * 6.0) + 1.0) / 2.0
	var col = Color(0.8, 0.6, 0.1) if not enraged else Color(1.0, 0.2, 0.0)
	var glow_col = Color(0.9, 0.7, 0.2) if not enraged else Color(1.0, 0.4, 0.1)

	draw_circle(Vector2.ZERO, 96 + pulse * 10, Color(col.r, col.g, col.b, 0.06))
	draw_circle(Vector2.ZERO, 80 + pulse * 8, Color(col.r, col.g, col.b, 0.12))

	if enraged:
		draw_circle(Vector2.ZERO, 104 + enrage_pulse * 14, Color(1.0, 0.2, 0.0, 0.12))

	if is_slamming:
		var charge_progress = slam_charge / slam_charge_time
		draw_arc(Vector2.ZERO, 72, -PI / 2, -PI / 2 + TAU * charge_progress, 64, Color(1.0, 0.8, 0.0, 0.8), 4.0)
		draw_circle(Vector2.ZERO, 96 + charge_progress * 20, Color(1.0, 0.8, 0.0, charge_progress * 0.15))

	if is_roaring:
		var roar_progress = roar_charge / roar_charge_time
		draw_circle(Vector2.ZERO, 80 + roar_progress * 40, Color(0.8, 0.3, 1.0, roar_progress * 0.2))
		draw_arc(Vector2.ZERO, 80 + roar_progress * 40, 0, TAU, 64, Color(0.8, 0.3, 1.0, roar_progress * 0.6), 3.0)

	var points = PackedVector2Array()
	for i in range(6):
		var angle = TAU * i / 6 + time * 0.2
		var slam_bulge = slam_charge / slam_charge_time * 8.0 if is_slamming else 0.0
		var r = 64.0 + sin(time * 2.0 + i) * 4.0 + slam_bulge
		points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 1.0))

	var mid_points = PackedVector2Array()
	for i in range(6):
		var angle = TAU * i / 6 + time * 0.2 + PI / 6
		mid_points.append(Vector2(cos(angle), sin(angle)) * 50.0)
	draw_colored_polygon(mid_points, Color(col.r * 0.5, col.g * 0.5, col.b * 0.5, 1.0))

	var inner_points = PackedVector2Array()
	for i in range(6):
		var angle = TAU * i / 6 + time * 0.2
		inner_points.append(Vector2(cos(angle), sin(angle)) * 38.0)
	draw_colored_polygon(inner_points, col)

	for i in range(6):
		var angle = TAU * i / 6 + time * 0.2
		var inner = Vector2(cos(angle), sin(angle)) * 38.0
		var outer = Vector2(cos(angle), sin(angle)) * 64.0
		draw_line(inner, outer, Color(col.r * 0.6, col.g * 0.6, col.b * 0.6, 0.5), 2.0)

	draw_circle(Vector2.ZERO, 20, Color(glow_col.r, glow_col.g, glow_col.b, 0.9))
	draw_circle(Vector2.ZERO, 10, Color(1, 1, 1, 0.9))

	if enraged:
		var x_size = 28.0
		draw_line(Vector2(-x_size, -x_size), Vector2(x_size, x_size), Color(1, 0.2, 0, 0.9), 4.0)
		draw_line(Vector2(x_size, -x_size), Vector2(-x_size, x_size), Color(1, 0.2, 0, 0.9), 4.0)

	var bar_width = 120.0
	var bar_height = 8.0
	draw_rect(Rect2(-bar_width / 2, -85, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, -85, bar_width * (float(hp) / float(max_hp)), bar_height), col)
	draw_rect(Rect2(-bar_width / 2, -85, bar_width, bar_height), Color(col.r * 0.6, col.g * 0.6, col.b * 0.6, 0.5), false, 1.5)

	var font = ThemeDB.fallback_font
	var name_text = "GRAVEN"
	var name_size = font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(font, Vector2(-name_size.x / 2 + 1, -93), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(-name_size.x / 2, -94), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(col.r, col.g, col.b, 1.0))

func _physics_process(delta):
	if player == null:
		return
	time += delta
	queue_redraw()

	if not enraged and float(hp) / float(max_hp) <= ENRAGE_THRESHOLD:
		_enrage()

	if is_slamming or is_roaring:
		velocity = Vector2.ZERO
		move_and_slide()
		_handle_slam(delta)
		_handle_roar(delta)
		return

	var current_speed = speed * (2.0 if enraged else 1.0)
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * current_speed
	move_and_slide()

	damage_cooldown -= delta
	var dist = global_position.distance_to(player.global_position)
	if dist < 80 and damage_cooldown <= 0:
		player.take_damage(CONTACT_DAMAGE)
		damage_cooldown = 1.0
		player.trigger_shake(12.0, 0.3)

	summon_timer += delta
	if summon_timer >= summon_interval:
		summon_timer = 0.0
		_summon_enemies()

	slam_timer += delta
	if slam_timer >= slam_interval:
		slam_timer = 0.0
		is_slamming = true
		slam_charge = 0.0

	roar_timer += delta
	if roar_timer >= roar_interval:
		roar_timer = 0.0
		is_roaring = true
		roar_charge = 0.0

func _handle_slam(delta):
	if not is_slamming:
		return
	slam_charge += delta
	if slam_charge >= slam_charge_time:
		is_slamming = false
		_release_slam()

func _release_slam():
	for i in range(4):
		var angle = TAU * i / 4
		var ring = SlamRing.new()
		ring.position = global_position
		ring.direction = Vector2(cos(angle), sin(angle))
		ring.player_ref = player
		get_parent().add_child(ring)
	player.trigger_shake(14.0, 0.4)

func _handle_roar(delta):
	if not is_roaring:
		return
	roar_charge += delta
	if roar_charge >= roar_charge_time:
		is_roaring = false
		_release_roar()

func _release_roar():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < 400:
			if enemy.has_method("apply_roar_boost"):
				enemy.apply_roar_boost()
	var roar_wave = RoarWave.new()
	roar_wave.position = global_position
	get_parent().add_child(roar_wave)
	player.trigger_shake(10.0, 0.3)

func _enrage():
	enraged = true
	summon_interval = 5.0
	slam_interval = 6.0
	roar_interval = 10.0
	for i in range(2):
		_spawn_mob("res://Scenes/Game/Mobs/feind.tscn")

func _summon_enemies():
	if enraged:
		_spawn_mob("res://Scenes/Game/Mobs/feind.tscn")
		_spawn_mob("res://Scenes/Game/Mobs/wren.tscn")
	else:
		_spawn_mob("res://Scenes/Game/Mobs/wren.tscn")
		_spawn_mob("res://Scenes/Game/Mobs/wren.tscn")

func _spawn_mob(scene_path):
	var mob = load(scene_path).instantiate()
	var angle = randf() * TAU
	mob.position = global_position + Vector2(cos(angle), sin(angle)) * 100.0
	mob.player = player
	mob.apply_phase(current_phase)
	mob.apply_difficulty(difficulty)
	get_parent().add_child(mob)

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	player.gain_xp(XP_VALUE)
	for i in range(12):
		var angle = TAU * i / 12
		var effect = DeathParticle.new()
		effect.position = global_position
		effect.direction = Vector2(cos(angle), sin(angle))
		get_parent().add_child(effect)
	queue_free()

func apply_phase(phase):
	current_phase = phase

func apply_difficulty(d):
	difficulty = d
	max_hp = int(max_hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp

func apply_roar_boost():
	pass

class SlamRing extends Node2D:
	var direction = Vector2.ZERO
	var speed = 200.0
	var lifetime = 1.5
	var elapsed = 0.0
	var player_ref = null
	var hit_player = false

	func _process(delta):
		elapsed += delta
		position += direction * speed * delta
		queue_redraw()
		if player_ref != null and not hit_player:
			var dist = global_position.distance_to(player_ref.global_position)
			if dist < 35:
				hit_player = true
				player_ref.take_damage(20)
				player_ref.trigger_shake(16.0, 0.4)
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var col = Color(0.9, 0.7, 0.1)
		var ring_radius = lerp(30.0, 8.0, t)
		draw_circle(Vector2.ZERO, ring_radius + 12, Color(col.r, col.g, col.b, alpha * 0.15))
		draw_arc(Vector2.ZERO, ring_radius + 6, 0, TAU, 32, Color(col.r, col.g, col.b, alpha * 0.4), 6.0)
		draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 32, Color(col.r, col.g, col.b, alpha * 0.9), 3.0)
		draw_circle(Vector2.ZERO, ring_radius * 0.3, Color(1, 1, 1, alpha * 0.7))

class RoarWave extends Node2D:
	var lifetime = 0.8
	var elapsed = 0.0

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var radius = lerp(80.0, 500.0, t)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(0.8, 0.3, 1.0, alpha * 0.5), 4.0)
		draw_arc(Vector2.ZERO, radius * 0.7, 0, TAU, 64, Color(0.8, 0.3, 1.0, alpha * 0.3), 2.0)

class DeathParticle extends Node2D:
	var direction = Vector2.ZERO
	var speed = 250.0
	var lifetime = 0.8
	var elapsed = 0.0

	func _process(delta):
		elapsed += delta
		position += direction * speed * delta
		speed *= 0.93
		queue_redraw()
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		draw_circle(Vector2.ZERO, lerp(10.0, 2.0, t), Color(0.9, 0.7, 0.2, alpha))
		draw_circle(Vector2.ZERO, lerp(5.0, 1.0, t), Color(1.0, 1.0, 0.8, alpha * 0.8))
