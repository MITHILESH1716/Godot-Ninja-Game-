extends AnimatedSprite2D


@onready var wood_spike: AnimatedSprite2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $Killzone/CollisionShape2D


func _physics_process(delta: float) -> void:
	if wood_spike.frame == 7:
		collision_shape_2d.disabled = false
	else:
		collision_shape_2d.disabled = true
