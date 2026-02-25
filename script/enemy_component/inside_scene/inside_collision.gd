class_name AreaInComponent
extends Area2D

func return_component()->EnemyComponent:
	var component = get_parent()
	while component:
		if  component is EnemyComponent:
			return component
		component = component.get_parent()
	return null
