extends CanvasLayer

@onready var panel = $Panel
@onready var title = $Panel/Title
@onready var start_button = $Panel/StartButton
@onready var exit_button = $Panel/ExitButton

const PANEL_SIZE = Vector2(400, 300)

func _ready():
	var screen = get_viewport().get_visible_rect().size
	panel.size = PANEL_SIZE
	panel.position = (screen - PANEL_SIZE) / 2
	title.position = Vector2(100, 40)
	title.size = Vector2(200, 50)
	start_button.position = Vector2(100, 120)
	start_button.size = Vector2(200, 50)
	exit_button.position = Vector2(100, 190)
	exit_button.size = Vector2(200, 50)
	start_button.pressed.connect(_on_start)
	exit_button.pressed.connect(_on_exit)

func _on_start():
	get_tree().change_scene_to_file("res://Scenes/Menu/character_select.tscn")

func _on_exit():
	get_tree().quit()
