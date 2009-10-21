module Livecode
	module MIDI

		NOTE_ON = 0x90
		NOTE_OFF = 0x80
		PROGRAM_CHANGE = 0xC0

    	class NoMIDIDestinations < Exception ; end
		class NoMIDIClient < Exception; end

	end
end

%w{client note instrument}.each{ |c| live_require "livecode/midi/#{c}" }

