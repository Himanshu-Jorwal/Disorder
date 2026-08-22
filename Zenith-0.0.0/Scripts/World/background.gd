extends Node2D

var stars = []
const STAR_COUNT = 200

func _ready():
	randomize()
	for i in range(STAR_COUNT):
		stars.append({
			"pos": Vector2(randf_range(-2000, 2000), randf_range(-2000, 2000)),
			"size": randf_range(1.0, 3.0),
			"brightness": randf_range(0.4, 1.0)
		})

func _draw():
	# Deep space background
	draw_rect(Rect2(-4000, -4000, 8000, 8000), Color(0.02, 0.02, 0.05))
	
	# Stars
	for star in stars:
		var col = Color(1, 1, 1, star.brightness)
		draw_circle(star.pos, star.size, col)
