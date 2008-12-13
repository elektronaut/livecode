module Livecode
	module MIDI
		class Note
			attr_accessor :channel, :number, :duration, :velocity
			def initialize( options )
				@channel  = options[:channel] || 0
				@number   = options[:number]
				@velocity = options[:velocity] || 127
				@duration = options[:duration] || nil
			end
			def play( client )
				client.note_on( self )
				@play_thread ||= Thread.new do
					sleep( @duration )
					client.note_off( self )
				end
			end
		end
	end
end