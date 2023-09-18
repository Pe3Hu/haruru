extends Node


func _ready() -> void:
	Global.node.sketch = Global.scene.sketch.instantiate()
	Global.node.game.get_node("Layer0").add_child(Global.node.sketch)
	#datas.sort_custom(func(a, b): return a.value < b.value)
	#012 description
	#Global.node.sketch.diplomacy.servants_simulation()
	pass


func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_Q:
				if event.is_pressed() && !event.is_echo():
					#shift_earldom_with_neighbors
					#shift_dukedom_with_neighbors
					Global.node.sketch.cloth.shift_dukedom_with_neighbors(-1)
			KEY_E:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.cloth.shift_dukedom_with_neighbors(1)
			KEY_Z:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.cloth.shift_patch_with_neighbors(-1)
			KEY_C:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.cloth.shift_patch_with_neighbors(1)
			KEY_A:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.cloth.shift_layer(-1)
			KEY_D:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.cloth.shift_layer(1)
					#Global.node.sketch.diplomacy.do_it()
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					Global.node.sketch.cloth.add_states("earldom")


#func _process(delta_) -> void:
#	$FPS.text = str(Engine.get_frames_per_second())
