extends CharacterBody3D

@export var gravity : float = 20.0
@export var jump_speed : float = 7.0
@export var run_speed : float = 5.0
@export var acceleration : float = 10.0
@export var kickdash_speed_mult : float = 2.5

# timers representing the time since relevant actions
var jump_t : float = 1000.0
var attack_t : float = 1000.0
var landed_t : float = 1000.0
var is_grounded : bool

# each attack state has conditions within which it can override the current
# state (which includes which state is currently active), and a timer after
# which the attack state is cleared (+ a cooldown for determining when you
# can attack again). also movement can depend on the state (i.e. run speed)
var attack_state : String = ""
var attack_length : float = -1000.0
@export var attack_cooldown : float = 0.05

func _process(delta: float) -> void:
	
	var move := Input.get_axis("move_left", "move_right")
	
	# moving
	if move:
		velocity.x = lerp(velocity.x, run_speed * move * (0.3 if attack_state == "punch" else 1.0), acceleration * delta)
		$Sprite3D.flip_h = move < 0.0
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
	
	# grounding-related stuff
	if is_on_floor():
		
		# just landed
		if not is_grounded:
			landed_t = 0.0
		
		if Input.is_action_just_pressed("jump"):
			jump_t = 0.0
			velocity.y = jump_speed
		
	else:
		# gravity
		velocity.y -= gravity * delta
	
	is_grounded = is_on_floor()
	
	if Input.is_action_just_pressed("attack") and attack_length < -attack_cooldown:
		attack_t = 0.0
	
	# determine attack
	if attack_length <= 0.0 or (attack_state == "flying_kickdash" and landed_t == 0.0):
		attack_state = ""
	
	if (attack_state == "" or attack_state == "punch") and jump_t < 0.02 and attack_t < 0.02:
		attack_state = "flying_tornado_kick"
		attack_length = 0.3
	elif attack_state == "punch" and jump_t == 0.0:
		attack_state = "uppercut"
		attack_length = 0.3
	elif attack_state == "" and attack_t == 0.0 and not is_grounded:
		attack_state = "flying_kickdash"
		attack_length = 0.3
		velocity.x = 4.0 * (-run_speed if $Sprite3D.flip_h else run_speed)
	elif attack_state == "" and attack_t == 0.0 and landed_t < 0.1:
		attack_state = "sliding_kickdash"
		attack_length = 0.3
		velocity.x = 4.0 * (-run_speed if $Sprite3D.flip_h else run_speed)
	elif attack_state == "" and attack_t == 0.0:
		attack_state = "punch"
		attack_length = 0.15
	
	move_and_slide()
	
	$Sprite3D.scale = Vector3.ONE
	if attack_state != "":
		$AnimationPlayer.play(attack_state)
	else:
		if is_grounded:
			$AnimationPlayer.play("walk" if move else "idle")
		else:
			$AnimationPlayer.play("jump" if velocity.y > 0.0 else "fall")
	
	jump_t += delta
	attack_t += delta
	landed_t += delta
	attack_length -= delta
