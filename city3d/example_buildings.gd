extends RefCounted
# Visual landmarks are fictional examples placed separately from mapped buildings.
# Simple materials and a small bounded number of shapes keep mobile cost predictable.
func box(parent: Node3D, name: String, pos: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
    var node:=MeshInstance3D.new()
    node.name=name
    var geometry:=BoxMesh.new()
    geometry.size=dimensions
    node.mesh=geometry
    var material:=StandardMaterial3D.new()
    material.albedo_color=color
    material.roughness=0.82
    node.material_override=material
    node.position=pos
    parent.add_child(node)
    return node
func cylinder(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color):
    var node:=MeshInstance3D.new()
    node.name=name
    var geometry:=CylinderMesh.new()
    geometry.top_radius=radius
    geometry.bottom_radius=radius
    geometry.height=height
    geometry.radial_segments=16
    node.mesh=geometry
    var material:=StandardMaterial3D.new()
    material.albedo_color=color
    material.roughness=0.8
    node.material_override=material
    node.position=pos
    parent.add_child(node)
func decorate(parent: Node3D, data: Dictionary):
    var kind: String=data.category
    var title: String=data.name
    var width: float=data.width
    var depth: float=data.depth
    var height: float=data.height
    var neutral:=Color("c9c6b5")
    var dark:=Color("3a4648")
    var rust:=Color("9d5442")
    var dx: float=data.point[0]-data.center[0]
    var dz: float=data.point[1]-data.center[1]
    var outward:=Vector3(signf(dx),0,0) if absf(dx/width)>absf(dz/depth) else Vector3(0,0,signf(dz))
    var front:=Vector3(outward.x*(width/2+0.16),0,outward.z*(depth/2+0.16))
    var frontage: float=depth if outward.x!=0 else width
    var entrance:=Node3D.new()
    entrance.name="ExampleFront"
    entrance.position=front
    entrance.rotation.y=atan2(outward.x,outward.z)
    parent.add_child(entrance)
    var color: Color={"civic":Color("365a79"),"vehicle":Color("bb5a3c"),"transport":Color("366d6b"),"retail":Color("65594e"),"industrial":Color("585f5c"),"worship":Color("8e7354"),"secret":Color("475047")}.get(kind,Color("5a6664"))
    box(entrance,"SignBacking",Vector3(0,3.8,0.55),Vector3(minf(frontage-1,12),0.85,0.12),color)
    var label:=Label3D.new()
    label.name="ExampleLabel"
    label.text=title.to_upper()+"  ·  EXAMPLE"
    label.font_size=44
    label.pixel_size=minf(0.011,frontage/maxf(280.0,title.length()*32.0))
    label.position=Vector3(0,3.8,0.64)
    label.modulate=Color("f7f3e5")
    label.outline_size=4
    label.double_sided=false
    entrance.add_child(label)
    # Canopies, bay frames and vertical piers form distinctive silhouettes.
    if kind in ["transport","vehicle","retail"]:
        box(entrance,"EntranceCanopy",Vector3(0,3.05,0.25),Vector3(minf(frontage-1,8),0.16,0.5),color)
        for side in [-1,1]:box(entrance,"EntryPier",Vector3(side*minf(frontage*0.3,3.5),1.4,0.16),Vector3(0.18,2.8,0.24),neutral)
    if title=="Gas Station":
        # Compact forecourt equipment projects only into the audited setback.
        box(entrance,"FuelCanopy",Vector3(0,3.2,1.25),Vector3(7,0.25,2.5),Color("e8e3d2"))
        box(entrance,"FuelCanopyFascia",Vector3(0,3.15,2.45),Vector3(7,0.45,0.15),Color("ac4f3a"))
        for side in [-1,1]:
            box(entrance,"PumpPillar",Vector3(side*3.2,1.5,2.25),Vector3(0.18,3,0.18),Color("b8b9ae"))
            box(entrance,"FuelPump",Vector3(side*2,0.7,1.6),Vector3(0.6,1.4,0.5),Color("eee8d8"))
            box(entrance,"PumpDisplay",Vector3(side*2,1.1,1.87),Vector3(0.38,0.26,0.04),dark)
    if kind in ["civic","landmark","worship","office"]:
        for side in [-1,1]:box(entrance,"FacadePier",Vector3(side*(frontage/2-0.55),height/2,0.12),Vector3(0.42,height,0.25),neutral)
    if (kind=="residential" and title not in ["Apartment","Penthouse","Hotel"]) or title in ["Farm House","Barn","Bunkhouse","Ranger Station"]:
        var rise:=minf(2.5,width*0.13)
        var half:=width/2+0.3
        var slope:=atan2(rise,half)
        for side in [-1,1]:
            var roof=box(parent,"TileRoof",Vector3(side*half/2,height+rise/2,0),Vector3(sqrt(half*half+rise*rise),0.18,depth+0.6),Color("9c4e3d"))
            roof.rotation.z=-side*slope
            roof.material_override=preload("res://surface_materials.gd").roof()
    if kind in ["industrial","transport"]:
        for side in [-1,1]:box(parent,"RoofVent",Vector3(side*width*0.25,height+0.7,0),Vector3(1.4,1.4,1.2),dark)
    if title in ["Hospital","Clinic"]:
        box(entrance,"MedicalMarkerVertical",Vector3(0,5.0,0.5),Vector3(0.35,1.4,0.12),Color("37a16a"))
        box(entrance,"MedicalMarkerHorizontal",Vector3(0,5.0,0.52),Vector3(1.4,0.35,0.12),Color("37a16a"))
    if title in ["Church","Cathedral","Cemetery Chapel"]:
        box(parent,"BellTower",Vector3(0,height+1.8,0),Vector3(2.6,3.6,2.6),neutral)
        box(parent,"CrossVertical",Vector3(0,height+4.6,0),Vector3(0.18,2,0.18),dark)
        box(parent,"CrossHorizontal",Vector3(0,height+4.85,0),Vector3(1.1,0.18,0.18),dark)
    elif title=="Temple":
        # A tiered, warm stone gateway silhouette above the entrance.
        for tier in range(4):
            var tier_width:=5.0-tier*0.8
            box(parent,"TempleTier",Vector3(0,height+0.42+tier*0.7,0),Vector3(tier_width,0.6,3.5-tier*0.45),Color("c69b66"))
            box(parent,"TempleCornice",Vector3(0,height+0.77+tier*0.7,0),Vector3(tier_width+0.25,0.12,3.7-tier*0.45),Color("e3c28c"))
        cylinder(parent,"TempleFinial",Vector3(0,height+3.3,0),0.23,0.8,Color("c9a14f"))
    elif title in ["Mosque","Observatory","Planetarium"]:
        var dome:=MeshInstance3D.new()
        dome.name="Dome"
        var sphere:=SphereMesh.new()
        sphere.radius=2.4;sphere.height=3.2
        dome.mesh=sphere
        var dome_mat:=StandardMaterial3D.new()
        dome_mat.albedo_color=Color("c1ae87") if title=="Temple" else neutral
        dome.material_override=dome_mat
        dome.position=Vector3(0,height+0.9,0)
        parent.add_child(dome)
    elif title in ["Lighthouse","Radio Mast","Fire Watchtower","Billboard Tower"]:
        box(parent,"Tower",Vector3(0,height+3,0),Vector3(2,6,2),neutral)
        box(parent,"TowerCap",Vector3(0,height+6.1,0),Vector3(3,0.3,3),rust)
        if title=="Billboard Tower":box(parent,"Billboard",Vector3(0,height+4.4,0),Vector3(8,3,0.25),Color("507080"))
    elif title in ["Water Tower","Silo"]:
        cylinder(parent,"StorageTank",Vector3(0,height+2,0),2.6,4,Color("a3adab"))
        cylinder(parent,"TankCap",Vector3(0,height+4.2,0),2.9,0.4,dark)
    elif title in ["Helipad","Airport Terminal","Hospital"]:
        box(parent,"HelipadBase",Vector3(0,height+0.08,0),Vector3(7,0.12,7),Color("586b67"))
        for x in [-1.3,1.3]:box(parent,"HelipadLine",Vector3(x,height+0.16,0),Vector3(0.25,0.08,4),neutral)
        box(parent,"HelipadCross",Vector3(0,height+0.17,0),Vector3(2.7,0.08,0.25),neutral)
    elif title in ["Factory","Power Plant","Oil Refinery"]:
        for x in [-3,3]:cylinder(parent,"Stack",Vector3(x,height+2,0),0.55,4,Color("78817c"))
    elif title in ["Windmill"]:
        box(parent,"WindmillTower",Vector3(0,height+2,0),Vector3(1,4,1),neutral)
        for direction in [-1,1]:
            var blade=box(parent,"WindmillBlade",Vector3(0,height+4,0),Vector3(0.22,5,0.16),neutral)
            blade.rotation.z=direction*PI/4
    elif title in ["Greenhouse"]:
        box(parent,"GlassRoof",Vector3(0,height+0.3,0),Vector3(width*0.8,0.35,depth*0.8),Color("9cb6a8"))
    elif title in ["Underground Bunker","Secret Laboratory","Smuggling Den"]:
        box(parent,"SecurityVent",Vector3(0,height+0.4,0),Vector3(2,0.8,2),dark)
    # No gameplay or interior is implied by the sign.
    parent.set_meta("example_name",title)
