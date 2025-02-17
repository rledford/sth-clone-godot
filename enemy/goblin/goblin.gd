extends Enemy

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	hp = 1
	damage = 2
	speed = 120.0
	hit_particle_color = Color.BLUE
	coin_reward = 2
	init_fsm()

func idle_state_enter():
	if not attack_position:
		return
	anim.play("idle")

func idle_state_update(_delta: float):
	if has_valid_attack_position():
		return fsm.change_state("search")
	_update_attack_position()

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
	SignalBus.enemy_died.emit(coin_reward)
	anim.play("death")
	collider.disabled = true

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
