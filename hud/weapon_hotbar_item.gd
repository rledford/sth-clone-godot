class_name WeaponHotbarItem
extends PanelContainer

@export var icon_texture: Texture
@export var num: String
@export var weapon_id: String

var _prev_stylebox: StyleBoxFlat

@onready var num_label: Label = %NumLabel
@onready var icon_rect: TextureRect = %IconRect


func _ready() -> void:
	num_label.text = num
	icon_rect.texture = icon_texture

	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)


func set_selected(selected: bool) -> void:
	var stylebox = _get_stylebox()

	if selected:
		stylebox.set_border_color(Color.WHITE_SMOKE)
		stylebox.set_draw_center(true)
	else:
		stylebox.set_border_color("#9999991e")
		stylebox.set_draw_center(false)

	_apply_style(stylebox)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked! Hotbar Item! Should emit signal to change weapon")


func _on_mouse_entered() -> void:
	_prev_stylebox = _get_stylebox()
	var stylebox = _get_stylebox()
	stylebox.set_draw_center(true)
	_apply_style(stylebox)
	self.add_theme_stylebox_override("panel", stylebox)


func _on_mouse_exited() -> void:
	_apply_style(_prev_stylebox)


func _get_stylebox() -> StyleBox:
	return self.get_theme_stylebox("panel").duplicate()


func _apply_style(stylebox: StyleBox) -> void:
	self.add_theme_stylebox_override("panel", stylebox)
