require ENV['TM_SUPPORT_PATH'] + '/lib/escape.rb'

def find_dir( options )
	options = {
		:include_root => false
	}.merge( options )

	files = []
	files << ENV['TM_PROJECT_DIRECTORY'] if options[:include_root]
	files << ENV['TM_SELECTED_FILE']
	files << ENV['TM_FILEPATH']
	files << ENV['TM_DIRECTORY']
	
	res = files.find { |file| file && File.exists?(file) }
	res && File.file?(res) ? File.split(res).first : res
end


def is_running( process )
  all = `ps -U "$USER" -o ucomm`
  all.to_a[1..-1].find { |cmd| process == cmd.strip }
end

def terminal_script( command )
  return <<-APPLESCRIPT
    tell application "Terminal"
      activate
      do script "#{command}"
    end tell
	tell application "TextMate"
	  activate
	end tell
APPLESCRIPT
end

def iterm_script(dir)
  return <<-APPLESCRIPT
    tell application "iTerm"
      activate
      if exists the first terminal then
        set myterm to the first terminal
      else
        set myterm to (make new terminal)
      end if
      tell myterm
        activate current session
        launch session "Default Session"
        tell the last session
          write text "#{command}"
        end tell
      end tell
    end tell
	tell application "TextMate"
	  activate
	end tell
APPLESCRIPT
end

def run( options={} )
	
	command_string = ""
	if options[:dir]
		command_string += "cd #{e_as(e_sh(options[:dir]))}; clear; pwd; "
	end
	if options[:command]
		command_string += options[:command].to_s
	end
	
	puts command_string
	
	script = nil
	if ENV['TM_TERMINAL'] =~ /^iterm$/i || is_running('iTerm')
		script = iterm_script( command_string )
	else
		script = terminal_script( command_string )
	end
	open("|osascript", "w") { |io| io << script }
	
end

