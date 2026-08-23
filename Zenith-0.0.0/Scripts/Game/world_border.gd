extends StaticBody2D

const ARENA_WIDTH = 3000.0
const ARENA_HEIGHT = 2000.0
const WALL_THICKNESS = 50.0

const BASE_COLOR = Color(0.4, 0.1, 0.6, 0.8)
const GLOW_COLOR = Color(0.5, 0.1, 0.8, 0.3)

const SEGMENT_COUNT = 100
const PROXIMITY_THRESHOLD = 250.0

var time = 0.0
var player = null
var ripples = []

class Ripple:
	var wall = 0
	var origin = 0.0
	var progress = 0.0
	var speed = 0.5
	var alpha = 1.0

func _ready():
	_build_walls()

func _build_walls():
	_add_wall(Vector2(0, -ARENA_HEIGHT / 2), Vector2(ARENA_WIDTH + WALL_THICKNESS, WALL_THICKNESS))
	_add_wall(Vector2(0, ARENA_HEIGHT / 2), Vector2(ARENA_WIDTH + WALL_THICKNESS, WALL_THICKNESS))
	_add_wall(Vector2(-ARENA_WIDTH / 2, 0), Vector2(WALL_THICKNESS, ARENA_HEIGHT + WALL_THICKNESS))
	_add_wall(Vector2(ARENA_WIDTH / 2, 0), Vector2(WALL_THICKNESS, ARENA_HEIGHT + WALL_THICKNESS))

func _add_wall(pos, size):
	var body = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.position = pos
	body.add_child(shape)
	add_child(body)

func _get_wall_points():
	var hw = ARENA_WIDTH / 2
	var hh = ARENA_HEIGHT / 2
	return [
		[Vector2(-hw, -hh), Vector2(hw, -hh)],
		[Vector2(hw, -hh), Vector2(hw, hh)],
		[Vector2(hw, hh), Vector2(-hw, hh)],
		[Vector2(-hw, hh), Vector2(-hw, -hh)]
	]

func _closest_point_on_segment(point, a, b):
	var ab = b - a
	var t = clamp((point - a).dot(ab) / ab.dot(ab), 0.0, 1.0)
	return a + ab * t

func _get_point_proximity(world_pos):
	if player == null:
		return 1.0
	var dist = player.global_position.distance_to(world_pos)
	return clamp(dist / PROXIMITY_THRESHOLD, 0.0, 1.0)

func _process(delta):
	time += delta

	if fmod(time, 3.0) < delta:
		for w in range(4):
			var r = Ripple.new()
			r.wall = w
			r.origin = 0.0
			r.progress = 0.0
			ripples.append(r)

	if player != null:
		var walls = _get_wall_points()
		for w in range(4):
			var a = walls[w][0]
			var b = walls[w][1]
			var closest = _closest_point_on_segment(player.global_position, a, b)
			var dist = player.global_position.distance_to(closest)
			if dist < PROXIMITY_THRESHOLD * 0.5 and randf() < 0.04:
				var r = Ripple.new()
				r.wall = w
				var ab = b - a
				r.origin = clamp((closest - a).dot(ab) / ab.dot(ab), 0.0, 1.0)
				r.progress = 0.0
				r.speed = 0.6
				ripples.append(r)

	for r in ripples:
		r.progress += r.speed * delta
		r.alpha = 1.0 - r.progress
	ripples = ripples.filter(func(r): return r.progress < 1.0)

	queue_redraw()

func _get_heat_colors(prox):
	if prox > 0.6:
		return [
			Color(0.4, 0.1, 0.6, 0.12),   # outermost glow
			Color(0.5, 0.1, 0.8, 0.25),   # mid glow
			Color(0.55, 0.1, 0.85, 0.85), # core
			Color(1.0, 1.0, 1.0, 0.45)    # white center
		]
	else:
		var heat = 1.0 - prox / 0.6
		return [
			# Outer — deep red glow
			Color(0.8, 0.0, 0.0, 0.15 + heat * 0.1),
			# Mid — red to orange
			Color(1.0, 0.08 + heat * 0.15, 0.0, 0.35 + heat * 0.2),
			# Core — orange to yellow
			Color(1.0, 0.35 + heat * 0.35, 0.0, 0.9),
			# Center — yellow to white
			Color(1.0, 0.7 + heat * 0.3, heat * 0.6, 0.9 + heat * 0.1)
		]

