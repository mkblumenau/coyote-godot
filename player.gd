extends Control

"""
This script is attached to a node representing a player.
It displays the player's information, takes turns for computer players,
and handles player variables such as their number of eyes.
"""


@export var isHumanPlayer: bool = false
@export var isUIPlayer: bool = false
var card: int = 0
var eyesTotal = 3
var eyesOpen = 2
var canSeeMiddleCard = false
var gameplayScript
var canChallengeThisRound = true


# AI variables
var AIWaitTime: float = 3
var AILowBound = -15
var AIHighBound = 35


# Called when the node enters the scene tree for the first time.
func _ready():
	gameplayScript = $/root/Gameplay # get the script for the main gameplay actions
	#card = -30
	#updateName("foo")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	setSprite()
	#$PlayerName.set_text(self.get_name())
	$VBoxContainer/EyesCount.set_text(eyesCountWrittenOut())
	if isTurn():
		$TurnIndicator.show()
	else:
		$TurnIndicator.hide()
	pass


func loseEye():
	if eyesTotal > 0:
		eyesTotal -= 1
	if eyesOpen > eyesTotal:
		eyesOpen = eyesTotal


func openEye():
	if eyesOpen < eyesTotal:
		eyesOpen += 1


func peek():
	if eyesOpen > 0:
		eyesOpen -= 1
	canSeeMiddleCard = true
	canChallengeThisRound = false
	# send peek notification to the game log
	gameplayScript.sendPeekToGameLog(self)
	gameplayScript.sfx.playPeekSound()


func isAlive():
	return eyesTotal > 0


# total known to player
func totalKnownToPlayer():
	# Placeholder before I do a better job of writing this.
	# For now this is just for the AI.
	var foo = gameplayScript.cardTotal()
	foo -= card
	if not canSeeMiddleCard:
		foo -= gameplayScript.middleCard
	return foo


# string version of total known to player
func totalKnownToPlayerAsString():
	""" Returns the total that the player can see, in string form. """
	var total = 0
	var maxZeroFound = false
	var questionFound = false
	if gameplayScript.allCardsVisible:
		return str(int(gameplayScript.cardTotal()))
	
	for p in gameplayScript.livingPlayers():
		if p != self:
			if p.card == gameplayScript.MAX_ZERO_VALUE:
				maxZeroFound = true
			elif p.card == gameplayScript.QUESTION_VALUE:
				questionFound = true
			else:
				total += p.card
			
	if canSeeMiddleCard:
		if gameplayScript.middleCard == gameplayScript.MAX_ZERO_VALUE:
			maxZeroFound = true
		elif gameplayScript.middleCard == gameplayScript.QUESTION_VALUE:
			questionFound = true
		else:
			total += gameplayScript.middleCard
		
	var outputString = str(total)
	if questionFound:
		outputString += "?"
		
	if maxZeroFound:
		outputString += " (Max 0)"
		
	return outputString


func eyesCountWrittenOut():
	var outputString = ""
	if eyesTotal > 0:
		"""
		outputString += str(eyesTotal) + " eyes, "
		outputString += str(eyesOpen) + " open"
		"""
		outputString += "O ".repeat(eyesOpen)
		outputString += "C ".repeat(eyesTotal - eyesOpen)
	else:
		outputString = "Out"
	return outputString


#function for the AI action
func AITakeTurn():
	var chanceToChallenge = remap(gameplayScript.currentBid, AILowBound + totalKnownToPlayer(), AIHighBound + totalKnownToPlayer(), 0, 1)
	var randomPick = pow(randf_range(0, 1), 2)
	if randomPick < chanceToChallenge and not gameplayScript.isFirstTurnOfRound:
		gameplayScript.startChallenge()
	else:
		gameplayScript.raiseBid(gameplayScript.currentBid + 1 + randi() % 3)
	

func startAITurn():
	$AIWaitTimer.start()
	await $AIWaitTimer.timeout
	AITakeTurn()


func isTurn():
	#function to return if it's this player's turn
	return gameplayScript.currentPlayer == self


func setSprite():
	"""
	Sets the sprite to a file based on what card it is,
	as well as if the player is alive and/or the human player.
	"""
	#$Sprite2D.set_texture(load("res://assets/images/cards/Back.png"))
	var path = "res://assets/images/cards/"
	
	if isAlive():
		$CardSprite.show()
		if isUIPlayer and not gameplayScript.allCardsVisible:
			path += "Back"
		else:
			if card == 99:
				path += "Question mark"
			elif card == 100:
				path += "Max 0"
			else:
				path += str(card)
		
		path += ".png"
		$CardSprite.set_texture(load(path))
	else:
		$CardSprite.hide()


func updateName(newName):
	""" Updates the name, both of the node and on the display. """
	set_name.call_deferred(newName)
	$VBoxContainer/PlayerName.set_text(newName)
