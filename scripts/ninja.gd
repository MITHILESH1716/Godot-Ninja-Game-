extends CharacterBody2D


const SPEED = 170.0
const JUMP_VELOCITY = -350.0
var isAttack = false
var dead = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_attack: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and isAttack == false:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("run_left", "run_right")
	
	if direction < 0:
		animated_sprite_2d.flip_h = true
		attack_area.set_scale(Vector2(-1,1))
	elif direction > 0:
		animated_sprite_2d.flip_h = false
		attack_area.set_scale(Vector2(1,1))

	
	if direction and isAttack == false:
		animated_sprite_2d.play("old_ninja_run")
		velocity.x = direction * SPEED
	elif isAttack == false:
		animated_sprite_2d.play("old_ninja_idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		animated_sprite_2d.play("old_ninja_attack")
		isAttack = true
		velocity.x = 0
	
	if isAttack == true and animated_sprite_2d.frame == 4:
		collision_shape_attack.disabled = false
	

	if Checkpoint.player_death:
		death()
	move_and_slide()

func death():
	animated_sprite_2d.play("old_ninja_hurt")
	collision_shape_2d.disabled = true
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
	Checkpoint.player_death = false
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "old_ninja_attack":
		collision_shape_attack.disabled = true
		isAttack = false
