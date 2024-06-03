extends RayCast2D

@onready var effect :Line2D= $Effect
@onready var end = $End


var max_distance = 1000
@export var damage = 0.1
func _ready():
	target_position = Vector2(max_distance,0)

func _physics_process(delta):
	if is_colliding():
		var collide_points = to_local(get_collision_point())
		effect.points[1].x = collide_points.x
		end.position.x = collide_points.x -15
		var new_collider = get_collider()
		if new_collider is Monster:
			new_collider.take_damage(1*delta + damage)
			print(new_collider.max_hp)
