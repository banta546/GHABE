extends OptionButton

var _styles:Array

func _ready():
	self.disabled = true
	_styles = SongCache.new("song_cache.db").get_all_styles()
	_styles.push_front({"Id": 0, "Title": "None"})
	for style in _styles:
		self.add_item(style["Title"])

func _get_index_from_title(title:String):
	var idx:int = 0
	for style in _styles:
		if title == style["Title"]: break
		idx += 1
	return idx

func select_none():
	self.select(0)
	self.disabled = true

func get_title_from_index(idx:int):
	return _styles[idx]["Title"]

func set_style_from_element(e:Showblock.Element):
	match e.type:
		Showblock.Element.Type.SONG:
			self.disabled = true
			self.select(_get_index_from_title(e.style.title))
		Showblock.Element.Type.ADVERT:
			self.disabled = false
			if e.style != null:
				self.select(_get_index_from_title(e.style.title))
			else:
				self.select(0)
		Showblock.Element.Type.PREVIEW:
			self.disabled = false
			self.select(_get_index_from_title(e.style.title))
