extends Node2D

const RADIUS = 10.0
const GAP = 4.0
const LINE_LENGTH = 6.0
const LINE_WIDTH = 2.0
const CROSS_COLOR = Color(0.9, 0.9, 0.95, 0.9)

# 45-degree diagonal directions, forming an X instead of a +
const DIRECTIONS = [
	Vector2(0.7071, 0.7071),
	Vector2(0.7071, -0.7071),
	Vector2(-0.7071, 0.7071),
	Vector2(-0.7071, -0.7071),
]

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	queue_redraw()

func _draw():
	var pos = get_viewport().get_mouse_position()

	for dir in DIRECTIONS:
		draw_line(pos + dir * GAP, pos + dir * (GAP + LINE_LENGTH), CROSS_COLOR, LINE_WIDTH)

	draw_arc(pos, RADIUS, 0, TAU, 24, CROSS_COLOR, 1.5, true)
	draw_circle(pos, 1.5, CROSS_COLOR)
