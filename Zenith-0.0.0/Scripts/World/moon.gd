extends Node2D

var current_phase = 0
var time = 0.0

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

const MOON_RADIUS = 30.0
const SEGMENTS = 64

func _ready():
	var screen = get_viewport().get_visible_rect().size
	position = Vector2(screen.x / 2, 60)

func _process(delta):
	time += delta
	queue_redraw()

func _draw():
	var col = moon_colors[current_phase]
	var pulse = (sin(time * 1.5) + 1.0) / 2.0
	var glow_alpha = lerp(0.08, 0.18, pulse)

	# Glow layers
	draw_circle(Vector2.ZERO, MOON_RADIUS + 20, Color(col.r, col.g, col.b, glow_alpha * 0.4))
	draw_circle(Vector2.ZERO, MOON_RADIUS + 12, Color(col.r, col.g, col.b, glow_alpha * 0.6))
	draw_circle(Vector2.ZERO, MOON_RADIUS + 6, Color(col.r, col.g, col.b, glow_alpha))

	match current_phase:
		0: _draw_crescent(col)
		1: _draw_half(col)
		2: _draw_full(col)
		3: _draw_full(col)
		4: _draw_full(col)
		5: _draw_new(col)

	# Phase name
	var font = ThemeDB.fallback_font
	var text = phase_names[current_phase]
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	draw_string(font, Vector2(-text_size.x / 2, MOON_RADIUS + 22), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col)

func _draw_full(col):
	var points = _circle_points(Vector2.ZERO, MOON_RADIUS)
	draw_colored_polygon(points, col)

func _draw_half(col):
	# Left half only using arc points
	var points = PackedVector2Array()
	points.append(Vector2.ZERO)
	for i in range(SEGMENTS + 1):
		var angle = PI / 2 + PI * i / SEGMENTS
		points.append(Vector2(cos(angle), sin(angle)) * MOON_RADIUS)
	draw_colored_polygon(points, col)

func _draw_crescent(col):
	# Outer circle points
	var outer = _circle_points(Vector2.ZERO, MOON_RADIUS)
	draw_colored_polygon(outer, col)
	
	# Inner circle offset to create crescent cutout
	var inner = _circle_points(Vector2(MOON_RADIUS * 0.4, 0), MOON_RADIUS * 0.78)
	draw_colored_polygon(inner, Color(0.02, 0.02, 0.05))

func _draw_new(col):
	# Barely visible dark circle with faint outline
	var points = _circle_points(Vector2.ZERO, MOON_RADIUS)
	draw_colored_polygon(points, Color(col.r, col.g, col.b, 0.1))
	draw_arc(Vector2.ZERO, MOON_RADIUS, 0, TAU, SEGMENTS, Color(col.r, col.g, col.b, 0.3), 1.0)

func _circle_points(center, radius):
	var points = PackedVector2Array()
	for i in range(SEGMENTS):
		var angle = TAU * i / SEGMENTS
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points

func set_phase(phase):
	current_phase = phase
	queue_redraw()
