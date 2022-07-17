class_name SongCache

const Sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var _database:Sqlite

func _init(_path="song_cache.db"):
	_database = Sqlite.new()
	_database.verbosity_level = 0
	_database.path = _path

func has_markup(id:int):
	_database.open_db()
	_database.query("SELECT * FROM Track WHERE Id == {x}".format({"x":id}))
	_database.close_db()
	return _database.query_result[0]["HasMarkup"] == 1

func get_track_ref(id:int):
	_database.open_db()
	_database.query("SELECT * FROM Track WHERE Id == {x}".format({"x":id}))
	_database.close_db()
	return _database.query_result[0]

func get_style_ref(id=null, title=null):
	_database.open_db()
	if id != null: _database.query("SELECT * FROM UIItem WHERE Id == {x}".format({"x":id}))
	if title != null: _database.query("SELECT * FROM UIItem WHERE Title == {x}".format({"x":title}))
	_database.close_db()
	return _database.query_result[0]

func get_all_styles():
	_database.open_db()
	_database.query("SELECT * FROM UIItem")
	return _database.query_result

func get_style_from_title(title:String):
	_database.open_db()
	_database.query("SELECT * FROM UIItem WHERE Title == '{x}'".format({"x":title}))
	_database.close_db()
	return _database.query_result[0]

func get_songs(filter=""):
	_database.open_db()
	_database.query("SELECT * FROM Track WHERE HasMarkup == 1 AND Title LIKE '{x}%'".format({"x":filter}))
	_database.close_db()
	return _database.query_result

func get_adverts(filter=""):
	_database.open_db()
	_database.query("SELECT * FROM Track WHERE Artist == '' AND Title LIKE '{x}%'".format({"x":filter}))
	_database.close_db()
	return _database.query_result
