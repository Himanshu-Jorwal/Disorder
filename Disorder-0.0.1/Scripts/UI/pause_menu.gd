extends CanvasLayer

@onready var draw = $PauseDraw

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	draw.visible = false
	draw.resume_pressed.connect(_on_resume)
	draw.quit_pressed.connect(_on_quit)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if draw.visible:
			hide_pause()
		else:
			show_pause()

func show_pause():
	draw.visible = true
	get_tree().paused = true

func hide_pause():
	draw.visible = false
	get_tree().paused = false

func _on_resume():
	hide_pause()

func _on_quit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menu/bootstrap.tscn")
