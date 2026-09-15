extends CharacterBody3D

const SPEED = 5.0

# --- 1. NEW MOUSE CONTROL SETTINGS ---
# Lower values stop the wild browser flailing
@export var mouse_sensitivity: float = 0.0015 

@export_group("Vertical View Limits")
@export_range(-85.0, 85.0) var min_pitch: float = -45.0 # Max look up angle
@export_range(-85.0, 85.0) var max_pitch: float = 45.0  # Max look down angle

@export_group("Horizontal View Limits")
@export var limit_yaw: bool = true
@export_range(-180.0, 180.0) var min_yaw: float = -60.0 # Max left turn angle
@export_range(-180.0, 180.0) var max_yaw: float = 60.0  # Max right turn angle

# Internal tracking to prevent calculation feedback loops
var _camera_pitch: float = 0.0
var _player_yaw: float = 0.0

@onready var camera: Camera3D = $Camera3D

# --- TASK 3 UI & INTERACTION TRACKING ---
# Tracks the specific venue node the player is currently standing inside
var current_venue_zone: Node3D = null

func _ready() -> void:
	# Traps the mouse cursor inside the game runtime window
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Establish baseline angles from current scene positions
	_player_yaw = rotation.y
	if camera:
		_camera_pitch = camera.rotation.x

func _input(event: InputEvent) -> void:
	# --- CRITICAL WEB FIX: SECURE EXPLICIT CLICK CAPTURE ---
	# Browsers require a physical click inside the canvas to unlock mouse look-around data!
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				get_viewport().set_input_as_handled() # Prevents click from misfiring UI elements

	# Using _input ensures it fires past the UI layer once filters are ignored!
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# 2. PROCESSED MOUSE MOVEMENT MATH
		# Accumulate movements with the sensitivity scalar applied
		_camera_pitch -= event.relative.y * mouse_sensitivity
		_player_yaw -= event.relative.x * mouse_sensitivity
		
		# Clamp vertical view boundaries
		_camera_pitch = clamp(_camera_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		
		# Clamp horizontal view boundaries if checked
		if limit_yaw:
			_player_yaw = clamp(_player_yaw, deg_to_rad(min_yaw), deg_to_rad(max_yaw))
		
		# Apply stable rotations to prevent raw frame flailing
		if camera:
			camera.rotation.x = _camera_pitch
		rotation.y = _player_yaw

	# Press Escape to toggle the cursor out for web browser testing
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	# --- INTERACT KEY LISTENER ('E') ---
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if current_venue_zone != null:
			trigger_venue_video()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Walk relative to wherever your camera is pointing!
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# --- TASK 3 INTERACTION & LINK OPENER ---
func trigger_venue_video() -> void:
	if not current_venue_zone:
		return
		
	print("Opening video track link for: ", current_venue_zone.name)
	
	# Target your exact node name directly
	var venue_audio: AudioStreamPlayer3D = current_venue_zone.get_node_or_null("BarSpeaker")
	
	if venue_audio and venue_audio.playing:
		# Store the exact timestamp of the music playback so it doesn't reset to 0
		current_venue_zone.set_meta("paused_playback_position", venue_audio.get_playback_position())
		venue_audio.stop()
		print("SUCCESS: BarSpeaker found and paused.")
	else:
		print("WARNING: Active BarSpeaker node not found or not playing.")
	
	# Release mouse lock so the player can naturally move their cursor in the web browser
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Fallback channel URL leading directly to your artist handle
	var target_url: String = "https://youtube.com"
	
	# Check if this specific venue node has an individual custom URL metadata tag
	if current_venue_zone.has_meta("youtube_url"):
		target_url = current_venue_zone.get_meta("youtube_url")
	
	# --- WEB CHANNELS NATIVE JAVASCRIPT POP-UP COMPATIBILITY FIX ---
	# Bypasses standard OS.shell_open blocker metrics by using web interfaces directly
	if OS.has_feature("web"):
		var js_window = JavaScriptBridge.get_interface("window")
		if js_window:
			# Opens the target video in a clean, fresh browser window tab seamlessly
			js_window.open(target_url, "_blank")
	else:
		# Standard fallback channel execution if testing locally inside the editor desktop runtime
		OS.shell_open(target_url)

# --- WEB RESUME AUTOMATION LOOP ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		print("Player returned to sandbox tour browser tab. Resuming mechanics...")
		
		# Seamlessly re-capture mouse control automatically
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# If the player is still standing inside the venue area, resume the music right where it left off
		if current_venue_zone:
			var venue_audio: AudioStreamPlayer3D = current_venue_zone.get_node_or_null("BarSpeaker")
			if venue_audio and current_venue_zone.has_meta("paused_playback_position"):
				var resume_pos: float = current_venue_zone.get_meta("paused_playback_position")
				venue_audio.play(resume_pos)
				print("Local venue audio resumed seamlessly at timestamp: ", resume_pos)
