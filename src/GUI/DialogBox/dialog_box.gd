class_name DialogBox
extends CanvasLayer

signal dialog_closed()

@onready var dialog_title: Label = $"%Title"
@onready var dialog_text: RichTextLabel = $"%Text"
@onready var dialog_icon: TextureRect = $"%Icon"
@onready var close_button: Button = $"%CloseButton"

func show_dialog(title: String, text: String, icon: Texture, icon_color: Color) -> void:
	dialog_title.text = title
	dialog_text.text = text
	dialog_icon.texture = icon
	dialog_icon.modulate = icon_color
	close_button.grab_focus()
	

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		queue_free()
		dialog_closed.emit()
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
		dialog_closed.emit()


func _on_close_button_pressed() -> void:
	queue_free()
	dialog_closed.emit()
