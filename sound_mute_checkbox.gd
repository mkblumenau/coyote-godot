extends CheckBox

# Called when the node enters the scene tree for the first time.
func _ready():
	set_pressed_no_signal(!$/root/GlobalVariables.isSFXMuted())


func _on_toggled(toggled_on: bool) -> void:
	$/root/GlobalVariables.setSFXOn(toggled_on)
