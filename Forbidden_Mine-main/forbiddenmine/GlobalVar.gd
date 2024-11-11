extends Node
var new_world
@warning_ignore("shadowed_global_identifier")
@onready var inventory_slot_scene = preload("res://inventory_slot.tscn")

var load = 0
var action_distance = 4
var characterlocation
var charposition


var inventory = []
signal inventory_updated

var player_node: Node = null

func _ready():
	inventory.resize(36)

func add_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item["type"] and inventory[i]["effect"] == item["effect"]:
			inventory[i]["quantity"] += item["quantity"] 
			inventory_updated.emit()
			print("Item Added!", inventory)
			return true
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			return true
		return false
	
func remove_item(item_type, item_effect):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item_type["type"] and inventory[i]["effect"] == item_effect["effect"]:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false
		
			
func increase_inventory_size(extra_slots):
	inventory.resize(inventory.size() + extra_slots)
	inventory_updated.emit()
	
func set_player_references(player):
	player_node = player
	
func adjust_drop_position(position):
	var radius = 100
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position
	
func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_position(drop_position)
	item_instance.global_position = drop_position
	get_tree().current_scene.add_child(item_instance)
