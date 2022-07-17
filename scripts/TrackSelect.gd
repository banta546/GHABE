extends ConfirmationDialog

var type_select:int
var replace:bool
var _table:Tree
var _root:TreeItem

func _ready():
	type_select = Showblock.Element.Type.SONG
	replace = false
	_table = $MainMargin/Main/TrackView
	_table.set_column_titles_visible(true)
	var titles = ["Id", "Title", "Artist", "Intensity", "Length"]
	for i in range(len(titles)):
		_table.set_column_title(i, titles[i])
	_root = _table.create_item()
	_table.set_hide_root(true)
	titles = [[0,50], [3,25], [4,60]]
	for item in titles:
		_table.set_column_min_width(item[0], item[1])
		_table.set_column_expand(item[0], false)

func clear_filter():
	$MainMargin/Main/LineEdit.text = ""

func show_songs(filter:String="", id:int=0):
	_table.clear()
	for song in SongCache.new("song_cache.db").get_songs(filter) if type_select != Showblock.Element.Type.ADVERT else SongCache.new("song_cache.db").get_adverts(filter):
		var track:TreeItem = _table.create_item(_root)
		track.set_text(0, str(song["Id"]))
		track.set_text(1, song["Title"])
		track.set_text(2, song["Artist"])
		track.set_text(3, str(song["Intensity"]))
		track.set_text(4, str(song["Length"] + song["LeadInTime"] + song["LeadOutTime"]))
		if id != 0 and song["Id"] == id:
			replace = true
			track.select(0)
			_table.scroll_to_item(track)

func get_selected_tracks():
	if _table.get_selected() != null: return [int(_table.get_selected().get_text(0))]
