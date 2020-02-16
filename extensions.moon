exts=
	-- generic filetypes
	txt: "Text file"
	bin: "Binary file"
	'bak/old': "Backup file"
	'dat/pack': "Data file"
	db: "Database file"
	lock: "Lock file"
	tmp: "Temp file"

	-- config filetypes
	'cfg/conf/config': "Config file"
	ini: "INI config file"
	toml: "TOML config file"
	properties: "Properties config file"
	cron: "Crontab file"
	ovpn: "OpenVPN config file"

	-- images
	'jpg/jpeg': "JPEG image"
	png: "PNG image"
	gif: "GIF image"
	bmp: "BMP image"
	ico: "ICO image"
	cur: "Windows cursor"
	svg: "SVG image"

	-- audio
	'mid/midi': "MIDI audio"
	mp3: "MP3 audio"
	ogg: "Vorbis audio"
	opus: "Opus audio"
	wav: "WAV audio"

	-- video
	mkv: "Matrosha video"
	avi: "AVI video"
	mp4: "MP4 video"
	webm: "WEBM video"

	-- fonts
	otf: "OTF font"
	ttf: "TTF font"
	woff: "WOFF font"
	woff2: "WOFF2 font"

	-- office
	'doc/docx': "Word document"
	odt: "Open/LibreOffice document"
	'xls/xlsx': "Excel spreadsheet"
	ods: "Open/LibreOffice spreadsheet"
	pdf: "PDF document"
	rtf: "RTF document"

	-- source code
	c: "C source code"
	h: "C header"
	'cc/cpp/c++': "C++ source code"
	'hh/hpp/h++': "C++ header file"
	cs: "C# source code"
	rs: "Rust source code"
	ex: "Elixir source code"
	d: "Dependency file"
	f: "Fortran source code"
	go: "Go source code"
	s: "Assembly source"
	scala: "Scala source code"

	-- compiled code && apps
	o: "Object code"
	a: "Object code archive"
	so: "Shared object"
	exe: "Windows executable"
	dll: "Windows library"
	msi: "Windows installer"
	AppImage: "AppImage program"
	run: "RUN program"
	chm: "Compiled HTML"
	hta: "HTML application"

	-- archives
	tar: "Tar archive"
	tgz: "Gzip-compressed Tar archive"
	zip: "Zip archive"
	'7z': "7-Zip archive"
	rar: "RAR archive"
	asar: "Electron archive"
	deb: "Deb package"
	rpm: "RPM package"
	iso: "ISO image"
	img: "Raw image"
	jar: "JAR archive"
	war: "WAR archive"

	-- compression
	gz: "Gzip-compressed file"
	xz: "XZ-compressed file"
	lzma: "LZMA-compressed file"
	bz2: "BZ2-compressed file"
	lz4: "LZ4-compressed file"

	-- checksums
	md5: "MD5 checksum"
	sha1: "SHA1 checksum"

	-- shortcuts
	lnk: "Windows shortcut"
	desktop: "Desktop shortcut"

	-- shell scripts
	sh: "Shell script"
	fish: "Fish script"
	'bat/cmd': "Windows CMD script"
	ps1: "Powershell script"

	-- scripts
	lua: "Lua script"
	moon: "Moonscript script"
	js: "JavaScript script"
	exs: "Elixir script"
	vim: "VIM script"
	nvim: "NeoVIM script"
	py: "Python script"
	pyc: "Compiled Python script"
	sql: "SQL file"
	ts: "Typescript script"

	-- markup
	xml: "XML markup"
	html: "HTML markup"
	xhtml: "XHTML markup"
	json: "JSON markup"
	'yml/yaml': "YAML markup"
	rockspec: "Luarocks rockspec"
	md: "Markdown markup"
	css: "CSS styles"
	less: "LESS styles"
	'scss/sass': "SASS styles"

	-- dynamic webpages
	php: "PHP code"
	aspx: "ASPX code"
	jsp: "JSP code"
	ejs: "EJS template"
	etlua: "Etlua template"

	-- misc
	gpg: "GPG pubkey"
	pem: "PEM key"
	pub: "Public key"
	'sqlite/sqlite3': "SQLite database"

lookup=do
	tab={}
	for k, v in pairs exts
		for e in k\gmatch '([^/]+)'
			tab[e]=v
	setmetatable tab, {
		__index: (k) => "#{k\upper!} file"
	}
	tab

return lookup
