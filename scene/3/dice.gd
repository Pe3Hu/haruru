extends MarginContainer


@onready var bg = $BG
@onready var facets = $BG/Facets
@onready var timer = $Timer
var tween = null

var member = null
var box = null
var pace = null
var tick = null
var time = null
var counter = 0
var skip = true#false true
var anchor = null
var temp = true


func set_attributes(input_: Dictionary) -> void:
	member = input_.member
	box = input_.box
	#time = Time.get_unix_time_from_system()
	
	anchor = Vector2(0, -Global.vec.size.facet.y)
	init_facets()
	update_size()
	reset()
	#skip_animation()


func init_facets() -> void:
	var data = Global.dict.facet.type[member.type][member.specialization]
	var index_ = 0
	
	for outcome in data.outcomes:
		for _i in data.outcomes[outcome].facets:
			var input = data.outcomes[outcome].duplicate()
			input.member = member
			input.outcome = outcome
			input.index = index_
			index_ += 1
			input.erase("facets")
			var facet = Global.scene.facet.instantiate()
			facets.add_child(facet)
			facet.set_attributes(input)
	
	var a = facets.get_children()
	return


func update_size() -> void:
	var vector = Global.vec.size.facet#Vector2(facets.get_child(0).size)
	vector.y *= 1
	custom_minimum_size = vector


func reset() -> void:
	#shuffle_facets()
	pace = 20
	tick = 0
	facets.position.y = -Global.vec.size.facet.y * 1
	#timer.start()


func shuffle_facets() -> void:
	var array = []
	
	for facet in facets.get_children():
		facets.remove_child(facet)
		array.append(facet)
	
	array.shuffle()
	
	for facet in array:
		facets.add_child(facet)


func decelerate_spin() -> void:
	tick += 1
	var limit = {}
	limit.min = 1.0
	limit.max = max(limit.min, 10.0 - tick * 0.05)
	#start 50 min 0.5 max 2.5 step 0.1 stop 4 = 10 sec
	#start 50 min 1.5 max 2.5 step 0.1 stop 4 = 5 sec
	#start 50 min 2.0 max 3.0 step 0.1 stop 4 = 4 sec
	#start 50 min 2.0 max 3.0 step 0.1 stop 10 = 2.5 sec
	#start 50 min 2.0 max 5.0 step 0.1 stop 10 = 2 sec
	#start 100 min 1.0 max 10.0 step 0.1 stop 10 = 2.2 sec
	Global.rng.randomize()
	var gap = Global.rng.randf_range(limit.min, limit.max)
	pace -= gap
	timer.wait_time = 1.0 / pace


func _on_timer_timeout():
	if pace >= 0.5:
		var time_ = 1.0 / pace
		tween = create_tween()
		tween.tween_property(facets, "position", Vector2(0, 0), time_).from(anchor)
		tween.tween_callback(pop_up)
		decelerate_spin()
	else:
		#print("end at", Time.get_unix_time_from_system() - time_)
		#var unit = facets.get_child(3).unit
		pass


func pop_up() -> void:
	var facet = facets.get_child(facets.get_child_count() - 1)
	facets.move_child(facet, 0)
	
	if !skip:
		facets.position = anchor
		timer.start()


func skip_animation() -> void:
	#var salvo = 1
	#for _i in salvo:
	var facet = facets.get_children().pick_random()
	flip_to_index(facet.index)
	
	#get_parent().remove_child(self)
	#queue_free()


func flip_to_index(index_) -> void:
	for facet in facets.get_children():
		if facet.index == index_:
			var index = facet.get_index()
			var step = 1 - index
			
			if step < 0:
				step = facets.get_child_count() - index + 1
			
			for _j in step:
				pop_up()
			
			return


func get_current_facet_index() -> int:
	var facet = facets.get_child(1)
	return facet.index


func get_current_facet() -> MarginContainer:
	return facets.get_child(1)


func crush() -> void:
	get_parent().remove_child(self)
	queue_free()


func apply_outcome() -> void:
	var facet = get_current_facet()
	
	if facet.icon.subtype != "failure":
		var data = Global.dict.facet.type[facet.member.type][facet.member.specialization]
		var description = data.outcomes[facet.icon.subtype]
		var value = round(description.value * Global.num.conversion[description.resource] * member.fieldwork.abundance)
		var contribution = value * Global.dict.merchandise.price[description.resource]
		member.fieldwork.ladder.change_contribution(member, contribution)
		member.add_outcome(facet.icon.subtype)
		
		if Global.dict.conversion.raw.has(description.resource):
			member.extract_raw(description.resource, value)
			
		if Global.dict.conversion.product.has(description.resource):
			member.produce_product(description.resource, value)


func add_debuffs(value_: int) -> void:
	var unoriginals = {}
	
	for facet in facets.get_children():
		if facet.outcome.current != facet.outcome.original and facet.buff.current > 0:
			unoriginals[facet] = facet.buff.current
	
	while value_ > 0 and !unoriginals.keys().is_empty():
		value_ -= 1
		var facet = Global.get_random_key(unoriginals)
		facet.add_debuff(1)
		unoriginals[facet] -= 1
		
		if unoriginals[facet] == 0:
			unoriginals.erase(facet)
	
	if value_ > 0:
		var originals = {}
		
		for facet in facets.get_children():
			unoriginals[facet] = facet.debuff.limit
		
		while value_ > 0 and !originals.keys().is_empty():
			value_ -= 1
			var facet = Global.get_random_key(originals)
			facet.add_debuff(1)
			originals[facet] -= 1
			
			if originals[facet] == 0:
				originals.erase(facet)


func add_buffs(value_: int) -> void:
	var unoriginals = {}
	
	for facet in facets.get_children():
		if facet.outcome.current != facet.outcome.original and facet.debuff.current > 0:
			unoriginals[facet] = facet.debuff.current
	
	while value_ > 0 and !unoriginals.keys().is_empty():
		value_ -= 1
		var facet = Global.get_random_key(unoriginals)
		facet.add_buff(1)
		unoriginals[facet] -= 1
		
		if unoriginals[facet] == 0:
			unoriginals.erase(facet)
	
	if value_ > 0:
		var originals = {}
		
		for facet in facets.get_children():
			unoriginals[facet] = facet.buff.limit
		
		while value_ > 0 and !originals.keys().is_empty():
			value_ -= 1
			var facet = Global.get_random_key(originals)
			facet.add_buff(1)
			originals[facet] -= 1
			
			if originals[facet] == 0:
				originals.erase(facet)
