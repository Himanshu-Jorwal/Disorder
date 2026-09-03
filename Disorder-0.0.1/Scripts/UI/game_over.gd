extends CanvasLayer

@onready var draw = $GameOverDraw

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	draw.visible = false
	draw.restart_pressed.connect(_on_restart)

func show_game_over(score):
	draw.set_score(score)
	draw.visible = true

func _on_restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
