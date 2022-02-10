extends KinematicBody2D

export (int) var accel = 200
export (int) var max_speed = 1000
export (float) var rotation_speed = 1.5
export (PackedScene) var Bullet
export var player_mode = 'User'
export var team_no = 1

var velocity = Vector2()
var rotation_dir = 0
var speed = 0
var shoot = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	auto_shoot()
	
	if player_mode == 'User' :
		palyer_mode(delta)
	elif player_mode == 'NPC' :
		npc_mode(delta)
		
	velocity = Vector2(speed, 0).rotated(rotation)
	rotation += rotation_dir * rotation_speed * delta
	velocity = move_and_slide(velocity)

func palyer_mode(delta):
	$Camera2D.current = true
	get_input()

func npc_mode(delta):
	$Camera2D.current = false
	var player_list = get_tree().get_nodes_in_group("Player")
	var nearest_player = player_list[0]
	for player in player_list:
		if global_position != player.global_position and team_no != player.team_no :
			if player.global_position.distance_to(global_position) < nearest_player.global_position.distance_to(global_position):
				nearest_player = player
	
	var _direction = global_position.direction_to(nearest_player.global_position)
	var _rotation = _direction.angle()
	rotation_dir = 0
	
	var max_angle = PI * 2
	var difference = fmod(_rotation - rotation, max_angle)
	rotation_dir = fmod(2 * difference, max_angle) - difference
	
	speed = 600

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
	if(shoot > 0 && $Autoshoot_Timer.is_stopped()):
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
	if(area.get_parent().is_in_group("Asteroids")):
		pass # Replace with function body.

func _on_Area2D_area_exited(area):
	if(area.get_parent().is_in_group("Asteroids")):
		pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if(body.is_in_group("Player")):
		if body.team_no != team_no :
			shoot += 1

func _on_Area2D_body_exited(body):
	if(body.is_in_group("Player")):
		if body.team_no != team_no :
			shoot -= 1
