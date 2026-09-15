# track_title_card.gd
extends Control

@onready var venue_label: Label = $Panel/VBoxContainer/VenueLabel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var artist_label: Label = $Panel/VBoxContainer/ArtistLabel
@onready var panel: PanelContainer = $Panel

var ui_tween: Tween

func _ready() -> void:
	# Keep our scale corrections active to block the layout bug
	scale = Vector2(1.0, 1.0)
	panel.scale = Vector2(1.0, 1.0)
	
	# Layout enforcement constraints
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	panel.custom_minimum_size.y = 150
	
	# PRODUCTION LIGHTS: Force the panel completely invisible on boot
	modulate.a = 0.0
	
	# ENGINE STABILIZER: Wait 0.1 seconds for the game world to initialize 
	# before connecting the signals. This clears out frame-one ghost collisions!
	await get_tree().create_timer(0.1).timeout
	
	# Connect to our absolute root path safely to capture the street triggers
	var bus = get_node_or_null("/root/EventBus")
	if bus != null:
		if bus.has_signal("track_changed"):
			bus.track_changed.connect(_show_track)
		if bus.has_signal("track_cleared"):
			bus.track_cleared.connect(_hide_track)


func _show_track(venue_node: Node) -> void:
	# 1. Start with the incoming node's name as a baseline
	var venue_name = venue_node.name.replace("_", " ")
	var track_title = "Live Blues Session"
	var artist_name = "Traditional New Orleans"
	
	var data_source: Node = venue_node
	
	# 2. If the parent node was sent, target the ListeningZone child where the script lives
	if venue_node.has_node("ListeningZone"):
		data_source = venue_node.get_node("ListeningZone")
	
	# 3. Safely extract your custom data fields from the verified source
	if "song_title" in data_source: 
		track_title = data_source.song_title
	if "artist_name" in data_source: 
		artist_name = data_source.artist_name

	# 4. Format and push strings to your UI labels
	venue_label.text = venue_name.to_upper()
	title_label.text = '"' + track_title + '"'
	
	# --- INTEGRATION UPDATED INSTRUCTION STRING ---
	# Appends clear instructions right onto the artist subtitle text field for web players
	artist_label.text = "Music By: " + artist_name + "   |   [ Press E for Video ]   |   (Note: Click inside game window to resume mouse camera)"
	
	# 5. Handle smooth fade animation over 0.4 seconds
	if ui_tween and ui_tween.is_valid():
		ui_tween.kill()
		
	ui_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	ui_tween.tween_property(self, "modulate:a", 1.0, 0.4)


func _hide_track() -> void:
	# Smoothly fade out into the dark when walking in dead-zones between venues
	if ui_tween and ui_tween.is_valid():
		ui_tween.kill()
		
	ui_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	ui_tween.tween_property(self, "modulate:a", 0.0, 0.3)
