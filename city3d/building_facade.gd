extends RefCounted

# Shared near-field architecture. One mesh, up to three material surfaces per
# building: the number of windows does not create a node or draw call per pane.
const TRIM := Color("b3b0a1")
const FRAME := Color("454e4c")
const WOOD := Color("624636")
var batches: Dictionary={}
var count := 0
var limit := 0
var windows := 0
var edges := 0
var transform := Transform3D.IDENTITY
var materials: Array[Material]=[]
var vertex_counts: Array[int]=[0,0,0]

func _init():
    for kind in range(3):
        var surface:=SurfaceTool.new()
        surface.begin(Mesh.PRIMITIVE_TRIANGLES)
        batches[kind]=surface
        var mat:=StandardMaterial3D.new()
        mat.vertex_color_use_as_albedo=true
        mat.vertex_color_is_srgb=true
        mat.cull_mode=BaseMaterial3D.CULL_DISABLED
        mat.roughness=[0.88,0.38,0.2][kind]
        if kind==0:
            mat.normal_enabled=true
            mat.normal_texture=preload("res://assets/facade/textures/modular_urban_apartments_facade_plaster_nor_gl_1k.jpg")
            mat.normal_scale=0.3
            mat.uv1_triplanar=true
            mat.uv1_scale=Vector3.ONE*0.5
        if kind==2:
            var glass:=ShaderMaterial.new()
            glass.shader=preload("res://window_glazing.gdshader")
            materials.append(glass)
        else:
            materials.append(mat)

func _box(pos: Vector3, size: Vector3, color: Color, kind := 0):
    if count>=limit: return
    count+=1
    var surface: SurfaceTool=batches[kind]
    var half:=size/2
    for axis in range(3):
        for sign_value in [-1.0,1.0]:
            var normal:=Vector3.ZERO
            normal[axis]=sign_value
            var u:=Vector3.ZERO
            var v:=Vector3.ZERO
            u[(axis+1)%3]=half[(axis+1)%3]
            v[(axis+2)%3]=half[(axis+2)%3]
            var center:=pos+normal*half[axis]
            var points: Array[Vector3]=[center-u-v,center+u-v,center+u+v,center-u+v]
            # Godot front faces wind clockwise. Normals stay outward even when
            # a mapped polygon is clockwise instead of counterclockwise.
            var order: Array=[0,2,1,0,3,2] if sign_value>0 else [0,1,2,0,2,3]
            var coords: Array[Vector2]=[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)]
            for index in order:
                surface.set_normal(transform.basis*normal)
                surface.set_color(color)
                var tangent:=transform.basis*u.normalized()
                surface.set_tangent(Plane(tangent,-sign_value))
                surface.set_uv(coords[index])
                surface.set_uv2(Vector2(transform.origin.x+pos.x,transform.origin.z+pos.y))
                surface.add_vertex(transform*points[index])
                vertex_counts[kind]+=1

func _window(x: float, y: float, timber: bool, balcony: bool):
    if count+12>limit: return
    var frame: Color=WOOD if timber else FRAME
    # The dark reveal sits behind a projecting surround and sill. Opaque glazed
    # panes keep mobile depth sorting stable, with metallic sky reflections.
    _box(Vector3(x,y,0.08),Vector3(1.56,1.62,0.16),Color("282c29"),1)
    _box(Vector3(x,y,0.175),Vector3(1.27,1.35,0.025),Color("334b50"),2)
    for side in [-1,1]:
        _box(Vector3(x+side*0.71,y,0.21),Vector3(0.1,1.58,0.22),TRIM)
        _box(Vector3(x,y+side*0.75,0.21),Vector3(1.5,0.1,0.22),TRIM)
    _box(Vector3(x,y,0.23),Vector3(0.065,1.4,0.06),frame,1)
    _box(Vector3(x,y-0.1,0.23),Vector3(1.36,0.055,0.06),frame,1)
    _box(Vector3(x,y-0.86,0.27),Vector3(1.76,0.12,0.45),Color("aca997"))
    _box(Vector3(x,y+0.95,0.42),Vector3(1.96,0.13,0.9),TRIM)
    windows+=1
    if balcony and count+15<limit:
        var level:=y-1.45
        _box(Vector3(x,level,0.65),Vector3(2.65,0.18,1.4),TRIM)
        for rail_y in [level+0.35,level+1.05]:
            _box(Vector3(x,rail_y,1.3),Vector3(2.55,0.055,0.055),FRAME,1)
        for bar in range(7):
            _box(Vector3(x-1.2+bar*0.4,level+0.66,1.3),Vector3(0.035,0.88,0.035),FRAME,1)
        for side in [-1,1]:
            _box(Vector3(x+side*1.25,level+1.05,0.65),Vector3(0.055,0.055,1.3),FRAME,1)
            _box(Vector3(x+side*1.25,level+0.65,0.15),Vector3(0.055,0.9,0.055),FRAME,1)

func _door(x: float, shop: bool):
    _box(Vector3(x,1.25,0.08),Vector3(1.55,2.5,0.18),Color("302b25"),1)
    _box(Vector3(x,1.2,0.19),Vector3(1.27,2.3,0.06),WOOD,1)
    for y in [0.6,1.7]:
        _box(Vector3(x,y,0.23),Vector3(1.03,0.86,0.035),Color("795740"),1)
    _box(Vector3(x+0.43,1.15,0.28),Vector3(0.045,0.24,0.06),Color("9f9a81"),1)
    for side in [-1,1]:
        _box(Vector3(x+side*0.74,1.3,0.25),Vector3(0.12,2.6,0.25),TRIM)
    _box(Vector3(x,2.6,0.25),Vector3(1.6,0.12,0.25),TRIM)
    for step_index in range(2):
        _box(Vector3(x,0.09+step_index*0.15,0.65-step_index*0.2),Vector3(2.0,0.18,0.9),Color("817e71"))
    _box(Vector3(x,2.85,0.72),Vector3(2.6,0.16,1.5),Color("b6b4a5"))
    if shop:
        _box(Vector3(x,3.18,0.13),Vector3(2.6,0.42,0.12),Color("345f57"),1)

