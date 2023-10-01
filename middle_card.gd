extends Control

var card = 0
var gameplayScript

# Called when the node enters the scene tree for the first time.
func _ready():
	gameplayScript = $/root/Gameplay # get the script for the main gameplay actions
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
	
	for p in gameplayScript.players():
		if p.isUIPlayer and not p.canSeeMiddleCard:
			isVisible = false
			
	if gameplayScript.allCardsVisible:
		isVisible = true

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
