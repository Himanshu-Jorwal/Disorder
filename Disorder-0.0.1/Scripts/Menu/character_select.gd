extends CanvasLayer

@onready var select_draw = $SelectDraw

var selected = 0
var characters = [
	{
		"name": "Zaire",
		"gender": "Female",
		"attack1": "Crossbow",
		"attack2": "Lance",
		"absolute": "Indra's Verdict",
		"attack1_desc": "Fires a spread of bolts",
		"attack2_desc": "Piercing lance through enemies",
		"absolute_desc": "Bolts explode outward in all directions",
		"color": Color(0.6, 0.3, 1.0)
	},
	{
		"name": "Daggers",
		"gender": "Female",
		"attack1": "Shard",
		"attack2": "Mirror",
		"absolute": "Kamikaze",
		"attack1_desc": "Fast shard that shatters on impact",
		"attack2_desc": "Clone that attracts enemies and explodes",
		"absolute_desc": "Long Dash",
		"color": Color(0.2, 0.8, 0.7)
	},
	{
		"name": "Milano",
		"gender": "Female",
		"attack1": "Chime",
		"attack2": "Rift",
		"absolute": "La Pena De Muerte",
		"attack1_desc": "Slow resonating orb, heavy damage",
		"attack2_desc": "Pulls nearby enemies toward a rift",
		"absolute_desc": "Laser",
		"color": Color(1.0, 0.5, 0.1)
	}
]

func _ready():
	select_draw.setup(characters, selected)
	select_draw.character_selected.connect(_on_character_selected)

func _on_character_selected(index):
	GameState.selected_character = index
	get_tree().change_scene_to_file("res://Scenes/Game/world.tscn")
