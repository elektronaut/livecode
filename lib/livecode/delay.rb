module Livecode

	# Delay lets you schedule a block for later.
	#
	# Examples:
	#
	#  Delay(1000){puts "One second later"}
	#  later = proc{puts "I am a proc"}
	#  Delay(500, later)

	class Delay
		attr_accessor :time, :proc

		# Time is specified in milliseconds
		def initialize(time, proc=nil, &block)
			@time = time || 1
			if proc
				@proc = proc
			elsif block_given?
				@proc = block
			end
			if @proc
				@thread = Thread.new do
					sleep @time.to_f / 1000
				end
			end
		end
	end
end