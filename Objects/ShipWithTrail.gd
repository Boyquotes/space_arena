extends KinematicBody2D

export (int) var accel = 200
export (int) var max_speed = 1000
export (float) var rotation_speed = 1.5
export (PackedScene) var Bullet

var velocity = Vector2()
var rotation_dir = 0
var speed = 0
var shoot = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	auto_shoot()
	get_input()
	velocity = Vector2(speed, 0).rotated(rotation)
	rotation += rotation_dir * rotation_speed * delta
	velocity = move_and_slide(velocity)

func get_input():
	rotation_dir = 0
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		rotation_dir += 1
	if Input.is_action_pressed("ui_left"):
		rotation_dir -= 1
	if Input.is_action_just_released("ui_down"):
		#velocity = Vector2(-speed, 0).rotated(rotation)
		speed -= accel
		if speed < 0:
			speed = 0
	if Input.is_action_just_released("ui_up"):
		#velocity = Vector2(speed, 0).rotated(rotation)
		speed += accel 
		if speed > max_speed:
			speed = max_speed
	#if Input.is_action_just_pressed("ui_select"):
		#shoot()

func auto_shoot():
	if(shoot == true && $Autoshoot_Timer.is_stopped()):
		shoot()

func shoot():
	$Autoshoot_Timer.start()
	var b = Bullet.instance()
##	add_child(b)
##	b.transform = $Muzzle.transform
	owner.add_child(b)
	b.transform = $Muzzle.global_transform
	b.rotation_degrees = b.rotation_degrees + rand_range(-2, 2)


func _on_Area2D_area_entered(area):
	if(area.get_parent().name == "Asteroid"):
		shoot = true


func _on_Area2D_area_exited(area):
	if(area.get_parent().name == "Asteroid"):
		shoot = false
