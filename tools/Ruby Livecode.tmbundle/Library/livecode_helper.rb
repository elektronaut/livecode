require "#{ENV['TM_BUNDLE_PATH']}/Library/run_in_terminal"

def file_path
	ENV['TM_FILEPATH']
end

def livecode_file
	file_path + ".!livetmp"
end

def write_livecode_file( data, mode="a" )
	File.open( livecode_file, mode ){ |fh| fh.write( data ) }
end

def init_livecode_file!
	write_livecode_file( "$__LIVECODE__ = true # We are now live\n", "w" )
end

def start_session!
	init_livecode_file!
	run :command => "tail -f \"#{livecode_file}\" | irb; exit", :dir => find_dir( :include_root => true )
end

def execute(code)
    write_livecode_file("# == #{Time.now} ==\n" + code + "\n")
end

