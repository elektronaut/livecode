module Livecode
	
	module Silenceable
		def self.apply( obj )
			unless obj.respond_to?( :silenced? )
				class << obj
					include Silenceable
				end
			end
			return obj
		end
		attr_accessor :silenced
		@silenced = false
		def silenced?; @silenced ? true : false; end
	end

	class ClockRecipients
		include Enumerable

		def initialize
			@collection = {}
		end
		
		def each
			@collection.each{ |key,r| yield r }
		end
		
		def each_with_index
			@collection.each{ |key,r| yield key, r }
		end
		
		def keys
			@collection.map{|k,o| k}
		end
		
		def has_key?( key )
			( @collection.keys.map{|k| k }.include?( key.to_sym ) ) ? true : false
		end
		
		def set( key, obj, &block )
			obj = block if block_given?
			if obj
				@collection[key.to_sym] = Silenceable.apply( obj )
			elsif has_key?( key )
				@collection.delete( key.to_sym )
			end
		end
		alias :add :set
		alias :attach :set
		
		def get( key )
			return nil unless self.has_key?( key )
			@collection[key.to_sym]
		end
		alias :[] :get
		
		def method_missing( method_sym, *args, &block )
			#method_name = method_sym.to_s
			#if method_name =~ /=$/
			#	self.set( method_name.gsub( /=$/, '' ), *args )
			#elsif block_given?
			#	self.set( method_name, *args, &block )
			#else
			#	return nil unless self.has_key?( method_name )
			#	self.get( method_name )
			#end
		end
		
		def silence( *keys )
			keys.each{ |k| self[k].silenced = true }
		end
		alias :mute :silence
		
		def silence_all
			each_with_index{ |k,o| self[k].silenced = true }
		end
		alias :mute_all :silence_all
		
		def solo( *keys )
			silence_all
			keys.each{ |k| self[k].silenced = false }
		end
		alias :play :solo
		
		def enable_all
			each_with_index{ |k,o| self[k].silenced = false }
		end
		alias :play_all :enable_all
		alias :unsolo   :enable_all
		
	end
	
	class Clock

		attr_accessor :tempo, :subdiv, :debug
		attr_reader   :tick
		
		class << self
			
			def register( clock )
				@@all_clocks ||= []
				@@all_clocks << clock
				puts "New clock registered: #{clock.inspect}"; return nil
			end
			
			def stop_all
				if @@all_clocks
					@@all_clocks.each do |clock|
						clock.stop
					end
				end
				puts "All clocks stopped"; return nil
			end
			
			def count
				@@all_clocks ? @@all_clocks.length : 0
			end
			
		end
		
		def initialize( options={} )
			@tempo  = options[:tempo]  || 120
			@subdiv = options[:subdiv] || 16
			@debug  = options[:debug]  || false
			@tick   = 0
			@recipients = ClockRecipients.new
			@clock_thread = nil
			@running = false
			Clock.register( self )
		end
		
		def recipients; @recipients; end
		alias :r :recipients
		
		def tick_length
			tl = ( ( 1 / ( @tempo.to_f / 60 ) ) * 4 ) / @subdiv
			tl = 0.00000001 if tl <= 0
			tl
		end
		alias :tl :tick_length
		
		def stop_clock_thread
			if @clock_thread
				@clock_thread.exit
				@clock_thread = nil
			end
		end
		
		def start_clock_thread
			@clock_thread ||= Thread.new do
				while @running
					recipients.each do |r|; unless r.silenced?
						puts "Sending tick #{@tick} to #{r.inspect}" if @debug
						if r.kind_of?( Proc )
							r.call( self )
						elsif r.respond_to?( :tick )
							r.tick( self )
						end
					end; end
					sleep( tick_length )
					@tick += 1
				end
			end
		end

		def start
			@running = true
			stop_clock_thread
			start_clock_thread
			return self
		end
		alias :play :start
		
		def stop
			stop_clock_thread
			@tick = 0
			@running = false
			return self
		end

		def pause;   @running = false; self; end
		def restart; @tick = 0; start; end
		
		def running?; @running ? true : false; end
		
		def method_missing( method_name, *args, &block )
			self.recipients.send( method_name, *args, &block )
		end
	end
end