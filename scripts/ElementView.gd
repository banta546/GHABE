extends ItemList

var _type_ref:Dictionary

func _ready():
	_type_ref = {
		Showblock.Element.Type.SONG: "( S )",
		Showblock.Element.Type.ADVERT: "( A )",
		Showblock.Element.Type.PREVIEW: "( P )"
	}

func get_active_element():
	for i in range(self.get_item_count()):
		if self.is_selected(i): return i

func set_elements(sb:Showblock):
	self.clear()
	for e in sb.elements:
		self.add_item("{x} - {y}".format({"x":_type_ref[e.type], "y":e.tracks[0].title}))

func add_element(e:Showblock.Element):
	self.add_item("{x} - {y}".format({"x":_type_ref[e.type], "y":e.tracks[0].title}))

func replace_element(e:Showblock.Element, idx:int):
	self.set_item_text(idx, "{x} - {y}".format({"x":_type_ref[e.type], "y":e.tracks[0].title}))
