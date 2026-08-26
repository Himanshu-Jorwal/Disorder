extends Node2D

signal character_selected(index)

var characters = []
var selected = 0
var hovered = -1
var card_width = 300.0
var card_height = 520.0
var card_spacing = 50.0
var time = 0.0

var character_textures = [
	preload("res://Assets/Characters/zaire.png"),
	preload("res://Assets/Characters/daggers.png"),
	preload("res://Assets/Characters/milano.png")
]

func setup(chars, sel):
	characters = chars
	selected = sel
	hovered = sel

func _process(delta):
	time += delta
	queue_redraw()

func _get_card_positions():
	var screen = get_viewport().get_visible_rect().size
	var total_width = card_width * 3 + card_spacing * 2
	var start_x = (screen.x - total_width) / 2
	var center_y = screen.y / 2 + 20.0
	var positions = []
	for i in range(3):
		positions.append(Vector2(start_x + i * (card_width + card_spacing), center_y - card_height / 2))
	return positions

func _draw():
	var screen = get_viewport().get_visible_rect().size
	var font = ThemeDB.fallback_font
	var positions = _get_card_positions()

	# Background
	draw_rect(Rect2(0, 0, screen.x, screen.y), Color(0.02, 0.02, 0.05))

	# Title
	var title = "SELECT YOUR CHARACTER"
	var title_size = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 26)
	draw_string(font, Vector2(screen.x / 2 - title_size.x / 2 + 1, 61), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0, 0, 0, 0.9))
	draw_string(font, Vector2(screen.x / 2 - title_size.x / 2, 60), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.8, 0.6, 1.0, 1.0))

	# Cards
	for i in range(3):
		var pos = positions[i]
		var char = characters[i]
		var col = char.color
		var is_hovered = i == hovered
		var pulse = (sin(time * 2.0 + i) + 1.0) / 2.0

		# Card shadow
		draw_rect(Rect2(pos.x + 4, pos.y + 4, card_width, card_height), Color(0, 0, 0, 0.5))

		# Card background
		var bg_col = Color(0.06, 0.04, 0.1, 1.0)
		if is_hovered:
			bg_col = Color(0.1, 0.07, 0.16, 1.0)
		draw_rect(Rect2(pos.x, pos.y, card_width, card_height), bg_col)

		# Card border
		var border_col = Color(col.r * 0.5, col.g * 0.5, col.b * 0.5, 0.6)
		if is_hovered:
			border_col = Color(col.r, col.g, col.b, 0.8 + pulse * 0.2)
		draw_rect(Rect2(pos.x, pos.y, card_width, card_height), border_col, false, 2.0)

		# Glow on hover
		if is_hovered:
			draw_rect(Rect2(pos.x - 3, pos.y - 3, card_width + 6, card_height + 6), Color(col.r, col.g, col.b, 0.08 + pulse * 0.05), false, 6.0)

		# Character art
		var art_height = 300.0
		var texture = character_textures[i]
		draw_texture_rect(texture, Rect2(pos.x, pos.y, card_width, art_height), false)
		draw_line(Vector2(pos.x, pos.y + art_height), Vector2(pos.x + card_width, pos.y + art_height), border_col, 1.5)

		# Character name
		var name_size = font.get_string_size(char.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)
		var name_x = pos.x + card_width / 2 - name_size.x / 2
		draw_string(font, Vector2(name_x + 1, pos.y + art_height + 30), char.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0, 0, 0, 0.9))
		draw_string(font, Vector2(name_x, pos.y + art_height + 30), char.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(col.r, col.g, col.b, 1.0))

		# Divider below name
		draw_line(Vector2(pos.x + 14, pos.y + art_height + 44), Vector2(pos.x + card_width - 14, pos.y + art_height + 44), Color(col.r * 0.4, col.g * 0.4, col.b * 0.4, 0.4), 1.0)

		# Abilities
		var ability_y = pos.y + art_height + 50.0
		var abilities = [
			[char.attack1, char.attack1_desc],
			[char.attack2, char.attack2_desc],
			[char.absolute, char.absolute_desc]
		]

		for j in range(abilities.size()):
			var ab = abilities[j]
			var ay = ability_y + j * 60.0

			# Subtle divider between abilities
			if j > 0:
				draw_line(Vector2(pos.x + 14, ay - 6), Vector2(pos.x + card_width - 14, ay - 6), Color(col.r * 0.3, col.g * 0.3, col.b * 0.3, 0.3), 1.0)

			# Ability name
			draw_string(font, Vector2(pos.x + 16, ay + 16), "- " + ab[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(col.r, col.g, col.b, 1.0))
			# Ability desc
			draw_string(font, Vector2(pos.x + 16, ay + 33), ab[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.65, 0.65, 0.65, 0.85))

	# Controls tip box — right side
	var tip_width = 200.0
	var tip_height = 160.0
	var tip_x = screen.x - tip_width - 30.0
	var tip_y = screen.y / 2 - tip_height / 2

	# Tip box background
	draw_rect(Rect2(tip_x - 1, tip_y - 1, tip_width + 2, tip_height + 2), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(tip_x, tip_y, tip_width, tip_height), Color(0.06, 0.04, 0.1, 1.0))
	draw_rect(Rect2(tip_x, tip_y, tip_width, tip_height), Color(0.4, 0.25, 0.7, 0.6), false, 1.5)

	# Tip title
	var tip_title = "CONTROLS"
	var tip_title_size = font.get_string_size(tip_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(font, Vector2(tip_x + tip_width / 2 - tip_title_size.x / 2, tip_y + 22), tip_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.8, 0.6, 1.0, 1.0))

	# Divider
	draw_line(Vector2(tip_x + 10, tip_y + 30), Vector2(tip_x + tip_width - 10, tip_y + 30), Color(0.4, 0.25, 0.7, 0.4), 1.0)

	# Tips
	var tips = [
		["Ability 1", "Left Click"],
		["Ability 2", "Right Click"],
		["Absolute", "X"],
		["Move", "WASD"],
		["Pause", "ESC"]
	]

	for i in range(tips.size()):
		var ty = tip_y + 50 + i * 22.0
		draw_string(font, Vector2(tip_x + 14, ty), tips[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.7, 0.7, 0.85))
		var key_size = font.get_string_size(tips[i][1], HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
		draw_string(font, Vector2(tip_x + tip_width - key_size.x - 14, ty), tips[i][1], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.6, 1.0, 0.9))

	# Bottom hint
	var hint = "CLICK TO SELECT"
	var hint_size = font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_string(font, Vector2(screen.x / 2 - hint_size.x / 2, screen.y - 30), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.5, 0.4, 0.7, 0.7))

func _input(event):
	if event is InputEventMouseMotion:
		var positions = _get_card_positions()
		hovered = -1
		for i in range(3):
			var pos = positions[i]
			var rect = Rect2(pos.x, pos.y, card_width, card_height)
			if rect.has_point(event.position):
				hovered = i

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var positions = _get_card_positions()
		for i in range(3):
			var pos = positions[i]
			var rect = Rect2(pos.x, pos.y, card_width, card_height)
			if rect.has_point(event.position):
				selected = i
				emit_signal("character_selected", i)
