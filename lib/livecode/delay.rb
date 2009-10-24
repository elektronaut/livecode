module Livecode

	# = Delay
	#
	# Delay lets you schedule a block for later.
	#
	#  Delay.new(1000){puts "One second later"}
	#  later = proc{puts "I am a proc"}
	#  Delay.new(500, later)

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
			Silenceable.apply(@proc) if @proc
			if @proc && !@proc.silenced?
				@thread = Thread.new do
					wait @time.to_f
					@proc.call
				end
			end
		end
	end
end