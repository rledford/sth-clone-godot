extends AudioStreamPlayer
class_name Music

const BOSS_FIGHT_THEME_01 = preload("res://music/Boss Fight Theme 01.mp3")
const BOSS_FIGHT_THEME_02 = preload("res://music/Boss Fight Theme 02.mp3")
const BOSS_FIGHT_THEME_03 = preload("res://music/Boss Fight Theme 03.mp3")
const STANDARD_ENCOUNTER_THEME_01 = preload("res://music/Standard Encounter Theme 01.mp3")
const STANDARD_ENCOUNTER_THEME = preload("res://music/Standard Encounter Theme.mp3")

const tracks = [
	BOSS_FIGHT_THEME_01,
	BOSS_FIGHT_THEME_02,
	BOSS_FIGHT_THEME_03,
	STANDARD_ENCOUNTER_THEME_01,
	STANDARD_ENCOUNTER_THEME
]

var action_volume: int = -10
var menu_volume: int = -20
var silent_volume: int = -50

var _last_played_track: Resource


func _ready() -> void:
	self.volume_db = silent_volume

	SignalBus.game_over.connect(func(_wave: int): _on_game_over())
	SignalBus.wave_started.connect(func(_wave: int): _on_wave_start())
	SignalBus.break_started.connect(func(_break_time: float): _on_break_start())


func _on_game_over() -> void:
	_play_random_track(menu_volume)


func _on_wave_start() -> void:
	_play_random_track(action_volume)


func _on_break_start() -> void:
	await _fade_out(silent_volume, 3)
	self.stop()


func _play_random_track(volume: int) -> void:
	_play(_get_random_track(), volume)


func _play(res: Resource, volume: int) -> void:
	if self.playing:
		await _fade_out(silent_volume, 2)
		self.stop()

	self.set_stream(res)
	self.play()
	_last_played_track = res
	await _fade_in(volume, 4)


# These two look quite similar, but they'll probably need to be tweaked separately
func _fade_out(volume: int, duration: int) -> Signal:
	var fade_out = create_tween()
	fade_out.set_ease(Tween.EaseType.EASE_OUT)
	fade_out.set_trans(Tween.TransitionType.TRANS_QUAD)
	fade_out.tween_property(self, "volume_db", volume, duration)
	return fade_out.finished


func _fade_in(volume: int, duration: int) -> Signal:
	var fade_in = create_tween()
	fade_in.set_ease(Tween.EaseType.EASE_OUT)
	fade_in.set_trans(Tween.TransitionType.TRANS_QUAD)
	fade_in.tween_property(self, "volume_db", volume, duration)
	return fade_in.finished


func _get_random_track() -> Resource:
	if not _last_played_track:
		return tracks.pick_random()

	var new_track = tracks.pick_random()
	while new_track == _last_played_track:
		new_track = tracks.pick_random()
	return new_track
