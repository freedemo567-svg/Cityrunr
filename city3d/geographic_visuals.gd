extends RefCounted

# Build one mesh per tile, using the mapped footprints rather than a box for
# every building. Colours are illustrative; OSM does not supply facade art.
const WALL_COLORS := [Color("d6c7aa"), Color("d3d0bf"), Color("c4b49b"), Color("d9c2ae"), Color("b9c3ad")]
const ROOF_COLORS := [Color("a7614b"), Color("8e7165"), Color("aaa397"), Color("ad725c")]

static func triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, normal: Vector3, color: Color):
    for point in [a,b,c]:
        surface.set_normal(normal)
        surface.set_color(color)
        surface.set_uv(Vector2(point.x,point.z))
        surface.add_vertex(point)

static func quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3, color: Color):
    triangle(surface,a,b,c,normal,color)
    triangle(surface,a,c,d,normal,color)

static func strip(surface: SurfaceTool, a: Vector3, b: Vector3, half_width: float, color: Color):
    var side: Vector3=(b-a).normalized().cross(Vector3.UP)*half_width
    quad(surface,a-side,a+side,b+side,b-side,Vector3.UP,color)

static func wall(surface: SurfaceTool, a: Vector3, b: Vector3, height: float, color: Color, outward_sign: float):
    var normal: Vector3=(b-a).cross(Vector3.UP).normalized()*outward_sign
    var length:=a.distance_to(b)
    var points: Array[Vector3]=[a,b,b+Vector3.UP*height,a,b+Vector3.UP*height,a+Vector3.UP*height]
    var coords: Array[Vector2]=[Vector2.ZERO,Vector2(length,0),Vector2(length,height),Vector2.ZERO,Vector2(length,height),Vector2(0,height)]
    for i in range(points.size()):
        surface.set_normal(normal)
        surface.set_color(color)
        surface.set_uv(coords[i])
        surface.add_vertex(points[i])

static func buildings(entries: Array, origin: Vector3) -> ArrayMesh:
    if entries.is_empty(): return null
    var surface:=SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    var made:=false
    for entry in entries:
        var polygon:=PackedVector2Array()
        for point in entry[1]:
            var local:=Vector2(float(point[0])-origin.x,float(point[1])-origin.z)
            if polygon.is_empty() or local.distance_squared_to(polygon[-1])>0.0001: polygon.append(local)
        if polygon.size()>2 and polygon[0].distance_squared_to(polygon[-1])<0.0001: polygon.remove_at(polygon.size()-1)
        if polygon.size()<3: continue
        var indices:=Geometry2D.triangulate_polygon(polygon)
        if indices.is_empty():
            # Invalid source outlines still get a visible fallback footprint.
            var minimum:=Vector2(INF,INF)
            var maximum:=Vector2(-INF,-INF)
            for point in polygon:
                minimum=minimum.min(point)
                maximum=maximum.max(point)
            polygon=PackedVector2Array([minimum,Vector2(maximum.x,minimum.y),maximum,Vector2(minimum.x,maximum.y)])
            indices=Geometry2D.triangulate_polygon(polygon)
        var area:=0.0
        for i in range(polygon.size()): area+=polygon[i].cross(polygon[(i+1)%polygon.size()])
        var height: float=entry[2]
        var wall_color: Color=WALL_COLORS[posmod(int(entry[0]),WALL_COLORS.size())]
        var roof: Color=ROOF_COLORS[posmod(int(entry[0]),ROOF_COLORS.size())]
        if entry.size()>3 and entry[3] is Dictionary:
            var palette={"residential":"d8c6a9","office":"aabfc0","civic":"d6d6c8","transport":"aeb9b7","vehicle":"d3d0c4","retail":"d8c8b1","leisure":"c3cdcc","industrial":"9fa9a4","rural":"c4ad91","landmark":"cfc7ae","worship":"e4d9c0","media":"b1bdbe","secret":"929e92"}
            wall_color=Color(palette.get(entry[3].category,"d6c7aa"))
            roof=Color("747e7b")
        for i in range(polygon.size()):
            var p: Vector2=polygon[i]
            var q: Vector2=polygon[(i+1)%polygon.size()]
            var a:=Vector3(p.x,0,p.y)
            var b:=Vector3(q.x,0,q.y)
            wall(surface,a,b,height,wall_color,-1.0 if area>0 else 1.0)
        for i in range(0,indices.size(),3):
            var a: Vector2=polygon[indices[i]]
            var b: Vector2=polygon[indices[i+1]]
            var c: Vector2=polygon[indices[i+2]]
            triangle(surface,Vector3(a.x,height,a.y),Vector3(b.x,height,b.y),Vector3(c.x,height,c.y),Vector3.UP,roof)
        made=true
    return surface.commit() if made else null
