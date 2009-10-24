module Livecode

	# Silenceable lets you mute procs and blocks when used by Timer and Clock.
	module Silenceable
		class << self
			def apply(obj)
				unless obj.respond_to?(:silenced?)
					class << obj
						include Silenceable
					end
				end
				return obj
			end
		end
		attr_accessor :silenced
		@silenced = false
		def silenced?; @silenced ? true : false; end
	end
end