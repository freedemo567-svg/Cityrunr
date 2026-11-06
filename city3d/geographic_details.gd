extends Node3D

# Bounded near-field decoration. Source footprints and collisions remain mapped;
# facade designs are illustrative, not scans of the corresponding real buildings.
var architecture=preload("res://architecture.gd").new()
var last_focus:=Vector3(INF,0,INF)
var roots: Array[Node3D]=[]
var budget := 0
var focus_position:=Vector3.ZERO
var tree_scene=preload("res://assets/vegetation/island-tree.glb")
var shrub_scene=preload("res://assets/vegetation/shrub_01.gltf")
const RADIUS := 110.0
const LIMIT := 24
func _ready(): add_child(architecture)
func refresh(tiles: Array, focus: Vector3, force := false):
    if not force and focus.distance_to(last_focus)<25: return
    last_focus=focus
    focus_position=focus
    for node in roots:
        remove_child(node)
        node.queue_free()
    roots.clear()
    var nearby: Array=[]
    for tile in tiles:
        for entry in tile.get("buildings",[]):
            var polygon:=PackedVector2Array()
            var center:=Vector2.ZERO
            for p in entry[1]: polygon.append(Vector2(p[0],p[1]))
            if polygon.size()>2 and polygon[0]==polygon[-1]: polygon.remove_at(polygon.size()-1)
            if polygon.size()<3: continue
            for p in polygon: center+=p
            center/=polygon.size()
            var distance:=INF
            var focus_2d:=Vector2(focus.x,focus.z)
            for i in range(polygon.size()):
                var closest:=Geometry2D.get_closest_point_to_segment(focus_2d,polygon[i],polygon[(i+1)%polygon.size()])
                distance=minf(distance,focus_2d.distance_squared_to(closest))
            if distance<RADIUS*RADIUS: nearby.append({"polygon":polygon,"center":center,"height":float(entry[2]),"distance":distance,"id":int(entry[0])})
    budget=24*640
    nearby.sort_custom(func(a,b): return a.distance<b.distance)
    for i in range(mini(LIMIT,nearby.size())):
        _decorate(nearby[i])
        if i<12: _plant(nearby[i],tiles)
    _trees(tiles,focus)
func _decorate(data: Dictionary):
    if budget<=0: return
    var node:=Node3D.new()
    node.name="FacadeDetail%02d" % roots.size()
    node.position=Vector3(data.center.x,0,data.center.y)
    add_child(node)
    roots.append(node)
    _roof_detail(node,data)
    var local_polygon:=PackedVector2Array()
    for point in data.polygon: local_polygon.append(point-data.center)
    var facade=preload("res://building_facade.gd").new()
    var used: int=facade.build(node,local_polygon,data.height,posmod(int(data.id),4),focus_position-node.position,mini(640,budget),node.get_node_or_null("TiledRoof")!=null)
    budget-=used
    for visual in node.find_children("*","GeometryInstance3D",true,false):
        visual.visibility_range_end=RADIUS
        visual.visibility_range_end_margin=10

func _plant(data: Dictionary, tiles: Array):
    var polygon: PackedVector2Array=data.polygon
    var first: Vector2=polygon[0]
    var direction: Vector2=(first-data.center).normalized()
    var position_2d:=first+direction*8.0
    var candidate:=Vector3(position_2d.x,0,position_2d.y)
    for tile in tiles:
        for bounds in tile.get("boxes",[]):
            if bounds.grow(3.0).has_point(position_2d): return
        for road in tile.get("roads",[]):
            if Geometry3D.get_closest_point_to_segment(candidate,road[0],road[1]).distance_to(candidate)<10.0: return
    var shrub: Node3D=shrub_scene.instantiate()
    shrub.name="RoadsidePlanting%02d" % roots.size()
    shrub.position=candidate
    shrub.rotation.y=fposmod(data.center.x,TAU)
    shrub.scale=Vector3.ONE*2.8
    for visual in shrub.find_children("*","GeometryInstance3D",true,false):
        visual.visibility_range_end=65
        visual.visibility_range_end_margin=8
    add_child(shrub)
    roots.append(shrub)

func _trees(tiles: Array, focus: Vector3):
    if tiles.is_empty(): return
    var made:=0
    var cell:=Vector2i(floori(focus.x/24),floori(focus.z/24))
    for ring in range(1,6):
        for x in range(-ring,ring+1):
            for z in range(-ring,ring+1):
                if absi(x)!=ring and absi(z)!=ring: continue
                var key:=cell+Vector2i(x,z)
                if posmod(key.x*31+key.y*17,3)!=0: continue
                var point:=Vector3(key.x*24+8,0,key.y*24+7)
                if not _clear_for_tree(tiles,point): continue
                var tree: Node3D=tree_scene.instantiate()
                tree.name="LandscapeTree%02d" % made
                tree.position=point
                tree.scale=Vector3.ONE*(2.4+posmod(key.x,3)*0.15)
                tree.rotation.y=float(posmod(key.x+key.y,6))
                for visual in tree.find_children("*","GeometryInstance3D",true,false):
                    visual.visibility_range_end=130
                    visual.visibility_range_end_margin=15
                add_child(tree)
                roots.append(tree)
                made+=1
                if made>=16: return
func _clear_for_tree(tiles: Array, point: Vector3) -> bool:
    for tile in tiles:
        for bounds in tile.get("boxes",[]):
            if bounds.grow(6).has_point(Vector2(point.x,point.z)): return false
        for segment in tile.get("roads",[])+tile.get("rail",[]):
            # Rails retain source arrays; roads already contain Vector3 endpoints.
            var a: Vector3=segment[0] if segment[0] is Vector3 else Vector3(segment[0][0],0,segment[0][1])
            var b: Vector3=segment[1] if segment[1] is Vector3 else Vector3(segment[1][0],0,segment[1][1])
            if Geometry3D.get_closest_point_to_segment(point,a,b).distance_to(point)<12: return false
    return true

func _roof_detail(node: Node3D, data: Dictionary):
    var poly: PackedVector2Array=data.polygon
    if poly.size()!=4 or data.height>9: return
    var first:=poly[1]-poly[0]
    var second:=poly[2]-poly[1]
    var width:=first.length()
    var depth:=second.length()
    if width<4 or width>22 or depth<4 or depth>22: return
    if absf(first.normalized().dot(second.normalized()))>0.03: return
    if (poly[3]-poly[2]+first).length()>0.2 or (poly[0]-poly[3]+second).length()>0.2: return
    if int(data.id)%2==0:
        var roof:=Node3D.new()
        roof.name="TiledRoof"
        roof.rotation.y=-atan2(first.y,first.x)
        node.add_child(roof)
        architecture.roof(roof,Vector3(width,data.height,depth),Color("c7bda8"))
    else:
        var tank:=MeshInstance3D.new()
        tank.name="RoofTank"
        var cylinder:=CylinderMesh.new()
        cylinder.top_radius=0.65
        cylinder.bottom_radius=0.65
        cylinder.height=1.35
        tank.mesh=cylinder
        tank.material_override=architecture.material(Color("343b38"))
        tank.position=Vector3(0,data.height+0.675,0)
        node.add_child(tank)
