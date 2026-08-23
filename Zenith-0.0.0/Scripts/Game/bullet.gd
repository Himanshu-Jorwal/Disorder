extends Area2D

const SPEED = 600.0
var direction = Vector2.ZERO
var lifetime = 2.0
var damage = 1

var damage_number_scene = preload("res://Scenes/UI/damage_number.tscn")

func _draw():
	draw_circle(Vector2.ZERO, 10, Color(1, 1, 0.3, 0.1))
	draw_circle(Vector2.ZERO, 7, Color(1, 1, 0.3, 0.2))
	draw_circle(Vector2.ZERO, 4, Color(1, 1, 0.6, 1.0))
	draw_circle(Vector2.ZERO, 2, Color(1, 1, 1, 1.0))

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * SPEED * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func setup(pos, dir, dmg = 1):
	position = pos
	direction = dir
	damage = dmg

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		var dmg_num = damage_number_scene.instantiate()
		get_parent().add_child(dmg_num)
		dmg_num.setup(global_position, damage)
		queue_free()
