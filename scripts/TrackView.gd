extends Tree

var _root:TreeItem

func _clear_table():
	self.clear()
	_ready()

func _ready():
	self.set_column_titles_visible(true)
	var titles = ["Id", "Title", "Artist", "Length", "Rivals"]
	for i in range(len(titles)):
		self.set_column_title(i, titles[i])
	var sizes = [[0,50], [3,100], [4,50]]
	for size in sizes:
		self.set_column_min_width(size[0], size[1])
		self.set_column_expand(size[0], false)
	_root = self.create_item()
	self.set_hide_root(true)

func get_active_track():
	var index:int = 0
	var track:TreeItem = _root.get_children()
	while track != null:
		if track == self.get_selected(): break
		index += 1
		track = track.get_next()
	return [index, self.get_selected().get_range(3), self.get_selected().is_checked(4)]

func set_tracks(tracks:Array):
	_clear_table()
	for track in tracks:
		var t:TreeItem = self.create_item(_root)
		for i in range(5):
			if i == 3: continue
			t.set_text_align(i, TreeItem.ALIGN_CENTER)
		t.set_text(0, str(track.id))
		t.set_text(1, track.title)
		t.set_text(2, track.artist)
		t.set_text(3, str(track.play_length))
		match track.type:
			Showblock.Track.Type.SONG:
				t.set_cell_mode(4, TreeItem.CELL_MODE_CHECK)
				t.set_editable(4, true)
				t.set_checked(4, track.is_rivals)
			Showblock.Track.Type.RESULT:
				t.set_cell_mode(3, TreeItem.CELL_MODE_RANGE)
				t.set_range_config(3, 16000, 40000, 1000, false)
				t.set_range(3, track.play_length)
				t.set_editable(3, true)
			Showblock.Track.Type.PREVIEW:
				t.set_cell_mode(3, TreeItem.CELL_MODE_RANGE)
				t.set_range_config(3, 8000, 40000, 1000, false)
				t.set_range(3, track.play_length)
				t.set_editable(3, true)
