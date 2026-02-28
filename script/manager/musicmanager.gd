class_name MusicManager
extends Node

@onready var the_first: AudioStreamPlayer = $TheFirst
@onready var with_wolf: AudioStreamPlayer = $WithWolf
@onready var with_gorlen: AudioStreamPlayer = $WithGorlen
@onready var the_final: AudioStreamPlayer = $TheFinal
@onready var gametimemanager: Node = $"../gametimemanager"

@export var all_music:Array[AudioStreamPlayer]

var a_stop_music:AudioStreamPlayer
var a_stop_time:float

var is_second:=false
var no_continue:=false

func _ready() -> void:
	GameEvent.more_difficulty.connect(on_more_difficulty)
	GameEvent.the_first_damage.connect(on_the_first_damage)
	gametimemanager.the_second_music.connect(the_second)
	GameEvent.always_stop.connect(stop_music)
	#GameEvent.player_died.connect(stop_music)
	GameEvent.always_start.connect(on_stop_end)


func on_more_difficulty(difficulty := 0)->void:
	match difficulty:
		5:
			no_continue=true
		6:
			play(with_wolf,the_first)
			no_continue=false
		10:
			no_continue=true
		11:
			play(with_gorlen,with_wolf)
			no_continue=false
		14:
			no_continue=true
		15:
			play(the_final,with_gorlen)
			no_continue=false

func on_the_first_damage()->void:
	play(the_first)

func the_second()->void:
	play(with_wolf,the_first)

func play(which_music:AudioStreamPlayer,wait_music:AudioStreamPlayer=null)->void:
	if is_second:
		is_second=false
		for music:AudioStreamPlayer in all_music:
			if ! music==which_music:
				music.stop()
	if wait_music:
		if wait_music.playing:
			await wait_music.finished
	if !which_music.playing:
		which_music.play()
		for music:AudioStreamPlayer in all_music:
			if ! music==which_music:
				music.stop()

func stop_music()->void:
	for music:AudioStreamPlayer in all_music:
		if music.playing:
			a_stop_music=music
			music.stream_paused=true

func on_stop_end()->void:
	if a_stop_music:
		a_stop_music.stream_paused=false

func _on_the_first_finished() -> void:
	if no_continue:
		return
	play(the_first)
	is_second=true

func _on_with_wolf_finished() -> void:
	if no_continue:
		return
	play(with_wolf)
	is_second=true

func _on_with_gorlen_finished() -> void:
	if no_continue:
		return
	play(with_gorlen)
	is_second=true

func _on_the_final_finished() -> void:
	if no_continue:
		return
	play(the_final)
	is_second=true
