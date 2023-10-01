extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func addText(string):
	# Call this to add a line to the game log.
	addLineToBeginning(string)


# These two functions exist so it's easy to change in addText
# if you want the new lines to go on the end.
func addLineToBeginning(string):
	set_text(string + "\n" + get_text())


func addLineToEnd(string):
	set_text(get_text() + "\n" + string)


func logInReverseOrder():
	""" Returns the game log in reverse order.
	Assuming that each new line goes at the top of the game log, 
	resulting in reverse chronological order (newest first),  
	this should return them in regular chronological order  
	(starting at the first event and ending at the newest). """
	var splitLog = get_text().split("\n")
	splitLog.reverse()
	return "\n".join(splitLog)


func saveTextToFile():
	# Saves the game log to a file.
	var time = Time.get_datetime_dict_from_system(false)
	var outputFilename = "user://"
	#var outputFilename = "user://Documents/BoggleGodot/"
	outputFilename += "Coyote_Game_"
	
	var fooString = "%02d-%02d-%02d" % [time["year"], time["month"], time["day"]]
	outputFilename += fooString + "_"
	
	fooString = "%02d_%02d_%02d" % [time["hour"], time["minute"], time["second"]]
	outputFilename += fooString + ".txt"
	
	var outputString = logInReverseOrder()
	
	var file = FileAccess.open(outputFilename, FileAccess.WRITE)
	#print(file)
	file.store_string(outputString)
	addText("The game log was saved.")


func _on_save_to_file_button_pressed():
	saveTextToFile()
