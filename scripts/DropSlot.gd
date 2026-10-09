extends Panel

@export var slot_index: int = 0

func _can_drop_data(at_position, data):
	var root = get_tree().current_scene
	if root.has_method("_can_drop_in_slot"):
		return root._can_drop_in_slot(at_position, data)
	return false

func _drop_data(_at_position, data):
	var root = get_tree().current_scene
	if root.has_method("_drop_in_slot"):
		root._drop_in_slot(slot_index, data)
