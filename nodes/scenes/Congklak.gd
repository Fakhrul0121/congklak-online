extends CanvasLayer

var holes_player = []
var holes_opponent = []
var player_turn: bool

func _ready():
	#coonect to room
	DatabaseManager.connect_to_room()
	DatabaseManager.database_reference_room.patch_data_update.connect(on_received_updated_congklak)
	GameManager.get_opponent_id()
	$PlayerName.text = GameManager.room["players"][GameManager.player_id]["name"]
	$OpponentName.text = GameManager.room["players"][GameManager.opponent_id]["name"]
	player_turn = GameManager.room["player_turn"] == GameManager.player_id
	#set max house
	GameManager.set_max_house()
	#get holes
	var holes = get_tree().get_nodes_in_group("Holes")
	for hole in holes:
		#insert to player and opponent list holes
		if hole.is_in_group("Player"):
			holes_player.push_back(hole)
			#connect holes
			hole.connect("hole_picked", hole_picked)
		elif hole.is_in_group("Opponent"):
			holes_opponent.push_back(hole)
			hole.disable = true
	holes_player.sort_custom(func(a, b): return a.id < b.id)
	holes_opponent.sort_custom(func(a, b): return a.id < b.id)
	synchronize_holes()
	check_turn()

func on_received_updated_congklak(data):
	print(data)
	if data.data:
		if data.key == "players":
			GameManager.room[data.key].merge(data.data, true)
			synchronize_holes()
		elif data.data.has("player_turn"):
			player_turn = data.data["player_turn"] == GameManager.player_id
			GameManager.room.merge(data.data, true)
			check_turn()
	##ifs when the game is over
	GameManager.check_empty()
	if  GameManager.check_game_over():
		get_tree().change_scene_to_file("res://nodes/scenes/Result.tscn")

func disable_all():
	for hole in holes_player:
		hole.disable = true

func hole_picked(id_hole_picked,holes):
	disable_all()
	print("ass", id_hole_picked)
	$Loading.visible = true
	await get_tree().create_timer(1).timeout
	$Loading.visible = false
	GameManager.MoveBeans(id_hole_picked)
	synchronize_holes()

func synchronize_holes():
	for hole in holes_player:
		hole.label.text = str(GameManager.room["players"][GameManager.player_id]["holes"][hole.id])
	for hole in holes_opponent:
		hole.label.text = str(GameManager.room["players"][GameManager.opponent_id]["holes"][hole.id])
	$AlatBantu/HousePlayer.text = str(GameManager.room["players"][GameManager.player_id]["house"])
	$AlatBantu/HouseOpponent.text = str(GameManager.room["players"][GameManager.opponent_id]["house"])

func check_turn():
	for hole in holes_player:
		hole.disable = !player_turn
