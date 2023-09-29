extends MarginContainer


@onready var treads = $Treads

var members = []


func add_member(member_: MarginContainer) -> void:
	members.append(member_)
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	treads.add_child(hbox)
	var input = {}
	input.type = "number"
	input.subtype = member_.index
	var icon = Global.scene.icon.instantiate()
	icon.name = "Index"
	hbox.add_child(icon)
	icon.set_attributes(input)
	input.type = "number"
	input.subtype = member_.index
	icon = Global.scene.icon.instantiate()
	hbox.add_child(icon)
	icon.set_attributes(input)
	icon.name = "Points"
	sort_by_points()


func remove_member(member_: MarginContainer) -> void:
	members.erase(member_)
	var tread = get_tread(member_)
	treads.remove_child(tread)


func get_tread(member_: MarginContainer) -> Variant:
	for tread in treads.get_children():
		if tread.get_node("Index").get_number() == member_.index:
			return tread
	
	return null


func get_points(member_: MarginContainer) -> Variant:
	var hbox = get_tread(member_)
	return hbox.get_node("Points").get_number()


func set_points(member_: MarginContainer, value_: int) -> void:
	var hbox = get_tread(member_)
	hbox.get_node("Points").set_number(value_)
	sort_by_points()


func change_points(member_: MarginContainer, value_: int) -> void:
	var hbox = get_tread(member_)
	hbox.get_node("Points").change_number(value_)
	sort_by_points()


func sort_by_points() -> void:
	var datas = []
	
	for member in members:
		var data = {}
		data.member = member
		data.tread = get_tread(member)
		data.points = get_points(member)
		treads.remove_child(data.tread)
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.points > b.points)
	
	for data in datas:
		treads.add_child(data.tread)
