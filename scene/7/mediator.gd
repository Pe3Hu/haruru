extends MarginContainer


@onready var rl = $VBox/Realm
@onready var purse = $VBox/Purse
@onready var warehouse = $VBox/Warehouse

var realm = null


func set_attributes(input_: Dictionary):
	realm = input_.realm
	rl.text = "Realm " + str(realm.index)
	purse.set_attributes(input_)
