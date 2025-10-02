extends CharacterBody2D

var player : CharacterBody2D

var health = 10
var dead = false
var speed = 50
var chase_speed = 100
var acceleration = 4000
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Vector2(-1,0)

var rng = RandomNumberGenerator.new()

enum State {
	WALK,
	RUN,
	ATTACK,
	HURT,
	DEATH
}

var current_state = State.WALK

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ray_cast_2d: RayCast2D = $CollisionShape2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d_attack_area: CollisionShape2D = $CollisionShape2D/deathArea/CollisionShape2D
@onready var _1_label: Label = $"-1 Label"


func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_direction()
	
func handle_movement(delta):
	if dead:
		velocity.x = 0
		handle_death()
	if current_state == State.WALK:
		animated_sprite_2d.play("walk")
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")
		velocity = velocity.move_toward(direction * chase_speed, acceleration * delta)
	elif current_state == State.ATTACK:
		velocity.x = 0
		if animated_sprite_2d.frame == 2:
			collision_shape_2d_attack_area.disabled = false
	velocity.y += gravity
	move_and_slide()
	
func handle_death():
	animated_sprite_2d.play("death")

func handle_direction():
	if not ray_cast_2d.is_colliding():
		if direction.x == 1:
			direction.x = -1
		elif direction.x == -1:
			direction.x = 1
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

func _on_player_detector_area_body_entered(body: Node2D) -> void:
	player = body
	start_chase()

func _on_player_detector_area_body_exited(_body: Node2D) -> void:
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

func handle_attack(random_num):
	if random_num == 1:
		animated_sprite_2d.play("attack_1")
	elif random_num == 2:
		animated_sprite_2d.play("attack_2")
	elif random_num == 3:
		animated_sprite_2d.play("attack_3")



func _on_player_in_range_attack_body_entered(_body: Node2D) -> void:
	if current_state != State.DEATH:
		await get_tree().create_timer(0.25).timeout
		current_state = State.ATTACK
		var random_num = rng.randi_range(1,3)
		handle_attack(random_num)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack_1" or "attack_2" or "attack_3":
		current_state = State.RUN
		collision_shape_2d_attack_area.disabled = true
	if animated_sprite_2d.animation == "death":
		queue_free()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		health -= 1
		_1_label.visible = true
		await get_tree().create_timer(0.2).timeout
		_1_label.visible = false
	if health <= 0:
		dead = true
		current_state = State.DEATH
