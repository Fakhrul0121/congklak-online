extends CanvasLayer

var player_id
var status
@onready var title = $Title

func _ready():
	status = GameManager.room["players"][GameManager.player_id]["status"]
	print(GameManager.room, " result")
	if status == "winner":
		title.text = "you win"
	elif status == "draw":
		title.text = "it's a draw"
	elif status == "loser":
		title.text = "you're a loser"

func _on_button_pressed():
	get_tree().change_scene_to_file("res://nodes/scenes/MainMenu2.tscn")
