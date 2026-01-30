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

func _ready() -> void:
    GameEvent.more_difficulty.connect(on_more_difficulty)
    GameEvent.the_first_damage.connect(on_the_first_damage)
    gametimemanager.the_second_music.connect(the_second)
    GameEvent.game_stop.connect(stop_music)
    #GameEvent.player_died.connect(stop_music)
    GameEvent.stop_end.connect(on_stop_end)


func on_more_difficulty(difficulty := 0)->void:
    match difficulty:
        6:
            play(with_wolf)
        11:
            play(with_gorlen,with_wolf)
        15:
            play(the_final,with_gorlen)


func on_the_first_damage()->void:
    play(the_first)

func the_second()->void:
    play(with_wolf,the_first)

func play(which_music:AudioStreamPlayer,wait_music:AudioStreamPlayer=null)->void:
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


#func _on_the_first_finished() -> void:
	#play(the_first)
#
#func _on_with_wolf_finished() -> void:
	#play(with_wolf)
#
#func _on_with_gorlen_finished() -> void:
	#play(with_gorlen)
#
#func _on_the_final_finished() -> void:
	#play(the_final)

