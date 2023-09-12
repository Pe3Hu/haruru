extends MarginContainer


@onready var dices = $VBox/Dices
@onready var title = $VBox/Title


func roll_dices(count_: int) -> void:
	for _i in count_:
		var dice = Global.scene.dice.instantiate()
		dices.add_child(dice)


func flip_dices(values_: Array) -> void:
	for _i in range(dices.get_child_count()-1, -1, -1):
		var dice = dices.get_child(_i)
		
		if _i < values_.size():
			var value = values_[_i]
			dice.flip_to_value(value)


func get_facet_value_on_dices() -> Array:
	var values = []
	
	for dice in dices.get_children():
		values.append(dice.get_current_facet_value())
	
	return values


func crush_dices() -> void:
	for dice in dices.get_children():
		dices.remove_child(dice)
		dice.queue_free()
