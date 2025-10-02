extends AnimatedSprite2D

var active = false

@onready var spike: AnimatedSprite2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $Killzone/CollisionShape2D


func _physics_process(_delta: float) -> void:
	if spike.frame >= 5 and spike.frame <= 7:
		collision_shape_2d.disabled = false
	else:
		collision_shape_2d.disabled = true
