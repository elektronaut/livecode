module Livecode
	module MIDI
		class Instrument
			attr_accessor :client, :channel

			def initialize( channel )
				@channel = channel
			end

			def play( number, duration, velocity=127 )
				raise NoMIDIClient unless @client
				note = Note.new( :channel => @channel, :number => number, :duration => duration, :velocity => velocity )
				note.play( @client )
			end

		end

	end
end