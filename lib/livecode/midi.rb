require 'livecode'
require 'livecode/midi/coremidi'

%w{ 
	client
}.each{|l| live_require "livecode/midi/#{l}"}