func _shutter(x: float):
    _box(Vector3(x,1.3,0.13),Vector3(2.3,2.55,0.2),FRAME,1)
    _box(Vector3(x,1.3,0.25),Vector3(2.08,2.35,0.06),Color("788780"),1)
    for slat in range(11):
        _box(Vector3(x,0.25+slat*0.21,0.31),Vector3(2.08,0.035,0.045),Color("a0aaa1"),1)
    _box(Vector3(x,2.85,0.64),Vector3(2.65,0.12,1.3),Color("65766a"),1)

func build(parent: Node3D, polygon: PackedVector2Array, height: float, style: int, focus: Vector3, box_limit := 640, pitched := false) -> int:
    limit=box_limit
    var area:=0.0
    for i in range(polygon.size()): area+=polygon[i].cross(polygon[(i+1)%polygon.size()])
    var faces: Array=[]
    var focus_2d:=Vector2(focus.x,focus.z)
    for i in range(polygon.size()):
        var a:=polygon[i]
        var b:=polygon[(i+1)%polygon.size()]
        if a.distance_to(b)<2.6: continue
        var nearest:=Geometry2D.get_closest_point_to_segment(focus_2d,a,b)
        faces.append({"a":a,"b":b,"distance":nearest.distance_squared_to(focus_2d)})
    faces.sort_custom(func(a,b): return a.distance<b.distance)
    var door_added:=false
    var remaining_length:=0.0
    for face in faces: remaining_length+=face.a.distance_to(face.b)
    for face in faces:
        var a: Vector2=face.a
        var b: Vector2=face.b
        var direction: Vector2=(b-a).normalized()
        var outward:=Vector3(direction.y,0,-direction.x)*(1 if area>0 else -1)
        var middle: Vector2=(a+b)/2
        transform=Transform3D(Basis(Vector3.UP,atan2(outward.x,outward.z)),Vector3(middle.x,0,middle.y))
        var length:=a.distance_to(b)
        var start:=count
        var floor_count:=clampi(roundi(height/3),1,6)
        var floor_pitch:=height/floor_count
        var allowance:=maxi(32,floori((box_limit-count)*length/remaining_length))
        remaining_length-=length
        # Foundation, floor string courses, cornice and a real parapet silhouette.
        _box(Vector3(0,0.25,0.045),Vector3(length,0.5,0.2),Color("807d70"))
        for level in range(1,floor_count):
            _box(Vector3(0,level*floor_pitch+0.04,0.12),Vector3(length,0.15,0.35),TRIM)
        _box(Vector3(0,height-0.12,0.17),Vector3(length+0.1,0.22,0.45),TRIM)
        if not pitched:
            _box(Vector3(0,height+0.32,-0.02),Vector3(length,0.65,0.2),Color("a5a294"))
            _box(Vector3(0,height+0.67,0),Vector3(length+0.1,0.12,0.32),TRIM)
        var columns:=mini(maxi(1,floori(length/3.1)),maxi(1,floori((allowance-(count-start)-5)/float(floor_count*12))))
        var pitch:=length/columns
        var openings: Array=[]
        for column in range(columns):
            var x: float=(column-(columns-1)/2.0)*pitch
            var world:=transform*Vector3(x,0,0)
            openings.append({"x":x,"distance":world.distance_squared_to(focus)})
        openings.sort_custom(func(a,b): return a.distance<b.distance)
        for opening in openings:
            if count-start+12>allowance: break
            var x: float=opening.x
            for floor_index in range(floor_count):
                if count-start+12>allowance: break
                if not door_added and floor_index==0:
                    _door(x,style==3)
                    door_added=true
                elif style==3 and floor_index==0 and pitch>2.5 and count-start+15<=allowance:
                    _shutter(x)
                else:
                    _window(x,1.55+floor_index*floor_pitch,style==0,style>=2 and floor_index>0 and int(round(x/pitch))%2==0 and count-start+27+12*(floor_count*(columns-1))<=allowance)
        # Rainwater downpipe at the end, with offset brackets.
        if count+4<limit:
            _box(Vector3(length/2-0.2,height/2,0.18),Vector3(0.08,height,0.08),Color("666e67"),1)
            for y in [1.0,height-0.8]:
                _box(Vector3(length/2-0.2,y,0.15),Vector3(0.16,0.07,0.2),FRAME,1)
        edges+=1
        if count+12>=limit: break
    var mesh:=ArrayMesh.new()
    for kind in range(3):
        var surface: SurfaceTool=batches[kind]
        if vertex_counts[kind]==0: continue
        surface.index()
        surface.commit(mesh)
        mesh.surface_set_material(mesh.get_surface_count()-1,materials[kind])
    if mesh.get_surface_count()>0:
        var visual:=MeshInstance3D.new()
        visual.name="ArchitecturalFacade"
        visual.mesh=mesh
        visual.set_meta("window_count",windows)
        visual.set_meta("detailed_edges",edges)
        visual.set_meta("primitive_count",count)
        parent.add_child(visual)
    return count
