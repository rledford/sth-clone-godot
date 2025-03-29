extends Node2D

@onready var area_of_effect: Area2D = $AreaOfEffect

func _ready() -> void:
	area_of_effect.body_entered.connect(onbo)
