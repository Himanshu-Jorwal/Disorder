extends Node2D

func _process(_delta):
	queue_redraw()

func _draw():
	var screen = get_viewport().get_visible_rect().size
	var fps = Engine.get_frames_per_second()
	var font = ThemeDB.fallback_font
	var text = "FPS: " + str(fps)

	var col = Color(0.4, 1.0, 0.4)   # green — healthy
	if fps < 30:
		col = Color(1.0, 0.35, 0.35)  # red — struggling
	elif fps < 50:
		col = Color(1.0, 0.85, 0.35)  # amber — a bit soft

	var font_size = 14
	var ts = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	# Small translucent backing chip so it stays legible over any background
	var chip_y = screen.y - 32.0
	draw_rect(Rect2(8, chip_y, ts.x + 16, 24), Color(0, 0, 0, 0.45))
	draw_string(font, Vector2(16, chip_y + 17), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)
