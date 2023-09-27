extends Polygon2D


var cloth = null
var patch = null
var type = null
var element = null
var terrain = null
var index = null
var abundance = null
var appellation = null
var square = null
var workplaces = null
var knobs = []
var seams = []
var neighbors = {}
var grand = false
var center = Vector2()


func set_attributes(input_: Dictionary) -> void:
	cloth = input_.cloth
	type = input_.type
	knobs.append_array(input_.knobs)
	#position = input_.position
	index = Global.num.index.flap
	Global.num.index.flap += 1
	
	set_vertexs()
	paint_based_on_index()
	init_seams()


func set_vertexs() -> void:
	var vertexs = []
	
	for knob in knobs:
		var vertex = knob.position
		vertexs.append(vertex)
		center += vertex
	
	center /= knobs.size()
	set_polygon(vertexs)


func paint_based_on_index() -> void:
	var h = float(index) / Global.num.size.flap.row / Global.num.size.flap.col
	var s = 0.75
	var v = 1
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func paint_gray() -> void:
	var color_ = Color.GRAY
	set_color(color_)


func paint_based_on_element() -> void:
	set_color(Global.color.element[element])


func paint_based_on_terrain() -> void:
	if terrain != null:
		set_color(Global.color.terrain[terrain])
	else:
		set_color(Color.GRAY)


func paint_based_on_patch_index() -> void:
	var h = float(patch.index) / Global.num.index.patch
	var s = 0.75
	var v = 1
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func paint_based_on_abundance() -> void:
	var h = 0
	var s = 0
	var v = float(abundance - Global.dict.abundance.limit.min) / (Global.dict.abundance.limit.max - Global.dict.abundance.limit.min)
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func paint_based_on_state_type_index(type_: String) -> void:
	if patch.state[type_] != null and patch.state[type_] != cloth.liberty:
		var h = float(patch.state[type_].index) / Global.num.index.state[type_]
		var s = 0.75
		var v = 1
		var color_ = Color.from_hsv(h,s,v)
		set_color(color_)
		
		patch.state[type_].hub.visible = true
		
	else:
		paint_gray()


func paint_based_on_realm_index() -> void:
	if patch.realm != null:
		var h = float(patch.realm.index) / Global.num.index.realm
		var s = 0.75
		var v = 1
		var color_ = Color.from_hsv(h,s,v)
		set_color(color_)
	else:
		paint_gray()


func paint_based_on_realm_terrain() -> void:
	if patch.realm != null:
		set_color(Global.color.terrain[terrain])
	else:
		paint_gray()


func init_seams() -> void:
	for _i in knobs.size():
		var _j = (_i + 1) % knobs.size()
		var knobs_ = [knobs[_i],knobs[_j]]
		
		for _k in knobs_.size():
			var _l = (_k + 1) % knobs_.size()
			var first = knobs_[_k]
			var second = knobs_[_l]
			
			if !cloth.couplers.keys().has(first):
				cloth.couplers[first] = {}
			
			if !cloth.couplers.keys().has(second):
				cloth.couplers[second] = {}
			
			if !cloth.couplers[first].keys().has(second):
				var input = {}
				input.cloth = cloth
				input.knobs = knobs_
				var seam = Global.scene.seam.instantiate()
				cloth.seams.add_child(seam)
				seam.set_attributes(input)
				cloth.couplers[second][first] = seam
			
			cloth.couplers[second][first].add_flap(self)


func calc_square() -> void:
	var a = knobs[0].position
	var b = knobs[1].position
	var c = knobs[2].position
	square = abs((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) / 2
	workplaces = round(square / Global.num.size.flap.workplace)


func set_abundance() -> void:
	abundance = Global.dict.abundance.terrain[terrain][element]


func set_terrain(terrain_: String) -> void:
	terrain = terrain_
	
	var appellations = Global.dict.appellation.temp[terrain]
	
	if !appellations.is_empty():
		appellation = appellations.pick_random()
		appellations.erase(appellation)
	else:
		Global.fill_appellation_temp(terrain)
		set_terrain(terrain_)


func check_terrain_in_neighbors_old(terrain_: String) -> bool:
	var flag = false
	
	for seam in neighbors:
		var neighbor = neighbors[seam]
		
		if neighbor.terrain == terrain:
			flag = true
			break
	
	return flag


func get_neighbor_terrains() -> Array:
	var terrains = []
	
	#print(neighbors.size())
	for seam in neighbors:
		var neighbor = neighbors[seam]
		#print(neighbor.terrain)
		
		if neighbor.terrain != null and !terrains.has(neighbor.terrain):
			terrains.append(neighbor.terrain)
	
	return terrains


func get_non_neighbor_terrains() -> Array:
	var terrains = []
	terrains.append_array(Global.arr.terrain)
	
	for terrain in get_neighbor_terrains():
		terrains.erase(terrain)
	
	return terrains


func check_avalible_terrain_based_on_neighbors(terrain_: String) -> bool:
	var terrains = get_non_neighbor_terrains()
	#print([terrain_, terrains])
	return terrains.has(terrain_)
