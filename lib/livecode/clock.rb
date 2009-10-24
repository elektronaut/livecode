module Livecode
	class Clock
		class << self
			# Register a new clock
			def register(clock)
				clocks << clock
			end
			
			# All clocks
			def clocks
				@@clocks ||= []
			end
			
			# Stop all clocks
			def stop_all
				clocks.each{|clock| clock.stop}
			end
		end

		attr_accessor :tempo, :subdiv
		attr_reader   :tick
		
		def initialize(options={})
			@tempo   = options[:tempo]  || 120
			@subdiv  = options[:subdiv] || 16
			@tick    = -1
			@thread  = nil
			@running = false
			#@recipients = ClockRecipients.new
			Clock.register(self)
		end
		
		public

			# Length of a single tick (in seconds).
			def tick_length
				tl = ((1/(@tempo.to_f/60))*4)/@subdiv
				tl = 0.00000001 if tl <= 0
				tl
			end
			alias :tl :tick_length
		
			# Start the clock. Restarts if the clock is already running.
			def start
				@running = true
				stop_thread
				start_thread
				self
			end
			alias :play :start
			
			# Stop the clock.
			def stop
				stop_thread
				@tick = -1
				@running = false
				self
			end
			
			# Pause the clock.
			def pause
				@running = false
				self
			end
			
			# Restart the clock.
			def restart
				@tick = -1
				start
			end
			
			# Returns true if the clock is running.
			def running?
				@running ? true : false
			end
			
			def tick!
				@tick += 1
				# Do stuff
			end
			
		protected
		
			# Stop the clock thread.
			def stop_thread
				if @thread
					@thread.exit
					@thread = nil
				end
			end
			
			# Start the clock thread.
			def start_thread
				clock = self
				@thread ||= Thread.new do
					next_time = Time.now
					while @running
						clock.tick!
						next_time += tick_length
						sleep_time = next_time - Time.now
						sleep(sleep_time) if sleep_time > 0
					end
				end
			end
	end
end