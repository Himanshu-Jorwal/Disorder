extends Area2D

const BASE_SPEED = 600.0
var speed = BASE_SPEED
var direction = Vector2.ZERO
var lifetime = 2.0
var damage = 10
var piercing = false
var returning = false
var bullet_color = Color(1, 1, 0.6)
var player_ref = null
var returned = false
var already_hit = {}
var active = false
var activate_timer = 0.1
var bullet_type = "normal"
var time = 0.0

var damage_number_scene = preload("res://Scenes/UI/damage_number.tscn")

func _draw():
	var col = bullet_color
	match bullet_type:
		"normal":
			draw_circle(Vector2.ZERO, 10, Color(col.r, col.g, col.b, 0.1))
			draw_circle(Vector2.ZERO, 7, Color(col.r, col.g, col.b, 0.2))
			draw_circle(Vector2.ZERO, 4, col)
			draw_circle(Vector2.ZERO, 2, Color(1, 1, 1, 1.0))
		"star":
			# 4 pointed star shape
			var points = PackedVector2Array()
			var outer = 8.0
			var inner = 3.0
			for i in range(8):
				var angle = TAU * i / 8 - PI / 8
				var r = outer if i % 2 == 0 else inner
				points.append(Vector2(cos(angle), sin(angle)) * r)
			draw_colored_polygon(points, col)
			draw_circle(Vector2.ZERO, 2.5, Color(1, 1, 1, 0.9))
			# Glow
			draw_circle(Vector2.ZERO, 12, Color(col.r, col.g, col.b, 0.08))
		"shard":
			# Sharp elongated diamond
			var forward = direction.normalized()
			var perp = forward.rotated(PI / 2)
			var tip = forward * 10.0
			var back = -forward * 6.0
			var left = perp * 3.0
			var right = -perp * 3.0
			var points = PackedVector2Array([tip, left, back, right])
			draw_colored_polygon(points, col)
			draw_colored_polygon(points, Color(1, 1, 1, 0.3))
			draw_circle(Vector2.ZERO, 8, Color(col.r, col.g, col.b, 0.1))
		"lance":
			# Long thin piercing bolt
			var forward = direction.normalized()
			var perp = forward.rotated(PI / 2)
			var points = PackedVector2Array([
				forward * 18.0,
				perp * 3.0,
				-forward * 6.0,
				-perp * 3.0
			])
			draw_colored_polygon(points, col)
			draw_colored_polygon(points, Color(1, 1, 1, 0.4))
			draw_circle(Vector2.ZERO, 14, Color(col.r, col.g, col.b, 0.08))
		"heavy":
			# Large slow orb with ring
			draw_circle(Vector2.ZERO, 18, Color(col.r, col.g, col.b, 0.15))
			draw_circle(Vector2.ZERO, 14, Color(col.r, col.g, col.b, 0.3))
			draw_circle(Vector2.ZERO, 10, col)
			draw_circle(Vector2.ZERO, 5, Color(1, 1, 1, 0.8))
			# Ring around orb
			draw_arc(Vector2.ZERO, 16, time * 3.0, time * 3.0 + TAU * 0.7, 32, Color(col.r, col.g, col.b, 0.6), 2.0)

func _ready():
	add_to_group("bullets")

func _process(delta):
	time += delta
	if bullet_type == "heavy":
		queue_redraw()

func _physics_process(delta):
	if not active:
		activate_timer -= delta
		if activate_timer <= 0:
			active = true
		position += direction * speed * delta
		lifetime -= delta
		if lifetime <= 0:
			queue_free()
		return

	if returning and not returned:
		if player_ref != null:
			var to_player = (player_ref.global_position - global_position)
			if to_player.length() < 20:
				returned = true
				queue_free()
				return
			if lifetime < 1.0:
				direction = to_player.normalized()

	# Check enemy hits by distance
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == null:
			continue
		var id = enemy.get_instance_id()
		if id in already_hit:
			continue
		var hit_radius = 20.0
		if bullet_type == "heavy":
			hit_radius = 30.0
		elif bullet_type == "lance":
			hit_radius = 15.0
		var dist = global_position.distance_to(enemy.global_position)
		if dist < hit_radius:
			already_hit[id] = true
			enemy.take_damage(damage)
			var dmg_num = damage_number_scene.instantiate()
			get_parent().add_child(dmg_num)
			dmg_num.setup(global_position, damage)
			if not piercing:
				queue_free()
				return

	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func setup(pos, dir, dmg, col, is_piercing, is_returning, player = null, type = "normal"):
	position = pos
	direction = dir
	damage = dmg
	bullet_color = col
	piercing = is_piercing
	returning = is_returning
	player_ref = player
	bullet_type = type
	if is_returning:
		lifetime = 2.0
