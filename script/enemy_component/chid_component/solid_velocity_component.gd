class_name SolidVelocityComponent
extends VelocityController

func move(character:Enemy):
	# 1. 用模块里“方向 * 速度”作为本次期望速度
	var desired_vel = velocity
	# 2. 交给物理处理碰撞、滑动
	character.velocity = desired_vel
	if character.velocity.length() > speed*2.0:
		character.velocity = character.velocity.normalized()*speed*1.5 
	var collision = character.move_and_collide(desired_vel*get_physics_process_delta_time())
	if collision:
		var object= collision.get_collider() as Enemy
		var is_change:=false
		for component in object.all_component:
			if component is SolidVelocityComponent:
				is_change=true
				component.velocity = velocity*1.5
		if is_change:
			object.velocity *= 1.5
			#var the_velocity := collision.get_collider_velocity()
			#var projection = (desired_vel.dot(the_velocity) / the_velocity.length_squared()) * the_velocity
			#velocity *=0.1
			#character.velocity *=0.1
			pass
		else :
			character.velocity=character.velocity
