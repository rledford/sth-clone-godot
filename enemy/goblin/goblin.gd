extends Enemy

@export var hp: float = 2.0
@export var speed: float = 80.0
@export var damage: float = 1.0

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var fsm: StateMachine
var attack_position: Vector2

func _ready() -> void:
	attack_position = Vector2.INF
	init_fsm()

func idle_state_enter():
	if not attack_position:
		return
	anim.play("idle")

func idle_state_update(_delta: float):
	if has_valid_attack_position():
		return fsm.change_state("search")
	attack_position = _get_attack_position()

func search_state_enter():
	anim.play("move")
	
func search_state_update(_delta: float):
	if collider.global_position.distance_to(attack_position) > 10:
		velocity = (attack_position - collider.global_position).normalized() * speed
		move_and_slide()
		flip()

func attack_state_enter():
	anim.play("attack")
		
func death_state_enter():
	anim.play("death")
	collider.disabled = true

		
func has_valid_attack_position() -> bool:
	return attack_position and attack_position != Vector2.INF

func attack_anim_finished() -> void:
	# emit hit on player
	SignalBus.player_hit.emit(damage)

func init_fsm() -> void:
	fsm = StateMachine.new()
	
	add_child(fsm)
	
	var idle_state = State.new().on_enter(idle_state_enter).on_update(idle_state_update)
	var search_state = State.new().on_enter(search_state_enter).on_update(search_state_update)
	var attack_state = State.new().on_enter(attack_state_enter)
	var death_state = State.new().on_enter(death_state_enter)
	
	fsm.add_state("idle", idle_state)
	fsm.add_state("search", search_state)
	fsm.add_state("attack", attack_state)
	fsm.add_state("death", death_state)

	fsm.change_state("idle")

func _handle_hit(_amount: float) -> void:
	hp -= _amount
	if hp <= 0:
		fsm.change_state("death")

func _on_area_2d_area_entered(_area: Area2D) -> void:
	fsm.change_state("attack")

func _on_area_2d_area_exited(_area: Area2D) -> void:
	fsm.change_state("idle")
