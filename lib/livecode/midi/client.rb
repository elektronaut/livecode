module Livecode
	module MIDI
		class Client
			attr_reader :name, :source_name, :destination_name, :port_name
			def initialize(name="Livecode", options={})
				@name = name
				@source_name = options[:source_name] || @name
				@destination_name = options[:destination_name] || @name
				@port_name = options[:port_name]   || @name+"Port"
				@tread = nil
				initialize_coremidi_source
				initialize_coremidi_destination
				start
			end
			
			public

				# Stop the client
				def stop
					if @thread
						@thread.exit
						@thread = nil
					end
				end

				def start
					stop
					client = self
					@thread = Thread.new do
						CoreMIDI::Input.register(@name, @port_name, @source_name) do |packet|
							client.receive_packet(packet)
						end
					end
				end
				
				def receive_packet(packet)
					# Do stuff with packet?
				end
				
			protected
			
				def initialize_coremidi_source
					CoreMIDI::Source.register(@name, @source_name)
				end

				def initialize_coremidi_destination
					CoreMIDI::Destination.register(@name, @source_name)
				end
			
		end
	end
end
