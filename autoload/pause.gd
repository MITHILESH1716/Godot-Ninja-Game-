extends CanvasLayer

@onready var background: TextureRect = $Background

func _ready() -> void:
	set_visible1(false)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		set_visible1(!get_tree().paused)
		get_tree().paused = !get_tree().paused
		
		


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	set_visible1(false)
	
func set_visible1(is_visible1):
	for node in get_children():
		node.visible = is_visible1
