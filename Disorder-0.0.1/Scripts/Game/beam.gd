extends Node2D

var direction = Vector2.ZERO
var lifetime = 2.0
var damage = 80
var time = 0.0
var beam_length = 2000.0
var hit_cooldowns = {}

var damage_number_scene = preload("res://Scenes/UI/damage_number.tscn")

func _draw():
	var t = time / 2.0
	var alpha = 1.0 - t
	var width = lerp(20.0, 8.0, t)
	# Outer glow
	draw_line(Vector2.ZERO, direction * beam_length, Color(1.0, 0.5, 0.1, alpha * 0.2), width + 16)
	draw_line(Vector2.ZERO, direction * beam_length, Color(1.0, 0.6, 0.2, alpha * 0.4), width + 8)
	# Core beam
	draw_line(Vector2.ZERO, direction * beam_length, Color(1.0, 0.7, 0.3, alpha * 0.9), width)
	# Bright center
	draw_line(Vector2.ZERO, direction * beam_length, Color(1.0, 1.0, 0.8, alpha * 0.8), width * 0.3)

func _process(delta):
	time += delta
	lifetime -= delta
	queue_redraw()
	if lifetime <= 0:
		queue_free()
		return
	# Check enemies along beam
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_id = enemy.get_instance_id()
		if enemy_id in hit_cooldowns:
			hit_cooldowns[enemy_id] -= delta
			if hit_cooldowns[enemy_id] <= 0:
				hit_cooldowns.erase(enemy_id)
			continue
		var closest = _closest_point_on_beam(enemy.global_position)
		var dist = enemy.global_position.distance_to(closest)
		if dist < 30:
			enemy.take_damage(damage)
			var dmg_num = damage_number_scene.instantiate()
			get_tree().current_scene.add_child(dmg_num)
			dmg_num.setup(enemy.global_position, damage)
			hit_cooldowns[enemy_id] = 0.5

func _closest_point_on_beam(point):
	var beam_end = global_position + direction * beam_length
	var ab = beam_end - global_position
	var t = clamp((point - global_position).dot(ab) / ab.dot(ab), 0.0, 1.0)
	return global_position + ab * t

func setup(pos, dir):
	position = pos
	direction = dir
