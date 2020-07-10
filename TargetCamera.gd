extends Spatial

var sens : float = 0.1
var minAngle : float  = -60.0
var maxAngle : float  = 80.0
var Z = 0.0
var ZLerp = 0.0

var PlayerDelta : Vector2 = Vector2()
var CamDelta : Vector2 = Vector2()
var camrotl : Vector2 = Vector2()

onready var player = get_parent()
onready var ray = $Ray
onready var cam = $Camera

func _ready():
	ray.add_exception(get_parent())
	ray.add_exception(get_node("Camera"))

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	
func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _input(ev):
	var toggle = false
	if Input.is_action_pressed("ui_cancel"):
		toggle = true
		if toggle:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if not toggle:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if ev is InputEventMouseMotion and !Input.is_mouse_button_pressed(3):
		PlayerDelta = ev.relative
		rotation.x +=  deg2rad(PlayerDelta.y * sens)
		rotation.x = clamp(rotation.x, deg2rad(minAngle), deg2rad(maxAngle))
		player.rotation.y -= deg2rad(PlayerDelta.x * sens)
		
	if ev is InputEventMouseMotion and Input.is_mouse_button_pressed(3):
		CamDelta = ev.relative
		rotation.x +=  deg2rad(CamDelta.y * sens)
		rotation.x = clamp(rotation.x, deg2rad(minAngle), deg2rad(maxAngle))
		rotation.y -= deg2rad(CamDelta.x * sens)
	if !Input.is_mouse_button_pressed(3):
		rotation.y = 0.0
	
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_WHEEL_UP:
			Z = max(Z - 0.2, 0.0)

		elif ev.button_index == BUTTON_WHEEL_DOWN:
	
			Z = min(Z + 0.2, 8.0)

func _process(delta):
	camrotl = camrotl.linear_interpolate(CamDelta, 5.0 * delta)
	ZLerp = lerp(ZLerp, Z, 5.0 * delta)

	if ray.is_colliding():
		cam.global_transform.origin = ray.get_collision_point() + Vector3(0.0,0.5,0.0)
	else:
		cam.translation = Vector3(ray.cast_to.x,ray.cast_to.y, -ray.cast_to.z + ZLerp)


