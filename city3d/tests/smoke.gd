extends SceneTree
func _initialize():
    run.call_deferred()
func run():
    var scene = load("res://main.tscn").instantiate()
    root.add_child(scene)
    scene.set_physics_process(false)
    scene.money=0
    scene.in_car=false
    scene.player.position=Vector3(0,0.9,3)
    scene.car.position=Vector3(4,0,3)
    await process_frame
    if scene.player == null or scene.car == null:
        push_error("world actors missing"); quit(1); return
    if scene.car.get_node_or_null("CarVisual") == null or scene.traffic[0].get_node_or_null("CarVisual") == null:
        push_error("car models missing"); quit(1); return
    var styles={}
    for building in scene.town.buildings:
        styles[building.style]=true
        if scene.town.nearest(building.position).distance_to(building.position)<19:
            push_error("building overlaps road"); quit(1); return
    if styles.size()!=4:
        push_error("building variety missing"); quit(1); return
    if scene.architecture.building_roots.size()!=scene.town.buildings.size():
        push_error("architectural buildings missing"); quit(1); return
    var textured:=0
    for house in scene.architecture.building_roots:
        for visual in house.get_children():
            if visual.has_meta("textured_wall") and visual.material_override.albedo_texture!=null: textured+=1
    if textured!=scene.town.buildings.size():
        push_error("textured walls missing"); quit(1); return
    if scene.get_node_or_null("Story")!=null or scene.info.text.contains("JOB"):
        push_error("retired jobs still in HUD"); quit(1); return
    if scene.kerala_map.features.size()!=14:
        push_error("district map incomplete"); quit(1); return
    scene._toggle_kerala_map()
    if not scene.paused or not scene.kerala_map.visible:
        push_error("map did not pause world"); quit(1); return
    var tap:=InputEventScreenTouch.new()
    tap.index=9
    tap.position=scene.kerala_map.position+Vector2(450,100)
    tap.pressed=true
    scene._input(tap)
    if scene.kerala_map.selected!=1:
        push_error("district selection failed"); quit(1); return
    tap.position=scene.kerala_map.position+Vector2(900,25)
    scene._input(tap)
    if scene.paused or scene.kerala_map.visible:
        push_error("map resume failed"); quit(1); return
    for button in scene.drive_controls:
        if button.icon==null:
            push_error("driving icon missing"); quit(1); return
    if scene.engine_audio.stream.data.size()<1000 or scene.engine_audio.stream.loop_end!=44100:
        push_error("engine audio stream invalid"); quit(1); return
    scene._toggle_car()
    if not scene.engine_audio.playing:
        push_error("engine audio did not start"); quit(1); return
    var idle_pitch: float=scene.engine_audio.pitch_scale
    scene.car_speed=15
    scene._sync_engine()
    if scene.engine_audio.pitch_scale<=idle_pitch:
        push_error("engine audio does not respond to speed"); quit(1); return
    scene.car_speed=0
    scene._toggle_pause()
    if scene.engine_audio.playing:
        push_error("engine audio continues while paused"); quit(1); return
    scene._toggle_pause()
    if not scene.engine_audio.playing:
        push_error("engine audio did not resume"); quit(1); return
    if not scene.in_car:
        push_error("cannot enter nearby car"); quit(1); return
    scene._update_controls()
    var pedal:=InputEventScreenTouch.new()
    pedal.index=10
    pedal.position=Vector2(1200,570)
    pedal.pressed=true
    scene._input(pedal)
    var wheel:=InputEventScreenTouch.new()
    wheel.index=11
    wheel.position=Vector2(225,575)
    wheel.pressed=true
    scene._input(wheel)
    if not scene.accelerator or scene.steering!=1:
        push_error("simultaneous pedal/steering touch failed"); quit(1); return
    pedal.pressed=false
    scene._input(pedal)
    if scene.accelerator or scene.steering!=1:
        push_error("touch release affected other control"); quit(1); return
    wheel.pressed=false
    scene._input(wheel)
    wheel.pressed=true
    wheel.position=Vector2(190,575)
    scene._input(wheel)
    if absf(scene.steering-0.5)>0.01:
        push_error("analog steering did not scale"); quit(1); return
    wheel.pressed=false
    scene._input(wheel)
    if scene.steering!=0:
        push_error("wheel did not center after release"); quit(1); return
    scene._toggle_car()
    if scene.engine_audio.playing:
        push_error("engine audio did not stop after exit"); quit(1); return
    if scene.in_car:
        push_error("cannot leave car"); quit(1); return
    var traffic_start: Vector3=scene.traffic[0].position
    scene._move_traffic(0.5)
    if scene.traffic[0].position==traffic_start:
        push_error("traffic did not move"); quit(1); return
    scene._toggle_pause()
    var before: Vector3=scene.player.position
    scene.input_dir=Vector2(1,0)
    scene._physics_process(0.1)
    if scene.player.position!=before:
        push_error("pause did not freeze player"); quit(1); return
    scene._toggle_pause()
    scene.player.position=Vector3(0,0.9,3)
    scene.input_dir=Vector2(1,0)
    scene.boosting=false
    scene._physics_process(0.05)
    var walk: float=scene.player.velocity.x
    scene.boosting=true
    scene._physics_process(0.05)
    if scene.player.velocity.x<=walk:
        push_error("sprint did not increase speed"); quit(1); return
    scene.input_dir=Vector2.ZERO
    scene.boosting=false
    # Free exploration has no delivery requirements or campaign rewards.
    scene.discovered.clear()
    scene.distance_driven=0
    scene.top_speed=0
    scene._record_drive(1250,63)
    scene._record_drive(50,25)
    for place in scene.landmarks:
        scene.player.position=place.position+Vector3(0,0.9,0)
        scene._physics_process(0)
        scene._physics_process(0)
    if scene.discovered.size()!=4 or scene.distance_driven!=1300 or scene.top_speed!=63 or scene.money!=0:
        push_error("free exploration statistics incorrect"); quit(1); return
    scene._save_progress()
    scene.discovered.clear()
    scene.distance_driven=0
    scene.top_speed=0
    scene._load_progress()
    if scene.discovered.size()!=4 or scene.distance_driven!=1300 or scene.top_speed!=63:
        push_error("exploration save reload failed"); quit(1); return
    var saved_position: Vector3=scene.car.position
    scene.car.position=Vector3(0,0,0)
    scene._load_progress()
    if scene.car.position!=saved_position:
        push_error("position not restored"); quit(1); return
    if scene._restore_position([INF,0],Vector3.ZERO)!=Vector3.ZERO:
        push_error("invalid position accepted"); quit(1); return
    # Combat, cover, police, escape and defeat must work with old saves.
    scene.player.position=Vector3(0,0.9,0)
    scene.in_car=false
    scene.rivals[0].position=Vector3(0,0,-8)
    scene.shot_cooldown=0
    scene._fire()
    if scene.rivals[0].get_meta("hp") != 2 or scene.wanted_time <= 0:
        push_error("shot or wanted state failed"); quit(1); return
    scene._fire()
    if scene.rivals[0].get_meta("hp") != 2:
        push_error("shot cooldown failed"); quit(1); return
    scene.police.position=Vector3(-40,0,0)
    var police_before: Vector3=scene.police.position
    scene._update_combat(0.5)
    if not scene.police.visible or scene.police.position == police_before:
        push_error("police pursuit failed"); quit(1); return
    scene._fire()
    scene._update_combat(0.5)
    scene._fire()
    if scene.rivals[0].visible or scene.money != 50:
        push_error("rival defeat failed"); quit(1); return
    var cover: Vector3=scene.town.buildings[0].position
    if scene._clear_shot(cover-Vector3(10,0,0),cover+Vector3(10,0,0)):
        push_error("building did not block shot"); quit(1); return
    scene.police.position=scene.player.position
    scene.police_damage_cooldown=0
    scene.health=10
    scene._update_combat(0.1)
    if scene.health != 100 or scene.wanted_time != 0 or scene.money != 0:
        push_error("respawn failed"); quit(1); return
    scene.wanted_time=0.1
    scene._update_combat(0.2)
    if scene.wanted_time != 0 or scene.police.visible:
        push_error("wanted escape failed"); quit(1); return
    scene._save_progress()
    scene.money=0
    scene._load_progress()
    if scene.money != 0:
        push_error("combat cash save failed"); quit(1); return
    scene.wanted_time=0
    # Migrate an old story save without reactivating old tasks or discarding its fields.
    var legacy:=FileAccess.open("user://city_save.json",FileAccess.WRITE)
    legacy.store_string(JSON.stringify({"story_active":true,"story_step":3,"mission":2,"carrying":true,"money":900,"player":[0,3],"car":[4,3]}))
    legacy.close()
    scene._load_progress()
    scene._save_progress()
    var migrated=JSON.parse_string(FileAccess.get_file_as_string("user://city_save.json"))
    if migrated.story_step!=3 or scene.money!=900 or scene.info.text.contains("JOB"):
        push_error("legacy migration failed"); quit(1); return
    scene.car_speed=5
    scene._toggle_garage()
    if scene.garage_panel.visible:
        push_error("garage opened while moving"); quit(1); return
    scene.car_speed=0
    scene._toggle_garage()
    if not scene.garage_panel.visible or not scene.paused:
        push_error("garage failed to pause"); quit(1); return
    var paint_button: Button=scene.garage_panel.get_child(2)
    paint_button.get_meta("touch_down").call()
    if scene.paint_index!=1 or not scene.car.get_meta("paints").any(func(paint): return paint.albedo_color==scene.PAINTS[1]):
        push_error("paint change failed"); quit(1); return
    scene.garage_panel.get_child(3).get_meta("touch_down").call()
    scene.garage_panel.get_child(4).get_meta("touch_down").call()
    if scene.daylight!=1 or not scene.headlights or not scene.car.get_node("BeamLeft").visible:
        push_error("garage daylight/headlights failed"); quit(1); return
    scene.character_button.get_meta("touch_down").call()
    if scene.character_kind!=1 or not scene.human_visual.long_hair.visible or scene.character_button.text!="CHARACTER: FEMALE":
        push_error("character selection failed"); quit(1); return
    scene._toggle_garage()
    if scene.paused:
        push_error("garage did not resume"); quit(1); return
    scene.paint_index=0
    scene.daylight=0
    scene.headlights=false
    scene._set_character(0)
    scene._load_progress()
    if scene.paint_index!=1 or scene.daylight!=1 or not scene.headlights or scene.character_kind!=1 or not scene.human_visual.long_hair.visible:
        push_error("garage preferences not restored"); quit(1); return
    scene._set_character(0)
    if scene.human_visual.long_hair.visible:
        push_error("male character selection failed"); quit(1); return
    scene._toggle_pause()
    scene._toggle_garage()
    scene._toggle_garage()
    if not scene.paused:
        push_error("garage lost existing pause"); quit(1); return
    scene._toggle_pause()
    scene.in_car=true
    scene.braking=true
    scene.car_speed=-2
    scene._vehicle_lights()
    if scene.car.get_meta("lamps").Brakelight.emission_energy_multiplier<3 or scene.car.get_node("ReverseLeft").material_override.emission!=Color.WHITE:
        push_error("brake/reverse lamps failed"); quit(1); return
    scene.braking=false
    scene.in_car=false
    scene._vehicle_lights()
    scene.discovered.clear()
    var safe: Vector3=scene.town.nearest(Vector3(0,0,-30))
    if scene._restore_position([safe.x,safe.z],Vector3.ZERO)!=safe:
        push_error("town save rejected"); quit(1); return
    scene.car.position=Vector3(0,0,0)
    scene.car.rotation.y=0
    scene.traffic.clear()
    scene.car_speed=0
    scene._drive(0.2,0,1,false,false)
    if scene.car_speed<=0 or scene.car.position.z<=0:
        push_error("accelerator failed"); quit(1); return
    var accelerated: float=scene.car_speed
    scene._drive(0.1,0,0,true,false)
    if scene.car_speed>=accelerated:
        push_error("brake failed"); quit(1); return
    scene.car_speed=0
    scene._drive(0.2,0,0,false,true)
    if scene.car_speed>=0:
        push_error("reverse failed"); quit(1); return
    # The car's nose points along +Z, so its right side is local -X.
    # Test actual wheel input and travel at two headings in both gears.
    scene.in_car=true
    for heading in [0.0, PI/2]:
        for direction in [-1, 1]:
            for initial_speed in [-5.0, 5.0]:
                scene.car.position=Vector3.ZERO
                scene.car.rotation.y=heading
                scene.car_speed=initial_speed
                wheel.position=Vector2(155+70*direction,575)
                wheel.pressed=true
                scene._input(wheel)
                scene._drive(0.1,scene.steering,0,false,false)
                var right:=Vector3(-cos(heading),0,sin(heading))
                if scene.car.position.dot(right)*direction<=0 or (scene.car.rotation.y-heading)*direction*initial_speed>=0:
                    push_error("wheel steering direction incorrect for heading %s, input %s, speed %s" % [heading,direction,initial_speed]); quit(1); return
                wheel.pressed=false
                scene._input(wheel)
    scene.in_car=false
    scene.car.position=cover-Vector3(10,0,0)
    scene.car.rotation.y=PI/2
    scene.car_speed=22
    for i in range(8): scene._drive(0.25,0,1,false,false)
    if scene.town.blocked(scene.car.position,0):
        push_error("car crossed building"); quit(1); return
    scene.camera_angle=0
    scene._orbit(TAU+0.3,10)
    if absf(scene.camera_angle-0.3)>0.01 or scene.camera_pitch>1.1:
        push_error("360 orbit or pitch limit failed"); quit(1); return
    scene.camera_touch=2
    var drag:=InputEventScreenDrag.new()
    drag.index=2
    drag.relative=Vector2(100,0)
    scene._unhandled_input(drag)
    if absf(scene.camera_angle+0.5)>0.01:
        push_error("touch orbit failed"); quit(1); return
    scene._save_progress()
    scene.camera_angle=0
    scene._load_progress()
    if absf(scene.camera_angle+0.5)>0.01:
        push_error("camera save failed"); quit(1); return
    # Signals must hold AI traffic at red and allow progress on green.
    scene.features.elapsed=20
    var vehicle=scene.get_children().filter(func(node): return node.has_meta("progress"))[0]
    scene.traffic.append(vehicle)
    vehicle.set_meta("progress",35.0)
    vehicle.position=scene.town.roads[2][35]
    var stop_position: Vector3=vehicle.position
    scene._move_traffic(0.1)
    if vehicle.position!=stop_position or scene.features.signal_phase()!=0:
        push_error("traffic did not stop for red"); quit(1); return
    scene.features.elapsed=0
    scene._move_traffic(0.1)
    if vehicle.position==stop_position:
        push_error("green did not release traffic"); quit(1); return
    scene.features.elapsed=13
    if scene.features.signal_phase()!=1:
        push_error("amber phase missing"); quit(1); return
    scene.features.elapsed=20
    scene.features.tick(0)
    if scene.features.signals[0].lamps[0].material_override.emission==Color.BLACK:
        push_error("red lamp not lit"); quit(1); return
    var crossing: Dictionary=scene.features.crossings[0]
    scene.features.train_x=crossing.position.x
    scene.features.tick(0)
    if not crossing.closed or not scene.features.blocks_vehicle(crossing.position+Vector3(0,0,-7),crossing.position+Vector3(0,0,-5)):
        push_error("rail barrier did not close/block car"); quit(1); return
    scene.features.train_x=200
    scene.features.tick(0)
    if crossing.closed:
        push_error("rail gate did not reopen"); quit(1); return
    var bridge: Dictionary=scene.features.bridges[0]
    if scene.features.blocks_vehicle(bridge.position,bridge.position):
        push_error("bridge not drivable"); quit(1); return
    if not scene.features.blocks_vehicle(Vector3(-152,0,0),Vector3(-153,0,0)):
        push_error("sea boundary not blocked"); quit(1); return
    if scene.human_visual.find_child("ScannedHead",true,false)==null:
        push_error("scanned human face missing"); quit(1); return
    if scene.human_visual.animation==null or scene.human_visual.animation.get_animation(scene.human_visual.walk_name).length<=0:
        push_error("human animation missing"); quit(1); return
    scene.human_visual.set_motion(Vector3(2,0,0))
    if not scene.human_visual.animation.is_playing():
        push_error("walking animation not playing"); quit(1); return
    scene.human_visual.set_motion(Vector3.ZERO)
    if scene.human_visual.animation.is_playing():
        push_error("idle animation did not pause"); quit(1); return
    scene.features.elapsed=7
    scene._toggle_pause()
    var rail_before: Vector3=scene.features.train.position
    scene._physics_process(1)
    if scene.features.train.position!=rail_before or scene.features.elapsed!=7:
        push_error("pause did not freeze infrastructure"); quit(1); return
    scene._toggle_pause()
    # Every supported vehicle can be selected, driven and restored from a save.
    scene.traffic.clear()
    scene.features.train_x=220
    scene.features.tick(0)
    for kind in range(scene.fleet.NAMES.size()):
        scene.car.position=Vector3(4,0,3)
        scene.car.rotation.y=0
        scene._set_vehicle(kind)
        if not scene.car.has_node("CarVisual") or scene.car.get_meta("lamps").is_empty():
            push_error("fleet visual/lights missing"); quit(1); return
        scene.car_speed=0
        scene._drive(0.1,0,1,false,false)
        if scene.car_speed<=0:
            push_error("fleet vehicle cannot accelerate"); quit(1); return
    scene.in_car=true
    scene._start_horn()
    if not scene.horn.playing or scene.horn.stream.get_length()<0.2:
        push_error("horn sample failed"); quit(1); return
    scene._stop_horn()
    if scene.horn.playing:
        push_error("horn release failed"); quit(1); return
    scene._start_horn()
    scene._toggle_pause()
    if scene.horn.playing or scene.horn_down:
        push_error("horn did not stop on pause"); quit(1); return
    scene._toggle_pause()
    scene.car.position=Vector3(4,0,3)
    scene._save_progress()
    scene._set_vehicle(0)
    scene._load_progress()
    if scene.vehicle_kind!=5 or not scene.car.has_node("BeamLeft"):
        push_error("fleet save failed"); quit(1); return
    print("City 3D fleet, horn and regression smoke passed")
    quit()
