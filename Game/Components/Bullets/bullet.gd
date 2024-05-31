class_name Bullet
extends Area2D

@onready var bullet_time_out :Timer = $Bullet_TimeOut

var direction = Vector2.RIGHT
var speed = 400
var bullet_damage := 1
var shotgun: = false
var range_in_time := 0.2
var range_in_pixels := 500

func _ready():
	$Model.self_modulate = Color(randf_range(0,1), randf_range(0,1), randf_range(0,1), 1)
func _process(delta):
	translate(direction.normalized() * speed* delta)
	if shotgun:
		bullet_time_out.start(range_in_time)
		shotgun = false




func _on_body_entered(body):
	if body is Monster:
		body.take_damage(bullet_damage)
		queue_free()


func _on_visiblity_notifier_screen_exited():
	queue_free()


func _on_bullet_time_out_timeout():
	queue_free()
