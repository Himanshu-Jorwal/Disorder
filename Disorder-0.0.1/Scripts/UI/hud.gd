extends CanvasLayer

@onready var moon = $Moon
@onready var hud_draw = $HUDDraw

func _ready():
	pass

func update(hp, max_hp, xp, xp_to_next, level, cd1, max_cd1, cd2, max_cd2, cd_abs, max_cd_abs, name1, name2, name_abs):
	hud_draw.update_stats(hp, max_hp, xp, xp_to_next, level, cd1, max_cd1, cd2, max_cd2, cd_abs, max_cd_abs, name1, name2, name_abs)

func update_moon(phase_name):
	pass
