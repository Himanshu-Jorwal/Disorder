extends CanvasLayer

@onready var panel = $Panel
@onready var score_label = $Panel/ScoreLabel
@onready var restart_button = $Panel/RestartButton

const PANEL_SIZE = Vector2(400, 250)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var screen = get_viewport().get_visible_rect().size
	panel.size = PANEL_SIZE
	panel.position = (Vector2(screen) - PANEL_SIZE) / 2
	
	score_label.position = Vector2(100, 100)
	score_label.size = Vector2(200, 50)
	
	restart_button.position = Vector2(100, 170)
	restart_button.size = Vector2(200, 50)
	
	visible = false
	restart_button.pressed.connect(_on_restart)

func show_game_over(score):
	score_label.text = "Score: " + str(score)
	visible = true

func _on_restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
