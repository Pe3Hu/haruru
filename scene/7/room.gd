extends MarginContainer


@onready var vendors = $VBox/Vendors
@onready var bidders = $VBox/Bidders
@onready var commodity = $VBox/Commodity

var marketplace = null


func set_attributes(input_: Dictionary):
	marketplace = input_.marketplace
	var input = {}
	input.type = "resource"
	input.subtype = input_.commodity
	commodity.set_attributes(input)


func add_vendor(mediator_: MarginContainer) -> void:
	var input = {}
	input.room = self
	input.mediator = mediator_
	var vendor = Global.scene.vendor.instantiate()
	vendors.add_child(vendor)
	vendor.set_attributes(input)
	mediator_.rooms.vendor.append(self)
	sort_vendors()


func add_bidder(mediator_: MarginContainer) -> void:
	var input = {}
	input.room = self
	input.mediator = mediator_
	var bidder = Global.scene.bidder.instantiate()
	bidders.add_child(bidder)
	bidder.set_attributes(input)
	mediator_.rooms.bidder.append(self)
	sort_bidders()


func get_resource() -> String:
	return commodity.subtype


func sort_vendors() -> void:
	var datas = []
		
	for vendor in vendors.get_children():
		var data = {}
		data.limit = vendor.lp.get_number()
		data.vendor = vendor
		vendors.remove_child(vendor)
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.limit > b.limit)
	
	for data in datas:
		vendors.add_child(data.vendor)


func sort_bidders() -> void:
	var datas = []
		
	for bidder in bidders.get_children():
		var data = {}
		data.limit = bidder.lp.get_number()
		data.bidder = bidder
		bidders.remove_child(bidder)
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.limit > b.limit)
	
	for data in datas:
		bidders.add_child(data.bidder)


func start_session() -> void:
	if vendors.get_child_count() > 0 and bidders.get_child_count() > 0:
		var nodes = []
		nodes.append_array(bidders.get_children())
		nodes.shuffle()
		
		for bidder in nodes:
			bidder.pick_vendor()
		
		for vendor in vendors.get_children():
			if vendor.get_stack_number() == 0:
				vendor.refill_stack()
			else:
				vendor.get_reject()
	else:
		close()


func close() -> void:
	for bidder in bidders.get_children():
		bidder.leave_room()
	
	for vendor in vendors.get_children():
		vendor.leave_room()
	
	marketplace.rooms.remove_child(self)
	queue_free()