func _draw():
	var walls = _get_wall_points()
	var hw = ARENA_WIDTH / 2
	var hh = ARENA_HEIGHT / 2
	var corners = [
		Vector2(-hw, -hh),
		Vector2(hw, -hh),
		Vector2(hw, hh),
		Vector2(-hw, hh)
	]

	for w in range(4):
		var a = walls[w][0]
		var b = walls[w][1]
		var perp = (b - a).normalized().rotated(PI / 2)

		for s in range(SEGMENT_COUNT):
			var t0 = float(s) / SEGMENT_COUNT
			var t1 = float(s + 1) / SEGMENT_COUNT
			var p0 = a.lerp(b, t0)
			var p1 = a.lerp(b, t1)
			var mid = (p0 + p1) / 2.0

			var prox = _get_point_proximity(mid)
			var colors = _get_heat_colors(prox)

			# Extremely high frequency, very tight amplitude — cosmic static feel
			var n0 = sin(time * 60.0 + t0 * TAU * 20.0) * 1.2
			var n1 = sin(time * 85.0 + t0 * TAU * 28.0 + 1.1) * 0.8
			var n2 = sin(time * 43.0 + t0 * TAU * 15.0 + 2.3) * 0.6
			var n3 = sin(time * 110.0 + t0 * TAU * 35.0 + 0.7) * 0.4
			var n4 = sin(time * 140.0 + t0 * TAU * 45.0 + 1.8) * 0.25
			var wave0 = n0 + n1 + n2 + n3 + n4

			var n0b = sin(time * 60.0 + t1 * TAU * 20.0) * 1.2
			var n1b = sin(time * 85.0 + t1 * TAU * 28.0 + 1.1) * 0.8
			var n2b = sin(time * 43.0 + t1 * TAU * 15.0 + 2.3) * 0.6
			var n3b = sin(time * 110.0 + t1 * TAU * 35.0 + 0.7) * 0.4
			var n4b = sin(time * 140.0 + t1 * TAU * 45.0 + 1.8) * 0.25
			var wave1 = n0b + n1b + n2b + n3b + n4b

			var wp0 = p0 + perp * wave0
			var wp1 = p1 + perp * wave1

			var intensity = (sin(time * 15.0 + t0 * TAU * 8.0) + 1.0) / 2.0
			var line_width = lerp(1.2, 2.8, intensity)

			draw_line(wp0, wp1, colors[0], line_width + 10)
			draw_line(wp0, wp1, colors[1], line_width + 4)
			draw_line(wp0, wp1, colors[2], line_width)
			draw_line(wp0, wp1, colors[3], line_width * 0.3)

	for r in ripples:
		var wall = walls[r.wall]
		var a = wall[0]
		var b = wall[1]
		var spread = r.progress * 0.35
		var pos_fwd = a.lerp(b, clamp(r.origin + spread, 0.0, 1.0))
		var pos_bwd = a.lerp(b, clamp(r.origin - spread, 0.0, 1.0))
		var mid = a.lerp(b, r.origin)
		var prox = _get_point_proximity(mid)
		var colors = _get_heat_colors(prox)
		var size = lerp(8.0, 2.0, r.progress)
		draw_circle(pos_fwd, size, Color(colors[1].r, colors[1].g, colors[1].b, r.alpha * 0.7))
		draw_circle(pos_bwd, size, Color(colors[1].r, colors[1].g, colors[1].b, r.alpha * 0.7))

	for i in range(4):
		_draw_mechanical_corner(corners[i], i)

