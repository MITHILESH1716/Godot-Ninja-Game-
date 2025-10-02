extends Area2D

@onready var text_checkpoint: Label = $textCheckpoint


func _on_body_entered(_body: Node2D) -> void:
		print("Collision")
		text_checkpoint.visible = true
		Checkpoint.last_position = global_position
