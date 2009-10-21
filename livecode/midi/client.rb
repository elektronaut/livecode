require 'dl/import'

module Livecode
	module MIDI
		class Client
			attr_reader :client_name
		
			def initialize( client_name="RubyLivecode", auto_open=true )
				@client_name = client_name
				open if auto_open
			end
			
			# Attach an instrument to the client. Accepts one or more arguments, 
			# which can be either numeric or instances of MIDI::Instrument.
			# New MIDI::Instruments will automatically be created for the given MIDI channel
			# if the argument is numeric.
			#
			# Example:
			#   client = MIDI::Client.new( "MyClient" )
			#   drums = client.add_instrument( MIDI::Instrument.new( 9 ) ) # MIDI channel 10
			#   bass, lead = client.add_instrument( 0, 1 )                 # MIDI channels 1 and 2
			#
			def add_instrument( *instruments )
				unless instruments.kind_of?( Array )
					instruments = [instruments]
				end
				instruments = instruments.map do |i|
					i = Instrument.new( i ) unless i.kind_of?( Instrument )
					i.client = self
					i
				end
				( instruments.length == 1 ) ? instruments.first : instruments
			end
			alias :inst :add_instrument
			alias :instr :add_instrument
		
			# Create and open outport. This is automatically done on Client.new unless
			# otherwise specified.
			def open
				client_name = CoreFoundation.cFStringCreateWithCString( nil, @client_name, 0 )
				@client = DL::PtrData.new( nil )
				CoreMIDI.mIDIClientCreate( client_name, nil, nil, @client.ref )
				port_name = CoreFoundation.cFStringCreateWithCString(nil, "Output", 0)
				@outport = DL::PtrData.new(nil)
				CoreMIDI.mIDIOutputPortCreate( @client, port_name, @outport.ref )

				number_of_destinations = CoreMIDI.mIDIGetNumberOfDestinations()
				raise NoMIDIDestinations if number_of_destinations < 1
				@destination = CoreMIDI.mIDIGetDestination( 0 )
			end

			# Close and dispose of outport.
			def close
				CoreMIDI.mIDIClientDispose( @client ) if @client
			end
		
			# Send note on message
			def note_on(midi_note)
				message(NOTE_ON | midi_note.channel, midi_note.number, midi_note.velocity)
			end

			# Send note off message
			def note_off(midi_note)
				message(NOTE_OFF | midi_note.channel, midi_note.number, midi_note.velocity)
			end

			# Send raw message to client
			def message( *args )
				format = "C" * args.size
				bytes = args.pack( format ).to_ptr
				packet_list = DL.malloc( 256 )
				packet_ptr = CoreMIDI.mIDIPacketListInit( packet_list )
				packet_ptr = CoreMIDI.mIDIPacketListAdd( packet_list, 256, packet_ptr, 0, 0, args.size, bytes )
				CoreMIDI.mIDISend( @outport, @destination, packet_list )
	        end

			# Core MIDI API
			module CoreMIDI
				extend DL::Importable
				dlload '/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMIDI'
				extern "int MIDIClientCreate(void *, void *, void *, void *)"
				extern "int MIDIClientDispose(void *)"
				extern "int MIDIGetNumberOfDestinations()"
				extern "void * MIDIGetDestination(int)"
				extern "int MIDIOutputPortCreate(void *, void *, void *)"
				extern "void * MIDIPacketListInit(void *)"
				extern "void * MIDIPacketListAdd(void *, int, void *, int, int, int, void *)"
				extern "int MIDISend(void *, void *, void *)"
			end

			# Core Foundation API
			module CoreFoundation
				extend DL::Importable
				dlload '/System/Library/Frameworks/CoreFoundation.framework/Versions/Current/CoreFoundation'

				extern "void * CFStringCreateWithCString (void *, char *, int)"
	        end

		end
	end
end