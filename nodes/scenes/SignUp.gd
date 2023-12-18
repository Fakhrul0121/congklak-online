extends CanvasLayer

@onready var http_request = $HTTPRequest
@onready var error = $Error

func _ready():
	Firebase.Auth.connect("signup_succeeded", _on_FirebaseAuth_signup_succeeded)
	Firebase.Auth.connect("login_failed", _on_FirebaseAuth_signup_failed)

func _on_FirebaseAuth_signup_succeeded(auth_info: Dictionary):
	get_tree().change_scene_to_file("res://nodes/scenes/Login.tscn")
	pass
	
func _on_FirebaseAuth_signup_failed(code, message: String):
	error.visible = true
	error.text = message
	pass

func _on_sign_up_button_pressed():
	if $VBoxContainer/UsernameLineEdit.text.trim() == "":
		error.visible = true
		error.text = "username must be filled"
		return
	var email = $VBoxContainer/EmailLineEdit.text
	var password = $VBoxContainer/PassowrdLineEdit.text
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection("userdata")
	var add_task : FirestoreTask = firestore_collection.add(PlayerInfo.player_info.email, {'nama': "alice"})
	var addedUser : FirestoreDocument = await add_task.task_finished
	Firebase.Auth.signup_with_email_and_password(email, password)
	pass # Replace with function body.
