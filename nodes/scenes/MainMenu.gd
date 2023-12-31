extends CanvasLayer

@export var holes = [7,7,7,7,7,7,7]

func _ready():
	Firebase.Auth.connect("login_succeeded", _on_FirebaseAuth_login_succeeded)
	pass

func _process(delta):
	
	
	pass
	#var doc_fields
	#if GameManager.room_id != null:
		#var document = await GameManager.access_doc(GameManager.room_id)
		#if document != null:
			#if document["isFull"]:
				#$Loading/AnimationPlayer.stop()
				#$Loading.text = "connected!"
				#await get_tree().create_timer(1).timeout
				#get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")

func loading_animation():
	$Loading.text = "loading..."
	$Loading.visible = true
	$Loading/AnimationPlayer.play("loading")
	pass

func _on_FirebaseAuth_login_succeeded(auth_info: Dictionary):
	pass

func _on_join_button_down():
	if $NameEdit.text == "":
		$Loading.visible = true
		$Loading.text = "FILL NAME"
		return
	loading_animation()
	#search for room
	Firebase.Auth.login_with_email_and_password("dummytestingcongklak@maildrop.cc","testing123")
	await Firebase.Auth.login_succeeded
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
			var player_name = $NameEdit.text
			GameManager.player_id = player_name
			GameManager.room["isFull"] = true
			GameManager.room["players"][player_name] = {'name':player_name,'holes':holes,'house':0}
			DatabaseManager.database_reference_room_list.update(GameManager.room_id,GameManager.room)
			$Loading.text = "CONNECTED"
			$Loading/AnimationPlayer.stop()
			$Loading.visible_characters = -1
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")
			

func _on_host_button_down():
	if $NameEdit.text == "":
		$Loading.visible = true
		$Loading.text = "fill name"
		return
	loading_animation()
	#create a room
	var player_name = $NameEdit.text
	Firebase.Auth.login_with_email_and_password("dummytestingcongklak@maildrop.cc","testing123") ##used for testing
	await Firebase.Auth.login_succeeded
	DatabaseManager.database_reference_room_list = Firebase.Database.get_database_reference("room", {}) ##for connecting to database
	GameManager.room_id = DatabaseManager.generate_random_id()
	var data = {'isFull': false,'time_created':Time.get_datetime_dict_from_system(true), 'isMoved':false, 'player_turn':player_name, 'players':{player_name:{'name':player_name,'holes':[7,7,7,7,7,7,7],'house':0}}}
	DatabaseManager.database_reference_room_list.update(GameManager.room_id,data) ##push data
	GameManager.room = data
	await DatabaseManager.database_reference_room_list.push_successful
	#var add_task: FirestoreTask = GameManager.firestore_collection.add("", {'isFull': false,'time_created':Time.get_datetime_dict_from_system(true), 'isMoved':false, 'player_turn':player_name, 'players':{player_name:{'name':player_name,'holes':[7,7,7,7,7,7,7],'house':0}}})
	#var document = await add_task.add_document
	GameManager.player_id = player_name
	DatabaseManager.database_reference_room_list.patch_data_update.connect(patch_data_host)

func patch_data_host(data):
	if data.key == GameManager.room_id:
		GameManager.room.merge(data.data,true)
		$Loading.text = "CONNECTED"
		$Loading/AnimationPlayer.stop()
		$Loading.visible_characters = -1
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://nodes/scenes/Congklak.tscn")
