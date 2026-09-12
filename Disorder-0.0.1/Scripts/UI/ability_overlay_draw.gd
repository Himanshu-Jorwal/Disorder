extends Node2D

var overlay_width = 40.0
var overlay_height = 0.0
var cd_text = ""

func _draw():
	if overlay_height > 0.01:
		draw_rect(Rect2(0, 0, overlay_width, overlay_height), Color(0, 0, 0, 0.7))

	if cd_text != "":
		var font = ThemeDB.fallback_font
		var cd_size = font.get_string_size(cd_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
		var cx = overlay_width / 2 - cd_size.x / 2
		var cy = overlay_width / 2 + 5
		draw_string(font, Vector2(cx + 1, cy + 1), cd_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0, 0, 0, 0.9))
		draw_string(font, Vector2(cx, cy), cd_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.9))
