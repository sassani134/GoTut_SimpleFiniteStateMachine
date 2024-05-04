extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 1200.0

enum STATE {IDLE, WALK, JUMP, FALL}
var current_state : STATE

@export var dust : PackedScene

@onready var player_sprite : Sprite2D = $Sprite2D
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_set_state(STATE.IDLE)

func _physics_process(delta) -> void:
	_update_state(delta)

func _set_state(new_state: STATE) -> void:
	if current_state == new_state:
		return
	_exit_state()
	current_state = new_state
	_enter_state()

func _enter_state() -> void:
	match current_state:
		STATE.IDLE:
			anim_player.play("idle")
		STATE.WALK:
			anim_player.play("walk")
		STATE.JUMP:
			velocity.y = JUMP_VELOCITY
			anim_player.play("jump")
		STATE.FALL:
			anim_player.play("fall")

func _update_state(delta: float)-> void:
	var direction = Input.get_axis("ui_left","ui_right")
	match current_state:
		STATE.IDLE:
			if direction:
				_set_state(STATE.WALK)
			elif !is_on_floor():
				_set_state(STATE.FALL)
			elif Input.is_action_just_pressed("ui_accept"):
				_set_state(STATE.JUMP)
		
		STATE.WALK:
			velocity.x = direction * SPEED
			if  velocity.x > 0:
				player_sprite.flip_h = true
			elif velocity.x < 0:
				player_sprite.flip_h = false
				
			if !is_on_floor():
				_set_state(STATE.FALL)
			elif  Input.is_action_just_pressed("ui_accept"):
				_set_state(STATE.JUMP)
			elif velocity.x == 0:
				_set_state(STATE.IDLE)
			
			move_and_slide()
			
		STATE.JUMP:
			velocity.x = direction * SPEED
			if velocity.x > 0:
				player_sprite.flip_h = true
			elif velocity.x < 0:
				player_sprite.flip_h = false
			
			if !is_on_floor():
				velocity.y += GRAVITY * delta
				if velocity.y > 0:
					_set_state(STATE.FALL)
			
			move_and_slide()
		
		STATE.FALL:
			velocity.x = direction * SPEED
			if  velocity.x > 0:
				player_sprite.flip_h = true
			elif velocity.x < 0:
				player_sprite.flip_h = false
			
			if  is_on_floor():
				_set_state(STATE.IDLE)
			else:
				velocity.y += GRAVITY * delta
			
			move_and_slide()

func _exit_state() -> void :
	match current_state :
		STATE.IDLE:
			pass
		STATE.WALK:
			pass
		STATE.JUMP:
			pass
		STATE.FALL:
			var new_dust : CPUParticles2D = dust.instantiate()
			get_parent().add_child(new_dust)
			new_dust.global_position = global_position + Vector2(0,12)
			new_dust.emitting = true
			await new_dust.finished
			new_dust.queue_free()
