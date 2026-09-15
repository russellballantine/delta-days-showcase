# event_bus.gd
extends Node

# Broadcasts data when a venue becomes active (accepts any variable/object)
signal track_changed(track_data)

# Broadcasts when the player leaves a venue completely
signal track_cleared()
