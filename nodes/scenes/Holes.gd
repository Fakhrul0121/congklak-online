extends Area2D

@export var id: int
var mouseInsideHole = false
var disable = false: set = set_disable
@onready var label = $Label
signal hole_picked(id)

func _input(event):
	if mouseInsideHole and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hole_picked.emit(id)

func _on_mouse_entered():
	mouseInsideHole = true
	pass # Replace with function body.


func _on_mouse_exited():
	mouseInsideHole = false
	pass # Replace with function body.

func set_disable(value):
	disable = value
	$CollisionShape2D.disabled = value
