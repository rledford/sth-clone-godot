extends Enemy

const SparkParticle = preload("res://particles/spark_particle.tscn")

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_blocked_point: Node2D = $HitBlockedPoint

@export var block_time = 4.5
var block_timer = 0.0
var state_id_before_block_started: String

var is_blocking = false

func _ready() -> void:
	hp = 2
	damage = 3
	speed = 35.0
	hit_particle_color = Color.BLACK
	coin_reward = 4
	init_fsm()
	
func _handle_hit(damage: int) -> void:
	if is_blocking:
		var spark = SparkParticle.instantiate() as CPUParticles2D
		spark.one_shot = true
		spark.color = Color.YELLOW
		spark.position = hit_blocked_point.position
		add_child(spark)
		return
	
	super._handle_hit(damage)
	
	if hp > 0:
		self.state_id_before_block_started = fsm.get_current_state_id()
		self.fsm.change_state("block")

func idle_state_enter():
	if not attack_position:
		return
	anim.play("idle")

func idle_state_update(_delta: float):
	if has_valid_attack_position():
		return fsm.change_state("move")
	_update_attack_position()

func move_state_enter():
	anim.play("move")
	
func move_state_update(_delta: float):
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
	
func block_state_enter():
	self.anim.play("block")
	self.block_timer = 0.0
	self.is_blocking = true

func block_state_update(delta):
	self.block_timer += delta
	
	if self.block_timer > block_time:
		self.fsm.change_state(self.state_id_before_block_started)
	
func block_state_exit():
	self.is_blocking = false

func init_fsm() -> void:
	fsm = StateMachine.new()
	
	add_child(fsm)
	
	var idle_state = State.new().on_enter(idle_state_enter).on_update(idle_state_update)
	var move_state = State.new().on_enter(move_state_enter).on_update(move_state_update)
	var attack_state = State.new().on_enter(attack_state_enter)
	var block_state = State.new().on_enter(block_state_enter).on_update(block_state_update).on_exit(block_state_exit)
	var death_state = State.new().on_enter(death_state_enter)
	
	fsm.add_state("idle", idle_state)
	fsm.add_state("move", move_state)
	fsm.add_state("block", block_state)
	fsm.add_state("attack", attack_state)
	fsm.add_state("death", death_state)

	fsm.change_state("idle")
	
func start_block() -> void:
	is_blocking = true

func end_block() -> void:
	is_blocking = false
