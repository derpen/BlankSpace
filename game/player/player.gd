class_name PlayerController extends CharacterBody3D

@export var move_speed : float = 5.0
@export var mouse_sensitivity : float = 1.0

@export_group("Default values;Do not touch")
@export var current_camera : Camera3D
@export var head : Node3D
@export var raycaster : InteractRaycaster
@export var player_state : PLAYER_STATE = PLAYER_STATE.WALKING
@export var dialogue_handler : DialogueHandler
@export var screen_fader : ScreenFader
@export var item_notification : ItemNotification
@export var light_ambient : SpotLight3D
#@export var light_flashlight : SpotLight3D

var mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CAPTURED
var enable_cam : bool = true
var inventory : Dictionary

enum PLAYER_STATE { WALKING, INTERACTING, DISABLED }

func _ready() -> void:
	Input.set_mouse_mode(mouse_mode)

	#GlobalsManager.player_node = self


var camera_motion : Vector2i
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_motion = event.relative

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q and OS.is_debug_build():
			_toggle_mouse_mode()
	

## Will always walk
func _set_player_state_walking() -> void:
	player_state = PLAYER_STATE.WALKING


## Will always disabled
func _set_player_state_disabled() -> void:
	player_state = PLAYER_STATE.DISABLED


func _set_player_state(new_state: int) -> void:
	player_state = new_state as PLAYER_STATE


## Hopefully only used in Debug mode
func _toggle_mouse_mode() -> void:
	if mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_mode = Input.MOUSE_MODE_VISIBLE
		enable_cam = false
	else:
		mouse_mode = Input.MOUSE_MODE_CAPTURED
		enable_cam = true

	Input.set_mouse_mode(mouse_mode)


func _change_mouse_mode(new_mouse_mode : Input.MouseMode) -> void:
	mouse_mode = new_mouse_mode
	if mouse_mode == Input.MOUSE_MODE_VISIBLE:
		enable_cam = false
	elif mouse_mode == Input.MOUSE_MODE_CAPTURED:
		enable_cam = true

	Input.set_mouse_mode(mouse_mode)


## Left right
func _handle_yaw(current_camera_motion: Vector2i) -> void:
	rotate_y(-current_camera_motion.x * mouse_sensitivity * 0.01)


## Up down
func _handle_pitch(current_camera_motion: Vector2i) -> void:
	head.rotate_x(-current_camera_motion.y * mouse_sensitivity * 0.01)
	head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)


func _physics_process(_delta: float) -> void:
	if player_state == PLAYER_STATE.WALKING:
		var input_velocity_z : float = Input.get_axis("move_backward", "move_forward")
		var input_velocity_x : float = Input.get_axis("move_left", "move_right")

		var input_velocity : Vector3 = -transform.basis.z * input_velocity_z + transform.basis.x * input_velocity_x
		input_velocity = input_velocity.normalized() * move_speed

		## Cringe slope hack
		var floor_normal : Vector3 = get_floor_normal()
		if floor_normal != Vector3.ZERO and input_velocity.x != 0.0 and input_velocity_z != 0.0:
			input_velocity.y = 10.0

		velocity = input_velocity + get_gravity()

		if enable_cam:
			_handle_yaw(camera_motion)
			_handle_pitch(camera_motion)

		camera_motion = Vector2.ZERO


		#if velocity.x != 0 or velocity.z != 0:
			#if !footstep_audio_playing:
				#footstep_audio.play_one_shot()
				#footstep_audio_playing = true
				#_footstep_cooldown()

		move_and_slide()
	

#var footstep_audio_playing : bool = false
#func _footstep_cooldown() -> void:
	#await get_tree().create_timer(0.5).timeout
	#footstep_audio_playing = false

## TODO
## Should play audio here
func _give_item(item: String) -> void:
	if item not in inventory:
		inventory[item] = item
		item_notification._show_item_received(item)


func _remove_item(item: String) -> void:
	if item in inventory:
		inventory.erase(item)
		item_notification._show_item_removed(item)


func _check_item(item: String) -> bool:
	## if its empty, just return true right away
	if item.is_empty():
		return true

	var result : bool
	if item in inventory:
		result = true
	else:
		result = false

	return result
