extends RefCounted
func engine(kind: int=0) -> AudioStreamWAV:
    var stream:=AudioStreamWAV.new()
    stream.format=AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate=22050
    var frames:=44100
    var samples:=PackedByteArray()
    samples.resize(frames*2)
    # Procedural engine tone: periodic harmonics and a slow combustion pulse.
    var noise:=RandomNumberGenerator.new()
    noise.seed=117+kind
    var filtered:=0.0
    for i in range(frames):
        var t:=float(i)/stream.mix_rate
        var pulse:=0.72+0.28*sin(TAU*(7+kind)*t)
        var value: float=(sin(TAU*30*t)*0.48+sin(TAU*60*t)*0.23+sin(TAU*90*t)*0.14+sin(TAU*120*t)*0.1)*pulse
        filtered=lerpf(filtered,noise.randf_range(-1,1),0.12)
        value=value*0.8+filtered*0.3
        samples.encode_s16(i*2,int(clampf(value,-1,1)*12000))
    stream.data=samples
    stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin=0
    stream.loop_end=frames
    return stream

func impact() -> AudioStreamWAV:
    var stream:=AudioStreamWAV.new()
    stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=22050
    var data:=PackedByteArray();data.resize(11025*2)
    var noise:=RandomNumberGenerator.new();noise.seed=881
    for i in range(11025):
        var t:=float(i)/22050
        var v: float=(noise.randf_range(-1,1)*0.65+sin(TAU*65*t)*0.35)*exp(-t*15)
        data.encode_s16(i*2,int(v*22000))
    stream.data=data
    return stream

func road() -> AudioStreamWAV:
    var stream:=AudioStreamWAV.new()
    stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=22050
    var samples:=PackedByteArray();samples.resize(44100*2)
    var noise:=RandomNumberGenerator.new();noise.seed=501
    var filtered:=0.0
    for i in range(44100):
        filtered=lerpf(filtered,noise.randf_range(-1,1),0.35)
        samples.encode_s16(i*2,int(filtered*13000))
    stream.data=samples;stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
    stream.loop_begin=0;stream.loop_end=44100
    return stream
