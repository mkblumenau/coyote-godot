extends Node

#variables

#reference to the game log

# These define which numbers are used as the placeholders for
# the Max Zero and Question cards respectively.
var MAX_ZERO_VALUE = 100
var QUESTION_VALUE = 99

var DEFAULT_STARTING_BID = -16
var CHALLENGE_WAIT_TIME: float = 4 # in seconds

var deck = []
@export var currentPlayer: Node
var isFirstTurnOfRound = true
var currentBid = -16
var middleCard = 0
var allCardsVisible = false
var cardDealtFromQuestion = 0

@export var playerTemplate: PackedScene #The template for a new player.
var gameLog

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	gameLog = $UICanvas/GameLog/VBoxContainer/GameLogText
	var newPlayer
	#print(str($/root/GlobalVariables.playerCount))
	# Create the right number of players as children.
	# Reparent them all to PlayerGrid.
	# Make the first player in the list the player whose turn it is.
	# Make sure the first player to be created is a human.
	for i in range($/root/GlobalVariables.playerCount + 1):
		newPlayer = playerTemplate.instantiate()
		#newPlayer.reparent($PlayerGrid)
		$PlayerGrid.add_child(newPlayer)
		if i == 0:
			newPlayer.isHumanPlayer = true
			newPlayer.isUIPlayer = true
			newPlayer.updateName("Player")
		else:
			newPlayer.updateName("Comp" + str(i))
		$PlayerGrid.move_child($PlayerGrid/MiddleCard, -1)
	
	currentPlayer = players()[0]
	#print(players()[0])
	setUpRound()
	startTurn()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var playerToUse = currentPlayer
	for p in players():
		if p.isUIPlayer:
			playerToUse = p
	
	$UICanvas/TotalVisibleToPlayer.text = "Total visible: " + playerToUse.totalKnownToPlayerAsString()
	pass


func livingPlayers():
	# Returns a list of all living players.
	# Use len(livingPlayers()) to get living player count.
	return players().filter(func(player): return player.isAlive())


func players():
	# Returns a list of all players.
	return $PlayerGrid.get_children().filter(func(player): return player.is_in_group("Player"))


func nextLivingPlayer(player):
	# Get the next living player after a specific player.
	# This and lastLivingPlayer exist instead of just using lastLivingPlayerNew
	# because I made them before writing nextLivingPlayerNew.
	return nextLivingPlayerNew(player, true)


func lastLivingPlayer(player):
	# Get the previous living player after a specific player.
	return nextLivingPlayerNew(player, false)


func nextLivingPlayerNew(player, direction):
	# Return the next living player in a direction.
	# true = forward/in turn order
	# false = backward/against turn order
	# This doesn't use livingPlayers() just in case player is dead.
	
	var index = players().find(player)
	var currentPlayerNLP = player
	
	var indexChange = 1
	
	if direction:
		indexChange = 1
	else:
		indexChange = -1
		
	if len(livingPlayers()) < 2:
		"""
		Error checking: If there's one or less living players,
		don't bother cycling through the list.
		Just return the same player as the input.
		I don't think this would ever be an issue.
		"""
		return player
	else:
		while true:
			# Change the index in the specified direction,
			# making sure it doesn't go out of bounds.
			# Then if the player at that index is alive, return them.
			index += indexChange
			index = wrapi(index, 0, len(players()))
			currentPlayerNLP = players()[index]
			if currentPlayerNLP.isAlive():
				return currentPlayerNLP


func setUpRound():
	# Resets everything for a new round.
	# However, this doesn't automatically start the turn.
	makeDeck()
	dealOutCards()
	resetPeeks()
	currentBid = DEFAULT_STARTING_BID
	isFirstTurnOfRound = true
	$PlayerGrid/MiddleCard.card = middleCard


func makeDeck():
	# Creates a fresh deck.
	deck.clear()
	deck.append(-10)
	deck.append(-5)
	for i in range(11):
		deck.append(i)
	deck.append(15)
	deck.append(20)
	deck.append(MAX_ZERO_VALUE)
	deck.append(QUESTION_VALUE)
	deck.shuffle()


func dealOutCards():
	# Deals the top cards from the deck out to each living player.
	# Also to the middle as well as a spot reserved for if ? is in play.
	var i = 0
	for player in players():
		if player.isAlive():
			player.card = deck[i]
			i += 1
		else:
			player.card = 0
	middleCard = deck[i]
	i += 1
	cardDealtFromQuestion = deck[i]
	pass


func resetPeeks():
	# Resets whether players peeked.
	for player in players():
		if player.isAlive():
			player.canSeeMiddleCard = false
		else:
			player.canSeeMiddleCard = true


func cardTranslated(cardNumber):
	# Expresses a card number as text.
	# Used by the game log.
	if cardNumber == MAX_ZERO_VALUE:
		return "Max 0"
	elif cardNumber == QUESTION_VALUE:
		return "?"
	else:
		return str(cardNumber)


func startTurn():
	# Start a turn without changing whose turn it is.
	#print(currentPlayer)
	if currentPlayer.isHumanPlayer:
		# show the interface and set the minimum bid to the current + 1
		#$UICanvas/BidInput.min_value = currentBid + 1
		$UICanvas/BidInput.value = currentBid + 1
		showPlayerUI()
		pass
	else:
		# call the script for the AI turn
		currentPlayer.startAITurn()
		pass


func nextPlayersTurn():
	#print(nextLivingPlayer(currentPlayer).get_name())
	currentPlayer = nextLivingPlayer(currentPlayer)
	startTurn()


func lastPlayerNewTurn():
	currentPlayer = lastLivingPlayer(currentPlayer)
	startTurn()


func specificPlayerStartTurn(player):
	# Have a specific player start a turn.
	currentPlayer = player
	startTurn()


