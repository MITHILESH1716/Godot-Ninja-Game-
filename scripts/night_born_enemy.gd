extends CharacterBody2D

var player : CharacterBody2D

var dead = false
var health = 10
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Vector2(1,0)
var speed = 50
var chase_speed = 120
var acceleration = 3000

var rng = RandomNumberGenerator.new()

var random_num = null

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
@onready var _1_label: Label = $"-1_label"
@onready var collision_shape_2d_attack: CollisionShape2D = $CollisionShape2D/attackRange/CollisionShape2D


func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	handle_animation(delta)
	handle_direction()
	
func handle_animation(delta):
	if dead:
		animated_sprite_2d.play("death")
	
	if current_state == State.WALK:
		animated_sprite_2d.play("walk")
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")
		velocity = velocity.move_toward(direction * chase_speed, acceleration * delta)
	elif current_state == State.ATTACK:
		velocity.x = 0
		if animated_sprite_2d.frame == 9:
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


	
func track_player():
	timer.stop()

func stop_tracking():
	if timer.time_left <= 0:
		timer.start()



func _on_player_in_range_body_entered(body: Node2D) -> void:
	if !dead:
		current_state = State.RUN
		player = body
		track_player()


func _on_player_in_range_body_exited(body: Node2D) -> void:
	stop_tracking()


func _on_timer_timeout() -> void:
	if !dead:
		current_state = State.WALK


func _on_player_in_attack_range_body_entered(body: Node2D) -> void:
	if !dead:
		current_state = State.ATTACK
		handle_attack()
		
func handle_attack():
	animated_sprite_2d.play("attack")


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		current_state = State.RUN
	
	if animated_sprite_2d.animation == "death":
		queue_free()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		health-=1
		if !dead:
			_1_label.visible = true
			await get_tree().create_timer(0.2).timeout
			_1_label.visible = false
	
	if health <= 0:
		dead = true
		current_state = State.DEATH
