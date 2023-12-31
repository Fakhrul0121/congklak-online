extends Node


var room_id = null
var room = {}
var player_id = null
var opponent_id = null
var max_house: int = 0

func set_max_house():
	for i in room["players"][player_id]["holes"]:
		max_house += i

func get_opponent_id():
	for p in room.players.keys():
		if player_id != p:
			opponent_id = p

func MoveBeans(hole_picked: int):
	#code how to move beans
	#assign player
	var p = room["players"][player_id]
	var beans_picked = p["holes"][hole_picked]
	#assign opponent
	var o = room["players"][opponent_id]
	p["holes"][hole_picked] = 0
	var i = hole_picked + 1
	while true:
		if i == 15:
			i = 0;
		if i < 7:
			p["holes"][i] += 1
		elif i == 7:
			p["house"] += 1
		else:
			o["holes"][i - 8] += 1
		beans_picked -= 1
		if beans_picked == 0:
			break
		i += 1
	if (i < 7 and p["holes"][i] == 1 and o["holes"][abs(i-6)] != 0):
		var fill = 0
		fill += p["holes"][i]
		p["holes"][i] = 0
		fill += o["holes"][abs(i-6)]
		o["holes"][abs(i-6)] = 0
		p["house"] += fill
	room["players"][player_id] = p
	room["players"][opponent_id] = o
	DatabaseManager.database_reference_room.update("players",{player_id:p,opponent_id:o})
	await DatabaseManager.database_reference_room.patch_data_update
	if (i != 7):
		room["player_turn"] = opponent_id
		DatabaseManager.database_reference_room_list.update(room_id,{"player_turn":opponent_id})

func check_empty():
	var players = room["players"].keys()
	for p in players:
		print(p," ", room["players"][p]["holes"], " check_empty ")
		if room["players"][p]["holes"][0] == 0 && room["players"][p]["holes"][1] == 0 && room["players"][p]["holes"][2] == 0 && room["players"][p]["holes"][3] == 0 && room["players"][p]["holes"][4] == 0 && room["players"][p]["holes"][5] == 0 && room["players"][p]["holes"][6] == 0:
			move_opponent_all_to_house(p)
			return true
	return false


func move_opponent_all_to_house(pl_id):
	var opponent_beans = 0
	var op_id
	if pl_id == player_id:
		op_id = opponent_id
	elif pl_id == opponent_id:
		op_id = player_id
	for h_id in range(room["players"][op_id]["holes"].size()):
		opponent_beans += room["players"][op_id]["holes"][h_id]
		room["players"][op_id]["holes"][h_id] = 0
	room["players"][op_id]["house"] += opponent_beans

func check_game_over():
	var players = room["players"].keys()
	var op_id
	for p_id in players:
		print(p_id, " check_game_over")
		print(max_house)
		if room["players"][p_id]["house"] >= max_house:
			print("returning")
			if p_id == player_id:
				op_id = opponent_id
			elif p_id == opponent_id:
				op_id = player_id
			if room["players"][p_id]["house"] > room["players"][op_id]["house"]:
				room["players"][p_id]["status"] = "winner"
				room["players"][op_id]["status"] = "loser"
			elif room["players"][p_id]["house"] == room["players"][op_id]["house"]:
				room["players"][p_id]["status"] = "draw"
				room["players"][op_id]["status"] = "draw"
			else:
				room["players"][p_id]["status"] = "loser"
				room["players"][op_id]["status"] = "winner"
			return true
	return false
