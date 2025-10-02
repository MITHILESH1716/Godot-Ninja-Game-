extends CharacterBody2D

var player : CharacterBody2D

var health = 10
var speed = 70
var chase_speed = 170
var acceleration = 1000
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Vector2(1,0)
var dead = false

var rng = RandomNumberGenerator.new()

enum State {
	WALK,
	RUN,
	ATTACK,
	DEATH
}

var current_state = State.WALK

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ray_cast_2d: RayCast2D = $CollisionShape2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d_attack: CollisionShape2D = $CollisionShape2D/attackArea/CollisionShape2D
@onready var _1_lable: Label = $"-1 Lable"


func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_direction()
	
func handle_movement(delta):
	if current_state == State.WALK:
		animated_sprite_2d.play("walk")
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")
		velocity = velocity.move_toward(direction * chase_speed, acceleration * delta)
	elif current_state == State.ATTACK:
		velocity.x = 0
		if animated_sprite_2d.animation == "attack_1" and animated_sprite_2d.frame == 3:
			collision_shape_2d_attack.disabled = false
		elif animated_sprite_2d.animation == "attack_2" and animated_sprite_2d.frame == 2:
			collision_shape_2d_attack.disabled = false
		elif animated_sprite_2d.animation == "attack_3" and animated_sprite_2d.frame == 3:
			collision_shape_2d_attack.disabled = false
	elif dead and current_state == State.DEATH:
		velocity.x = 0
		collision_shape_2d_attack.disabled = true
		animated_sprite_2d.play("death")
	velocity.y += gravity
	move_and_slide()
	
func handle_direction():
	if not ray_cast_2d.is_colliding() and current_state != State.DEATH:
		if direction.x == 1:
			direction = Vector2(-1,0)
		else:
			direction = Vector2(1,0)
		current_state = State.WALK
		
	if current_state == State.RUN:
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
		if direction == Vector2(1,0):
			direction = Vector2(-1,0)
		elif direction == Vector2(-1,0):
			direction = Vector2(1,0)
	
	if direction.x == 1:
		animated_sprite_2d.flip_h = false
		collision_shape_2d.scale.x = 1
	else:
		animated_sprite_2d.flip_h = true
		collision_shape_2d.scale.x = -1
		
		
func _on_player_detector_body_entered(body: Node2D) -> void:
	player = body
	start_chase()


func _on_player_detector_body_exited(_body: Node2D) -> void:
	stop_chase()

func start_chase():
	if current_state != State.DEATH:
		current_state = State.RUN
		timer.stop()
	
func stop_chase():
	if timer.time_left <= 0:
		timer.start()

func _on_timer_timeout() -> void:
	if current_state != State.DEATH:
		current_state = State.WALK


func _on_attack_detector_area_body_entered(_body: Node2D) -> void:
	if current_state != State.DEATH:
		current_state = State.ATTACK
		handle_attack()

func handle_attack():
	var random_num = rng.randi_range(1,3)
	if random_num == 1:
		animated_sprite_2d.play("attack_1")
	elif random_num == 2:
		animated_sprite_2d.play("attack_2")
	elif random_num == 3:
		animated_sprite_2d.play("attack_3")
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack_1" or "attack_2" or "attack_3":
		collision_shape_2d_attack.disabled = true
		if current_state != State.DEATH:
			current_state = State.RUN
	if animated_sprite_2d.animation == "death":
		queue_free()
		
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		health -= 1
		if !dead:
			_1_lable.visible = true
			await get_tree().create_timer(0.2).timeout
			_1_lable.visible = false
	if health <= 0:
		dead = true
		current_state = State.DEATH
	
