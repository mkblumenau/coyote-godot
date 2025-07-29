extends Node

"""
This is a global script; it runs in all scenes and is not reset between them.
It's used for data that's accessed between scenes,
such as the number of players to start a game
and the state of the sound server.
"""

var playerCount: int = 2
var SFXBus = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(get_path())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setSFXOn(newState):
	AudioServer.set_bus_mute(SFXBus, not newState)


func isSFXMuted():
	return AudioServer.is_bus_mute(SFXBus)


func toggleSFX():
	setSFXOn(isSFXMuted())
