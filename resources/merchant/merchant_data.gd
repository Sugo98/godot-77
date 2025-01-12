class_name MerchantData extends Resource

@export var name: String
@export_multiline var description: String
@export var back_ground_texture: Texture2D

@export_category("Face")
@export var face : Array[FaceData]
@export var face_probability : Array[int]
