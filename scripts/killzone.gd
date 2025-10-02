extends Node2D

func _ready():
	pass

func _on_body_entered(_body: Node2D) -> void:
	Checkpoint.player_death = true
