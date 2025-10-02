extends Node2D

func _enter_tree() -> void:
	if Checkpoint.last_position:
		$Ninja.global_position = Checkpoint.last_position
