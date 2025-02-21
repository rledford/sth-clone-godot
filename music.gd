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

var volume: float = -10
var initial_volume: float = volume - 40
var fade_in_duration: float = 6
var fade_out_duration: float = 2

var _last_played_track: Resource

func _ready() -> void:
	_play_random_track()
	SignalBus.game_over.connect(func(_wave: int): _on_game_over())

func _on_game_over() -> void:
	_play_random_track()

func _play_random_track() -> void:
	_play(_get_random_track())

func _play(res: Resource) -> void:
	if self.playing:
		await _fade_out()
		self.stop()
		
	self.set_stream(res)
	self.volume_db = initial_volume
	self.play()
	_last_played_track = res
	await _fade_in()

# These two look quite similar, but they'll probably need to be tweaked separately
func _fade_out() -> Signal:
	var fade_out = create_tween()
	fade_out.set_ease(Tween.EaseType.EASE_OUT)
	fade_out.set_trans(Tween.TransitionType.TRANS_QUAD)
	fade_out.tween_property(self, "volume_db", initial_volume, fade_out_duration)
	return fade_out.finished

func _fade_in() -> Signal:
	var fade_in = create_tween()
	fade_in.set_ease(Tween.EaseType.EASE_OUT)
	fade_in.set_trans(Tween.TransitionType.TRANS_QUAD)
	fade_in.tween_property(self, "volume_db", volume, fade_in_duration)
	return fade_in.finished

func _get_random_track() -> Resource:
	if not _last_played_track:
		return tracks.pick_random()

	var new_track = tracks.pick_random()
	while new_track == _last_played_track:
		new_track = tracks.pick_random()
	return new_track
