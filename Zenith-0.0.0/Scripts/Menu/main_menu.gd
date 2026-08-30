extends CanvasLayer

@onready var menu_draw = $MenuDraw

func _ready():
	menu_draw.start_pressed.connect(_on_start)
	menu_draw.exit_pressed.connect(_on_exit)

func _on_start():
	get_tree().change_scene_to_file("res://Scenes/Menu/character_select.tscn")

func _on_exit():
	get_tree().quit()
