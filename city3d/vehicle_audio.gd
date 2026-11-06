extends RefCounted
func engine() -> AudioStreamWAV:
    var stream:=AudioStreamWAV.new()
    stream.format=AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate=22050
    var frames:=44100
    var samples:=PackedByteArray()
    samples.resize(frames*2)
    # Procedural engine tone: periodic harmonics and a slow combustion pulse.
    for i in range(frames):
        var t:=float(i)/stream.mix_rate
        var pulse:=0.72+0.28*sin(TAU*7*t)
        var value: float=(sin(TAU*30*t)*0.48+sin(TAU*60*t)*0.23+sin(TAU*90*t)*0.14+sin(TAU*120*t)*0.1)*pulse
        samples.encode_s16(i*2,int(clampf(value,-1,1)*12000))
    stream.data=samples
    stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin=0
    stream.loop_end=frames
    return stream
