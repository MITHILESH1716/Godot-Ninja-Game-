extends CharacterBody2D

var player : CharacterBody2D

var health = 10
var dead = false
var speed = 80
var chase_speed = 130
var acceleration = 3000
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Vector2(1,0)

var rng = RandomNumberGenerator.new()
var random_num = null

enum State {
	WALK,
	RUN,
	ATTACK,
	HURT,
	DEATH
}

var current_state = State.WALK

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $CollisionShape2D/RayCast2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d_attack: CollisionShape2D = $CollisionShape2D/attackArea/CollisionShape2D
@onready var _1_label: Label = $"-1_label"

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	handle_animation(delta)
	handle_direction()
	
func handle_animation(delta):
	if dead:
		velocity.x = 0
		animated_sprite_2d.play("death")
	
	if current_state == State.WALK:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		animated_sprite_2d.play("walk")
	elif current_state == State.RUN:
		velocity = velocity.move_toward(direction * chase_speed, acceleration * delta)
		animated_sprite_2d.play("run")
	elif current_state == State.ATTACK:
		velocity.x = 0
		if random_num == 1:
			animated_sprite_2d.play("attack_1")
			if animated_sprite_2d.frame == 2:
				collision_shape_2d_attack.disabled = false
			else:
				collision_shape_2d_attack.disabled = true
		elif random_num == 2:
			animated_sprite_2d.play("attack_2")
			if animated_sprite_2d.frame == 4:
				collision_shape_2d_attack.disabled = false
			else:
				collision_shape_2d_attack.disabled = true
		elif random_num == 3:
			animated_sprite_2d.play("attack_3")
			if animated_sprite_2d.frame == 2:
				collision_shape_2d_attack.disabled = false
			else:
				collision_shape_2d_attack.disabled = true
		
	velocity.y += gravity
	move_and_slide()
	
func handle_direction():
	if !ray_cast_2d.is_colliding():
		if direction.x == 1:
			direction = Vector2(-1,0)
		elif direction.x == -1:
			direction = Vector2(1,0)
		current_state = State.WALK
	
	if current_state == State.RUN:
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
	
	if direction.x == 1:
		animated_sprite_2d.flip_h = false
		collision_shape_2d.scale.x = 1
	elif direction.x == -1:
		animated_sprite_2d.flip_h = true
		collision_shape_2d.scale.x = -1

func _on_player_detector_area_body_entered(body: Node2D) -> void:
	player = body
	start_chase()
	
func start_chase():
	if !dead:
		current_state = State.RUN
		timer.stop()
	
func stop_chase():
	if timer.time_left <= 0:
		timer.start()

func _on_timer_timeout() -> void:
	if !dead:
		current_state = State.WALK

func _on_player_in_attack_range_body_entered(_body: Node2D) -> void:
	if !dead:
		handle_attack()
		current_state = State.ATTACK
	
func handle_attack():
	random_num = rng.randi_range(1,3)
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack_1" or "attack_2" or "attack_3":
		current_state = State.RUN
		collision_shape_2d_attack.disabled = true
	
	if animated_sprite_2d.animation == "death":
		queue_free()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		health -= 1
		if !dead:
			_1_label.visible = true
			await get_tree().create_timer(0.2).timeout
			_1_label.visible = false
	
	if health <= 0:
		dead = true
		current_state = State.DEATH
