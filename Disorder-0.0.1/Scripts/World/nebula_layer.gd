extends Node2D

var nebulae = []
const NEBULA_COUNT = 32
const ARENA_HALF_WIDTH = 1500.0
const ARENA_HALF_HEIGHT = 1000.0
const BORDER_MARGIN = 150.0

func _ready():
	randomize()

	# Two layers: an inner ring hugging the border for continuous coverage,
	# and an outer scatter at varying depth so it doesn't look like a flat ring
	var angle_step = TAU / NEBULA_COUNT
	for i in range(NEBULA_COUNT):
		var angle = i * angle_step + randf_range(-angle_step * 0.4, angle_step * 0.4)
		var dir = Vector2(cos(angle), sin(angle))
		var border_t = _border_distance_along_angle(dir)
		var depth = randf_range(0.0, 900.0)
		var pos = dir * (border_t + BORDER_MARGIN + depth)
		nebulae.append(_make_nebula(pos))

	# Static content — draw exactly once and never again. No _process, no per-frame cost.
	queue_redraw()

func _border_distance_along_angle(dir):
	var tx = INF
	var ty = INF
	if abs(dir.x) > 0.0001:
		tx = ARENA_HALF_WIDTH / abs(dir.x)
	if abs(dir.y) > 0.0001:
		ty = ARENA_HALF_HEIGHT / abs(dir.y)
	return min(tx, ty)

func _make_nebula(pos):
	var dist_to_border = _distance_to_border(pos)
	# Hard cap so the nebula's outer edge can never cross the true wall, no matter its size
	var max_reach = max(60.0, dist_to_border - 60.0)
	var base_radius = min(randf_range(500.0, 1000.0), max_reach)

	var tint_roll = randf()
	var col = Color(0.3, 0.15, 0.5)
	if tint_roll < 0.25:
		col = Color(0.1, 0.25, 0.45)   # deep teal-blue
	elif tint_roll < 0.5:
		col = Color(0.45, 0.15, 0.35)  # muted rose
	elif tint_roll < 0.75:
		col = Color(0.15, 0.15, 0.5)   # indigo

	# Cluster of overlapping offset blobs instead of one perfect circle, for an organic cloud shape
	var blobs = []
	var blob_count = randi_range(4, 6)
	for j in range(blob_count):
		var offset_mag = randf_range(0.0, base_radius * 0.35)
		var offset_ang = randf() * TAU
		var offset = Vector2(cos(offset_ang), sin(offset_ang)) * offset_mag
		var blob_radius = randf_range(base_radius * 0.45, base_radius * 0.75)
		# Keep offset + blob radius within base_radius, so max_reach still holds for every blob
		blob_radius = min(blob_radius, base_radius - offset_mag)
		blobs.append({"offset": offset, "radius": blob_radius})

	return {"pos": pos, "color": col, "blobs": blobs}

func _distance_to_border(pos):
	var dx = max(abs(pos.x) - ARENA_HALF_WIDTH, 0.0)
	var dy = max(abs(pos.y) - ARENA_HALF_HEIGHT, 0.0)
	return sqrt(dx * dx + dy * dy)

func _draw():
	for neb in nebulae:
		for blob in neb.blobs:
			var bpos = neb.pos + blob.offset
			draw_circle(bpos, blob.radius, Color(neb.color.r, neb.color.g, neb.color.b, 0.06))
			draw_circle(bpos, blob.radius * 0.6, Color(neb.color.r, neb.color.g, neb.color.b, 0.09))
			draw_circle(bpos, blob.radius * 0.3, Color(neb.color.r, neb.color.g, neb.color.b, 0.12))
