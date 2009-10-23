module Livecode
	module Extensions
		module Main
			def live_require(file)
				Livecode.loader.load_file(file)
			end
 
			def reload!
				Livecode.loader.reload!
			end
		end
	end
end