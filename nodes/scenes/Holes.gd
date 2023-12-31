extends Area2D

@export var id: int
var mouseInsideHole = false
var disable = false: set = set_disable
@onready var label = $Label
signal hole_picked(id,button)

func _input(event):
	if mouseInsideHole and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hole_picked.emit(id,self)

func _on_mouse_entered():
	mouseInsideHole = true
	pass # Replace with function body.


func _on_mouse_exited():
	mouseInsideHole = false
	pass # Replace with function body.

func set_disable(value):
	disable = value
	if disable:
		$AnimationPlayer.play("Fade")
	else:
		$AnimationPlayer.play_backwards("Fade")
	$CollisionShape2D.disabled = value
