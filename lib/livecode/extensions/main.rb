module Livecode
	module Extensions
		module Main
			# Sleep for a certain amount of milliseconds
			def wait(time)
				sleep(time / 1000.0)
			end
			
			def live_require(file)
				Livecode.loader.load_file(file)
			end
 
			def reload!
				Livecode.loader.reload!
			end
		end
	end
end