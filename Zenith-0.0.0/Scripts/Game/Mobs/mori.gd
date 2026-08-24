extends CharacterBody2D

const XP_VALUE = 20
const CONTACT_DAMAGE = 20

var size_level = 1
var player = null
var hp = 60
var max_hp = 60
var damage_cooldown = 0.0
var current_phase = 0
var difficulty = 1.0
var time = 0.0
var grow_timer = 0.0

# Size 0 = tiny blob fragment, 1 = default, 2 = large
const SIZE_STATS = {
	0: {"radius": 6.0,  "hp": 1,   "speed": 150.0, "bar_width": 12.0, "bar_y": -12.0, "grow_time": 0.0},
	1: {"radius": 16.0, "hp": 60,  "speed": 85.0,  "bar_width": 32.0, "bar_y": -28.0, "grow_time": 25.0},
	2: {"radius": 36.0, "hp": 150, "speed": 45.0,  "bar_width": 60.0, "bar_y": -48.0, "grow_time": 0.0},
}

func _ready():
	add_to_group("enemies")
	_apply_size_stats()

func _apply_size_stats():
	var stats = SIZE_STATS[size_level]
	max_hp = int(stats.hp * (1.0 + (difficulty - 1.0) * 0.3)) if difficulty > 1.0 else stats.hp
	hp = max_hp
	grow_timer = 0.0
	# Update collision shape to match visual size
	var shape = $CollisionShape2D.shape as CircleShape2D
	if shape:
		shape.radius = stats.radius

func _draw():
	var stats = SIZE_STATS[size_level]
	var radius = stats.radius
	var col = Color(0.6, 0.1, 0.8)

	if size_level == 0:
		draw_circle(Vector2.ZERO, radius, col)
		draw_circle(Vector2.ZERO, radius * 0.4, Color(1, 1, 1, 0.5))
		return

	var points = PackedVector2Array()
	var steps = 16
	for i in range(steps):
		var angle = TAU * i / steps
		var wobble = sin(time * 3.0 + angle * 3.0) * (radius * 0.12)
		var r = radius + wobble
		points.append(Vector2(cos(angle), sin(angle)) * r)

	draw_circle(Vector2.ZERO, radius + 8, Color(col.r, col.g, col.b, 0.1))
	draw_colored_polygon(points, col)
	draw_circle(Vector2.ZERO, radius * 0.35, Color(1, 1, 1, 0.3))

	# Growth ring
	if size_level == 1:
		var grow_max = SIZE_STATS[1].grow_time
		if grow_max > 0:
			var grow_progress = grow_timer / grow_max
			draw_arc(Vector2.ZERO, radius + 6, -PI / 2, -PI / 2 + TAU * grow_progress, 32, Color(1.0, 0.6, 0.0, 0.7), 2.5)

	# HP bar
	var bar_width = stats.bar_width
	var bar_height = 4.0
	var bar_y = stats.bar_y
	draw_rect(Rect2(-bar_width / 2, bar_y, bar_width, bar_height), Color.BLACK)
	draw_rect(Rect2(-bar_width / 2, bar_y, bar_width * (float(hp) / float(max_hp)), bar_height), col)

func _physics_process(delta):
	if player == null:
		return
	time += delta
	queue_redraw()

	var grow_time = SIZE_STATS[size_level].grow_time
	if size_level == 1 and grow_time > 0:
		grow_timer += delta
		if grow_timer >= grow_time:
			_grow()

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SIZE_STATS[size_level].speed
	move_and_slide()

	damage_cooldown -= delta
	var dist = global_position.distance_to(player.global_position)
	if dist < SIZE_STATS[size_level].radius + 16 and damage_cooldown <= 0:
		player.take_damage(CONTACT_DAMAGE)
		damage_cooldown = 1.0

func _grow():
	size_level = 2
	_apply_size_stats()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	player.gain_xp(XP_VALUE * (size_level + 1))
	_spawn_splits()
	queue_free()

func _spawn_splits():
	match size_level:
		2:
			_spawn_mori(1, 2)
		1:
			_spawn_mori(0, 3)
		0:
			pass

func _spawn_mori(spawn_size, count):
	for i in range(count):
		var mori = load("res://Scenes/Game/Mobs/mori.tscn").instantiate()
		mori.size_level = spawn_size
		mori.player = player
		mori.difficulty = difficulty
		mori.position = global_position + Vector2(randf_range(-25, 25), randf_range(-25, 25))
		mori.apply_phase(current_phase)
		get_parent().add_child(mori)

func apply_phase(phase):
	current_phase = phase

func apply_difficulty(d):
	difficulty = d
	max_hp = int(SIZE_STATS[size_level].hp * (1.0 + (difficulty - 1.0) * 0.3))
	hp = max_hp
