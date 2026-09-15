extends Area3D

@export_category("Blues Track Data")
@export var song_title: String = ""
@export var artist_name: String = ""

@export_category("Audio Settings")
@export var fade_duration: float = 1.0 # Standardized to a snappy 1.0 second fade out
@export var target_volume_linear: float = 1.0

var volume_tween: Tween

# FIXED: Now scans internally down its own children list, perfect for our clean hierarchy!
func find_speaker() -> AudioStreamPlayer3D:
	for child in get_children():
		if child is AudioStreamPlayer3D:
			return child
	return null

func _ready() -> void:
	var target_speaker = find_speaker()
	if target_speaker:
		target_speaker.volume_linear = 0.0
		if not target_speaker.playing:
			target_speaker.play()
	else:
		print("CRITICAL AUDIO ERROR: No AudioStreamPlayer3D node found inside: ", name)

func fade_volume(target_linear: float) -> void:
	var target_speaker = find_speaker()
	
	if target_speaker == null:
		return

	if volume_tween and volume_tween.is_valid():
		volume_tween.kill()
	
	volume_tween = create_tween()
	var property_tweener = volume_tween.tween_property(target_speaker, "volume_linear", target_linear, fade_duration)
	
	if property_tweener != null:
		property_tweener.set_trans(Tween.TRANS_SINE)
		property_tweener.set_ease(Tween.EASE_OUT)

func _on_body_entered(body: Node3D) -> void:
	# Ignore everything except your player character capsule body layout
	if not (body.name.begins_with("Character") or body is CharacterBody3D):
		return
		
	print("SUCCESS: Player entered trigger: ", body.name)
	fade_volume(target_volume_linear)
	
	# --- OPTION A POP-UP SYSTEM LINK ---
	# Assigns this specific venue node reference to the player's interact memory slot
	if "current_venue_zone" in body:
		body.current_venue_zone = self
	
	# FIXED: Transmits 'self' so the screen UI can successfully read your new text formatting entries!
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal("track_changed"):
		bus.track_changed.emit(self)

func _on_body_exited(body: Node3D) -> void:
	if not (body.name.begins_with("Character") or body is CharacterBody3D):
		return
		
	print("SUCCESS: Player left trigger: ", body.name)
	fade_volume(0.0)
	
	# --- OPTION A CLEANUP ---
	# Checks if the player is still holding this venue, then safely clears the interact target
	if "current_venue_zone" in body and body.current_venue_zone == self:
		body.current_venue_zone = null
	
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal("track_cleared"):
		bus.track_cleared.emit()
