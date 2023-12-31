extends CanvasLayer

var player_name
var document : FirestoreDocument

func _ready():
	#PlayerInfo.player_info["email"]
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection("userdata")
	firestore_collection.get_doc(PlayerInfo.player_info["email"])
	document = await firestore_collection.get_document
	player_name = document.doc_fields["username"]
	$PlayerId.text += player_name
	button_status(true)
	GameManager.player_id = PlayerInfo.player_info["email"]
	pass

func button_status(enable : bool):
	$HBoxContainer/JoinButton.disabled = !enable
	$HBoxContainer/HostButton.disabled = !enable

func loading_animation():
	$Status.visible = true
	$Status/AnimationPlayer.play("loading")

func _on_host_button_pressed():
	loading_animation()
	button_status(false)
	DatabaseManager.database_reference_room_list = Firebase.Database.get_database_reference("room", {}) ##for connecting to database
	GameManager.room_id = DatabaseManager.generate_random_id()
	var data = {'isFull': false,'time_created':Time.get_datetime_dict_from_system(true), 'isMoved':false, 'player_turn':GameManager.player_id, 'players':{GameManager.player_id:{'name':player_name,'holes':[7,7,7,7,7,7,7],'house':0}}}
	DatabaseManager.database_reference_room_list.update(GameManager.room_id,data) ##push data
	GameManager.room = data
	DatabaseManager.database_reference_room_list.push_failed.connect(_on_push_failed)
	await DatabaseManager.database_reference_room_list.push_successful
	#var add_task: FirestoreTask = GameManager.firestore_collection.add("", {'isFull': false,'time_created':Time.get_datetime_dict_from_system(true), 'isMoved':false, 'player_turn':player_name, 'players':{player_name:{'name':player_name,'holes':[7,7,7,7,7,7,7],'house':0}}})
	#var document = await add_task.add_document
	DatabaseManager.database_reference_room_list.patch_data_update.connect(patch_data_host)

func _on_push_failed():
	$Status/AnimationPlayer.stop()
	$Status.text = "SOMETHING WENT WRONG"
	$Status.visible_characters = -1
	button_status(true)

func patch_data_host(data):
	if data.key == GameManager.room_id:
		GameManager.room.merge(data.data,true)
		$Status.text = "CONNECTED"
		$Status/AnimationPlayer.stop()
		$Status.visible_characters = -1
		$CancelButton.disabled = true
		await get_tree().create_timer(1).timeout
		if GameManager.room["isFull"]:
			get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")


func _on_join_button_pressed():
	loading_animation()
	button_status(false)
	#search for room
	DatabaseManager.database_reference_room_list = Firebase.Database.get_database_reference("room", {})
	DatabaseManager.database_reference_room_list.new_data_update.connect(new_data_join) ##whenever a new data is push, function will fire. Inside new_data_join, data will search for an empty room
	$CancelButton.disabled = false

func new_data_join(data):
	if data.data != null && data.data != {}:
		var this_data = data.data
		GameManager.room_id = data.key
		GameManager.room = this_data
		if GameManager.room_id == null:
			$Loading.text = "ROOM COULD NOT BE FOUND. TRY AGAIN LATER"
			$Loading/AnimationPlayer.stop()
			$Loading.visible_characters = -1
		else:
			GameManager.room["isFull"] = true
			GameManager.room["players"][GameManager.player_id] = {'name':player_name,'holes':[7,7,7,7,7,7,7],'house':0}
			DatabaseManager.database_reference_room_list.update(GameManager.room_id,GameManager.room)
			$Loading.text = "CONNECTED"
			$Loading/AnimationPlayer.stop()
			$Loading.visible_characters = -1
			$CancelButton.disabled = true
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")
