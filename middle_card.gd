extends Control

var card = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	setSprite()
	pass


func setSprite():
	""" Sets the sprite to a file based on what card it is. """
	#$Sprite2D.set_texture(load("res://assets/images/cards/Back.png"))
	var path = "res://assets/images/cards/"
	var isVisible = true
	
	for p in playersList():
		if p.isUIPlayer and not p.canSeeMiddleCard:
			isVisible = false

	if isVisible:
		# Placeholders for before I import the values into/from the game manager.
		if card == 99:
			path += "Question mark"
		elif card == 100:
			path += "Max 0"
		else:
			path += str(card)
	else:
		path += "Back"
	
	path += ".png"
	#print(path)
	$Sprite2D.set_texture(load(path))


func playersList():
	var tempList = get_parent().get_children()
	var output = []
	for i in tempList:
		if i.is_in_group("Player"):
			output.append(i)
	
	return output