func _draw_mechanical_corner(pos, index):
	var pulse = (sin(time * 2.0 + index * PI / 2) + 1.0) / 2.0
	var arm_length = 80.0
	var arm_thickness = 12.0
	var plate_size = 26.0

	var dir_h = Vector2.RIGHT if index == 0 or index == 3 else Vector2.LEFT
	var dir_v = Vector2.DOWN if index == 0 or index == 1 else Vector2.UP

	var h_end = pos + dir_h * arm_length
	var v_end = pos + dir_v * arm_length

	draw_line(pos, h_end, Color(0.0, 0.0, 0.0, 0.8), arm_thickness + 6)
	draw_line(pos, v_end, Color(0.0, 0.0, 0.0, 0.8), arm_thickness + 6)
	draw_line(pos, h_end, Color(0.06, 0.04, 0.08, 1.0), arm_thickness + 2)
	draw_line(pos, v_end, Color(0.06, 0.04, 0.08, 1.0), arm_thickness + 2)
	draw_line(pos, h_end, Color(0.1, 0.08, 0.14, 1.0), arm_thickness)
	draw_line(pos, v_end, Color(0.1, 0.08, 0.14, 1.0), arm_thickness)
	draw_line(pos, h_end, Color(0.3, 0.25, 0.45, 0.8), 2.0)
	draw_line(pos, v_end, Color(0.3, 0.25, 0.45, 0.8), 2.0)
	draw_line(pos, h_end, Color(0.1, 0.6, 0.5, 0.3 + pulse * 0.25), 1.2)
	draw_line(pos, v_end, Color(0.1, 0.6, 0.5, 0.3 + pulse * 0.25), 1.2)

	var perp_h = dir_h.rotated(PI / 2)
	var perp_v = dir_v.rotated(PI / 2)
	for i in range(1, 5):
		var t = float(i) / 5.0
		var h_mark = pos + dir_h * arm_length * t
		var v_mark = pos + dir_v * arm_length * t
		draw_line(h_mark - perp_h * (arm_thickness / 2 + 1), h_mark + perp_h * (arm_thickness / 2 + 1), Color(0.0, 0.0, 0.0, 0.9), 2.5)
		draw_line(v_mark - perp_v * (arm_thickness / 2 + 1), v_mark + perp_v * (arm_thickness / 2 + 1), Color(0.0, 0.0, 0.0, 0.9), 2.5)
		draw_line(h_mark - perp_h * (arm_thickness / 2 - 1), h_mark + perp_h * (arm_thickness / 2 - 1), Color(0.25, 0.2, 0.35, 0.5), 1.0)
		draw_line(v_mark - perp_v * (arm_thickness / 2 - 1), v_mark + perp_v * (arm_thickness / 2 - 1), Color(0.25, 0.2, 0.35, 0.5), 1.0)
		draw_circle(h_mark + perp_h * (arm_thickness / 2 - 3), 2.0, Color(0.0, 0.0, 0.0, 1.0))
		draw_circle(h_mark + perp_h * (arm_thickness / 2 - 3), 1.2, Color(0.4, 0.35, 0.5, 1.0))
		draw_circle(h_mark - perp_h * (arm_thickness / 2 - 3), 2.0, Color(0.0, 0.0, 0.0, 1.0))
		draw_circle(h_mark - perp_h * (arm_thickness / 2 - 3), 1.2, Color(0.4, 0.35, 0.5, 1.0))
		draw_circle(v_mark + perp_v * (arm_thickness / 2 - 3), 2.0, Color(0.0, 0.0, 0.0, 1.0))
		draw_circle(v_mark + perp_v * (arm_thickness / 2 - 3), 1.2, Color(0.4, 0.35, 0.5, 1.0))
		draw_circle(v_mark - perp_v * (arm_thickness / 2 - 3), 2.0, Color(0.0, 0.0, 0.0, 1.0))
		draw_circle(v_mark - perp_v * (arm_thickness / 2 - 3), 1.2, Color(0.4, 0.35, 0.5, 1.0))

	var half = plate_size / 2
	draw_rect(Rect2(pos - Vector2(half + 4, half + 4), Vector2(plate_size + 8, plate_size + 8)), Color(0.0, 0.0, 0.0, 0.9))
	draw_rect(Rect2(pos - Vector2(half + 1, half + 1), Vector2(plate_size + 2, plate_size + 2)), Color(0.08, 0.06, 0.12, 1.0))
	draw_rect(Rect2(pos - Vector2(half, half), Vector2(plate_size, plate_size)), Color(0.1, 0.08, 0.16, 1.0))
	draw_rect(Rect2(pos - Vector2(half - 4, half - 4), Vector2(plate_size - 8, plate_size - 8)), Color(0.14, 0.11, 0.22, 1.0))
	draw_rect(Rect2(pos - Vector2(half, half), Vector2(plate_size, plate_size)), Color(0.15, 0.5, 0.4, 0.8), false, 1.5)
	draw_rect(Rect2(pos - Vector2(half - 4, half - 4), Vector2(plate_size - 8, plate_size - 8)), Color(0.1, 0.35, 0.3, 0.5), false, 1.0)

	var bolt_offsets = [
		Vector2(-half + 5, -half + 5),
		Vector2(half - 5, -half + 5),
		Vector2(-half + 5, half - 5),
		Vector2(half - 5, half - 5)
	]
	for bv in bolt_offsets:
		draw_circle(pos + bv, 3.0, Color(0.0, 0.0, 0.0, 1.0))
		draw_circle(pos + bv, 2.0, Color(0.3, 0.28, 0.4, 1.0))
		draw_circle(pos + bv, 0.8, Color(0.55, 0.5, 0.65, 0.8))

	draw_line(pos + Vector2(-half + 4, -half + 4), pos + Vector2(-half + 10, -half + 4), Color(0.08, 0.06, 0.12, 1.0), 1.5)
	draw_line(pos + Vector2(-half + 4, -half + 4), pos + Vector2(-half + 4, -half + 10), Color(0.08, 0.06, 0.12, 1.0), 1.5)
	draw_line(pos + Vector2(half - 4, half - 4), pos + Vector2(half - 10, half - 4), Color(0.08, 0.06, 0.12, 1.0), 1.5)
	draw_line(pos + Vector2(half - 4, half - 4), pos + Vector2(half - 4, half - 10), Color(0.08, 0.06, 0.12, 1.0), 1.5)

	draw_circle(pos, lerp(6.0, 9.0, pulse), Color(0.1, 0.7, 0.55, 0.35))
	draw_circle(pos, lerp(3.5, 5.5, pulse), Color(0.15, 0.85, 0.65, 0.8))
	draw_circle(pos, lerp(1.5, 2.5, pulse), Color(0.6, 1.0, 0.9, 1.0))
