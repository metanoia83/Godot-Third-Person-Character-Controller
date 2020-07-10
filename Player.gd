extends KinematicBody

var gravity = -60.0
var max_gravity = -150.0
var speed = 0.0
var velocity = Vector3()
var jump_height = 25.0
var dir = Vector3()
var input = Vector3()
var floor_normal = Vector3.UP
var snap = Vector3.DOWN
var move_blend = 0.0
var jump_blend = 0.0
var stop_on_slope = false
var max_slope = deg2rad(40.0)
var jumping = false
var moving = false
var can_run = false
var can_attack = false
var anim = ANIM_WALK
var attack_state = 0

var state
enum { WALK, JUMP, ATTACK }

const ANIM_WALK = 0
const ANIM_JUMP= 1
const ANIM_ATTACK= 2
const BLEND_MINIMUM = 0.5
const RUN_JUMPD_BLEND_AMOUNT = 0.05
const IDLE_BLEND_AMOUNT = 0.2
const JUMPU_BLEND_AMOUNT = 0.1


func _physics_process(delta):
	
	animate()
	velocity.x = 0.0
	velocity.z = 0.0
	input = Vector3.ZERO
	
	if(Input.is_action_pressed("forward")):
		input.z += 1
		speed = 14
		moving = true
		can_run = false
		can_attack = true

	if(Input.is_action_pressed("backward")):
		input.z -= 1
		speed = 8.0
		moving = true
		can_run = false
		can_attack = true

	if(Input.is_action_pressed("left")):
		input.x += 1
		speed = 8.0
		moving = true
		can_run = false

	if(Input.is_action_pressed("right")):
		input.x -= 1
		speed = 8.0
		moving = true
		can_run = false
		can_attack = true
		
	if(Input.is_action_just_pressed("run")):
		can_run = true

	if can_run:
		input.z += 1
		speed = 14.0
		moving = true
		can_attack = true

		
	input = input.normalized()
	
	dir = (transform.basis.z * input.z + transform.basis.x * input.x)
	
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	
	velocity.y += gravity * delta
	
	if velocity.y < max_gravity:
		velocity.y = max_gravity
		
	if(Input.is_action_just_pressed("jump")) and is_on_floor():
		snap = Vector3.ZERO
		velocity.y = jump_height
		jumping = true
		moving = true
		can_run = false
	else:
		snap = Vector3.DOWN
	
	stop_on_slope = true if get_floor_velocity().x == 0 and get_floor_velocity().z == 0 else false

	velocity = move_and_slide_with_snap(velocity,snap,floor_normal, stop_on_slope ,1, max_slope)
	
	if is_on_floor() and velocity.y < 0:
		velocity.y = 0.0
		jumping = false
		can_attack = false


func change_state(new_state):
	state = new_state
	match state:
		WALK:
			anim = ANIM_WALK
		JUMP:
			anim = ANIM_JUMP
		ATTACK:
			anim = ANIM_ATTACK
	
func animate():
	
	var animate = $Char/AnimationTree
	var walkblend = Vector2(input.x,input.z)
	
	if jumping:
		if (velocity.y > 0):
			change_state(JUMP)
			jump_blend -= JUMPU_BLEND_AMOUNT
			jumping = true
		else:
			jump_blend += IDLE_BLEND_AMOUNT
			jumping = false

	else:
		if dir.length() < BLEND_MINIMUM:
			moving = false
		
		if moving:
			can_attack = true
			change_state(WALK)
			move_blend -= RUN_JUMPD_BLEND_AMOUNT
		
		if !moving:
			can_attack = true
			change_state(WALK)
			move_blend += RUN_JUMPD_BLEND_AMOUNT
		
		if moving and can_attack:
			if(Input.is_action_pressed("attack")):
				change_state(ATTACK)
				
		if !moving and can_attack:
			if(Input.is_action_pressed("attack")):
				change_state(ATTACK)
				attack_state += RUN_JUMPD_BLEND_AMOUNT
			if(Input.is_action_just_released("attack")):
				change_state(WALK)
				attack_state -= RUN_JUMPD_BLEND_AMOUNT

		if (velocity.y < 0) and !jumping:
			change_state(JUMP)
			jump_blend += IDLE_BLEND_AMOUNT
			jumping = false
			
			
	move_blend = clamp(move_blend,0,1.0)
	jump_blend = clamp(jump_blend,0,1.0)
	attack_state = clamp(attack_state,0,1.0)
	animate["parameters/Move/8/Blend2/blend_amount"] = move_blend
	animate["parameters/Jump/8/Blend2/blend_amount"] = jump_blend
	animate["parameters/Attack/8/Blend2/blend_amount"] = attack_state
	animate["parameters/Jump/blend_position"] = walkblend
	animate["parameters/Move/blend_position"]= walkblend
	animate["parameters/Attack/blend_position"]= walkblend
	animate["parameters/State/current"]=anim
