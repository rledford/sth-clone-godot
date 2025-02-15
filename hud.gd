extends CanvasLayer
@onready var health_bar: ProgressBar = $ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_health_changed.connect(_handle_player_health_changed)

func _handle_player_health_changed(health: int, max_health: int) -> void:
	health_bar.value = health
	health_bar.max_value = max_health
