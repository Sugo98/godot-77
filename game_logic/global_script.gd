class_name Global extends Node

enum CharacterClass {Any,Fighter,Wizard,Ranger,MasterMind}

const basic_dice_faces = [
	"res://resources/dice_faces/sword1.tres",
	"res://resources/dice_faces/shield1.tres",
	"res://resources/dice_faces/food1.tres",
	"res://resources/dice_faces/wood1.tres",
	"res://resources/dice_faces/wheel1.tres",
]

const sixth_face = {
	CharacterClass.Fighter : "res://resources/dice_faces/sword_shield1.tres",
	CharacterClass.Wizard : "res://resources/dice_faces/fireball1.tres",
	CharacterClass.Ranger : "res://resources/dice_faces/food_wood1.tres",
	CharacterClass.MasterMind : "res://resources/dice_faces/gear1.tres"
}

const caravan_repair_cost : int = 3
const caravan_discount_repair_cost : int = 2
const bridge_repair_cost : int = 2
const bridge_discount_repair_cost : int = 1

const food_consumption : int = 2

const fast_animation_time : float = 0.25
const medium_animation_time : float = 0.5
const slow_animation_time : float = 1

const luigi_green_dark := Color("102927")
const luigi_green_light := Color("4fcdc4")
const luigi_red_dark := Color("331515")
const luigi_red_light := Color("ff6b6b")
const luigi_brown_drak := Color("231b19")
