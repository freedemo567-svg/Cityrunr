extends RefCounted
static var rounded_cache: Dictionary={}

static func rounded_box(size: Vector3) -> ArrayMesh:
    var key:=str(size)
    if rounded_cache.has(key): return rounded_cache[key]
    var half:=size/2
    var radius:=minf(0.12,minf(half.x,minf(half.y,half.z))*0.45)
    var inset:=half-Vector3.ONE*radius
    var surface:=SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for axis in range(3):
        var u_axis: int=(axis+1)%3
        var v_axis: int=(axis+2)%3
        var u_values: Array=[-half[u_axis],-inset[u_axis],0.0,inset[u_axis],half[u_axis]]
        var v_values: Array=[-half[v_axis],-inset[v_axis],0.0,inset[v_axis],half[v_axis]]
        for sign_value in [-1,1]:
            for u in range(4):
                for v in range(4):
                    var order: Array=[Vector2i(0,0),Vector2i(1,1),Vector2i(1,0),Vector2i(0,0),Vector2i(0,1),Vector2i(1,1)] if sign_value>0 else [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]
                    for corner in order:
                        var point:=Vector3.ZERO
                        point[axis]=half[axis]*sign_value
                        point[u_axis]=u_values[u+corner.x]
                        point[v_axis]=v_values[v+corner.y]
                        var closest:=point.clamp(-inset,inset)
                        var normal: Vector3=(point-closest).normalized()
                        surface.set_normal(normal)
                        surface.set_uv(Vector2((point[u_axis]/size[u_axis])+0.5,(point[v_axis]/size[v_axis])+0.5))
                        surface.add_vertex(closest+normal*radius)
    surface.index()
    var mesh:=surface.commit()
    rounded_cache[key]=mesh
    return mesh
