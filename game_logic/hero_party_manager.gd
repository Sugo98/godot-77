class_name HeroesManager extends Node

@export var max_health : int
@export var max_food : int
@export var max_wood : int
@export var heroes_ui: HeroesUI
@export var heroes_container : Node
@export var repair_cost : int
@export var repair_discounted_cost : int

var heroes: Array[Dice]
var health : int
var food : int
var wood : int
var shield : int
var spikes : int
var xp : int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maximize_variables()
	parse_heroes()
	#prepare_for_level()

func maximize_variables():
	health = max_health
	food = max_food
	update_all_labels()

func parse_heroes():
	for hero in heroes_container.get_children():
		heroes.append(hero as Dice)

func prepare_for_level():
	for hero in heroes:
		hero.prepare_for_level()

func prepare_for_merchant():
	for hero in heroes:
		hero.prepare_for_merchant()

func after_shopping(balance : int):
	xp -= balance
	update_all_labels()
	for hero in heroes:
		hero.save_new_dice()

func update_all_labels():
	heroes_ui.update_food(food)
	heroes_ui.update_health(health)
	heroes_ui.update_wood(wood)
	heroes_ui.update_xp(xp)

func eat(x : int):
	food -= x
	if food < 0 :
		print("game over")
	update_all_labels()

func increase_food(x):
	food = clamp(food+x, 0, max_food)
	update_all_labels()

func increase_wood(x):
	wood = clamp(wood+x, 0, max_wood)
	update_all_labels()

func reset_turn():
	for hero in heroes:
		hero.roll_dice()
	shield = 0
	spikes = 0

func suffer_damage(x):
	if x<= 0:
		return
	while( shield and x):
		shield -= 1
		x -= 1
	health -= x
	update_all_labels()

func increase_shield(x):
	shield += x

func increase_spikes(x):
	spikes += x

func gain_xp(x):
	xp += x
	update_all_labels()

func repair(x, discount:bool, pos):
	var c = repair_discounted_cost if discount else repair_cost 
	if wood < c:
		Utils.create_text_feedback("Not Enough Wood", pos)
		return
	wood -= c
	health += x
	update_all_labels()
	Utils.create_text_feedback("-" + str(c) +" Wood", pos)
	await get_tree().create_timer(0.3).timeout
	Utils.create_text_feedback("+" + str(x) +" HP", pos)
