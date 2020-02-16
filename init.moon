import command, interact, config, app, signal from howl
import Process from howl.io
import ActionBuffer from howl.ui

-- forward delcaration
local FileManager
extensions=bundle_load 'extensions'

-- config variables
local showtype, typemode, showhidden
showtype_default=false
typemode_default='extension'
showhidden_default=true

config.define
	name: 'files_showtype'
	description: "Whether or not the file manager will display the filetypes"
	scope: 'global'
	type_of: 'boolean'

config.define
	name: 'files_typemode'
	description: "How the file manager will detect the filetype"
	scope: 'global'
	options: {'command', 'extension', 'smart'}

config.define
	name: 'files_showhidden'
	description: "Whether or not the file manager will display hidden files"
	scope: 'global'
	type_of: 'boolean'

config.watch 'files_showtype', (key, val) ->
	showtype=val
	showtype=showtype_default if val==nil
	FileManager.updateall!

config.watch 'files_typemode', (key, val) ->
	typemode=val
	typemode=typemode_default if val==nil
	FileManager.updateall!

config.watch 'files_showhidden', (key, val) ->
	showhidden=val
	showhidden=showhidden_default if val==nil
	FileManager.updateall!

showtype=config.files_showtype
typemode=config.files_typemode
showhidden=config.files_showhidden
showtype=showtype_default if showtype==nil
typemode=typemode_default if typemode==nil
showhidden=showhidden_default if showhidden==nil

-- main code
getinfo= (file) ->
	filetype=''
	if file.is_directory
		filetype="Directory"
	elseif showtype
		if typemode=='extension'
			filetype=extensions[file.extension] if file.extension
		elseif typemode=='command'
			filetype=(Process.execute {'file', '-b', file})\gsub '\n', ''
		elseif typemode=='smart'
			filetype=rawget extensions, file.extension
			filetype=(Process.execute {'file', '-b', file})\gsub '\n', '' unless filetype
	{
		:file
		name: file.display_name
		directory: file.is_directory
		hidden: file.is_hidden
		symlink: file.is_link
		type: filetype
	}

