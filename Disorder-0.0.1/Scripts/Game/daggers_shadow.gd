extends Node2D

var lifetime = 3.0
var elapsed = 0.0
var player_ref = null
var exploded = false
const EXPLOSION_RADIUS = 120.0
const EXPLOSION_DAMAGE = 60
const ATTRACT_RADIUS = 350.0
const ATTRACT_FORCE = 320.0
var warning_wave_spawned = false
var time = 0.0

func _process(delta):
	elapsed += delta
	time += delta
	queue_redraw()

	# At 2 seconds fire attraction wave
	if elapsed >= 2.0 and not warning_wave_spawned:
		warning_wave_spawned = true
		_spawn_attract_wave()

	if elapsed >= lifetime:
		_explode()

func _spawn_attract_wave():
	var wave = AttractWave.new()
	wave.position = global_position
	wave.player_ref = player_ref
	wave.attract_radius = ATTRACT_RADIUS
	wave.attract_force = ATTRACT_FORCE
	get_parent().add_child(wave)

func _explode():
	if exploded:
		return
	exploded = true
	if player_ref != null:
		var dist = global_position.distance_to(player_ref.global_position)
		if dist < EXPLOSION_RADIUS:
			player_ref.take_damage(40)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var dist = global_position.distance_to(enemy.global_position)
		if dist < EXPLOSION_RADIUS:
			enemy.take_damage(EXPLOSION_DAMAGE)
			# Fixed knockback outward
			var push_dir = (enemy.global_position - global_position).normalized()
			enemy.global_position += push_dir * 80.0
	var ring = ExplosionRing.new()
	ring.position = global_position
	ring.max_radius = EXPLOSION_RADIUS
	get_parent().add_child(ring)
	queue_free()

func _draw():
	var pulse = (sin(time * 3.0) + 1.0) / 2.0
	var phase2 = elapsed >= 2.0
	var warn_pulse = (sin(time * 8.0) + 1.0) / 2.0 if phase2 else 0.0

	# Countdown arc
	var arc_progress = 0.0
	if not phase2:
		arc_progress = 1.0 - (elapsed / 2.0)
	else:
		arc_progress = 1.0 - ((elapsed - 2.0) / 1.0)

	var arc_col = Color(0.2, 0.8, 0.7) if not phase2 else Color(1.0, 0.5, 0.1)
	draw_arc(Vector2.ZERO, 26, -PI / 2, -PI / 2 + TAU * arc_progress, 32, Color(arc_col.r, arc_col.g, arc_col.b, 0.95), 2.5)

	# Very dark body
	draw_circle(Vector2.ZERO, 20 + pulse * 2, Color(0.1, 0.4, 0.35, 0.06 + warn_pulse * 0.08))
	draw_circle(Vector2.ZERO, 16, Color(0.03, 0.03, 0.05, 0.97))
	draw_circle(Vector2.ZERO, 10, Color(0.05, 0.15, 0.12, 0.9 + warn_pulse * 0.1))
	draw_circle(Vector2.ZERO, 5, Color(0.15, 0.6, 0.5, 0.6 + warn_pulse * 0.3))
	draw_circle(Vector2.ZERO, 2, Color(1, 1, 1, 0.5 + warn_pulse * 0.4))

	# Teal outline
	draw_arc(Vector2.ZERO, 16, 0, TAU, 32, Color(0.2, 0.8, 0.65, 0.4 + warn_pulse * 0.3), 1.5)

class AttractWave extends Node2D:
	var elapsed = 0.0
	var lifetime = 1.2
	var attract_radius = 350.0
	var attract_force = 250.0
	var player_ref = null
	var pulled = false

	func _process(delta):
		elapsed += delta
		queue_redraw()
		# Pull enemies when wave passes through them
		if not pulled:
			var current_radius = lerp(0.0, attract_radius, elapsed / lifetime)
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if enemy.is_in_group("bosses"):
					continue
				var dist = global_position.distance_to(enemy.global_position)
				if dist < current_radius + 20 and dist > current_radius - 40:
					var pull_dir = (global_position - enemy.global_position).normalized()
					enemy.global_position += pull_dir * attract_force * delta * 8.0
		if elapsed >= lifetime:
			pulled = true
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var current_radius = lerp(0.0, attract_radius, t)
		var width = lerp(16.0, 4.0, t)
		# Teal attraction wave
		draw_arc(Vector2.ZERO, current_radius + width, 0, TAU, 64, Color(0.1, 0.7, 0.6, alpha * 0.15), width * 2.5)
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, Color(0.2, 0.9, 0.75, alpha * 0.85), width)
		draw_arc(Vector2.ZERO, current_radius - width * 0.3, 0, TAU, 64, Color(1, 1, 1, alpha * 0.4), width * 0.3)
		# Arrow indicators showing pull direction
		for i in range(8):
			var angle = TAU * i / 8
			var arrow_pos = Vector2(cos(angle), sin(angle)) * current_radius
			var inward = -Vector2(cos(angle), sin(angle))
			draw_line(arrow_pos, arrow_pos + inward * 12.0, Color(0.3, 1.0, 0.85, alpha * 0.6), 2.0)

class ExplosionRing extends Node2D:
	var elapsed = 0.0
	var lifetime = 0.7
	var max_radius = 120.0

	func _process(delta):
		elapsed += delta
		queue_redraw()
		if elapsed >= lifetime:
			queue_free()

	func _draw():
		var t = elapsed / lifetime
		var alpha = 1.0 - t
		var current_radius = lerp(0.0, max_radius, t)
		var width = lerp(20.0, 4.0, t)
		draw_arc(Vector2.ZERO, current_radius + width, 0, TAU, 64, Color(1.0, 0.5, 0.1, alpha * 0.2), width * 2)
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 64, Color(1.0, 0.6, 0.15, alpha * 0.9), width)
		draw_arc(Vector2.ZERO, current_radius - width * 0.3, 0, TAU, 64, Color(1, 1, 0.8, alpha * 0.6), width * 0.3)
		draw_circle(Vector2.ZERO, lerp(20.0, 5.0, t), Color(1, 1, 1, alpha * 0.4))
		
