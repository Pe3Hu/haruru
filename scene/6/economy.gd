extends MarginContainer


@onready var accountants = $Accountants

var sketch = null


func init_accountants() -> void:
	for realm in sketch.diplomacy.realms.get_children():
		var input = {}
		input.realm = realm
		input.economy = self
		var accountant = Global.scene.accountant.instantiate()
		accountants.add_child(accountant)
		accountant.set_attributes(input)
