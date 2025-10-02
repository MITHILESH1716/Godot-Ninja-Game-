extends Area2D

@export var target_scene = PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if !target_scene:
			print("No scene in this door")
			return
		if get_overlapping_bodies().size() > 0:
			next_level()
			
func next_level():
	var ERR = get_tree().change_scene_to_packed(target_scene)
	
	if ERR != OK:
		print("Something failed in the door scene")
