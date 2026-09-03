extends Node2D

signal back_pressed

const DEV_NAME = "Deva Path"
const GITHUB_URL = "https://github.com/Himanshu-Jorwal"
const LIST_HALF_WIDTH = 300

var roles = [
	"GAMEPLAY LOGIC",
	"PROJECT ARCHITECTURE",
	"UI & MENU",
	"WORLD & ARENA DESIGN",
	"MOON PHASE SYSTEM",
	"BOSS DESIGN",
	"ENEMY AI",
	"CHARACTER ABILITIES",
]

var hovered_back = false
var hovered_github = false

func _ready():
	pass

func _process(_delta):
	queue_redraw()

func _get_github_button():
	var screen = get_viewport().get_visible_rect().size
	var cx = screen.x / 2
	return {"label": "GITHUB", "rect": Rect2(cx - 90, screen.y - 500, 180, 40)}

func _get_back_button():
	var screen = get_viewport().get_visible_rect().size
	var cx = screen.x / 2
	return {"label": "BACK", "rect": Rect2(cx - 90, screen.y - 450, 180, 40)}

func _input(event):
	var github_btn = _get_github_button()
	var back_btn = _get_back_button()

	if event is InputEventMouseMotion:
		hovered_github = github_btn.rect.has_point(event.position)
		hovered_back = back_btn.rect.has_point(event.position)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if github_btn.rect.has_point(event.position):
			OS.shell_open(GITHUB_URL)
		elif back_btn.rect.has_point(event.position):
			emit_signal("back_pressed")

func _draw_button(btn, is_hovered, font):
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

func _draw_credit_row(y, cx, left_text, right_text, font, size, text_col, dash_col):
	var lx = cx - LIST_HALF_WIDTH
	draw_string(font, Vector2(lx, y), left_text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, text_col)

	var right_size = font.get_string_size(right_text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	var rx = cx + LIST_HALF_WIDTH - right_size.x
	draw_string(font, Vector2(rx, y), right_text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, text_col)

	var dash = "-"
	var dash_size = font.get_string_size(dash, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	draw_string(font, Vector2(cx - dash_size.x / 2, y), dash, HORIZONTAL_ALIGNMENT_LEFT, -1, size, dash_col)

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

	# Title
	var title = "CREDITS"
	var title_size = 56
	var ts = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size)
	var ty = 90
	draw_string(font, Vector2(cx - ts.x / 2 + 3, ty + 3), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(cx - ts.x / 2, ty), title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color(0.95, 0.95, 0.95, 1.0))

	var line_width = ts.x * 1.2
	draw_line(Vector2(cx - line_width / 2, ty + 22), Vector2(cx + line_width / 2, ty + 22), Color(0.4, 0.4, 0.4, 0.5), 1.0)

	# Role list — left aligned role, dash in the middle, name right aligned
	var role_y = ty + 70
	var role_size = 18
	for role in roles:
		_draw_credit_row(role_y, cx, role, DEV_NAME, font, role_size, Color(0.85, 0.85, 0.85), Color(0.45, 0.45, 0.45))
		role_y += 30

	# Honest AI-art credit, same row style, warm amber tint to set it apart as a disclosure
	role_y += 14
	_draw_credit_row(role_y, cx, "CHARACTER ART", "AI Generated (For Now)", font, role_size, Color(0.85, 0.7, 0.45), Color(0.55, 0.48, 0.35))

	# GitHub button
	var github_btn = _get_github_button()
	_draw_button(github_btn, hovered_github, font)

	# Back button — stacked directly below GitHub
	var back_btn = _get_back_button()
	_draw_button(back_btn, hovered_back, font)
