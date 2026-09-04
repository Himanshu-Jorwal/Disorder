extends CanvasLayer

@onready var draw = $UpgradeDraw

var upgrades = [
	{"name": "Damage +10%", "type": "damage", "value": 0.10},
	{"name": "Fire Rate +10%", "type": "fire_rate", "value": 0.10},
	{"name": "Move Speed +10%", "type": "speed", "value": 0.10},
	{"name": "Heart +1", "type": "hp", "value": 20},
]

var player = null
var offered = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	draw.visible = false
	draw.option_pressed.connect(_on_option_pressed)

func show_upgrades(p):
	player = p
	offered = []
	var pool = upgrades.duplicate()
	pool.shuffle()
	offered = pool.slice(0, 3)
	draw.set_options([offered[0].name, offered[1].name, offered[2].name])
	draw.visible = true
	get_tree().paused = true

func _on_option_pressed(index):
	apply_upgrade(offered[index])
	draw.visible = false
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
