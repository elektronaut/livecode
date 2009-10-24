module Livecode

	# Timer lets you loop a block at a certain interval.
	#
	# Examples:
	#
	#  timer = Timer(100) {puts "I'm executed every 100ms!"}
	#  timer.stop       # Stops the execution
	#  timer.start      # Starts the timer again
	#  timer.time = 200 # Reschedules the timer
    #
	#  timer_proc = proc{puts "I'm a proc"}
	#  timer2 = Timer(100, timer_proc)

	class Timer
		attr_accessor :time, :proc

		def initialize(time, proc=nil, &block)
			@time = time || 1
			if proc
				@proc = proc
			elsif block_given?
				@proc = block
			end
			@tread = nil
			start
		end
		
		# Call the block
		def call
			@proc.call if @proc
		end
		
		# Start the timer
		def start
			stop
			timer = self
			@thread = Thread.new do
				next_time = Time.now
				while true
					timer.call
					next_time += (timer.time.to_f / 1000)
					sleep_time = next_time - Time.now
					sleep(sleep_time) if sleep_time > 0
				end
			end
		end
		alias :run :start

		# Stop the timer.
		def stop
			if @thread
				@thread.exit
				@thread = nil
			end
		end
		alias :clear :stop
		alias :end :stop
		
	end
end