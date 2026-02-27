extends DropComment

var bonus:=0

func on_died():
	var entities_Layer=get_tree().get_first_node_in_group("实体图层")
	for i in drop_range:
		for index in all_dropthing.size():
			if randf()<all_droppresent[index]*GameEvent.increase_percent:
				var drop_instance=all_dropthing[index].instantiate() as Node2D
				call_deferred("add_bottle",entities_Layer,_get_position(index,i),drop_instance)
				if index==2:
					bonus+=1
		if i == drop_range-1 and bonus==0:
			var drop_instance=all_dropthing[2].instantiate() as Node2D
			call_deferred("add_bottle",entities_Layer,_get_position(2,i),drop_instance)

func get_rangR(i:int):
	return randf_range(10+i*10,40+i*40)
