extends CanvasLayer

var player_id
var holes_player = []
var holes_opponent = []
var room_data

func _ready():
	#get doc
	room_data = await GameManager.access_doc(GameManager.room_id)
	#assign id
	player_id = GameManager.player_id
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
	check_turn()
	synchronize_holes()

func check_turn():
	if player_id != GameManager.player_turn:
		print("sit ", player_id)
		for hole in holes_player:
			print(hole, " ", player_id)
			hole.disable = true
	else:
		print("NoSit ", player_id)
		for hole in holes_player:
			print(hole, " ", player_id)
			hole.disable = false

func disable_all():
	for hole in get_tree().get_nodes_in_group("hole"):
		hole.disable = true

func hole_picked(id_hole_picked):
	GameManager.MoveBeans(id_hole_picked, player_id)
	synchronize_holes.rpc()
	#await get_tree().create_timer(1).timeout
	
	#if GameManager.check_empty():
	#	synchronize_holes.rpc()
	#	await get_tree().create_timer(1).timeout
	#if GameManager.check_winner():
	#	get_tree().change_scene_to_file.rpc("res://nodes/Result.tscn")
	#	return
	if player_id != GameManager.player_turn:
		print("yay")
		check_turn.rpc()
	else:
		print("nay")



@rpc("any_peer", "call_local")
func synchronize_holes():
	var opponent_id=GameManager.get_opponent(player_id)
	for hole in holes_player:
		hole.label.text = str(GameManager.players[player_id]["holes"][hole.id])
	for hole in holes_opponent:
		hole.label.text = str(GameManager.players[opponent_id]["holes"][hole.id])
	$AlatBantu/HousePlayer.text = str(GameManager.players[player_id]["house"])
	$AlatBantu/HouseOpponent.text = str(GameManager.players[opponent_id]["house"])
