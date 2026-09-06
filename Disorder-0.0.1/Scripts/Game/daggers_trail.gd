extends Node2D

var points_left = []
var points_right = []
const MAX_LIFE = 0.35
const MAX_POINTS = 24
var trail_color = Color(0.2, 0.9, 0.75)

func _process(delta):
	_age_points(points_left, delta)
	_age_points(points_right, delta)
	queue_redraw()

func _age_points(arr, delta):
	for p in arr:
		p.life -= delta
	while arr.size() > 0 and arr[0].life <= 0.0:
		arr.pop_front()

func add_point(pos_left, pos_right):
	points_left.append({"pos": pos_left, "life": MAX_LIFE})
	points_right.append({"pos": pos_right, "life": MAX_LIFE})
	if points_left.size() > MAX_POINTS:
		points_left.pop_front()
	if points_right.size() > MAX_POINTS:
		points_right.pop_front()

func _draw_strand(arr):
	if arr.size() < 2:
		return
	for i in range(arr.size() - 1):
		var p0 = arr[i]
		var p1 = arr[i + 1]
		var avg_t = ((p0.life / MAX_LIFE) + (p1.life / MAX_LIFE)) / 2.0
		if avg_t <= 0.0:
			continue
		# Soft outer glow
		draw_line(p0.pos, p1.pos, Color(trail_color.r, trail_color.g, trail_color.b, avg_t * 0.15), lerp(2.0, 10.0, avg_t))
		# Bright core
		draw_line(p0.pos, p1.pos, Color(trail_color.r, trail_color.g, trail_color.b, avg_t * 0.6), lerp(1.0, 3.0, avg_t))

func _draw():
	_draw_strand(points_left)
	_draw_strand(points_right)
