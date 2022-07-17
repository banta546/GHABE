extends Panel

#	This node will act as a signal delegate
#	and for dealing with windows/popups

var load_file:FileDialog
var save_file:FileDialog
var track_select:ConfirmationDialog
var preview_select:ConfirmationDialog
var warning:AcceptDialog
var main:VBoxContainer

func _ready():
	load_file = $LoadFile
	save_file = $SaveFile
	track_select = $TrackSelect
	preview_select = $PreviewSelect
	warning = $Warning
	main = $MainMargin/Main
	
	#show_warning("This is a WIP\nReport any bugs to @banta546#6962")

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #

func _show_load_file():
	if main.sb.elements.size() > 0:
		show_warning("Your block isn't empty, loading one will erase it")
	load_file.show()

func _return_load_path(path:String):
	main.load_block_from_file(path)

func _show_save_file():
	if main.sb.elements.size() == 0:
		show_warning("The block is empty. Put some stuff in first")
		return
	save_file.show()

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #

func _show_track_select(type:int):
	track_select.type_select = type
	track_select.replace = false
	track_select.show_songs()
	track_select.clear_filter()
	track_select.show()

func _track_selected():
	if track_select.get_selected_tracks() != null: 
		if track_select.replace == true: main.add_element_to_block(track_select.type_select, track_select.get_selected_tracks(), main.element_view.get_active_element())
		if track_select.replace == false: main.add_element_to_block(track_select.type_select, track_select.get_selected_tracks())

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #

func _edit_element():
	if main.element_view.get_active_element() == null: return
	var type:int = main.sb.elements[main.element_view.get_active_element()].type
	match type:
		Showblock.Element.Type.PREVIEW:
			preview_select.replace = true
			preview_select.show_songs()
			preview_select.clear_all()
			preview_select.import_tracks_from_element(main.sb.elements[main.element_view.get_active_element()].tracks)
			preview_select.show()
		_:
			track_select.type_select = main.sb.elements[main.element_view.get_active_element()].type
			track_select.replace = true
			track_select.show_songs("", main.sb.elements[main.element_view.get_active_element()].tracks[0].id)
			track_select.clear_filter()
			track_select.show()

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #

func _show_preview_select():
	preview_select.replace = false
	preview_select.show_songs()
	preview_select.clear_all()
	preview_select.show()

func _preview_tracks_selected():
	if len(preview_select.track_ids) != 0:
		if preview_select.replace == true: main.add_element_to_block(Showblock.Element.Type.PREVIEW, preview_select.track_ids, main.element_view.get_active_element())
		if preview_select.replace == false: main.add_element_to_block(Showblock.Element.Type.PREVIEW, preview_select.track_ids)
	preview_select.clear_all()

  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #

func show_warning(text:String):
	warning.dialog_text = text
	warning.show()

