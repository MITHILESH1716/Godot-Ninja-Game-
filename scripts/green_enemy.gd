extends AnimatedSprite2D

const SPEED = 60

var direction = 1
var dead = false

@onready var animated_sprite_2d: AnimatedSprite2D = $"."
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_2d_down_left: RayCast2D = $RayCast2D_down_left
@onready var ray_cast_2d_down_right: RayCast2D = $RayCast2D_down_right


func _process(delta: float) -> void:
	if dead == false:
		if not ray_cast_2d_down_left.is_colliding():
			direction = 1
			animated_sprite_2d.flip_h = false
		elif not ray_cast_2d_down_right.is_colliding():
			direction = -1
			animated_sprite_2d.flip_h = true
		if ray_cast_left.is_colliding():
			direction = 1
			animated_sprite_2d.flip_h = false
		elif ray_cast_right.is_colliding():
			direction = -1
			animated_sprite_2d.flip_h = true
		position.x += direction * SPEED * delta
	else:
		animated_sprite_2d.play("hurt")



func _on_killzone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		dead = true


func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "hurt":
		queue_free()
