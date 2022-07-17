extends VBoxContainer

var ghabe:Panel

var load_file:FileDialog
var track_select:ConfirmationDialog
var block_length:Range
var block_cap:OptionButton
var style_select:OptionButton
var channel_select:OptionButton

var element_view:ItemList
var track_view:Tree

var sb:Showblock

func _ready():
	ghabe = get_node("../..")
	load_file = get_node("../../LoadFile")
	block_length = $BlockLength
	style_select = $StyleSelect
	channel_select = $ElementContainer/Buttons/ChannelSelect
	block_cap = $ElementContainer/Buttons/BlockLengthSelect
	element_view = $ElementContainer/ElementView
	track_view = $TrackView
	
	sb = Showblock.new()

func _update_track_view(e_index:int):
	track_view.set_tracks(sb.elements[e_index].tracks)
	style_select.set_style_from_element(sb.elements[e_index])

func _edit_track():
	var t:Array = track_view.get_active_track()
	sb.edit_track(element_view.get_active_element(), t[0], t[1], t[2])
	block_length.set_current_length(sb.get_total_length())

func _set_style(idx:int):
	if idx != 0: sb.set_new_style(element_view.get_active_element(), style_select.get_title_from_index(idx))
	if idx == 0: sb.elements[element_view.get_active_element()].style = null

func move_element_in_block(dir:int):
	if sb.elements.size() > 1 and element_view.get_active_element() != null:
		var idx:int = element_view.get_active_element()
		var hold:Showblock.Element = sb.elements[idx]
		if dir == 1 and idx != element_view.get_item_count()-1:
			sb.elements.remove(idx)
			sb.elements.insert(idx+1, hold)
			element_view.move_item(idx, idx+1)
		if dir == -1 and element_view.get_active_element() != 0:
			sb.elements.remove(idx)
			sb.elements.insert(idx-1, hold)
			element_view.move_item(idx, idx-1)

func remove_element_from_block():
	if element_view.get_active_element() != null:
		sb.elements.remove(element_view.get_active_element())
		element_view.remove_item(element_view.get_active_element())
		track_view.clear()
		block_length.set_current_length(sb.get_total_length())
		style_select.select_none()

func add_element_to_block(type:int, tracks:Array, idx:int=-1):
	if idx == -1:
		sb.add_element(type, tracks)
		element_view.add_element(sb.elements[-1])
	if idx >= 0:
		sb.add_element(type, tracks, idx)
		element_view.replace_element(sb.elements[idx], idx)
		track_view.set_tracks(sb.elements[idx].tracks)
	block_length.set_current_length(sb.get_total_length())

func change_block_size(idx:int):
	var sizes = {0:1800000, 1:3600000}
	block_length.set_max_length(sizes[idx])
	block_length.set_current_length(sb.get_total_length())

func change_channel(idx:int):
	sb.channel = idx+1

func load_block_from_file(path:String):
	sb.parse_file(path)
	style_select.select_none()
	element_view.set_elements(sb)
	track_view.clear()
	block_cap.select(0 if sb.get_total_length() < 1800000 else 1)
	change_block_size(0 if sb.get_total_length() < 1800000 else 1)
	channel_select.select(0 if sb.channel == 1 else 1)

func save_block_to_file(path:String):
	var bw:BlockWriter = BlockWriter.new()
	bw.write_to_file(path, sb)
