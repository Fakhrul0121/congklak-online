extends Node

var room_id
var player_id
var opponent_id 
@onready var firestore_collection : FirestoreCollection = Firebase.Firestore.collection('roomdata')


func access_doc(room_id):
	var document_task: FirestoreTask = firestore_collection.get_doc(room_id)
	var document: FirestoreDocument = await document_task.get_document
	if document != null:
		return document.doc_fields
	else:
		return null

func MoveBeans(room_fields: Dictionary,hole_picked: int, player_id: int):
	#code how to move beans
	#assign player
	var p = room_fields["players"][player_id]
	var beans_picked = p["holes"][hole_picked]
	#assign opponent
	var o = room_fields.get(opponent_id)
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
	room_fields["players"][player_id] = p
	room_fields["players"][opponent_id] = o
	if (i != 7):
		room_fields["player_turn"] = opponent_id
	
#
#@rpc("any_peer","call_local")
#func transfer_players_data(players, player_turn):
	##transfer the players data
	#print(player_turn, "tpd")
	#self.players = players
	#self.player_turn = player_turn
	#pass
#
func get_opponent(player_id):
	var document = await access_doc(room_id)
	var opponent_id
	for key in document["players"].keys():
		if key != player_id:
			opponent_id = key
	return opponent_id

#@rpc("any_peer", "call_local")
#func check_empty():
	#for p in players:
		#if p["holes"] == [0,0,0,0,0,0,0]:
			#move_opponent_all_to_house(p["id"])
			#return true
	#return false
#
#func move_opponent_all_to_house(player_id):
	#var opponent_beans = 0
	#var opponent_id = get_opponent(player_id)
	#for h in players.get(opponent_id)["holes"]:
		#opponent_beans += h
		#h = 0
	#players.get(opponent_id)["house"] += opponent_beans
#
#@rpc("any_peer", "call_local")
#func check_winner():
	#for p in players:
		#if p["house"] > (1*7):
			#var o = players.get(get_opponent(p["id"]))
			#if p["house"] > o["house"]:
				#p["status"] = "winner"
				#o["status"] = "loser"
			#elif p["house"] == o["house"]:
				#p["status"] = "draw"
				#o["status"] = "draw"
			#else:
				#p["status"] = "loser"
				#o["status"] = "winner"
			#return true
	#return false
