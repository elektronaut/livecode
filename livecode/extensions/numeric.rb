module Livecode
	module Extensions
		module Numeric

			def chance?
				( rand() < self ) ? true : false
			end
			alias :c? :chance?

		end
	end
end