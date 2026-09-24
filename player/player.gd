extends CharacterBody3D

@export var gravity : float = 20.0
@export var jump_speed : float = 7.0
@export var run_speed : float = 5.0
@export var acceleration : float = 10.0

# timers representing the time since relevant actions
var jump_t : float
var attack_t : float
var landed_t : float
var is_grounded : bool

func _process(delta: float) -> void:
	
	var anim_to_play : String
	
	var move := Input.get_axis("move_left", "move_right")
	
	# moving
	if move:
		velocity.x = lerp(velocity.x, run_speed * move, acceleration * delta)
		anim_to_play = "walk"
		$Sprite3D.flip_h = move < 0.0
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		anim_to_play = "idle"
	
	# grounding-related stuff
	if is_on_floor():
		
		# just landed
		if not is_grounded:
			landed_t = 0.0
		
		if Input.is_action_just_pressed("jump"):
			jump_t = 0.0
			velocity.y = jump_speed
			anim_to_play = "jump"
		
	else:
		# gravity
		velocity.y -= gravity * delta
		
		if velocity.y > 0.0:
			anim_to_play = "jump"
		else:
			anim_to_play = "fall"
	
	is_grounded = is_on_floor()
	
	if Input.is_action_just_pressed("attack") and attack_t > 0.35:
		attack_t = 0.0
	
	# determine attack
	if abs(jump_t - attack_t) < 0.1 and attack_t < 0.3 and not is_grounded:
		anim_to_play = "flying_tornado_kick"
	elif attack_t < 0.3:
		anim_to_play = "punch"
		velocity.x = lerp(velocity.x, 0.0, acceleration * 2.0 * delta)
	
	# attack = punch
	# jump + attack = flying tornado kick
	# attack + airborne = flying kickdash
	# attack + landing = sliding kickdash
	# attack then jump = uppercut (knocks enemy into air)
	
	move_and_slide()
	
	$Sprite3D.scale = Vector3.ONE
	$AnimationPlayer.play(anim_to_play)
	
	jump_t += delta
	attack_t += delta
	landed_t += delta
