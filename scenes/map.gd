extends TileMap
class_name MyTileMap

var start = Vector2i(-1,-1)
var end = Vector2i(31,21)

func get_random_empty_tile_():
	while true:
		var coords = Vector2i(randi()%end.x, randi()%end.y)
		if get_tile_kind_at(coords)==0:
			return coords


func get_random_empty_tile(tiles_to_avoid, center_coord, radius=4):
	var tiles = []
	for x in radius*2:
		for y in radius*2:
			var coords = center_coord + Vector2i(x-radius, y-radius)
			if coords == center_coord:
				continue
			if get_tile_kind_at(coords)==0:
				tiles.append(coords)
	if tiles.size()>0:
		tiles.shuffle()
		return tiles[0]
	else:
		return null



func get_tile_kind_at(coords):
	# kind legend:
	# 0 = empty paths
	# 1 = trees
	# 2 = mountains/walls
	# 3 = treasure
	# 4 = immovable trees/walls
	# 5 = trap
	# 6 = enemy home
	var td: TileData = get_cell_tile_data(0, coords)
	var kind = 0
	if td:
		if td.terrain==5: # just paths
			kind = 0
		elif td.terrain==3:  # free grass
			kind = 4
		elif td.terrain==1 or td.terrain==4:  # walls
			kind = 2
		elif td.terrain==2: # this is the special ones
			kind=3
		elif td.terrain==6: # this a trap
			kind=5
		elif td.terrain==7: # this a trap
			kind=6
		else: # [0, 4]: # 4 is not movable
			# regular blocks
			kind=1
	else:
		return -1
	return kind

var graph = {}

class MyTile:
	var kind: int = 0
	var edges: Array = []

func build_graph(coords):
	if not coords in graph:
		var tile = MyTile.new()
		tile.kind = get_tile_kind_at(coords)
		graph[coords] = tile
		for delta in [Vector2i(0,-1), Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0)]:
			var neighbor = coords + delta
			if get_cell_tile_data(0, coords):
				tile.edges.append(neighbor)
				build_graph(neighbor)

class MyNode:
	var coords: Vector2i
	var source
	var length
	func _init(coords_, source_, length_):
		coords = coords_
		source = source_
		length = length_
		
func find_path_recreate(coords, node):
	var path = []
	if coords:
		path.append(coords)
	path.append(node.coords)
	while node.source:
		node = node.source
		path.append(node.coords)
	path.reverse()
	path.pop_front()
	return path
	

func find_path(from, to, memory=null):
	var queue = [MyNode.new(from, null, 1)]
	var visited = {from:true}
	if memory:
		for coords in memory:
			visited[coords] = false
	var current_path = null
	while queue:
		var node = queue.pop_front()
		if current_path==null or current_path.length < node.length:
			current_path = node
		for edge in graph[node.coords].edges:
			if not edge in graph or graph[edge].kind in [0, 4, 3, 5, 6]: # 5 makes them walk on traps
				pass
			else:
				# not passable
				continue
			if edge == to:
				return [true, find_path_recreate(edge, node)]
			if not edge in visited:
				queue.push_back(MyNode.new(edge, node, node.length+1))
				visited[edge] = true
	return [false, find_path_recreate(null, current_path)]
