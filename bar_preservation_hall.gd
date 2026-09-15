extends StaticBody3D

@onready var speaker = $BarSpeaker

# Duration of the fade in seconds
var fade_time: float = 2.5 

func _ready() -> void:
	speaker.stop() 

# Triggered when the player steps inside the invisible box
func _on_listening_zone_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D":
		# If it's totally stopped, kickstart it at complete silence first
		if not speaker.playing:
			speaker.volume_db = -80.0
			speaker.play()
		
		# Animate smoothly from the CURRENT volume up to full volume (0.0 dB)
		var tween = create_tween()
		tween.tween_property(speaker, "volume_db", 0.0, fade_time)

# Triggered when the player walks away down the street
func _on_listening_zone_body_exited(body: Node3D) -> void:
	if body.name == "CharacterBody3D":
		# Animate smoothly from the CURRENT volume down to silent (-80.0 dB)
		var tween = create_tween()
		tween.tween_property(speaker, "volume_db", -80.0, fade_time)
		# Turn off the speaker completely only after the fade finishes
		tween.tween_callback(speaker.stop)
