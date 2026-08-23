extends Area2D

var lifetime = 3.0
var pull_strength = 150.0
var time = 0.0

func _draw():
	draw_circle(Vector2.ZERO, 80, Color(1.0, 0.5, 0.1, 0.08))
	draw_circle(Vector2.ZERO, 60, Color(1.0, 0.5, 0.1, 0.12))
	draw_circle(Vector2.ZERO, 40, Color(1.0, 0.5, 0.1, 0.18))
	draw_arc(Vector2.ZERO, 80, 0, TAU, 64, Color(1.0, 0.6, 0.2, 0.6), 2.0)

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	time += delta
	lifetime -= delta
	queue_redraw()
	if lifetime <= 0:
		queue_free()
	# Pull all enemies toward rift
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var dist = enemy.global_position.distance_to(global_position)
		if dist < 200:
			var pull_dir = (global_position - enemy.global_position).normalized()
			enemy.global_position += pull_dir * pull_strength * delta

func _on_body_entered(body):
	pass

func setup(pos):
	position = pos
