extends CharacterBody2D

const BASE_SPEED = 200.0
const BASE_FIRE_RATE = 0.2
const BASE_DAMAGE = 1

var speed_multiplier = 1.0
var fire_rate_multiplier = 1.0
var damage_multiplier = 1.0

var time_since_last_shot = 0.0
var bullet_scene = preload("res://Scenes/Game/bullet.tscn")
var hp = 5
var xp = 0
var level = 1
var xp_to_next_level = 50
var score = 0
var time_alive = 0.0

var upgrade_menu = null

func _draw():
	# Outer glow layers
	draw_circle(Vector2.ZERO, 28, Color(1, 1, 1, 0.03))
	draw_circle(Vector2.ZERO, 24, Color(1, 1, 1, 0.06))
	draw_circle(Vector2.ZERO, 20, Color(1, 1, 1, 0.1))
	# Core
	draw_circle(Vector2.ZERO, 16, Color(1, 1, 1, 1.0))
	# Inner bright spot
	draw_circle(Vector2.ZERO, 8, Color(1, 1, 1, 1.0))

func _ready():
	add_to_group("player")

func _physics_process(delta):
	time_alive += delta
	score = int(time_alive * 10) + (level * 100)

	var direction = Vector2.ZERO
	if Input.is_key_pressed(KEY_D): direction.x += 1
	if Input.is_key_pressed(KEY_A): direction.x -= 1
	if Input.is_key_pressed(KEY_S): direction.y += 1
	if Input.is_key_pressed(KEY_W): direction.y -= 1
	direction = direction.normalized()
	velocity = direction * BASE_SPEED * speed_multiplier
	move_and_slide()

	time_since_last_shot += delta
	var current_fire_rate = BASE_FIRE_RATE / fire_rate_multiplier
	if time_since_last_shot >= current_fire_rate:
		shoot()
		time_since_last_shot = 0.0

func shoot():
	var bullet = bullet_scene.instantiate()
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	var dmg = int(BASE_DAMAGE * damage_multiplier)
	get_parent().add_child(bullet)
	bullet.setup(global_position, dir, dmg)

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	get_tree().paused = true
	var game_over = get_parent().get_node("GameOver")
	game_over.show_game_over(score)

func gain_xp(amount):
	xp += amount
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	xp = 0
	xp_to_next_level = int(xp_to_next_level * 1.4)
	if upgrade_menu:
		upgrade_menu.show_upgrades(self)
