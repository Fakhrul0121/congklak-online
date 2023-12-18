extends Node

var players = {}
var player_turn

#@rpc("any_peer", "call_local")
func MoveBeans(hole_picked: int, player_id: int):
	#code how to move beans
	#assign player
	var p = players.get(player_id)
	var beans_picked = p["holes"][hole_picked]
	#assign opponent
	var o = players.get(get_opponent(player_id))
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
		p["house"] = fill
	players[player_id] = p
	players[get_opponent(player_id)] = o
	if i != 7:
		player_turn = get_opponent(player_id)

@rpc("any_peer")
func sync_player_data():
	#sync the players data
	pass

func get_opponent(player_id):
	var opponent_id
	for key in players.keys():
		if key != player_id:
			opponent_id = key
	return opponent_id

@rpc("any_peer", "call_local")
func check_empty():
	for p in players:
		if p["holes"] == [0,0,0,0,0,0,0]:
			move_opponent_all_to_house(p["id"])
			return true
	return false

func move_opponent_all_to_house(player_id):
	var opponent_beans = 0
	var opponent_id = get_opponent(player_id)
	for h in players.get(opponent_id)["holes"]:
		opponent_beans += h
		h = 0
	players.get(opponent_id)["house"] += opponent_beans

@rpc("any_peer", "call_local")
func check_winner():
	for p in players:
		if p["house"] > (1*7):
			var o = players.get(get_opponent(p["id"]))
			if p["house"] > o["house"]:
				p["status"] = "winner"
				o["status"] = "loser"
			elif p["house"] == o["house"]:
				p["status"] = "draw"
				o["status"] = "draw"
			else:
				p["status"] = "loser"
				o["status"] = "winner"
			return true
	return false
