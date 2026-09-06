extends Node2D

var start = Vector2.ZERO
var end = Vector2.ZERO
var color = Color(0.2, 0.9, 0.75)
var elapsed = 0.0
var lifetime = 0.6
var time = 0.0

func _process(delta):
	elapsed += delta
	time += delta
	queue_redraw()
	if elapsed >= lifetime:
		queue_free()

func _draw():
	var t = elapsed / lifetime
	var alpha = 1.0 - t
	var s = start - global_position
	var e = end - global_position
	var dir = (e - s).normalized()
	var perp = dir.rotated(PI / 2)
	var length = s.distance_to(e)

	# Void darkness — black center strip
	draw_line(s, e, Color(0.0, 0.0, 0.0, alpha * 0.95), lerp(14.0, 3.0, t))

	# Crackling edges — bright cyan/white
	var segments = 20
	for i in range(segments - 1):
		var t0 = float(i) / segments
		var t1 = float(i + 1) / segments
		var p0 = s.lerp(e, t0)
		var p1 = s.lerp(e, t1)
		# Top edge crack
		var crack0_top = p0 + perp * (lerp(10.0, 3.0, t) + sin(t0 * TAU * 5.0 + elapsed * 20.0) * lerp(4.0, 1.0, t))
		var crack1_top = p1 + perp * (lerp(10.0, 3.0, t) + sin(t1 * TAU * 5.0 + elapsed * 20.0) * lerp(4.0, 1.0, t))
		# Bottom edge crack
		var crack0_bot = p0 - perp * (lerp(10.0, 3.0, t) + sin(t0 * TAU * 5.0 + elapsed * 20.0 + PI) * lerp(4.0, 1.0, t))
		var crack1_bot = p1 - perp * (lerp(10.0, 3.0, t) + sin(t1 * TAU * 5.0 + elapsed * 20.0 + PI) * lerp(4.0, 1.0, t))
		# Outer void glow, tinted to Daggers' color
		draw_line(crack0_top, crack1_top, Color(color.r, color.g, color.b, alpha * 0.2), 6.0)
		draw_line(crack0_bot, crack1_bot, Color(color.r, color.g, color.b, alpha * 0.2), 6.0)
		# Bright white crack
		draw_line(crack0_top, crack1_top, Color(0.8, 0.95, 1.0, alpha * 0.8), 1.5)
		draw_line(crack0_bot, crack1_bot, Color(0.8, 0.95, 1.0, alpha * 0.8), 1.5)

	# Void glow behind everything, tinted to Daggers' color
	draw_line(s, e, Color(color.r, color.g, color.b, alpha * 0.12), lerp(30.0, 8.0, t))
	draw_line(s, e, Color(color.r, color.g, color.b, alpha * 0.2), lerp(20.0, 5.0, t))

	# Sparks at impact points
	for i in range(6):
		var seg_t = float(i) / 6.0
		var seg_pos = s.lerp(e, seg_t)
		var spark_offset = perp * sin(seg_t * TAU * 4.0 + elapsed * 25.0) * lerp(8.0, 2.0, t)
		draw_circle(seg_pos + spark_offset, lerp(3.0, 0.5, t), Color(1, 1, 1, alpha * 0.9))
		draw_circle(seg_pos - spark_offset, lerp(3.0, 0.5, t), Color(0.7, 0.9, 1.0, alpha * 0.7))
		
