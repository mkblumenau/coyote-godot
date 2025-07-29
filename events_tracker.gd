extends Node

"""
This script handles tracking events for the game log and the last event line.
"""

@export var gameManager: Node
@export var gameLogText: Node
@export var lastActionText: Node
@export var lineBreak: String
@export var roundBreak: String

var gameLog: Array[String]


func clearLog():
	gameLog.clear()
	updateLogText()


func gameLogReversed():
	var gl = gameLog.duplicate()
	gl.reverse()
	return gl


func updateLogText():
	gameLogText.set_text(getGameLogTextReversed())


func addLogLine(textToAdd):
	gameLog.append(textToAdd)
	updateLogText()


func addLineBreak():
	addLogLine(lineBreak)

func addRoundBreak():
	addLogLine(roundBreak)


# Returns the game log in text form.
func getGameLog():
	return "\n".join(gameLog)


func getGameLogTextReversed():
	return "\n".join(gameLogReversed())


# Saves the game log to a file.
func saveLogTextToFile():
	var time = Time.get_datetime_dict_from_system(false)
	var outputFilename = "user://"
	#var outputFilename = "user://Documents/BoggleGodot/"
	outputFilename += "Coyote_Game_"
	
	var fooString = "%02d-%02d-%02d" % [time["year"], time["month"], time["day"]]
	outputFilename += fooString + "_"
	
	fooString = "%02d_%02d_%02d" % [time["hour"], time["minute"], time["second"]]
	outputFilename += fooString + ".txt"
	
	var file = FileAccess.open(outputFilename, FileAccess.WRITE)
	#print(file)
	file.store_string(getGameLogTextReversed())
	addLogLine("The game log was saved.")


# Updates the last action element of the UI.
func updateLastAction():
	var gl = gameLogReversed()
	var textToUse = " "
	
	for i in gl:
		if i not in [lineBreak, roundBreak]:
			textToUse = i
			break
	lastActionText.set_text(textToUse)
