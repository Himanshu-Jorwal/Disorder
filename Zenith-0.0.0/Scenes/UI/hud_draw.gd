extends Node2D

const HEART_SIZE = 45.0
const HEART_SPACING = 52.0
const BASE_HEARTS = 5
const HP_PER_HEART = 20
const MARGIN = 45.0
const HEARTS_Y = 45.0
const XP_Y = 85.0
const XP_BAR_X = 25.0

const HEART_COLOR_FULL = Color(0.75, 0.08, 0.08, 1.0)
const HEART_COLOR_EMPTY = Color(0.251, 0.078, 0.078, 0.796)

var XP_BAR_WIDTH = (BASE_HEARTS - 1) * HEART_SPACING + HEART_SIZE
var XP_BAR_HEIGHT = 18.0

var current_hp = 100
var max_hp = 100
var current_xp = 0
var current_xp_max = 50
var current_level = 1

func _draw():
	var font = ThemeDB.fallback_font
	var total_hearts = int(max_hp / HP_PER_HEART)
	var base_hp = BASE_HEARTS * HP_PER_HEART
	var bonus_hearts = max(0, total_hearts - BASE_HEARTS)

	# Draw base 5 hearts
	for i in range(BASE_HEARTS):
		var pos = Vector2(MARGIN + i * HEART_SPACING, HEARTS_Y)
		var heart_hp_min = i * HP_PER_HEART
		var heart_hp_max = heart_hp_min + HP_PER_HEART

		if current_hp >= heart_hp_max:
			# Full heart
			_draw_heart(pos, HEART_COLOR_FULL, 1.0, true)
		elif current_hp > heart_hp_min:
			# Partial heart
			var partial = float(current_hp - heart_hp_min) / float(HP_PER_HEART)
			_draw_heart(pos, HEART_COLOR_EMPTY, 1.0, false)
			_draw_heart(pos, HEART_COLOR_FULL, partial, true)
		else:
			# Empty heart
			_draw_heart(pos, HEART_COLOR_EMPTY, 1.0, false)

	# Draw bonus hearts — either full or gone, no fading
	for i in range(bonus_hearts):
		var pos = Vector2(MARGIN + (BASE_HEARTS + i) * HEART_SPACING, HEARTS_Y)
		var heart_hp_min = (BASE_HEARTS + i) * HP_PER_HEART
		if current_hp > heart_hp_min:
			_draw_heart(pos, HEART_COLOR_FULL, 1.0, true)
		# If damaged past this heart just don't draw it at all

	# XP bar
	var xp_progress = float(current_xp) / float(current_xp_max)

	# Shadow
	draw_rect(Rect2(XP_BAR_X - 1, XP_Y - 1, XP_BAR_WIDTH + 2, XP_BAR_HEIGHT + 2), Color(0.0, 0.0, 0.0, 0.9))
	# Background
	draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH, XP_BAR_HEIGHT), Color(0.08, 0.05, 0.15, 1.0))
	# Fill
	if xp_progress > 0:
		draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH * xp_progress, XP_BAR_HEIGHT), Color(0.4, 0.15, 0.9, 1.0))
		draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH * xp_progress, XP_BAR_HEIGHT * 0.3), Color(0.65, 0.45, 1.0, 0.5))
	# Border
	draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH, XP_BAR_HEIGHT), Color(0.45, 0.25, 0.75, 0.9), false, 1.5)

	# XP text inside bar — styled like level text
	var xp_text = str(current_xp) + " / " + str(current_xp_max)
	var xp_font_size = 11
	var xp_text_size = font.get_string_size(xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size)
	var xp_text_x = XP_BAR_X + XP_BAR_WIDTH / 2 - xp_text_size.x / 2
	var xp_text_y = XP_Y + XP_BAR_HEIGHT - 4
	# Shadow
	draw_string(font, Vector2(xp_text_x + 1, xp_text_y + 1), xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size, Color(0.0, 0.0, 0.0, 0.9))
	# Glow
	draw_string(font, Vector2(xp_text_x - 1, xp_text_y - 1), xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size, Color(0.5, 0.2, 0.9, 0.3))
	# Main
	draw_string(font, Vector2(xp_text_x, xp_text_y), xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, xp_font_size, Color(0.8, 0.55, 1.0, 1.0))

	# Level text
	var level_text = "— LVL " + str(current_level) + " —"
	var level_font_size = 16
	var level_size = font.get_string_size(level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size)
	var level_x = XP_BAR_X + XP_BAR_WIDTH / 2 - level_size.x / 2
	var level_y = XP_Y + XP_BAR_HEIGHT + 32
	# Shadow
	draw_string(font, Vector2(level_x + 1, level_y + 1), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size, Color(0.0, 0.0, 0.0, 0.9))
	# Glow
	draw_string(font, Vector2(level_x - 1, level_y - 1), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size, Color(0.5, 0.2, 0.9, 0.3))
	# Main
	draw_string(font, Vector2(level_x, level_y), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, level_font_size, Color(0.8, 0.55, 1.0, 1.0))

func _draw_heart(pos, col, alpha, cracked):
	var s = HEART_SIZE
	var c = Color(col.r, col.g, col.b, alpha)
	var dark = Color(col.r * 0.2, col.g * 0.04, col.b * 0.04, alpha)
	var darker = Color(0.0, 0.0, 0.0, alpha * 0.9)

	# Thick black outer outline
	draw_colored_polygon(_heart_polygon(pos, s + 5.0), darker)
	# Dark red inner outline
	draw_colored_polygon(_heart_polygon(pos, s + 2.5), dark)
	# Main heart
	draw_colored_polygon(_heart_polygon(pos, s), c)

	if cracked:
		var crack_col = Color(col.r * 0.3, col.g * 0.03, col.b * 0.03, alpha * 0.95)
		# Main vertical crack
		draw_line(pos + Vector2(s * 0.05, -s * 0.35), pos + Vector2(-s * 0.05, -s * 0.1), crack_col, 2.0)
		draw_line(pos + Vector2(-s * 0.05, -s * 0.1), pos + Vector2(s * 0.08, s * 0.15), crack_col, 2.0)
		draw_line(pos + Vector2(s * 0.08, s * 0.15), pos + Vector2(s * 0.0, s * 0.38), crack_col, 2.0)
		# Left branch
		draw_line(pos + Vector2(-s * 0.05, -s * 0.1), pos + Vector2(-s * 0.28, s * 0.05), crack_col, 1.5)
		# Right branch
		draw_line(pos + Vector2(s * 0.08, s * 0.15), pos + Vector2(s * 0.3, s * 0.08), crack_col, 1.5)
		# Top right small crack
		draw_line(pos + Vector2(s * 0.22, -s * 0.25), pos + Vector2(s * 0.35, -s * 0.1), crack_col, 1.0)

func _heart_polygon(pos, s):
	var points = PackedVector2Array()
	var steps = 48
	for i in range(steps):
		var t = TAU * i / steps
		var x = s * 0.38 * pow(sin(t), 3)
		var y = -s * 0.38 * (0.8125 * cos(t) - 0.3125 * cos(2 * t) - 0.125 * cos(3 * t) - 0.0625 * cos(4 * t))
		points.append(pos + Vector2(x, y))
	return points

func update_stats(hp, max_hp_val, xp, xp_to_next, level):
	current_hp = hp
	max_hp = max_hp_val
	current_xp = xp
	current_xp_max = xp_to_next
	current_level = level
	queue_redraw()
