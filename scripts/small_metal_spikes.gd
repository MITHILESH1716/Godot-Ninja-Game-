extends AnimatedSprite2D

var active = false

@onready var small_metal_spikes: AnimatedSprite2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $Killzone/CollisionShape2D

func _process(_delta: float) -> void:
	if active:
		small_metal_spikes.play("afterActive")
		collision_shape_2d.disabled = false
		
func _on_player_detector_body_entered(_body: Node2D) -> void:
	small_metal_spikes.play("active")
	active = true
