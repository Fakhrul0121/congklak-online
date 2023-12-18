extends CanvasLayer

@onready var http_request = $HTTPRequest
@onready var error = $Error

func _ready():
	Firebase.Auth.connect("login_succeeded", _on_FirebaseAuth_login_succeeded)
	Firebase.Auth.connect("login_failed", _on_FirebaseAuth_login_failed)

func _on_FirebaseAuth_login_succeeded(auth_info: Dictionary):
	PlayerInfo.player_info = auth_info
	Firebase.Auth.save_auth(auth_info)
	get_tree().change_scene_to_file("res://nodes/scenes/Main.tscn")
	pass
	
func _on_FirebaseAuth_login_failed(code, message: String):
	error.visible = true
	error.text = message
	pass

func _on_login_button_pressed():
	var email = $VBoxContainer/EmailLineEdit.text
	var password = $VBoxContainer/PassowrdLineEdit.text
	Firebase.Auth.login_with_email_and_password(email, password)
	pass # Replace with function body.
