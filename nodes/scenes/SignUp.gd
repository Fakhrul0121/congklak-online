extends CanvasLayer

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
	if $VBoxContainer/UsernameLineEdit.text.dedent() == "":
		error.visible = true
		error.text = "username must be filled"
		return
	var email = $VBoxContainer/EmailLineEdit.text
	var password = $VBoxContainer/PassowrdLineEdit.text
	var username = $VBoxContainer/UsernameLineEdit.text
	Firebase.Auth.signup_with_email_and_password(email, password)
	Firebase.Auth.login_with_email_and_password(email, password)
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection("userdata")
	var add_task : FirestoreTask = firestore_collection.add(email, {'username': username})
	var addedUser : FirestoreDocument = await add_task.task_finished
	Firebase.Auth.logout()
	pass # Replace with function body.
