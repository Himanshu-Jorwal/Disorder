extends Node2D

signal start_pressed
signal exit_pressed

var time = 0.0
var hovered = -1

var buttons = []

func _ready():
	var screen = get_viewport().get_visible_rect().size
	var cx = screen.x / 2
	var cy = screen.y / 2
	buttons = [
		{"label": "START GAME", "rect": Rect2(cx - 100, cy + 20, 200, 44)},
		{"label": "EXIT", "rect": Rect2(cx - 100, cy + 80, 200, 44)},
	]

func _process(delta):
	time += delta
	queue_redraw()

func _input(event):
	if event is InputEventMouseMotion:
		hovered = -1
		for i in range(buttons.size()):
			if buttons[i].rect.has_point(event.position):
				hovered = i

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(buttons.size()):
			if buttons[i].rect.has_point(event.position):
				if i == 0:
					emit_signal("start_pressed")
				elif i == 1:
					emit_signal("exit_pressed")

func _draw():
	var screen = get_viewport().get_visible_rect().size
	var cx = screen.x / 2
	var font = ThemeDB.fallback_font

	# Background
	draw_rect(Rect2(0, 0, screen.x, screen.y), Color(0.02, 0.02, 0.03))

	# Subtle grid
	for i in range(0, int(screen.x), 80):
		draw_line(Vector2(i, 0), Vector2(i, screen.y), Color(1, 1, 1, 0.02), 1.0)
	for i in range(0, int(screen.y), 80):
		draw_line(Vector2(0, i), Vector2(screen.x, i), Color(1, 1, 1, 0.02), 1.0)

	# Border lines
	draw_line(Vector2(0, 2), Vector2(screen.x, 2), Color(0.3, 0.3, 0.3, 0.4), 1.0)
	draw_line(Vector2(0, screen.y - 2), Vector2(screen.x, screen.y - 2), Color(0.3, 0.3, 0.3, 0.4), 1.0)

	# ZENITH title
	var title = "ZENITH"
	var title_size = 72
	var ts = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size)
	draw_string(font, Vector2(cx - ts.x / 2 + 3, screen.y / 2 - 100 + 3), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(cx - ts.x / 2, screen.y / 2 - 100), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0.95, 0.95, 0.95, 1.0))

	# Thin line under title
	var line_width = ts.x * 1.2
	draw_line(Vector2(cx - line_width / 2, screen.y / 2 - 30), Vector2(cx + line_width / 2, screen.y / 2 - 30), Color(0.4, 0.4, 0.4, 0.5), 1.0)

	# Buttons
	for i in range(buttons.size()):
		var btn = buttons[i]
		var is_hovered = i == hovered
		var bg_col = Color(0.12, 0.12, 0.12) if is_hovered else Color(0.06, 0.06, 0.06)
		var border_col = Color(0.6, 0.6, 0.6, 0.8) if is_hovered else Color(0.25, 0.25, 0.25, 0.6)
		var text_col = Color(1.0, 1.0, 1.0) if is_hovered else Color(0.75, 0.75, 0.75)

		# Button background
		draw_rect(btn.rect, bg_col)
		draw_rect(btn.rect, border_col, false, 1.0)

		# Button text
		var font_size = 14
		var label_size = font.get_string_size(btn.label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var lx = btn.rect.position.x + btn.rect.size.x / 2 - label_size.x / 2
		var ly = btn.rect.position.y + btn.rect.size.y / 2 + label_size.y / 2 - 4
		draw_string(font, Vector2(lx, ly), btn.label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_col)

	# Credits
	var credits = "developed by Deva Path   github.com/Himanshu-Jorwal"
	draw_string(font, Vector2(15, screen.y - 14), credits, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.3, 0.3, 0.6))

	# Version
	draw_string(font, Vector2(screen.x - 60, screen.y - 14), "v0.0.0", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.3, 0.3, 0.5))
