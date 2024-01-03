extends CanvasLayer

@onready var error = $Error

func _ready():
	$Error.visible = false
	Firebase.Auth.connect("signup_succeeded", _on_FirebaseAuth_signup_succeeded)
	Firebase.Auth.connect("login_failed", _on_FirebaseAuth_signup_failed)

func _on_FirebaseAuth_signup_succeeded(auth_info: Dictionary):
	pass

func _on_FirebaseAuth_signup_failed(code, message: String):
	error.visible = true
	error.text = message
	$Error/AnimationTree.play("error")
	change_input_status(true)
	pass

func change_input_status(enabled):
	$VBoxContainer/EmailLineEdit.editable = enabled
	$VBoxContainer/UsernameLineEdit.editable = enabled
	$VBoxContainer/PassowrdLineEdit.editable = enabled
	$BackButton.disabled = !enabled
	$SignUpButton.disabled = !enabled

func _on_sign_up_button_pressed():
	change_input_status(false)
	if $VBoxContainer/UsernameLineEdit.text.dedent() == "":
		error.visible = true
		error.text = "USERNAME MUST BE FILLED"
		change_input_status(true)
		return
	$Error/AnimationTree.play("loading")
	var email = $VBoxContainer/EmailLineEdit.text
	var password = $VBoxContainer/PassowrdLineEdit.text
	var username = $VBoxContainer/UsernameLineEdit.text
	Firebase.Auth.signup_with_email_and_password(email, password)
	await Firebase.Auth.signup_succeeded
	Firebase.Auth.login_with_email_and_password(email, password)
	await Firebase.Auth.login_succeeded
	var firestore_collection : FirestoreCollection = Firebase.Firestore.collection("userdata")
	var add_task : FirestoreTask = firestore_collection.add(email, {'username': username})
	var addedUser = await add_task.task_finished
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://nodes/scenes/Login.tscn")
	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://nodes/scenes/Welcome.tscn")
