extends CharacterBody2D

var player : CharacterBody2D

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var dead = false
var health = 2
var direction = Vector2(-1,0)
var tracking = false

enum State {
	ATTACK,
	SHOOT,
	IDLE,
	DEATH
}

var current_state = State.IDLE

var rng = RandomNumberGenerator.new()
var random_num = null

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d_attack: CollisionShape2D = $CollisionShape2D/attackArea/CollisionShape2D
@onready var arrow: Area2D = $CollisionShape2D/arrow
@onready var sprite_2d: Sprite2D = $CollisionShape2D/arrow/Sprite2D
@onready var collision_shape_2d_arrow: CollisionShape2D = $CollisionShape2D/arrow/CollisionShape2D
@onready var _1_label: Label = $"-1_label"

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	handle_animation()
	handle_direction()
	
func handle_animation():
	if direction.x == 1:
		animated_sprite_2d.flip_h = false
		collision_shape_2d.scale.x = 1
	elif direction.x == -1:
		animated_sprite_2d.flip_h = true
		collision_shape_2d.scale.x = -1
	
	if dead:
		animated_sprite_2d.play("death")
		
	if current_state == State.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == State.ATTACK:
		if random_num == 1:
			animated_sprite_2d.play("attack_1")
			if animated_sprite_2d.frame == 3:
				collision_shape_2d_attack.disabled = false
			else:
				collision_shape_2d_attack.disabled = true
		elif random_num == 2:
			animated_sprite_2d.play("attack_2")
			if animated_sprite_2d.frame == 3:
				collision_shape_2d_attack.disabled = false
			else:
				collision_shape_2d_attack.disabled = true
		elif random_num == 3:
			animated_sprite_2d.play("attack_3")
			if animated_sprite_2d.frame == 4:
				collision_shape_2d_attack.disabled = false
			else:
				collision_shape_2d_attack.disabled = true
	elif current_state == State.SHOOT:
		animated_sprite_2d.play("shoot")
	
	velocity.y += gravity
	move_and_slide()

func handle_direction():
	if tracking:
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
	else:
		direction = Vector2(-1,0)


func _on_player_in_shooting_range_body_entered(body: Node2D) -> void:
	player = body
	if !dead:
		current_state = State.SHOOT
		track_player()


func _on_player_in_shooting_range_body_exited(_body: Node2D) -> void:
	stop_tracking()


func track_player():
	tracking = true
	timer.stop()
	
func stop_tracking():
	if timer.time_left <= 0:
		timer.start()


func _on_timer_timeout() -> void:
	if !dead:
		current_state = State.IDLE
		tracking = false


func _on_player_in_attack_range_body_entered(_body: Node2D) -> void:
	current_state = State.ATTACK
	random_num = rng.randi_range(1,3)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack_1" or "attack_2" or "attack_3":
		collision_shape_2d_attack.disabled = true
		current_state = State.SHOOT
	if animated_sprite_2d.animation == "shoot":
		current_state = State.IDLE
		handle_arrow()
	if animated_sprite_2d.animation == "death":
		queue_free()
func handle_arrow():
	sprite_2d.visible = true
	collision_shape_2d_arrow.disabled = false
	var og_pos = arrow.position
	var move = true
	while move:
		if !Checkpoint.player_death:
			arrow.position.x += 10
			await get_tree().create_timer(0.01).timeout
			if arrow.position.x >= 700:
				move = false
		else:
			move = false
	arrow.position = og_pos
	sprite_2d.visible = false
	collision_shape_2d_arrow.disabled = true
		
		


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		health -= 1
		if health >= 0:
			_1_label.visible = true
			await get_tree().create_timer(0.15).timeout
			_1_label.visible = false
	if health <= 0:
		current_state = State.DEATH
		dead = true
