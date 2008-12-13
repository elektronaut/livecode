module Livecode
	module Extensions
		module Object
			def help
				puts "No help for #{self.class.to_s}"; nil
			end
			alias :doc :help
		end
	end
end