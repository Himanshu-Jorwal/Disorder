extends CanvasLayer

@onready var panel = $Panel
@onready var option1 = $Panel/Option1
@onready var option2 = $Panel/Option2
@onready var option3 = $Panel/Option3

var upgrades = [
	{"name": "Damage +25%", "type": "damage", "value": 0.25},
	{"name": "Fire Rate +25%", "type": "fire_rate", "value": 0.25},
	{"name": "Move Speed +20%", "type": "speed", "value": 0.20},
	{"name": "Max HP +20", "type": "hp", "value": 20},
]

var player = null
var offered = []

const PANEL_SIZE = Vector2(400, 300)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var screen = get_viewport().get_visible_rect().size
	panel.size = PANEL_SIZE
	panel.position = (Vector2(screen) - PANEL_SIZE) / 2
	
	option1.position = Vector2(50, 80)
	option1.size = Vector2(300, 50)
	
	option2.position = Vector2(50, 150)
	option2.size = Vector2(300, 50)
	
	option3.position = Vector2(50, 220)
	option3.size = Vector2(300, 50)
	
	option1.pressed.connect(_on_option_pressed.bind(0))
	option2.pressed.connect(_on_option_pressed.bind(1))
	option3.pressed.connect(_on_option_pressed.bind(2))
	visible = false

func show_upgrades(p):
	player = p
	offered = []
	var pool = upgrades.duplicate()
	pool.shuffle()
	offered = pool.slice(0, 3)
	option1.text = offered[0].name
	option2.text = offered[1].name
	option3.text = offered[2].name
	visible = true
	get_tree().paused = true

func _on_option_pressed(index):
	apply_upgrade(offered[index])
	visible = false
	get_tree().paused = false

func apply_upgrade(upgrade):
	match upgrade.type:
		"damage":
			player.damage_multiplier += upgrade.value
		"fire_rate":
			player.fire_rate_multiplier += upgrade.value
		"speed":
			player.speed_multiplier += upgrade.value
		"hp":
			player.max_hp += upgrade.value
			player.hp += upgrade.value
