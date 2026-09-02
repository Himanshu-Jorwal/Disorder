extends Node2D

@onready var label = $Label

var velocity = Vector2.ZERO
var lifetime = 0.8
var elapsed = 0.0

func setup(pos, amount):
	position = pos
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0, 1.0))
	velocity = Vector2(randf_range(-20, 20), -80)

func _process(delta):
	elapsed += delta
	position += velocity * delta
	velocity.y += 30 * delta
	var t = elapsed / lifetime
	label.modulate = Color(1, 1, 1, 1.0 - t)
	if elapsed >= lifetime:
		queue_free()
