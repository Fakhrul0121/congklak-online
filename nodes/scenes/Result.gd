extends CanvasLayer

var player_id
var status
@onready var title = $Title

func _ready():
	player_id = multiplayer.get_unique_id()
	status = GameManager.players.get(player_id)["status"]
	if status == "winner":
		title.text = "you win"
	elif status == "draw":
		title.text = "it's a draw"
	elif status == "loser":
		title.text = "you're a loser"

func _on_button_pressed():
	get_tree().change_scene_to_file("res://nodes/MainMenu.tscn")
