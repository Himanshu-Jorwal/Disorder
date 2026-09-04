extends Node2D

var stars = []
const STAR_COUNT = 200

var time = 0.0
var current_bg_color = Color(0.02, 0.02, 0.05)
var target_bg_color = Color(0.02, 0.02, 0.05)

# Subtle base tint per moon phase — index matches MoonPhaseManager phases
const PHASE_TINTS = [
	Color(0.02, 0.02, 0.05),  # 0 CRESCENT — baseline
	Color(0.03, 0.03, 0.06),  # 1 HALF — slightly brighter
	Color(0.05, 0.045, 0.03), # 2 FULL — warm gold undertone
	Color(0.06, 0.02, 0.02),  # 3 BLOOD — red undertone
	Color(0.02, 0.03, 0.07),  # 4 BLUE — cool blue undertone
	Color(0.01, 0.01, 0.02),  # 5 NEW — near black
]

func _ready():
	randomize()

	for i in range(STAR_COUNT):
		var size = randf_range(1.0, 3.0)
		# Closer (bigger) stars tend brighter, distant (smaller) ones dimmer
		var depth_brightness = lerp(0.35, 1.0, (size - 1.0) / 2.0)
		var jitter = randf_range(-0.15, 0.15)

		var tint_roll = randf()
		var tint = Color(1, 1, 1)
		if tint_roll < 0.15:
			tint = Color(0.75, 0.82, 1.0)   # pale blue
		elif tint_roll < 0.25:
			tint = Color(1.0, 0.9, 0.75)    # warm white

		stars.append({
			"pos": Vector2(randf_range(-2000, 2000), randf_range(-2000, 2000)),
			"size": size,
			"brightness": clamp(depth_brightness + jitter, 0.15, 1.0),
			"tint": tint,
			"twinkle_speed": randf_range(0.5, 2.0),
			"twinkle_offset": randf_range(0.0, TAU),
		})

func set_phase(phase):
	if phase >= 0 and phase < PHASE_TINTS.size():
		target_bg_color = PHASE_TINTS[phase]

func _process(delta):
	time += delta
	current_bg_color = current_bg_color.lerp(target_bg_color, delta * 1.5)
	queue_redraw()

func _draw():
	# Deep space background — smoothly shifts tone with the current moon phase
	draw_rect(Rect2(-4000, -4000, 8000, 8000), current_bg_color)

	# Twinkling stars
	for star in stars:
		var twinkle = 0.75 + 0.25 * sin(time * star.twinkle_speed + star.twinkle_offset)
		var b = star.brightness * twinkle
		var col = Color(star.tint.r, star.tint.g, star.tint.b, b)
		draw_circle(star.pos, star.size, col)
