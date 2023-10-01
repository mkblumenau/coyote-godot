extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$StartGameButton.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_option_button_item_selected(index):
	$/root/GlobalVariables.playerCount = index + 1


func _on_start_game_button_pressed():
	get_tree().change_scene_to_file("res://gameplay.tscn")


func _on_rules_button_pressed():
	$RulesMenu.show()
	$RulesMenu/CloseButton.grab_focus()


func _on_close_button_pressed():
	$StartGameButton.grab_focus()
