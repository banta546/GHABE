extends ConfirmationDialog

var _track_view:Tree
var _track_list:ItemList
var _root:TreeItem

var active_index:int
var replace:bool

var track_ids:Array

func _ready():
	_track_view = $MainMargin/Main/TrackView
	_track_list = $MainMargin/Main/TrackList
	replace = false
	_track_view.set_column_titles_visible(true)
	var titles = ["Id", "Title", "Artist", "Intensity", "Length"]
	for i in range(len(titles)):
		_track_view.set_column_title(i, titles[i])
	_root = _track_view.create_item()
	_track_view.set_hide_root(true)
	titles = [[0,50], [3,25], [4,60]]
	for item in titles:
		_track_view.set_column_min_width(item[0], item[1])
		_track_view.set_column_expand(item[0], false)

func _set_active_index(idx:int):
	active_index = idx

func _add_track_to_list():
	if _track_view.get_selected() != null:
		track_ids.append(int(_track_view.get_selected().get_text(0)))
		_track_list.add_item(_track_view.get_selected().get_text(1) + " - " + _track_view.get_selected().get_text(2))

func _remove_track_from_list():
	if _track_list.get_item_count() < 1: return
	if _track_list.is_selected(active_index):
		_track_list.remove_item(active_index)
		track_ids.remove(active_index)

func _move_track_up():
	if _track_list.get_item_count() < 2 or active_index == 0: return
	if _track_list.is_selected(active_index):
		_track_list.move_item(active_index, active_index-1)
		active_index -= 1
		var hold:int = track_ids[active_index]
		track_ids.insert(active_index, track_ids[active_index+1])
		track_ids.remove(active_index+1)
		track_ids.insert(active_index+1, hold)
		track_ids.remove(active_index+2)
		_track_list.select(active_index)

func _move_track_down():
	if _track_list.get_item_count() < 2 or active_index == _track_list.get_item_count()-1: return
	if _track_list.is_selected(active_index):
		_track_list.move_item(active_index, active_index+1)
		active_index += 1
		var hold:int = track_ids[active_index]
		track_ids.insert(active_index, track_ids[active_index-1])
		track_ids.remove(active_index)
		track_ids.insert(active_index-1, hold)
		track_ids.remove(active_index+1)
		_track_list.select(active_index)
		_track_list.select(active_index)

func clear_all():
	$MainMargin/Main/Filter.text = ""
	track_ids = []
	_track_list.clear()

func import_tracks_from_element(tracks:Array):
	for track in tracks:
		track_ids.append(track.id)
		_track_list.add_item(track.title + " - " + track.artist)

func show_songs(filter:String=""):
	_track_view.clear()
	for song in SongCache.new("song_cache.db").get_songs(filter):
		var track:TreeItem = _track_view.create_item(_root)
		track.set_text(0, str(song["Id"]))
		track.set_text(1, song["Title"])
		track.set_text(2, song["Artist"])
		track.set_text(3, str(song["Intensity"]))
		track.set_text(4, str(song["Length"] + song["LeadInTime"] + song["LeadOutTime"]))
