extends Node2D

const HEART_SIZE = 45.0
const HEART_SPACING = 52.0
const BASE_HEARTS = 5
const HP_PER_HEART = 20
const MARGIN = 25.0
const HEARTS_Y = 45.0
const XP_Y = 85.0
const XP_BAR_X = 25.0

var XP_BAR_WIDTH = (BASE_HEARTS - 1) * HEART_SPACING + HEART_SIZE
var XP_BAR_HEIGHT = 18.0

const SLOT_SIZE = 52.0
const SLOT_SPACING = 18.0
const SLOT_Y_OFFSET = 80.0

var current_hp = 100
var max_hp = 100
var current_xp = 0
var current_xp_max = 50
var current_level = 1

var cd1 = 0.0
var max_cd1 = 0.25
var cd2 = 0.0
var max_cd2 = 1.0
var cd_abs = 0.0
var max_cd_abs = 30.0
var name1 = "Ability 1"
var name2 = "Ability 2"
var name_abs = "Absolute"

var heart_texture = preload("res://Assets/HUD/Heart.png")

func _draw():
	var screen = get_viewport().get_visible_rect().size
	var font = ThemeDB.fallback_font
	var total_hearts = int(max_hp / HP_PER_HEART)
	var bonus_hearts = max(0, total_hearts - BASE_HEARTS)

	# Base hearts
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

	# Bonus hearts
	for i in range(bonus_hearts):
		var pos = Vector2(MARGIN + (BASE_HEARTS + i) * HEART_SPACING, HEARTS_Y - HEART_SIZE / 2)
		var heart_hp_min = (BASE_HEARTS + i) * HP_PER_HEART
		if current_hp > heart_hp_min:
			draw_texture_rect(heart_texture, Rect2(pos, Vector2(HEART_SIZE, HEART_SIZE)), false, Color(1, 1, 1, 1.0))

	# XP bar
	draw_rect(Rect2(XP_BAR_X - 1, XP_Y - 1, XP_BAR_WIDTH + 2, XP_BAR_HEIGHT + 2), Color(0.0, 0.0, 0.0, 0.9))
	draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH, XP_BAR_HEIGHT), Color(0.08, 0.05, 0.15, 1.0))
	var xp_progress = float(current_xp) / float(current_xp_max)
	if xp_progress > 0:
		draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH * xp_progress, XP_BAR_HEIGHT), Color(0.4, 0.15, 0.9, 1.0))
		draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH * xp_progress, XP_BAR_HEIGHT * 0.3), Color(0.65, 0.45, 1.0, 0.5))
	draw_rect(Rect2(XP_BAR_X, XP_Y, XP_BAR_WIDTH, XP_BAR_HEIGHT), Color(0.45, 0.25, 0.75, 0.9), false, 1.5)

	# XP text
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

	# Ability slots
	var total_slot_width = SLOT_SIZE * 3 + SLOT_SPACING * 2
	var slot_start_x = XP_BAR_X + XP_BAR_WIDTH / 2 - total_slot_width / 2
	var slot_y = XP_Y + XP_BAR_HEIGHT + 55.0

	var slots = [
		[cd1, max_cd1, name1, Color(0.8, 0.4, 1.0), "LMB"],
		[cd2, max_cd2, name2, Color(0.4, 0.8, 1.0), "RMB"],
		[cd_abs, max_cd_abs, name_abs, Color(1.0, 0.6, 0.2), "X"]
	]

	for i in range(3):
		var slot = slots[i]
		var sx = slot_start_x + i * (SLOT_SIZE + SLOT_SPACING)
		var sy = slot_y
		var cooldown = slot[0]
		var max_cooldown = slot[1]
		var ability_name = slot[2]
		var col = slot[3]
		var key = slot[4]
		var is_ready = cooldown <= 0.0
		var cd_progress = cooldown / max_cooldown if max_cooldown > 0 else 0.0

		# Slot background
		draw_rect(Rect2(sx - 1, sy - 1, SLOT_SIZE + 2, SLOT_SIZE + 2), Color(0, 0, 0, 0.8))
		draw_rect(Rect2(sx, sy, SLOT_SIZE, SLOT_SIZE), Color(0.06, 0.04, 0.1, 1.0))

		# Icon placeholder
		var icon_col = col if is_ready else Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 1.0)
		draw_rect(Rect2(sx + 4, sy + 4, SLOT_SIZE - 8, SLOT_SIZE - 8), icon_col)

		# Cooldown overlay
		if not is_ready:
			var overlay_height = (SLOT_SIZE - 8) * cd_progress
			draw_rect(Rect2(sx + 4, sy + 4, SLOT_SIZE - 8, overlay_height), Color(0.0, 0.0, 0.0, 0.7))

		# Border
		var border_col = Color(col.r, col.g, col.b, 0.9) if is_ready else Color(col.r * 0.4, col.g * 0.4, col.b * 0.4, 0.5)
		draw_rect(Rect2(sx, sy, SLOT_SIZE, SLOT_SIZE), border_col, false, 2.0)

		# Ready glow
		if is_ready:
			draw_rect(Rect2(sx - 2, sy - 2, SLOT_SIZE + 4, SLOT_SIZE + 4), Color(col.r, col.g, col.b, 0.2), false, 2.0)

		# Ability name below slot
		var name_size = font.get_string_size(ability_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
		var name_x = sx + SLOT_SIZE / 2 - name_size.x / 2
		draw_string(font, Vector2(name_x + 1, sy + SLOT_SIZE + 14), ability_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0, 0, 0, 0.9))
		draw_string(font, Vector2(name_x, sy + SLOT_SIZE + 13), ability_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, col if is_ready else Color(col.r * 0.5, col.g * 0.5, col.b * 0.5, 0.8))

		# Key label in brackets below ability name
		var key_text = "(" + key + ")"
		var key_size = font.get_string_size(key_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
		var key_x = sx + SLOT_SIZE / 2 - key_size.x / 2
		draw_string(font, Vector2(key_x + 1, sy + SLOT_SIZE + 27), key_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0, 0, 0, 0.9))
		draw_string(font, Vector2(key_x, sy + SLOT_SIZE + 26), key_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.55, 0.55, 0.55, 0.8))

		# Cooldown timer
		if not is_ready:
			var cd_text = "%.1f" % cooldown
			var cd_size = font.get_string_size(cd_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
			draw_string(font, Vector2(sx + SLOT_SIZE / 2 - cd_size.x / 2 + 1, sy + SLOT_SIZE / 2 + 6), cd_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0, 0, 0, 0.9))
			draw_string(font, Vector2(sx + SLOT_SIZE / 2 - cd_size.x / 2, sy + SLOT_SIZE / 2 + 5), cd_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.9))

func update_stats(hp, max_hp_val, xp, xp_to_next, level, a1_cd, a1_max, a2_cd, a2_max, abs_cd, abs_max, a1_name, a2_name, abs_name):
	current_hp = hp
	max_hp = max_hp_val
	current_xp = xp
	current_xp_max = xp_to_next
	current_level = level
	cd1 = a1_cd
	max_cd1 = a1_max
	cd2 = a2_cd
	max_cd2 = a2_max
	cd_abs = abs_cd
	max_cd_abs = abs_max
	name1 = a1_name
	name2 = a2_name
	name_abs = abs_name
	queue_redraw()
