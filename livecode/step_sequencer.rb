module Livecode
	
	# String-based step sequencer.
	#
	# Example:
	#   clock = Clock.new( :tempo => 120 )
	#   seq = StepSequencer.new( clock )
	#   clock << Proc.new{ |tick,clock| puts "bap!" if seq['x...x...x...x...'] } # Prints "bap!" on every 1/4 note
	#
	class StepSequencer
		attr_accessor :clock, :steps

		def initialize( clock )
			@clock = clock
		end
		
		def string_step( str )
			str = str.gsub(/[\s]+/,'') # Skip spacing
			char = str[@clock.tick%str.length].chr rescue '.'
			( char =~ /[\._]/ ) ? nil : char
		end

		def step( pattern )
			return string_step( pattern ) if pattern.kind_of?( String )
			
			item = pattern[@clock.tick%pattern.length]
			return nil if item.respond_to?( :empty? ) && item.empty?
			return nil if item.kind_of?( Numeric ) && item == 0
			return item
		end
		alias :[] :step
		alias :at :step
		
	end
end