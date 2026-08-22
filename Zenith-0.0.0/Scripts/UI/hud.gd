extends CanvasLayer

@onready var hp_label = $HPLabel
@onready var xp_label = $XPLabel
@onready var level_label = $LevelLabel

func _ready():
	hp_label.position = Vector2(20, 20)
	xp_label.position = Vector2(20, 50)
	level_label.position = Vector2(20, 80)

func update(hp, xp, xp_to_next, level):
	hp_label.text = "HP: " + str(hp)
	xp_label.text = "XP: " + str(xp) + " / " + str(xp_to_next)
	level_label.text = "Level: " + str(level)

func update_moon(phase_name):
	pass
