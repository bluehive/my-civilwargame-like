extends Node
class_name MarchBgm
## Soft chordal march (sine pad + triad) via AudioStreamGenerator only.

@onready var player: AudioStreamPlayer = $Player

var _gen: AudioStreamGenerator
var _playback: AudioStreamGeneratorPlayback
var _phases: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]  # bass + 3 chord + soft lead
var _t := 0.0
var muted := false
var volume_linear := 0.385
var tempo_scale := 1.0
var _tempo_target := 1.0

const BPM := 88.0
const MIX_RATE := 22050.0

# Chord roots (Hz) cycling every 2 beats: Am / F / C / G  (martial but warmer)
const CHORDS := [
	[220.0, 261.63, 329.63],   # A3 C4 E4
	[174.61, 220.0, 261.63],   # F3 A3 C4
	[130.81, 164.81, 196.0],   # C3 E3 G3
	[196.0, 246.94, 293.66],   # G3 B3 D4
]

func _ready() -> void:
	_gen = AudioStreamGenerator.new()
	_gen.mix_rate = MIX_RATE
	_gen.buffer_length = 0.4
	player.stream = _gen
	player.volume_db = linear_to_db(volume_linear)
	player.play()
	_playback = player.get_stream_playback()

func _process(delta: float) -> void:
	tempo_scale = lerpf(tempo_scale, _tempo_target, clampf(delta * 1.8, 0.0, 1.0))
	_tempo_target = lerpf(_tempo_target, 1.0, clampf(delta * 0.25, 0.0, 1.0))
	if _playback == null:
		_playback = player.get_stream_playback()
		if _playback == null:
			return
	_fill()

func toggle_mute() -> void:
	muted = not muted
	player.volume_db = -80.0 if muted else linear_to_db(volume_linear)

func pulse_combat_tempo() -> void:
	_tempo_target = minf(1.85, _tempo_target + 0.55)
	tempo_scale = maxf(tempo_scale, 1.35)

func _soft_sin(phase: float) -> float:
	# Fundamental + soft 2nd harmonic (less buzzy than square)
	return sin(phase) * 0.85 + sin(phase * 2.0) * 0.15

func _fill() -> void:
	var frames := _playback.get_frames_available()
	if frames <= 0:
		return
	var beat_sec := 60.0 / (BPM * maxf(0.7, tempo_scale))
	for _i in frames:
		var beat_pos := fmod(_t / beat_sec, 8.0)
		var chord_i := int(beat_pos / 2.0) % CHORDS.size()
		var chord: Array = CHORDS[chord_i]
		var beat_frac := fmod(beat_pos, 1.0)
		# Slow attack within each half-bar
		var bar_frac := fmod(beat_pos, 2.0) / 2.0
		var pad_env := 0.55 + 0.45 * sin(bar_frac * PI)

		# Bass (one octave below root)
		var bass_f: float = float(chord[0]) * 0.5
		_phases[0] += TAU * bass_f / MIX_RATE
		var bass := _soft_sin(_phases[0]) * 0.16

		# Triad pad
		var chord_s := 0.0
		for vi in 3:
			_phases[vi + 1] += TAU * float(chord[vi]) / MIX_RATE
			chord_s += _soft_sin(_phases[vi + 1])
		chord_s = (chord_s / 3.0) * 0.20 * pad_env

		# Soft melodic top on downbeats (not square)
		var lead := 0.0
		if beat_frac < 0.55:
			var lead_f: float = float(chord[2]) * (1.0 if int(beat_pos) % 2 == 0 else 1.5)
			_phases[4] += TAU * lead_f / MIX_RATE
			var lenv := sin(clampf(beat_frac / 0.55, 0.0, 1.0) * PI)
			lead = _soft_sin(_phases[4]) * 0.07 * lenv

		# Gentle pulse (no harsh noise beep)
		var pulse := 0.0
		if beat_frac < 0.12:
			pulse = sin(beat_frac / 0.12 * PI) * 0.04 * (1.0 if int(beat_pos) % 2 == 0 else 0.6)

		var sample := clampf(bass + chord_s + lead + pulse, -1.0, 1.0)
		_playback.push_frame(Vector2(sample, sample))
		_t += 1.0 / MIX_RATE
