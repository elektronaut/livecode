module Livecode

	# = Timer
	#
	# Timer lets you loop a block at a certain interval.
	#
	#  timer = Timer.new(100) {puts "I'm executed every 100ms!"}
	#  timer.stop       # Stops the execution
	#  timer.start      # Starts the timer again
	#  timer.time = 200 # Reschedules the timer
    #
	# Proc objects are also supported:
	#
	#  timer_proc = proc{puts "I'm a proc"}
	#  timer2 = Timer.new(100, timer_proc)
	#
	# Timer will try to compensate for the run time of your code in order to stay in sync.
	# If you lose track of your variables, you can use <tt>Timer.stop_all</tt> to stop
	# all timers.

	class Timer
		
		class << self
			# Register a new timer
			def register(timer)
				timers << timer
			end

			# Returns all timers.
			def timers
				@@timers ||= []
			end
			
			# Stop all timers.
			def stop_all
				timers.each{|timer| timer.stop}
			end
		end
		
		attr_accessor :time, :proc

		def initialize(time, proc=nil, &block)
			@time = time || 1
			if proc
				@proc = proc
			elsif block_given?
				@proc = block
			end
			@tread = nil
			Timer.register(self)
			start
		end
		
		# Call the block
		def call
			Silenceable.apply(@proc) if @proc
			if @proc && !@proc.silenced?
				@proc.call
			end
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