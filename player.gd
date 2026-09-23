extends CharacterBody3D

@export var gravity : float = 3.0
@export var jump_speed : float = 4.0
@export var run_speed : float = 5.0
@export var acceleration : float = 10.0

# timers representing the time since relevant actions
var jump_t : float
var attack_t : float
var landed_t : float
var is_grounded : bool

func _process(delta: float) -> void:
	
	var move := Input.get_axis("move_left", "move_right")
	
	# moving
	if move:
		velocity.x = lerp(velocity.x, run_speed * move, acceleration * delta)
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
	
	if Input.is_action_just_pressed("attack"):
		attack_t = 0.0
	
	# special moves
	
	# im gonna make a fighting game you press B to jump and A to punch and A+B to do
	# a flying tornado kick and A in the air to do a flying kickdash and A then B to
	# do an uppercut and A right on landing on the ground to do a sliding kickdash
	
	move_and_slide()
	
	jump_t += delta
	attack_t += delta
	landed_t += delta
