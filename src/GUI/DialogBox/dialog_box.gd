class_name DialogBox
extends CanvasLayer

@onready var dialog_title: Label = $"%Title"
@onready var dialog_text: RichTextLabel = $"%Text"
@onready var dialog_icon: TextureRect = $"%Icon"

func _ready() -> void:
	hide()

func show_dialog(title: String, text: String) -> void:
	dialog_title.text = title
	dialog_text.text = text
	#dialog_icon.texture = icon
	show()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		queue_free()
