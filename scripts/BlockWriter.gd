class_name BlockWriter

const Sqlite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var _file:Sqlite

var t_idx:int
var s_idx:int

func _init():
	_file = Sqlite.new()
	_file.verbosity_level = 0
	t_idx = 1
	s_idx = 1

func _calculate_timestamps(sb:Showblock):
	var ts:int = 0
	for e in sb.elements:
		match e.type:
			Showblock.Element.Type.SONG:
				e.tracks[0].start_ts = ts
				ts += e.tracks[0].play_length
				e.tracks[1].start_ts = ts
				ts += e.tracks[1].play_length
				e.style.start_ts = e.tracks[1].start_ts
				e.style.play_length = e.tracks[1].play_length
			Showblock.Element.Type.ADVERT:
				e.tracks[0].start_ts = ts
				ts += e.tracks[0].play_length
				if e.style != null:
					e.style.start_ts = e.tracks[0].start_ts
					e.style.play_length = e.tracks[0].play_length
			Showblock.Element.Type.PREVIEW:
				e.style.start_ts = ts
				e.style.play_length = e.get_total_length()
				ts += 5000
				for t in e.tracks:
					t.start_ts = ts
					ts += t.play_length
	return sb

func _insert_track(ch:int, t:Showblock.Track):
	var t_ins = "INSERT INTO ScheduledTrack VALUES ({idx}, {channel}, {id}, {start_ts}, {play_length}, {play_offset}, {lead_in}, {lead_out}, {is_playable}, {checksumlow}, {checksumhigh}, {is_rivals})"
	var offset:int = 0
	if t.type == Showblock.Track.Type.RESULT or t.type == Showblock.Track.Type.PREVIEW: offset = t.play_offset
	_file.query(t_ins.format({"idx": t_idx, "channel":ch, "id":t.id, "start_ts":t.start_ts, "play_length":t.play_length, "play_offset":offset, "lead_in":t.lead_in, "lead_out":t.lead_out, "is_playable":1 if t.is_playable else 0, "checksumlow":-1, "checksumhigh":1, "is_rivals":1 if t.is_rivals else 0}))
	t_idx += 1

func _insert_style(ch:int, s:Showblock.Style):
	var s_ins = "INSERT INTO ScheduledUIItem VALUES ({idx}, {channel}, {id}, {start_ts}, {play_length}, {checksumlow}, {checksumhigh}, NULL)"
	_file.query(s_ins.format({"idx":s_idx, "channel":ch, "id":s.id, "start_ts":s.start_ts, "play_length":s.play_length, "checksumlow":-1, "checksumhigh":1}))
	s_idx += 1

func write_to_file(_path:String, sb:Showblock):
	_file.path = _path
	sb = _calculate_timestamps(sb)
	_file.open_db()
	_file.query("DROP TABLE IF EXISTS ScheduledTrack")
	_file.query("DROP TABLE IF EXISTS ScheduledUIItem")
	_file.query('CREATE TABLE "ScheduledTrack" ("Id" INTEGER NOT NULL, "ChannelId" INTEGER NOT NULL, "TrackId" INTEGER NOT NULL, "StartTimeStamp" INTEGER NOT NULL, "PlayLength" INTEGER NOT NULL,"PlayOffset" INTEGER NOT NULL,"LeadIn" INTEGER NOT NULL,"LeadOut" INTEGER NOT NULL,"IsPlayable" BOOL NOT NULL,"ChecksumLow" INTEGER NOT NULL,"ChecksumHigh" INTEGER NOT NULL,"IsRivalsMarker" BOOL NOT NULL,PRIMARY KEY("Id"))')
	_file.query('CREATE TABLE "ScheduledUIItem" ("Id" INTEGER NOT NULL,"ChannelId" INTEGER NOT NULL,"UIItemId" INTEGER NOT NULL,"StartTimeStamp" INTEGER NOT NULL,"PlayLength" INTEGER NOT NULL,"ChecksumLow" INTEGER NOT NULL,"ChecksumHigh" INTEGER NOT NULL,"Scope" TEXT,PRIMARY KEY("Id"))')
	for e in sb.elements:
		if e.style != null: _insert_style(sb.channel, e.style)
		for t in e.tracks:
			_insert_track(sb.channel, t)
	_file.close_db()
