extends CanvasLayer

@onready var moon = $Moon
@onready var hud_draw = $HUDDraw

func _ready():
	pass

func update(hp, max_hp, xp, xp_to_next, level):
	hud_draw.update_stats(hp, max_hp, xp, xp_to_next, level)

func update_moon(phase_name):
	pass