func raiseBid(newBid):
	# Called by a player script whenever the bid is raised.
	#print($PlayerGrid.get_children())
	currentBid = newBid
	currentPlayer.canChallengeThisRound = true
	isFirstTurnOfRound = false
	#update the game log
	#$UICanvas/GameLog/VBoxContainer/GameLogText.add_text(currentPlayer.get_name() + " raised the bid to " + str(newBid) + ".")
	gameLog.addText(currentPlayer.get_name() + " raised the bid to " + str(newBid) + ".")
	nextPlayersTurn()
	#print(str(newBid))


func cardTotal():
	# Returns the total of all cards in play.
	var total = 0
	var maxCard = -16
	var questionFound = false
	var maxZeroFound = false
	for p in livingPlayers():
		if p.card == MAX_ZERO_VALUE:
			maxZeroFound = true
		elif p.card == QUESTION_VALUE:
			questionFound = true
		else:
			if p.card > maxCard:
				maxCard = p.card
			total += p.card
			
	if middleCard == MAX_ZERO_VALUE:
		maxZeroFound = true
	elif middleCard == QUESTION_VALUE:
		questionFound = true
	else:
		if middleCard > maxCard:
			maxCard = middleCard
		total += middleCard
		
	if questionFound:
		if cardDealtFromQuestion == MAX_ZERO_VALUE:
			maxZeroFound = true
		else:
			if cardDealtFromQuestion > maxCard:
				maxCard = cardDealtFromQuestion
			total += cardDealtFromQuestion
			
	if maxZeroFound:
		total -= maxCard
		
	return total


func challengerWins():
	# Return whether or not the challenging player wins.
	return currentBid > cardTotal()


func resolveChallenge():
	# Resolve a challenge.
	# If the player who lost is dead after the challenger,
	# the player after them takes the next turn.
	$ChallengeTimer.start()
	# The timer is used for the coroutine in startChallenge().
	# Basically it's there to make sure that the game pauses to wait out the challenge.
	var challenger = currentPlayer
	var bidder = lastLivingPlayer(currentPlayer)
	var questionSeen = false
	# Tell the game log what all the cards were.
	gameLog.addText(challenger.get_name() + " challenged " + bidder.get_name() + "'s bid of " + str(currentBid) + ".")
	gameLog.addText("The total was " + str(cardTotal()) + ".")
	# actually say the card names here
	gameLog.addText("The middle card was " + cardTranslated(middleCard))
	if middleCard == QUESTION_VALUE:
		questionSeen = true
		
	for p in players():
		if p.isAlive():
			gameLog.addText(p.get_name() + " had " + cardTranslated(p.card))
			if p.card == QUESTION_VALUE:
				questionSeen = true
	
	if questionSeen:
		gameLog.addText("The card drawn from ? was " + cardTranslated(cardDealtFromQuestion))
	
	#Resolve the challenge.
	if challengerWins():
		gameLog.addText(challenger.get_name() + " won the challenge.")
		gameLog.addText("---")
		challenger.openEye()
		bidder.loseEye()
		#setUpRound()
		if bidder.isAlive():
			#specificPlayerStartTurn(bidder)
			currentPlayer = bidder
		else:
			if len(livingPlayers()) <= 1:
				victory(challenger)
			else:
				#specificPlayerStartTurn(challenger)
				currentPlayer = challenger
	else:
		# if the bidder wins
		gameLog.addText(bidder.get_name() + " won the challenge.")
		gameLog.addText("---")
		bidder.openEye()
		challenger.loseEye()
		#setUpRound()
		if challenger.isAlive():
			#specificPlayerStartTurn(challenger)
			currentPlayer = challenger
		else:
			if len(livingPlayers()) <= 1:
				victory(bidder)
			else:
				currentPlayer = nextLivingPlayer(challenger)
				#startTurn()
	pass


func startChallenge():
	#Calls resolveChallenge(), then waits a while before starting the next turn.
	resolveChallenge()
	await $ChallengeTimer.timeout
	# Only start the turn if more than one player is still alive.
	# Before I fixed this, there was an amusing bug where the winning player
	# would just continue to play forever against themselves.
	if len(livingPlayers()) > 1:
		setUpRound()
		startTurn()


func victory(player):
	#Tell the game log that player won.
	gameLog.addText(player.get_name() + " wins!")
	pass


func sendPeekToGameLog(player):
	# Tell the game log that that player peeked.
	# Called by player scripts.
	gameLog.addText(player.get_name() + " peeked.")
	pass


func showPlayerUI():
	$UICanvas/RaiseBidButton.show()
	$UICanvas/PeekButton.show()
	$UICanvas/ChallengeButton.show()
	$UICanvas/BidInput.show()


func hidePlayerUI():
	$UICanvas/RaiseBidButton.hide()
	$UICanvas/PeekButton.hide()
	$UICanvas/ChallengeButton.hide()
	$UICanvas/BidInput.hide()


func _on_raise_bid_button_pressed():
	hidePlayerUI()
	if $UICanvas/BidInput.value > currentBid:
		raiseBid($UICanvas/BidInput.value)
	else:
		raiseBid(currentBid + 1)


func _on_challenge_button_pressed():
	if not isFirstTurnOfRound:
		if currentPlayer.canChallengeThisRound:
			hidePlayerUI()
			startChallenge()


func _on_peek_button_pressed():
	if not isFirstTurnOfRound:
		if currentPlayer.eyesOpen > 0:
			if currentPlayer.canChallengeThisRound:
				currentPlayer.peek()


func _on_return_to_main_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_open_menu_button_pressed():
	$Menu.show()


func _on_close_menu_button_pressed():
	$Menu.hide()


func _on_rules_button_pressed():
	$RulesMenu.show()
	$Menu.hide()