class FileManager

	@dispatch_key= (evt) ->
		if evt.event.alt or evt.event.meta or evt.event.control or evt.event.super
			return
		if evt.source=='editor' and evt.parameters[1] and  evt.parameters[1].buffer and evt.parameters[1].buffer.data.filemanager
			return evt.parameters[1].buffer.data.filemanager\keyevent evt.event
		return false

	@closeall= () ->
		for buf in *app.buffers
			app\close_buffer buf if buf.data.filemanager

	@updateall= () ->
		for buf in *app.buffers
			buf.data.filemanager\update! if buf.data.filemanager

	@keys=
		e:
			info: "edit file"
			action: 'edit'
		o:
			info: "open with..."
			action: 'open'
		d:
			info: "delete file"
			action: 'delete'
		t:
			info: "create file"
			action: 'create'
		m:
			info: "Create directory"
			action: 'mkdir'
		h:
			info: "Show/hide hidden"
			action: 'toggle_hidden'
		return:
			info: "navigate into"
			action: 'navigate'
		escape:
			info: "exit"
			action: 'exit'
		backspace:
			info: "goto parent"
			action: 'navigate_parent'

	new: (@dir) =>
		-- create the buffer and associate it with this object and an editor
		@buffer=ActionBuffer!
		@buffer.data.filemanager=@
		app\add_buffer @buffer, true

		-- initial render
		@reload!

	update: () =>
		line=@cursor.line if @cursor
		@updatefiles!
		@render!
		@updatecurrent!
		@cursor.line=line if line

	reload: () =>
		@updatefiles!
		@render!
		@editor.line_at_top=1
		@cursor.line=@firstline
		@updatecurrent!

	updatefiles: () =>
		-- load all files
		@files=[getinfo file for file in *@dir.children when showhidden or not file.is_hidden]

		-- sort them first by directory, then by name
		table.sort @files, (a, b) ->
			if a.directory and not b.directory
				return true
			if b.directory and not a.directory
				return false
			return a.name<b.name

		-- get the max len of the longest filename
		@maxfilenamelen=0
		for file in *@files
			if #file.name>@maxfilenamelen
				@maxfilenamelen=#file.name

	updatecurrent: () =>
		@current=@files[@cursor.line-@firstline+1]

	render: () =>
		-- load editor/cursor info
		@editor=app\editor_for_buffer @buffer
		@cursor=@editor.cursor

		-- set the editor as writable
		@buffer.read_only=false

		-- display header
		@firstline=3
		@buffer.title="Files: #{@dir}"
		@buffer.text=""
		if parent=@dir.parent
			@buffer\append parent.short_path, 'comment'
			if parent.short_path!='/'
				@buffer\append '/', 'comment'
		@buffer\append @dir.basename, 'label'
		@buffer\append '\n'
		do
			keys=[k for k in pairs @@keys]
			table.sort keys, (a, b) ->
				return #a<#b if #a!=#b
				return a<b
			for k in *keys
				@buffer\append k, 'label'
				@buffer\append ': ', 'comment'
				@buffer\append @@keys[k].info
				@buffer\append '\n'
				@firstline+=1

		-- display files
		for file in *@files
			@buffer\append '\n'
			if file.hidden
				@buffer\append file.name, 'comment'
			elseif file.directory
				@buffer\append file.name, 'keyword'
			else
				@buffer\append file.name, 'emphasis'
			if file.symlink
				@buffer\append '@', 'label'
			@buffer\append string.rep ' ', @maxfilenamelen-#file.name+1
			@buffer\append file.type, 'comment'
		if #@files==0
			@buffer\append '\n'
			@buffer\append '(empty)', 'comment'

		-- validate buffer
		@buffer.read_only=true
		@buffer.modified=false

	keyevent: (evt) =>
		@updatecurrent!
		if key=(@@keys[evt.key_name] or @@keys[evt.character])
			@['action_'..key.action] @ -- call @action_<something> as a method; evil hack
			return signal.abort

	action_edit: () =>
		if @current and not @current.directory
			app\open_file @current.file

	action_navigate: () =>
		if @current.directory and not @current.symlink
			@dir=@current.file
			@reload!

	action_navigate_parent: () =>
		if parent=@dir.parent
			@dir=parent
			@reload!

	action_exit: () =>
		app\close_buffer @buffer

	action_create: () =>
		filename=interact.read_text
			title: "New filename"
		return unless filename
		(@dir/filename)\touch!
		@update!

	action_mkdir: () =>
		filename=interact.read_text
			title: "Directory name"
		return unless filename
		(@dir/filename)\mkdir!
		@update!

	action_delete: () =>
		local confirmation
		if @current.directory
			confirmation=interact.yes_or_no
				title: "Recursively delete directory #{@current.file}"
		else
			confirmation=interact.yes_or_no
				title: "Delete file #{@current.file}"
		if confirmation
			@current.file\rm_r!
			@update!

	action_open: () =>
		if @current
			Process
				cmd: {'xdg-open', @current.file.basename}
				read_stdout: false
				read_stderr: false
				write_stdin: false
				working_directory: @dir

	action_toggle_hidden: () =>
		config.files_showhidden=not config.files_showhidden

-- commands
command.register
	name: 'files'
	description: "opens a file manager"
	input: interact.select_directory
	handler: FileManager

command.register
	name: 'files-closeall'
	description: "closes all file managers"
	handler: FileManager.closeall

command.register
	name: 'files-updatell'
	description: "refreshes all file managers"
	handler: FileManager.updateall

-- signal handlers
signal.connect 'key-press', FileManager.dispatch_key, 1

-- unloading process
unload= ->
	command.unregister 'files'
	command.unregister 'files-closeall'
	command.unregister 'files-updateall'
	signal.disconnect 'key-press', FileManager.dispatch_key
	FileManager.closeall!

-- module definition
{
	info:
		author: "Codinget"
		description: "A file manager for Howl"
		license: 'MIT'
	:unload
}
