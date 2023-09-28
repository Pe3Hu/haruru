extends MarginContainer


@onready var bg = $BG
@onready var index = $VBox/Index
@onready var pp = $VBox/PreferredPrice
@onready var lp = $VBox/LimitedPrice
@onready var canned = $VBox/Canned

var room = null
var mediator = null
var fails = {}
var greed = null


func set_attributes(input_: Dictionary):
	room = input_.room
	mediator = input_.mediator
	greed = input_.greed 
	index.text = str(mediator.index)
	mediator.rooms.bidder.append(room)
	
	fails.current = 0
	fails.limit = 7
	
	fill_icons()
	
	if greed:
		var style = bg.get("theme_override_styles/panel")
		style.bg_color = Color.SKY_BLUE


func fill_icons() -> void:
	var resource = room.get_resource()
	var input = {}
	input.type = "number"
	input.subtype = mediator.appraisals[resource].expectation
	pp.set_attributes(input)
	input.type = "number"
	input.subtype = mediator.appraisals[resource].limit.buy
	lp.set_attributes(input)
	input.type = "number"
	input.subtype = mediator.purse.get_resource_value("canned")
	canned.set_attributes(input)


func pick_vendor() -> void:
	var vendors = []
	
	for vendor in room.vendors.get_children():
		if vendor.get_stack_number() > 0:
			vendors.append(vendor)
	
	
	if !vendors.is_empty():
		var vendor = vendors.pick_random()
		vendor.get_offer(self)
	else:
		get_reject()


func get_preferred_price() -> float:
	return pp.get_number()


func get_limited_price() -> float:
	return lp.get_number()


func get_accept() -> void:
	change_preferred_price(-1)
	fails.current = 0


func get_reject() -> void:
	change_preferred_price(1)
	fails.current += 1
	
	if get_preferred_price() == get_limited_price():
		fails.current += 1


func change_preferred_price(step_: int) -> void:
	var resource = room.get_resource()
	Global.rng.randomize()
	var correction = Global.rng.randf_range(mediator.appraisals[resource].correction.min, mediator.appraisals[resource].correction.max)
	mediator.appraisals[resource].expectation += step_ * correction
	
	if mediator.appraisals[resource].limit.buy < mediator.appraisals[resource].expectation:
		mediator.appraisals[resource].expectation = mediator.appraisals[resource].limit.buy
	
	pp.set_number(mediator.appraisals[resource].expectation)


func pick_up_purchase(vendor_: MarginContainer, value_: int) -> void:
	var resource = room.get_resource()
	
	if !vendor_.greed:
		vendor_.mediator.performances[resource] -= value_
	
	if !greed:
		mediator.performances[resource] += value_
	
	mediator.purse.change_resource_value(resource, value_)
	#vendor_.mediator.purse.change_resource_value(resource, -value_)
	vendor_.stack.set_number(0)


func keep_up_proposal() -> bool:
	fails.current -= 1
	Global.rng.randomize()
	var insist = Global.rng.randf_range(0, 1)# + float(fails.current) / fails.limit
	return insist > 0.1


func check_room_conditions() -> void:
	var budget = mediator.purse.get_resource_value("canned") * mediator.marketplace.bank.get_resource_price("canned")
	
	if budget > get_preferred_price() * Global.num.marketplace.stack.limit:
		var resource = room.get_resource()
		
		if fails.current >= fails.limit:
			leave_room()
			return
		
		if abs(mediator.goals[resource]) <= abs(mediator.performances[resource]):
			leave_room()
			return
	else:
		leave_room()
		return


func leave_room() -> void:
	room.bidders.remove_child(self)
	mediator.rooms.bidder.erase(room)
	queue_free()
