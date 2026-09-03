extends CanvasLayer

@onready var credits_draw = $CreditsDraw

func _ready():
	credits_draw.back_pressed.connect(_on_back)

func _on_back():
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")
