extends CharacterBody3D

@onready var game_rig = $game_rig
@onready var spring_arm_pivot = $springArmPivot
@onready var focus_point = $springArmPivot/focusPoint
@onready var spring_arm = $springArmPivot/focusPoint/SpringArm3D
@onready var animation_tree = $AnimationTree

@export var mouse_sensitivity = 0.005
@export var controller_sensitivity = 5


const LERP_VAL = .3
const SPEED = 4.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



	
	

func _unhandled_input(event): 
	if event.is_action_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if Input.is_action_just_pressed("ui_cancel"):
				get_tree().quit()
	
		
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		spring_arm_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		focus_point.rotate_x(-event.relative.y * mouse_sensitivity)
#	
			
		
		

	
func apply_controller_rotation():
	var axis_vector = Vector2.ZERO
	axis_vector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		spring_arm_pivot.rotate_y(deg_to_rad(-axis_vector.x) * controller_sensitivity)
		focus_point.rotate_x(deg_to_rad(-axis_vector.y)* controller_sensitivity)

		

		
		


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	apply_controller_rotation()
	focus_point.rotation.x = clamp(focus_point.rotation.x, deg_to_rad(-80), deg_to_rad(35))
	

	
	
	
	
	


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		
		game_rig.rotation.y = lerp_angle(game_rig.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		velocity.x = lerp(velocity.x, direction.x * 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * 0.0, LERP_VAL)
		
	animation_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / SPEED)

	move_and_slide()
