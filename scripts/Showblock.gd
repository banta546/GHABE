class_name Showblock

class Element:
	enum Type {SONG, ADVERT, PREVIEW}
	
	var type:int
	var tracks:Array
	var style:Style
	
	func get_total_length():
		var value:int = 0
		for track in self.tracks:
			value += track.play_length
		return value+5000 if self.type == Type.PREVIEW else value

class Track:
	enum Type {SONG, RESULT, ADVERT, STYLEADVERT, PREVIEW}
	
	var type:int
	var id:int
	var start_ts:int
	var play_length:int
	var play_offset:int
	var lead_in:int
	var lead_out:int
	var is_playable:bool
	var is_rivals:bool
	var title:String
	var artist:String
	
	func _init(_type):
		self.type = _type
	
	func load_from_block(source):
		self.id = source["TrackId"]
		self.start_ts = source["StartTimeStamp"]
		self.play_length = source["PlayLength"]
		self.play_offset = source["PlayOffset"]
		self.lead_in = source["LeadIn"]
		self.lead_out = source["LeadOut"]
		self.is_playable = source["IsPlayable"]
		self.is_rivals = source["IsRivalsMarker"]
		self.title = SongCache.new("song_cache.db").get_track_ref(self.id)["Title"]
		self.artist = SongCache.new("song_cache.db").get_track_ref(self.id)["Artist"]
	
	func load_from_cache(source):
		self.id = source["Id"]
		self.start_ts = 0
		self.lead_in = source["LeadInTime"]
		self.lead_out = source["LeadOutTime"]
		self.is_rivals = false
		self.title = source["Title"]
		self.artist = source["Artist"]
		match self.type:
			Type.RESULT:
				self.play_length = 32000
				self.play_offset = source["PreviewStartTime"]
				self.is_playable = false
			Type.PREVIEW:
				self.play_length = 8000
				self.play_offset = source["PreviewStartTime"]
				self.is_playable = false
			Type.SONG:
				self.play_length = source["Length"] + self.lead_in + self.lead_out
				self.play_offset = 0
				self.is_playable = true
			_:
				self.play_length = source["Length"] + self.lead_in + self.lead_out
				self.play_offset = 0
				self.is_playable = false

class Style:
	var id:int
	var start_ts:int
	var play_length:int
	var title:String
	
	func load_from_block(source):
		self.id = source["UIItemId"]
		self.start_ts = source["StartTimeStamp"]
		self.play_length = source["PlayLength"]
		self.title = SongCache.new("song_cache.db").get_style_ref(self.id)["Title"]

	func load_from_cache(source):
		self.id = source["Id"]
		self.start_ts = 0
		self.play_length = 0
		self.title = source["Title"]

var elements:Array
var channel:int

func _init():
	channel = 1

func _get_track_type(playable, markup, style):
	match [playable, markup, style]:
		[true, true, false]: return Track.Type.SONG
		[false, true, true]: return Track.Type.RESULT
		[false, true, false]: return Track.Type.PREVIEW
		[false, false, true]: return Track.Type.STYLEADVERT
		[false, false, false]: return Track.Type.ADVERT

func get_total_length():
	var ts:int = 0
	for element in self.elements:
		if element.type == Element.Type.PREVIEW: ts += 5000
		for track in element.tracks:
			ts += track.play_length
	return ts

func parse_file(_path:String):
	self.elements = []
	var block_cache:BlockCache = BlockCache.new(_path)
	self.channel = block_cache.get_tracks()[0]["ChannelId"]
	for _track in block_cache.get_tracks():
		var t:Track = Track.new(-1)
		t.load_from_block(_track)
		t.type = _get_track_type(t.is_playable, SongCache.new("song_cache.db").has_markup(t.id), block_cache.is_style_at_ts(t.start_ts))
		match t.type:
			Track.Type.SONG:
				var e:Element = Element.new()
				e.type = Element.Type.SONG
				e.tracks = [t]
				self.elements.append(e)
			Track.Type.RESULT:
				self.elements[-1].tracks.append(t)
				var s:Style = Style.new()
				s.load_from_block(block_cache.get_style_at_ts(t.start_ts))
				self.elements[-1].style = s
			Track.Type.ADVERT:
				var e:Element = Element.new()
				e.type = Element.Type.ADVERT
				e.tracks = [t]
				self.elements.append(e)
			Track.Type.STYLEADVERT:
				var e:Element = Element.new()
				e.type = Element.Type.ADVERT
				e.tracks = [t]
				var s:Style = Style.new()
				s.load_from_block(block_cache.get_style_at_ts(t.start_ts))
				e.style = s
				self.elements.append(e)
			Track.Type.PREVIEW:
				if self.elements[-1].type == Element.Type.PREVIEW:
					self.elements[-1].tracks.append(t)
				else:
					var e:Element = Element.new()
					e.type = Element.Type.PREVIEW
					e.tracks = [t]
					var s:Style = Style.new()
					s.load_from_block(block_cache.get_style_at_ts(t.start_ts-5000))
					e.style = s
					self.elements.append(e)

func set_new_style(e_idx:int, _ref:String):
	var s:Style = Style.new()
	s.load_from_cache(SongCache.new("song_cache.db").get_style_from_title(_ref))
	self.elements[e_idx].style = s

func edit_track(e_idx:int, t_idx:int, length:int, rivals:bool):
	match self.elements[e_idx].tracks[t_idx].type:
		Track.Type.SONG:
			self.elements[e_idx].tracks[t_idx].is_rivals = rivals
		_:
			self.elements[e_idx].tracks[t_idx].play_length = length

func add_element(_type:int, track_ids:Array, idx:int=-1):
	var e:Element = Element.new()
	var cache:SongCache = SongCache.new()
	e.type = _type
	match _type:
		Element.Type.SONG:
			var t:Track = Track.new(Track.Type.SONG)
			t.load_from_cache(cache.get_track_ref(track_ids[0]))
			if idx != -1:
				t.is_rivals = self.elements[idx].tracks[0].is_rivals
			var r:Track = Track.new(Track.Type.RESULT)
			r.load_from_cache(cache.get_track_ref(track_ids[0]))
			if idx != -1:
				r.play_length = self.elements[idx].tracks[1].play_length
			var s:Style = Style.new()
			s.load_from_cache(cache.get_style_ref(1046))
			e.tracks = [t, r]
			e.style = s
		Element.Type.ADVERT:
			var t:Track = Track.new(Track.Type.ADVERT)
			t.load_from_cache(cache.get_track_ref(track_ids[0]))
			e.tracks = [t]
		Element.Type.PREVIEW:
			for id in track_ids:
				var t:Track = Track.new(Track.Type.PREVIEW)
				t.load_from_cache(cache.get_track_ref(id))
				e.tracks.append(t)
				var s:Style = Style.new()
				s.load_from_cache(cache.get_style_ref(1058))
				e.style = s
	if idx == -1: self.elements.append(e)
	if idx > -1:
		self.elements.insert(idx, e)
		self.elements.remove(idx+1)
