extends Area2D


var direction = Vector2.RIGHT
var speed = 100
var target = null
var bullet_damage = 1


func _physics_process(delta):
	translate(direction.normalized() * speed* delta)
	if target:
		direction = target.global_position - global_position
		direction = direction.normalized()
		look_at(target.global_position)
	
	

func _on_body_entered(body):
	if body is Monster:
		body.take_damage(bullet_damage)
		queue_free()


func _on_seeking_zone_body_entered(body):
	target = body


func _on_visiblity_notifier_screen_exited():
	queue_free()
