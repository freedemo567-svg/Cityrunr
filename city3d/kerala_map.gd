extends Control

var features: Array = []
var selected := -1
var min_lon := 74.5
var max_lon := 77.5
var min_lat := 8.0
var max_lat := 13.0

func _ready():
    var file=FileAccess.open("res://assets/kerala/districts.json",FileAccess.READ)
    if file:
        var data=JSON.parse_string(file.get_as_text())
        if data is Dictionary: features=data.get("features",[])
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func _point(coordinate: Array) -> Vector2:
    # Longitude is corrected for latitude to retain approximate aspect ratio.
    return Vector2(65+(float(coordinate[0])-min_lon)*94, 520-(float(coordinate[1])-min_lat)*97)

func _draw():
    draw_rect(Rect2(Vector2.ZERO,size),Color("10252c"))
    var font=ThemeDB.fallback_font
    draw_string(font,Vector2(24,34),"KERALA | DISTRICT OVERVIEW",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color.WHITE)
    draw_string(font,Vector2(24,59),"District overview. Search a place in Kerala to explore its roads.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("d5e6e4"))
    for i in range(features.size()):
        var poly:=PackedVector2Array()
        for coordinate in features[i].geometry.coordinates[0]: poly.append(_point(coordinate))
        var color:=Color("e6b55c") if i==selected else Color.from_hsv(0.37+0.01*(i%5),0.40,0.65+0.02*(i%3))
        if poly.size()>=3:
            draw_colored_polygon(poly,color)
            draw_polyline(poly,Color("d4e9d6"),1.4,true)
        var y=92+i*29
        if i==selected: draw_rect(Rect2(420,y-21,300,26),Color("35554a"))
        draw_string(font,Vector2(430,y),features[i].properties.shapeName,HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color.WHITE)
    draw_string(font,Vector2(24,590),"Data: geoBoundaries / Pathways Data & lgdirectory.gov.in, 2021",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("d5e6e4"))
    draw_string(font,Vector2(24,612),"ODbL 1.0: geoboundaries.org | opendatacommons.org/licenses/odbl/1-0/",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("d5e6e4"))
    draw_rect(Rect2(size.x-94,10,80,38),Color("315b58"))
    draw_string(font,Vector2(size.x-82,36),"CLOSE",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)

func select_at(local: Vector2) -> bool:
    if Rect2(size.x-94,10,80,38).has_point(local): return true
    if local.x>=420 and local.x<=720:
        var i=int(floor((local.y-71)/29.0))
        if i>=0 and i<features.size(): selected=i
    else:
        for i in range(features.size()):
            var poly:=PackedVector2Array()
            for coordinate in features[i].geometry.coordinates[0]: poly.append(_point(coordinate))
            if Geometry2D.is_point_in_polygon(local,poly): selected=i; break
    queue_redraw()
    return false
