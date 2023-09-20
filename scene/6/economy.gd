extends MarginContainer


@onready var accountants = $Accountants

var sketch = null


func init_accountants() -> void:
	for empire in sketch.cloth.empires.get_children():
		var input = {}
		input.empire = empire
		input.economy = self
		var accountant = Global.scene.accountant.instantiate()
		accountants.add_child(accountant)
		accountant.set_attributes(input)
