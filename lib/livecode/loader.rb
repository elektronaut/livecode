module Livecode
 
	# = Loader
	# 
	# Handles (re)loading of library files, which is mostly useful for development.
	
	class Loader
		attr_accessor :reloadable_files
 
		def initialize
			@reloadable_files = []
			@reloading = false
		end
 
		def add_reloadable(file)
			file = parse_path(file)
			@reloadable_files << file unless @reloadable_files.include?(file)
		end
 
		def load_file(file, force=false)
			file = parse_path(file)
			return false if @reloading && !force && @reloadable_files.include?(file)
			add_reloadable file
			load("#{file}.rb")
		end
 
		def reload!
			puts "Reloading: #{@reloadable_files.inspect}"
			@reloading = true
			old_v = $-v; $-v = nil # Temporarily disable warnings
			results = @reloadable_files.map{ |f| load_file( f, true ) }
			$-v = old_v # Re-enable eventual warnings
			@reloading = false
			return results
		end
 
		def parse_path(path)
			path.gsub(/\.rb$/, '').gsub(/^\.\//, '')
		end
	end
 
	class << self
		attr_accessor :loader
		def loader
			@loader ||= Loader.new
			@loader
		end
	end
end