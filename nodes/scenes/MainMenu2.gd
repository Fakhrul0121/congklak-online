extends CanvasLayer

@export var holes = [7,7,7,7,7,7,7]
var player_name
var document : FirestoreDocument

func _ready():
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection("userdata")
	firestore_collection.get_doc(PlayerInfo.player_info["email"])
	document = await firestore_collection.get_document
	player_name = document.doc_fields["username"]

func _process(delta):
	pass

func loading_animation():
	$Loading.text = "loading..."
	$Loading.visible = true
	$Loading/AnimationPlayer.play("loading")
	pass

func _on_join_button_down():
	if $NameEdit.text == "":
		$Loading.visible = true
		$Loading.text = "FILL NAME"
		return
	loading_animation()
	#search for room
	DatabaseManager.database_reference_room_list = Firebase.Database.get_database_reference("room", {})
	DatabaseManager.database_reference_room_list.new_data_update.connect(new_data_join) ##whenever a new data is push, function will fire. Inside new_data_join, data will search for an empty room

func new_data_join(data):
	if data.data != null:
		var this_data = data.data
		GameManager.room_id = data.key
		GameManager.room = this_data
		if GameManager.room_id == null:
			$Loading.text = "ROOM COULD NOT BE FOUND. TRY AGAIN LATER"
			$Loading/AnimationPlayer.stop()
			$Loading.visible_characters = -1
		else:
			GameManager.room["isFull"] = true
			GameManager.room["players"][player_name] = {'name':player_name,'holes':holes,'house':0}
			DatabaseManager.database_reference_room_list.update(GameManager.room_id,GameManager.room)
			$Loading.text = "CONNECTED"
			$Loading/AnimationPlayer.stop()
			$Loading.visible_characters = -1
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")
			

func button_status(enable : bool):
	$Join.disabled = !enable
	$Host.disabled = !enable

func _on_host_button_down():
	loading_animation()
	button_status(false)
	DatabaseManager.database_reference_room_list = Firebase.Database.get_database_reference("room", {}) ##for connecting to database
	GameManager.room_id = DatabaseManager.generate_random_id()
	var data = {'isFull': false,'time_created':Time.get_datetime_dict_from_system(true), 'isMoved':false, 'player_turn':GameManager.player_id, 'players':{GameManager.player_id:{'name':player_name,'holes':[7,7,7,7,7,7,7],'house':0}}}
	DatabaseManager.database_reference_room_list.update(GameManager.room_id,data) ##push data
	GameManager.room = data
	await DatabaseManager.database_reference_room_list.push_successful
	DatabaseManager.database_reference_room_list.patch_data_update.connect(patch_data_host)

func patch_data_host(data):
	if data.key == GameManager.room_id:
		GameManager.room.merge(data.data,true)
		$Loading.text = "CONNECTED"
		$Loading/AnimationPlayer.stop()
		$Loading.visible_characters = -1
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")
