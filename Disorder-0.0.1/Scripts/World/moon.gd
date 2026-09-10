extends Node2D

var current_phase = 0
var time = 0.0
var moon_sprite = null

var moon_colors = {
	0: Color(0.9, 0.9, 1.0),
	1: Color(0.95, 0.95, 0.8),
	2: Color(1.0, 1.0, 0.7),
	3: Color(1.0, 0.2, 0.2),
	4: Color(0.4, 0.6, 1.0),
	5: Color(0.05, 0.05, 0.1)
}

var phase_names = {
	0: "Crescent Moon",
	1: "Half Moon",
	2: "Full Moon",
	3: "Blood Moon",
	4: "Blue Moon",
	5: "New Moon"
}

var phase_textures = {
	0: "res://Assets/World/Moon/moon_crescent.png",
	1: "res://Assets/World/Moon/moon_half.png",
	2: "res://Assets/World/Moon/moon_full.png",
	3: "res://Assets/World/Moon/moon_blood.png",
	4: "res://Assets/World/Moon/moon_blue.png",
	5: "res://Assets/World/Moon/moon_new.png",
}

const MOON_RADIUS = 34.5
const TEXTURE_DISPLAY_HEIGHT = 69.0

func _ready():
	var screen = get_viewport().get_visible_rect().size
	position = Vector2(screen.x / 2, 60)

	moon_sprite = Sprite2D.new()
	moon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(moon_sprite)
	_update_sprite_texture()

func _process(delta):
	time += delta
	queue_redraw()

func _update_sprite_texture():
	var path = phase_textures.get(current_phase, "")
	if path == "" or not ResourceLoader.exists(path):
		moon_sprite.texture = null
		return
	var tex = load(path)
	moon_sprite.texture = tex
	var tex_size = tex.get_size()
	if tex_size.y > 0:
		var s = TEXTURE_DISPLAY_HEIGHT / tex_size.y
		moon_sprite.scale = Vector2(s, s)

func _draw():
	var col = moon_colors[current_phase]
	var pulse = (sin(time * 1.5) + 1.0) / 2.0
	var glow_alpha = lerp(0.08, 0.18, pulse)

	draw_circle(Vector2.ZERO, MOON_RADIUS + 20, Color(col.r, col.g, col.b, glow_alpha * 0.4))
	draw_circle(Vector2.ZERO, MOON_RADIUS + 12, Color(col.r, col.g, col.b, glow_alpha * 0.6))
	draw_circle(Vector2.ZERO, MOON_RADIUS + 6, Color(col.r, col.g, col.b, glow_alpha))

	var font = ThemeDB.fallback_font
	var text = phase_names[current_phase]
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	draw_string(font, Vector2(-text_size.x / 2, MOON_RADIUS + 22), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col)

func set_phase(phase):
	current_phase = phase
	_update_sprite_texture()
	queue_redraw()
