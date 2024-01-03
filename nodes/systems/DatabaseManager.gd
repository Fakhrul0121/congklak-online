extends Node

@onready var firestore_collection_user_data : FirestoreCollection = Firebase.Firestore.collection('roomdata')
var database_reference_room_list: FirebaseDatabaseReference
var database_reference_room: FirebaseDatabaseReference

func generate_random_id() -> String:
	var id = ""
	const characters = "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
	for i in range(20):
		id += characters[randi()%characters.length()]
	return id

func connect_to_room():
	database_reference_room = Firebase.Database.get_database_reference("room/%s" % GameManager.room_id, {})


