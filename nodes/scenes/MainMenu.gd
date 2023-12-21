extends CanvasLayer



func _ready():
	pass

func _process(delta):
	var doc_fields
	if GameManager.room_id != null:
		var document = await GameManager.access_doc(GameManager.room_id)
		if document != null:
			if document["isFull"]:
				$Loading/AnimationPlayer.stop()
				$Loading.text = "connected!"
				await get_tree().create_timer(1).timeout
				get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")

func loading_animation():
	$Loading.text = "loading..."
	$Loading.visible = true
	$Loading/AnimationPlayer.play("loading")
	pass

func _on_join_button_down():
	if $NameEdit.text == "":
		$Loading.visible = true
		$Loading.text = "fill name"
		return
	loading_animation()
	#search for room
	var query: FirestoreQuery = FirestoreQuery.new()
	var result = []
	while (result == []):
		query.from("roomdata")
		query.where("isFull",FirestoreQuery.OPERATOR.EQUAL,false)
		query.order_by("time_created", FirestoreQuery.DIRECTION.DESCENDING)
		query.limit(1)
		result = await Firebase.Firestore.query(query).result_query
	var player_name = $NameEdit.text
	var doc_fields = result[0].doc_fields
	GameManager.room_id = result[0].doc_name
	GameManager.player_id = player_name
	doc_fields["isFull"] = true
	doc_fields["players"][player_name] = { "name": player_name, "house": 0, "holes": [7, 7, 7, 7, 7, 7, 7] }
	var up_task: FirestoreTask = GameManager.firestore_collection.update(GameManager.room_id, doc_fields)
	var doc_updated = await up_task.task_finished

func _on_host_button_down():
	if $NameEdit.text == "":
		$Loading.visible = true
		$Loading.text = "fill name"
		return
	loading_animation()
	#create a room
	var player_name = $NameEdit.text
	var add_task: FirestoreTask = GameManager.firestore_collection.add("", {'isFull': false,'time_created':Time.get_datetime_dict_from_system(true), 'isMoved':false, 'player_turn':player_name, 'players':{player_name:{'name':player_name,'holes':[7,7,7,7,7,7,7],'house':0}}})
	var document = await add_task.add_document
	GameManager.player_id = player_name
	GameManager.room_id = document.doc_name
