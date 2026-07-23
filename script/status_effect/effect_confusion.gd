extends StatusEffect
class_name EffectConfusion


func single_effect()->void:
	#检测_carrier类型
	if carrier is Player:
		#编辑键盘操作
		var key_origin_name:Dictionary = {"up":[KEY_W,KEY_UP,Vector2(0,1)],
		"down":[KEY_S,KEY_DOWN,Vector2(0,-1)],
		"left":[KEY_A,KEY_LEFT,Vector2(-1,0)],
		"right":[KEY_D,KEY_RIGHT,Vector2(1,0)]
		}
		#打乱键位顺序
		var key_array := key_origin_name.keys()
		var value_array := key_origin_name.values()
		value_array.shuffle()
		#编辑模拟摇杆操作
		var _carrier = carrier as Player
		var yaogan = _carrier.get_tree().get_first_node_in_group("yaogan") as VirtualThumbstick
		#分配键位
		for i in key_origin_name.size():
			var _value = value_array[i] as Array
			key_origin_name[key_array[i]] = _value
			InputMap.action_erase_events(key_array[i])
			for key_name in _value:
				if key_name is int:
					var key_event = InputEventKey.new()
					key_event.keycode = key_name
					InputMap.action_add_event(key_array[i], key_event)
			#编辑模拟摇杆操作
			yaogan.key_to_vector[key_array[i]] = _value[-1]
			print(yaogan.key_to_vector)
		
	elif carrier is Enemy:
		#未施工
		pass
		
	else :
		#有待施工
		return

func recover_effect() -> void:
	if carrier is Player:
		var key_origin_name:Dictionary = {"up":[KEY_W,KEY_UP,Vector2(0,1)],
		"down":[KEY_S,KEY_DOWN,Vector2(0,-1)],
		"left":[KEY_A,KEY_LEFT,Vector2(-1,0)],
		"right":[KEY_D,KEY_RIGHT,Vector2(1,0)]
		}
		#打乱键位顺序
		var key_array = key_origin_name.keys()
		var value_array = key_origin_name.values()
		#编辑模拟摇杆操作
		var _carrier = carrier as Player
		var yaogan = _carrier.get_tree().get_first_node_in_group("yaogan") as VirtualThumbstick
		#分配键位
		for i in key_origin_name.size():
			var _value = value_array[i] as Array
			InputMap.action_erase_events(key_array[i])
			for key_name in value_array[i]:
				if key_name is int:
					var key_event = InputEventKey.new()
					key_event.keycode = key_name
					InputMap.action_add_event(key_array[i], key_event)
			#编辑模拟摇杆操作
			yaogan.key_to_vector[key_array[i]] = _value[-1]
	elif carrier is Enemy:
		#未施工
		pass
		
	else :
		#有待施工
		pass
	
