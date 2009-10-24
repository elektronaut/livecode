module Livecode

	# = Silenceable
	#
	# Silenceable allows you to mute procs passed to Clock and Timer.
	
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
		def silenced
			@silenced ||= false
		end
		def silenced?
			silenced ? true : false; 
		end
		def mute
			@silenced = true
		end
		def unmute
			@silenced = false
		end
	end
end