module Livecode
	
	# = Clock
	#
	# Clock is quite literally the beating pulse of Livecode,
	# providing you with a way to sync up blocks of code.
	#
	# == Creating a clock
	#
	# Clock.new takes two options; :tempo and :resolution.
	# Tempo should be self-explanatory, and is measured in beats
	# per minute (BPM). The default is 120 BPM.
	# Resolution is the number of ticks per beat. The default 
	# is 4, which is the equivalent of 16th notes.
	#
	#  clock = Clock.new(:tempo => 120, :resolution => 4)
	#
	# == Control
	#
	#  clock.start    # Starts the clock
	#  clock.stop     # Stops the clock, resets the tick
	#  clock.pause    # Pauses the clock, does not reset the tick
	#  clock.restart  # Restarts the clock
	#  clock.running? # Check if the clock is running
	#
	# If you lose track of your variables, you can use 
	# <tt>Clock.stop_all</tt> to stop all clocks.
	#
	# == Ticks
	#
	# The clock is based on ticks, which is simply an incrementing counter.
	# <tt>clock.tick</tt> will return the current tick, while 
	# <tt>clock.tick_length</tt> will return the length of one tick expressed
	# in seconds.
	#
	# The modulo operator is quite handy for turning ticks into rythmical 
	# structures:
	#
	#  bassdrum.play if clock.tick % 4 == 0 # Plays the bass drum on every beat
	#  snare.play if clock.tick % 8 == 4 # ..and the snare on every other beat
	#
	# == Recipients
	#
	# A recipient is a callback that will be triggered on every tick. Each 
	# recipient must have a unique name, and there's a few ways to attach them.
	# The following examples all do the same:
	#
	#   clock.recipients.add(:hihat, proc{|c| hihat.play})
	#   clock.recipients[:hihat] = proc{|c| hihat.play})
	#   clock.recipients.hihat = proc{|c| hihat.play}
	#   clock.recipients.hihat{|c| hihat.play}
	#   clock[:hihat] = proc{|c| hihat.play}
	#   clock.hihat = proc{|c| hihat.play}
	#   clock.hihat{|c| hihat.play}
	#
	# To remove a recipient, simply unset it:
	#
	#  clock.hihat = false
	#
	# Furthermore, recipients can be muted, temporarily disabling them:
	#
	#  clock.mute(:bassdrum, :snare)  # Mutes the bass drum and snare
	#  clock.solo(:synth, :bass)      # Solos the synth and bass
	#  clock.enable_all               # Re-enables all recipients
	#
	# Remember: The callbacks are executed sequentially. If your callback takes
	# more than a split second, you should wrap the code in it's own thread to
	# allow for parallel processing.

	class Clock
		class << self
			# Register a new clock.
			def register(clock)
				clocks << clock
			end
			
			# Return all registered clocks.
			def clocks
				@@clocks ||= []
			end
			
			# Stop all clocks.
			def stop_all
				clocks.each{|clock| clock.stop}
			end
		end

		attr_accessor :tempo, :resolution
		attr_reader   :tick
		
		def initialize(options={})
			@tempo      = options[:tempo]      || 120
			@resolution = options[:resolution] || 4
			@tick       = -1
			@thread     = nil
			@running    = false
			@recipients = ClockRecipients.new
			Clock.register(self)
		end
		
		public

			# Clock recipients
			def recipients; @recipients; end
			alias :r :recipients

			# Length of a single tick (in seconds).
			def tick_length
				tl = (1/(@tempo.to_f/60))/@resolution
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
			
			# Run next tick.
			def tick!
				@tick += 1
				recipients.each do |r|; unless r.silenced?
					if r.kind_of?(Proc)
						r.call(self)
					elsif r.respond_to?(:tick)
						r.tick(self)
					end
				end; end
			end
			
			def method_missing(method_name, *args, &block)
				self.recipients.send(method_name, *args, &block)
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