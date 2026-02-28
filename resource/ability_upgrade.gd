extends Resource
class_name AbilityUpgrade

enum SOST_TYPE{
	角色能力,
	火球,
	枪,
	天堂之怒,
	光剑,
	环,
	剑
}



@export var ID:String
@export var Sort:String
@export var is_init:=false
@export var is_unlock:=false
@export var name:String
#当self_lock！=0时，他点一次就会从升级池里去掉
@export var self_lock:=0
#当有其他能力的lock_code与这个能力的self_lock相同时，将此能力再次加入升级池里
@export var lock_code:=0
@export_multiline var Description:String
