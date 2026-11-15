extends Area2D

@export var pole_height: float = 60.0
@export var flag_color: Color = Color(0.9, 0.15, 0.15)

var _won := false


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, pole_height)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -pole_height / 2.0)
	add_child(collision)

	body_entered.connect(_on_body_entered)


func _draw() -> void:
	draw_rect(Rect2(-2, -pole_height, 4, pole_height), Color(0.85, 0.85, 0.85))
	draw_rect(Rect2(-2, -pole_height, 4, pole_height), Color.BLACK, false, 1.0)
	var top := -pole_height + 2.0
	var flag := PackedVector2Array([Vector2(2, top), Vector2(32, top + 10), Vector2(2, top + 20)])
	draw_colored_polygon(flag, flag_color)
	flag.append(flag[0])
	draw_polyline(flag, Color.BLACK, 1.0)
	draw_circle(Vector2(0, -pole_height - 3), 4, Color(1.0, 0.85, 0.2))


func _on_body_entered(body: Node2D) -> void:
	if _won or not body is CharacterBody2D:
		return
	_won = true

	var timer := get_node_or_null(^"Timer") as Timer
	if timer:
		timer.stop()

	body.set_physics_process(false)
	var sprite := body.get_node_or_null(^"Sprite Player") as AnimatedSprite2D
	if sprite:
		sprite.play(&"idle")

	_show_message("You win!")


func _show_message(text: String) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 30)
	center.add_child(box)

	var label := Label.new()
	label.name = "WinLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 96)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 16)
	box.add_child(label)

	var button := Button.new()
	button.name = "RestartButton"
	button.text = "Restart"
	button.custom_minimum_size = Vector2(260, 80)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 48)
	button.pressed.connect(_on_restart_pressed)
	box.add_child(button)
	button.grab_focus()


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
