extends AudioStreamPlayer

var SFXBus = AudioServer.get_bus_index("SFX")
@export_category("Sound effects")
@export var raiseSound: AudioStream
@export var peekSound: AudioStream
@export var challengeSound: AudioStream
@export var endGameSound: AudioStream


func playSound(sound):
	if sound != null:
		stream = sound
		play()


func playRaiseSound():
	playSound(raiseSound)

func playPeekSound():
	playSound(peekSound)

func playChallengeSound():
	playSound(challengeSound)
	
func playEndGameSound():
	playSound(endGameSound)
