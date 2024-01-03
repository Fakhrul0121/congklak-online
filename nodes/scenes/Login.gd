extends CanvasLayer

@onready var error = $Error

func _ready():
	$Error.visible = false
	Firebase.Auth.connect("login_succeeded", _on_FirebaseAuth_login_succeeded)
	Firebase.Auth.connect("login_failed", _on_FirebaseAuth_login_failed)

func _on_FirebaseAuth_login_succeeded(auth_info: Dictionary):
	Firebase.Auth.save_auth(auth_info)
	PlayerInfo.set_player_info(auth_info)
	get_tree().change_scene_to_file("res://nodes/scenes/MainMenu2.tscn")
	pass
	
func _on_FirebaseAuth_login_failed(code, message: String):
	error.visible = true
	error.text = message
	$Error/AnimationTree.play("error")
	change_input_status(true)
	pass

func change_input_status(enabled):
	$VBoxContainer/EmailLineEdit.editable = enabled
	$VBoxContainer/PassowrdLineEdit.editable = enabled
	$BackButton.disabled = !enabled
	$LoginButton.disabled = !enabled

func _on_login_button_pressed():
	change_input_status(false)
	$Error/AnimationTree.play("loading")
	var email = $VBoxContainer/EmailLineEdit.text
	var password = $VBoxContainer/PassowrdLineEdit.text
	Firebase.Auth.login_with_email_and_password(email, password)
	pass # Replace with function body.


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://nodes/scenes/Welcome.tscn")

