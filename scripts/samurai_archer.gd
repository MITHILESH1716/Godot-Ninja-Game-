extends CharacterBody2D

var player : CharacterBody2D

var health = 10
var speed = 50
var chase_speed = 100
var acceleration = 300

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Vector2(1,0)
var left_bound = Vector2(-125,0)
var right_bound = Vector2(125,0)

var rng = RandomNumberGenerator.new()
var random_num = null
enum State {
	WALK,
	RUN,
	ATTACK,
	ARROW_SHOOT,
	HURT,
	DEATH
}

var current_state = State.WALK

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_detection: Area2D = $player_detection
@onready var attack_area: Area2D = $attackArea
@onready var attack_detector: Area2D = $attackDetector
@onready var collision_shape_2d: CollisionShape2D = $attackArea/CollisionShape2D


func _ready() -> void:
	left_bound = self.position + left_bound
	right_bound = self.position + right_bound
	
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_direction()
	
func handle_movement(delta):
	if current_state == State.WALK:
		animated_sprite_2d.play("walk")
		velocity = velocity.move_toward(direction * speed,acceleration * delta)
	elif current_state == State.RUN:
		animated_sprite_2d.play("run")
		velocity = velocity.move_toward(direction * chase_speed,acceleration * delta)
	elif current_state == State.ATTACK:
		velocity.x = 0
		if random_num == 1:
			animated_sprite_2d.play("attack_1")
			if animated_sprite_2d.frame == 3:
				collision_shape_2d.disabled = false
		elif random_num == 2:
			animated_sprite_2d.play("attack_2")
			if animated_sprite_2d.frame == 3:
				collision_shape_2d.disabled = false
		elif random_num == 3:
			animated_sprite_2d.play("attack_3")
			if animated_sprite_2d.frame == 4:
				collision_shape_2d.disabled = false
	elif current_state ==  State.ARROW_SHOOT:
		velocity.x = 0
		animated_sprite_2d.play("arrow_shot")
	elif current_state == State.HURT:
		animated_sprite_2d.play("hurt")
	elif current_state == State.DEATH:
		animated_sprite_2d.play("death")
	velocity.y += gravity * delta
	move_and_slide()

func handle_direction():
	if current_state == State.WALK:
		if self.position >= right_bound:
			direction = Vector2(-1,0)
			animated_sprite_2d.flip_h = true
			player_detection.scale.x = -1
			attack_area.scale.x = -1
			attack_detector.scale.x = -1
			arrow_player_detector.scale.x = -1
		elif self.position <= left_bound:
			direction = Vector2(1,0)
			animated_sprite_2d.flip_h = false
			player_detection.scale.x = 1
			attack_area.scale.x = 1
			attack_detector.scale.x = 1
			arrow_player_detector.scale.x = 1
	elif current_state == State.RUN:
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
		if direction.x == 1:
			animated_sprite_2d.flip_h = false
			player_detection.scale.x = 1
			attack_area.scale.x = 1
			attack_detector.scale.x = 1
			arrow_player_detector.scale.x = 1
		else:
			animated_sprite_2d.flip_h = true
			player_detection.scale.x = -1
			attack_area.scale.x = -1
			attack_detector.scale.x = -1
			arrow_player_detector.scale.x = -1
func _on_player_detection_body_entered(body: Node2D) -> void:
	player = body
	start_chase()


func _on_player_detection_body_exited(_body: Node2D) -> void:
	stop_chase()
	
	
@onready var timer: Timer = $Timer

func start_chase():
	current_state = State.RUN
	timer.stop()

func stop_chase():
	if timer.time_left <= 0:
		timer.start()

func _on_timer_timeout() -> void:
	current_state = State.WALK

	

func _on_attack_detector_body_entered(_body: Node2D) -> void:
	current_state = State.ATTACK
	random_num = rng.randi_range(1,3)

@onready var arrow: Area2D = $player_detection/arrow
@onready var arrow_player_detector: Area2D = $arrowPlayerDetector
@onready var sprite_2d_arrow: Sprite2D = $player_detection/arrow/Sprite2D
@onready var collision_shape_2d_arrow: CollisionShape2D = $player_detection/arrow/CollisionShape2D

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack_1" or "attack_2" or "attack_3":
		current_state = State.RUN
		collision_shape_2d.disabled = true
	
	if animated_sprite_2d.animation == "hurt":
		current_state = State.RUN
		
	if animated_sprite_2d.animation == "death":
		queue_free()
	
	if animated_sprite_2d.animation == "arrow_shot":
		handle_arrow()
		

func handle_arrow():
	sprite_2d_arrow.visible = true
	collision_shape_2d_arrow.disabled = false
	var arrow_shot = true
	var arrow_initial_position = arrow.position
	while arrow_shot and !Checkpoint.player_death:
		arrow.position.x += 10
		await get_tree().create_timer(0.01).timeout
		if arrow.position.x >= 350:
			arrow_shot = false
	
	arrow.position = arrow_initial_position
	sprite_2d_arrow.visible = false
	collision_shape_2d_arrow.disabled = true
	
	
func _on_hurt_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		current_state = State.HURT
		health -= 1
	if health <= 0:
		current_state = State.DEATH
		


func _on_arrow_player_detector_body_entered(body: Node2D) -> void:
	current_state = State.ARROW_SHOOT
	player = body
