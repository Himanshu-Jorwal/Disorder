extends Node2D

const HEART_SIZE = 45.0
const HEART_SPACING = 52.0
const BASE_HEARTS = 5
const HP_PER_HEART = 20
const MARGIN = 25.0
const HEARTS_Y = 45.0
const XP_Y = 85.0

const HEART_COLOR_FULL = Color(0.75, 0.08, 0.08, 1.0)
const HEART_COLOR_EMPTY = Color(0.25, 0.08, 0.08, 0.7)

var XP_BAR_WIDTH = (BASE_HEARTS - 1) * HEART_SPACING + HEART_SIZE
var XP_BAR_HEIGHT = 18.0
var XP_BAR_X = 25.0

var current_hp = 100
var max_hp = 100
var current_xp = 0
var current_xp_max = 50
var current_level = 1

var heart_texture = preload("res://Assets/HUD/Heart.png")

func _draw():
	var font = ThemeDB.fallback_font
	var total_hearts = int(max_hp / HP_PER_HEART)
	var bonus_hearts = max(0, total_hearts - BASE_HEARTS)

	# Draw base 5 hearts
	for i in range(BASE_HEARTS):
		var pos = Vector2(MARGIN + i * HEART_SPACING, HEARTS_Y - HEART_SIZE / 2)
		var heart_hp_min = i * HP_PER_HEART
		var heart_hp_max = heart_hp_min + HP_PER_HEART

		if current_hp >= heart_hp_max:
			draw_texture_rect(heart_texture, Rect2(pos, Vector2(HEART_SIZE, HEART_SIZE)), false, Color(1, 1, 1, 1.0))
		elif current_hp > heart_hp_min:
			var partial = float(current_hp - heart_hp_min) / float(HP_PER_HEART)
			draw_texture_rect(heart_texture, Rect2(pos, Vector2(HEART_SIZE, HEART_SIZE)), false, Color(0.3, 0.1, 0.1, 0.6))
			draw_texture_rect(heart_texture, Rect2(pos, Vector2(HEART_SIZE, HEART_SIZE)), false, Color(1, 1, 1, partial))
		else:
			draw_texture_rect(heart_texture, Rect2(pos, Vector2(HEART_SIZE, HEART_SIZE)), false, Color(0.3, 0.1, 0.1, 0.6))

	# Draw bonus hearts
	for i in range(bonus_hearts):
		var pos = Vector2(MARGIN + (BASE_HEARTS + i) * HEART_SPACING, HEARTS_Y - HEART_SIZE / 2)
		var heart_hp_min = (BASE_HEARTS + i) * HP_PER_HEART
		if current_hp > heart_hp_min:
			draw_texture_rect(heart_texture, Rect2(pos, Vector2(HEART_SIZE, HEART_SIZE)), false, Color(1, 1, 1, 1.0))

	# XP bar shadow
	draw_rect(Rect2(XP_BAR_X - 1, XP_Y - 1, XP_BAR_WIDTH + 2, XP_BAR_HEIGHT + 2), Color(0.0, 0.0, 0.0, 0.9))
	# XP bar background
	draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH, XP_BAR_HEIGHT), Color(0.08, 0.05, 0.15, 1.0))
	# XP bar fill
	var xp_progress = float(current_xp) / float(current_xp_max)
	if xp_progress > 0:
		draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH * xp_progress, XP_BAR_HEIGHT), Color(0.4, 0.15, 0.9, 1.0))
		draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH * xp_progress, XP_BAR_HEIGHT * 0.3), Color(0.65, 0.45, 1.0, 0.5))
	# XP bar border
	draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH, XP_BAR_HEIGHT), Color(0.45, 0.25, 0.75, 0.9), false, 1.5)

	# XP text inside bar
	var xp_text = str(current_xp) + " / " + str(current_xp_max)
	var xp_font_size = 11
	var xp_text_size = font.get_string_size(xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size)
	var xp_text_x = XP_BAR_X + XP_BAR_WIDTH / 2 - xp_text_size.x / 2
	var xp_text_y = XP_Y + XP_BAR_HEIGHT - 4
	draw_string(font, Vector2(xp_text_x + 1, xp_text_y + 1), xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size, Color(0.0, 0.0, 0.0, 0.9))
	draw_string(font, Vector2(xp_text_x - 1, xp_text_y - 1), xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size, Color(0.5, 0.2, 0.9, 0.3))
	draw_string(font, Vector2(xp_text_x, xp_text_y), xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size, Color(0.8, 0.55, 1.0, 1.0))

	# Level text
	var level_text = "— LVL " + str(current_level) + " —"
	var level_font_size = 16
	var level_size = font.get_string_size(level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size)
	var level_x = XP_BAR_X + XP_BAR_WIDTH / 2 - level_size.x / 2
	var level_y = XP_Y + XP_BAR_HEIGHT + 32
	draw_string(font, Vector2(level_x + 1, level_y + 1), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size, Color(0.0, 0.0, 0.0, 0.9))
	draw_string(font, Vector2(level_x - 1, level_y - 1), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size, Color(0.5, 0.2, 0.9, 0.3))
	draw_string(font, Vector2(level_x, level_y), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size, Color(0.8, 0.55, 1.0, 1.0))

func update_stats(hp, max_hp_val, xp, xp_to_next, level):
	current_hp = hp
	max_hp = max_hp_val
	current_xp = xp
	current_xp_max = xp_to_next
	current_level = level
	queue_redraw()
