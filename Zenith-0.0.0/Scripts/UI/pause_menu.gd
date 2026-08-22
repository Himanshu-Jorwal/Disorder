extends CanvasLayer

@onready var panel = $Panel
@onready var resume_button = $Panel/ResumeButton
@onready var title = $Panel/Title
@onready var quit_button = $Panel/QuitButton

const PANEL_SIZE = Vector2(400, 300)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var screen = get_viewport().get_visible_rect().size
	panel.size = PANEL_SIZE
	panel.position = (screen - PANEL_SIZE) / 2
	title.position = Vector2(PANEL_SIZE.x / 2 - 30, 40)
	resume_button.position = Vector2(100, 120)
	resume_button.size = Vector2(200, 50)
	quit_button.position = Vector2(100, 190)
	quit_button.size = Vector2(200, 50)
	visible = false
	resume_button.pressed.connect(_on_resume)
	quit_button.pressed.connect(_on_quit)

func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		if visible:
			hide_pause()
		else:
			show_pause()

func show_pause():
	visible = true
	get_tree().paused = true

func hide_pause():
	visible = false
	get_tree().paused = false

func _on_resume():
	hide_pause()

func _on_quit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/bootstrap.tscn")
