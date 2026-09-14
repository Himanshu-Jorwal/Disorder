extends Node

var selected_character = 0
var character_data = [
	{
		"name": "Zaire",
		"attack1": "Crossbow",
		"attack2": "Lance",
		"absolute": "Indra's Verdict",
		"color": Color(0.6, 0.3, 1.0)
	},
	{
		"name": "Daggers",
		"attack1": "Shard",
		"attack2": "Mirror",
		"absolute": "Kamikaze",
		"color": Color(0.2, 0.8, 0.7)
	},
	{
		"name": "Milano",
		"attack1": "Chime",
		"attack2": "Rift",
		"absolute": "La Pena\nDe Muerte",
		"color": Color(1.0, 0.5, 0.1)
	}
]

func get_character():
	return character_data[selected_character]
