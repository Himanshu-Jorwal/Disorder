extends Node2D

signal restart_pressed

var hovered = -1
var score_text = "Score: 0"

const PANEL_SIZE = Vector2(400, 260)
const BTN_SIZE = Vector2(200, 50)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	queue_redraw()

func set_score(score):
	score_text = "Score: " + str(score)

func _get_panel_rect():
	var screen = get_viewport().get_visible_rect().size
	return Rect2((screen - PANEL_SIZE) / 2, PANEL_SIZE)

func _get_button():
	var panel = _get_panel_rect()
	var cx = panel.position.x + panel.size.x / 2
	return {"label": "RESTART", "rect": Rect2(cx - BTN_SIZE.x / 2, panel.position.y + 180, BTN_SIZE.x, BTN_SIZE.y)}

func _input(event):
	if not visible:
		return
	var btn = _get_button()
	if event is InputEventMouseMotion:
		hovered = -1
		if btn.rect.has_point(event.position):
			hovered = 0
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if btn.rect.has_point(event.position):
			emit_signal("restart_pressed")

func _draw():
	var screen = get_viewport().get_visible_rect().size
	var font = ThemeDB.fallback_font
	var panel = _get_panel_rect()
	var cx = panel.position.x + panel.size.x / 2

	draw_rect(Rect2(0, 0, screen.x, screen.y), Color(0, 0, 0, 0.7))
	draw_rect(panel, Color(0.05, 0.05, 0.06, 0.97))
	draw_rect(panel, Color(0.3, 0.3, 0.3, 0.5), false, 1.0)

	var gx = int(panel.position.x)
	while gx < panel.position.x + panel.size.x:
		draw_line(Vector2(gx, panel.position.y), Vector2(gx, panel.position.y + panel.size.y), Color(1, 1, 1, 0.02), 1.0)
		gx += 40
	var gy = int(panel.position.y)
	while gy < panel.position.y + panel.size.y:
		draw_line(Vector2(panel.position.x, gy), Vector2(panel.position.x + panel.size.x, gy), Color(1, 1, 1, 0.02), 1.0)
		gy += 40

	var title = "YOU DIED"
	var title_size = 34
	var ts = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size)
	var ty = panel.position.y + 64
	draw_string(font, Vector2(cx - ts.x / 2 + 2, ty + 2), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(cx - ts.x / 2, ty), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0.85, 0.2, 0.2, 1.0))

	var line_width = ts.x * 1.2
	draw_line(Vector2(cx - line_width / 2, ty + 18), Vector2(cx + line_width / 2, ty + 18), Color(0.4, 0.4, 0.4, 0.5), 1.0)

	var score_size = 18
	var ss = font.get_string_size(score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, score_size)
	draw_string(font, Vector2(cx - ss.x / 2, panel.position.y + 120), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, score_size, Color(0.8, 0.8, 0.8))

	var btn = _get_button()
	var is_hovered = hovered == 0
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
