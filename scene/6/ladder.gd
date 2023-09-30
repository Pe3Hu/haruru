extends MarginContainer


@onready var treads = $Treads

var fieldwork = null
var members = []
var newbies = []


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
	input.subtype = 0
	icon = Global.scene.icon.instantiate()
	hbox.add_child(icon)
	icon.set_attributes(input)
	icon.name = "Points"
	input.type = "number"
	input.subtype = 0
	icon = Global.scene.icon.instantiate()
	hbox.add_child(icon)
	icon.set_attributes(input)
	icon.name = "Contribution"
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


func get_contribution(member_: MarginContainer) -> Variant:
	var hbox = get_tread(member_)
	return hbox.get_node("Contribution").get_number()


func set_contribution(member_: MarginContainer, value_: int) -> void:
	var hbox = get_tread(member_)
	hbox.get_node("Contribution").set_number(value_)


func change_contribution(member_: MarginContainer, value_: int) -> void:
	var hbox = get_tread(member_)
	hbox.get_node("Contribution").change_number(value_)


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


func sort_by_contribution() -> void:
	var datas = []
	
	for member in members:
		var data = {}
		data.member = member
		data.tread = get_tread(member)
		data.contribution = get_contribution(member)
		treads.remove_child(data.tread)
		datas.append(data)
	
	datas.sort_custom(func(a, b): return a.contribution > b.contribution)
	
	for data in datas:
		treads.add_child(data.tread)


func give_prizes() -> void:
	if Global.arr.terrain.has(fieldwork.terrain) and Global.dict.prize.has(treads.get_child_count()):
		sort_by_contribution()
		var prizes = Global.dict.prize[treads.get_child_count()]
		
		for _i in range(0, prizes.top):
			var points = prizes.top - _i
			var tread = treads.get_child(_i)
			var member = get_member_based_on_tread(tread)
			change_points(member, points)
		
		for _i in range(treads.get_child_count() - 1, treads.get_child_count() - prizes.bot - 1, -1):
			var points = -prizes.top + treads.get_child_count() - 1 - _i
			var tread = treads.get_child(_i)
			var member = get_member_based_on_tread(tread)
			change_points(member, points)

		sort_by_points()


func rotate_members() -> void:
	if fieldwork.downgrade != null :
		if Global.dict.prize.has(treads.get_child_count()) and Global.dict.prize.has(fieldwork.downgrade.ladder.treads.get_child_count()):
			#fieldwork.downgrade.sort_by_points()
			var swap = {}
			swap.upward = Global.dict.prize[treads.get_child_count()].bot
			swap.downgrade = Global.dict.prize[fieldwork.downgrade.ladder.treads.get_child_count()].top
			swap.current = min(swap.upward, swap.downgrade)
			#print([fieldwork.foreman.proprietor.index, fieldwork.terrain, fieldwork.abundance, swap])
		
			for _i in range(0, swap.current):
				var tread = treads.get_child(_i)
				var member = get_member_based_on_tread(tread)
				fieldwork.downgrade.ladder.newbies.append(member)
				fieldwork.layoff_employ(member)
				#print([fieldwork.foreman.proprietor.index, fieldwork.terrain, fieldwork.abundance, "downgrade", member.index])
			
			for _i in range(fieldwork.downgrade.ladder.treads.get_child_count() - 1, fieldwork.downgrade.ladder.treads.get_child_count() - swap.current - 1, -1):
				var tread = fieldwork.downgrade.ladder.treads.get_child(_i)
				var member = fieldwork.downgrade.ladder.get_member_based_on_tread(tread)
				newbies.append(member)
				fieldwork.downgrade.layoff_employ(member)
				#print([fieldwork.foreman.proprietor.index, fieldwork.downgrade.terrain, fieldwork.downgrade.abundance, "upward", member.index])


func get_member_based_on_tread(tread_: HBoxContainer) -> Variant:
	var index = tread_.get_node("Index").get_number()
	
	for member in members:
		if member.index == index:
			return member
	
	return null


func employ_newbies() -> void:
	while !newbies.is_empty():
		var newbie = newbies.pop_front()
		fieldwork.employ_member(newbie)


func reset_contributions() -> void:
	for member in members:
		set_contribution(member, 0)
