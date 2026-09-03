extends Node2D

signal resume_pressed
signal quit_pressed

var hovered = -1

const PANEL_SIZE = Vector2(360, 260)
const BTN_SIZE = Vector2(220, 46)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	queue_redraw()

func _get_panel_rect():
	var screen = get_viewport().get_visible_rect().size
	return Rect2((screen - PANEL_SIZE) / 2, PANEL_SIZE)

func _get_buttons():
	var panel = _get_panel_rect()
	var cx = panel.position.x + panel.size.x / 2
	return [
		{"label": "RESUME", "rect": Rect2(cx - BTN_SIZE.x / 2, panel.position.y + 120, BTN_SIZE.x, BTN_SIZE.y)},
		{"label": "GIVE UP", "rect": Rect2(cx - BTN_SIZE.x / 2, panel.position.y + 180, BTN_SIZE.x, BTN_SIZE.y)},
	]

func _input(event):
	if not visible:
		return
	var buttons = _get_buttons()
	if event is InputEventMouseMotion:
		hovered = -1
		for i in range(buttons.size()):
			if buttons[i].rect.has_point(event.position):
				hovered = i
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(buttons.size()):
			if buttons[i].rect.has_point(event.position):
				if i == 0:
					emit_signal("resume_pressed")
				elif i == 1:
					emit_signal("quit_pressed")

func _draw():
	var screen = get_viewport().get_visible_rect().size
	var font = ThemeDB.fallback_font
	var panel = _get_panel_rect()
	var cx = panel.position.x + panel.size.x / 2

	# Dim backdrop over gameplay
	draw_rect(Rect2(0, 0, screen.x, screen.y), Color(0, 0, 0, 0.65))

	# Panel background + border
	draw_rect(panel, Color(0.05, 0.05, 0.06, 0.97))
	draw_rect(panel, Color(0.3, 0.3, 0.3, 0.5), false, 1.0)

	# Subtle grid inside panel
	var gx = int(panel.position.x)
	while gx < panel.position.x + panel.size.x:
		draw_line(Vector2(gx, panel.position.y), Vector2(gx, panel.position.y + panel.size.y), Color(1, 1, 1, 0.02), 1.0)
		gx += 40
	var gy = int(panel.position.y)
	while gy < panel.position.y + panel.size.y:
		draw_line(Vector2(panel.position.x, gy), Vector2(panel.position.x + panel.size.x, gy), Color(1, 1, 1, 0.02), 1.0)
		gy += 40

	# Title
	var title = "PAUSED"
	var title_size = 32
	var ts = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size)
	var ty = panel.position.y + 60
	draw_string(font, Vector2(cx - ts.x / 2 + 2, ty + 2), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(cx - ts.x / 2, ty), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0.95, 0.95, 0.95, 1.0))

	# Thin divider under title
	var line_width = ts.x * 1.4
	draw_line(Vector2(cx - line_width / 2, ty + 16), Vector2(cx + line_width / 2, ty + 16), Color(0.4, 0.4, 0.4, 0.5), 1.0)

	# Buttons
	var buttons = _get_buttons()
	for i in range(buttons.size()):
		var btn = buttons[i]
		var is_hovered = i == hovered
		var bg_col = Color(0.12, 0.12, 0.12) if is_hovered else Color(0.06, 0.06, 0.06)
		var border_col = Color(0.6, 0.6, 0.6, 0.8) if is_hovered else Color(0.25, 0.25, 0.25, 0.6)
		var text_col = Color(1.0, 1.0, 1.0) if is_hovered else Color(0.75, 0.75, 0.75)

		draw_rect(btn.rect, bg_col)
		draw_rect(btn.rect, border_col, false, 1.0)

		var font_size = 14
		var label_size = font.get_string_size(btn.label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var lx = btn.rect.position.x + btn.rect.size.x / 2 - label_size.x / 2
		var ly = btn.rect.position.y + btn.rect.size.y / 2 + label_size.y / 2 - 4
		draw_string(font, Vector2(lx, ly), btn.label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_col)
