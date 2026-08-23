extends CharacterBody2D

const BASE_SPEED = 80.0
const XP_VALUE = 10
const CONTACT_DAMAGE = 20

var player = null
var hp = 30
var max_hp = 30
var damage_cooldown = 0.0
var speed = BASE_SPEED
var xp_multiplier = 1.0
var is_stealthed = false
var current_phase = 0
var difficulty = 1.0

func _ready():
	add_to_group("enemies")

func _draw():
	var col = get_phase_color()
	var glow = Color(col.r, col.g, col.b, 0.15)

	if is_stealthed:
		var distance = global_position.distance_to(player.global_position) if player else 999
		var alpha = 0.15 if distance > 150 else 0.85
		col = Color(col.r, col.g, col.b, alpha)
		glow = Color(col.r, col.g, col.b, alpha * 0.3)

	draw_circle(Vector2.ZERO, 26, Color(glow.r, glow.g, glow.b, 0.05))
	draw_circle(Vector2.ZERO, 22, Color(glow.r, glow.g, glow.b, 0.1))
	draw_circle(Vector2.ZERO, 18, Color(glow.r, glow.g, glow.b, 0.15))
	draw_circle(Vector2.ZERO, 16, col)

	var bar_width = 32.0
	var bar_height = 4.0
	var bar_x = -bar_width / 2
	var bar_y = -28.0
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(bar_x, bar_y, bar_width * (float(hp) / float(max_hp)), bar_height), Color.GREEN)

func _physics_process(delta):
	if player == null:
		return
	queue_redraw()
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	damage_cooldown -= delta
	var distance = global_position.distance_to(player.global_position)
	if distance < 32 and damage_cooldown <= 0:
		player.take_damage(CONTACT_DAMAGE)
		damage_cooldown = 1.0

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	player.gain_xp(int(XP_VALUE * xp_multiplier))
	queue_free()

func get_phase_color():
	match current_phase:
		0: return Color(0.8, 0.4, 1.0)
		1: return Color(0.4, 0.8, 1.0)
		2: return Color(1.0, 0.8, 0.2)
		3: return Color(1.0, 0.2, 0.2)
		4: return Color(0.2, 0.4, 1.0)
		5: return Color(0.5, 0.5, 0.6)
	return Color.RED

func apply_difficulty(d):
	difficulty = d
	speed = speed * (1.0 + (difficulty - 1.0) * 0.2)
	max_hp = int(max_hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp

func apply_phase(phase):
	current_phase = phase
	match phase:
		0:
			speed = BASE_SPEED
			hp = 30
			max_hp = 30
			xp_multiplier = 1.0
			is_stealthed = false
		1:
			speed = BASE_SPEED * 1.3
			hp = 30
			max_hp = 30
			xp_multiplier = 1.0
			is_stealthed = false
		2:
			speed = BASE_SPEED
			hp = 60
			max_hp = 60
			xp_multiplier = 1.2
			is_stealthed = false
		3:
			speed = BASE_SPEED * 1.5
			hp = 80
			max_hp = 80
			xp_multiplier = 1.5
			is_stealthed = false
		4:
			speed = BASE_SPEED * 0.6
			hp = 20
			max_hp = 20
			xp_multiplier = 2.0
			is_stealthed = false
		5:
			speed = BASE_SPEED
			hp = 40
			max_hp = 40
			xp_multiplier = 1.2
			is_stealthed = true
