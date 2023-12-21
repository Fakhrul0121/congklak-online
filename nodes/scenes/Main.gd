extends CanvasLayer

func _ready():
	#PlayerInfo.player_info["email"]
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection("userdata")
	firestore_collection.get_doc(PlayerInfo.player_info["email"])
	var document : FirestoreDocument = await firestore_collection.get_document
	print(document)
	$PlayerId.text += document.doc_fields["username"]
	pass


func _on_host_button_pressed():
	pass # Replace with function body.
