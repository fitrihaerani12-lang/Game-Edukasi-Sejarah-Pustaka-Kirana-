extends TextureRect

func _get_drag_data(_at_position):
	var root = get_tree().current_scene
	if root.has_node("GuideKirana/Popup"):
		var popup = root.get_node("GuideKirana/Popup")
		if popup.visible:
			return null
			
	if root.has_method("_card_dragged"):
		var data = root._card_dragged(self)
		
		var preview = TextureRect.new()
		preview.texture = texture
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.size = Vector2(120, 160)
		preview.modulate.a = 0.7
		set_drag_preview(preview)
		
		return data
	return null
