require File.dirname(__FILE__) + '/../../../ext/coremidi.bundle'

module Livecode
	module MIDI
		module CoreMIDI
			module API
				MidiPacket = Struct.new(:timestamp, :data)
			end

			# Unused, but left here for documentation
			def self.number_of_sources
				API.get_num_sources
			end

			class Packet
				# http://www.srm.com/qtma/davidsmidispec.html
				def self.parse(data)
					spec = {
						0x80 => Events::NoteOff,
						0x90 => lambda {|data| (data[Events::NoteOn.members.index("velocity")] == 0) ? Events::NoteOff : Events::NoteOn },
						0xA0 => Events::KeyPressure,
						0xC0 => Events::ProgramChange,
						0xD0 => Events::ChannelPressure
					}

					klass = spec.detect {|code, _|
						data[0] & 0xF0 == code # First byte is the type code
					}

					return Events::Unknown.new(data) if klass.nil?

					klass = klass.last
					klass = klass.call(data) if klass.respond_to?(:call) # Resolve any lambdas into a class

					klass.new(
					data[0] & 0x0F, # Second byte contains the channel
					*data[1..-1]
					)
				end
			end

			module Events
				class NoteOn          < Struct.new(:channel, :pitch, :velocity); end;
				class NoteOff         < Struct.new(:channel, :pitch, :velocity); end;
				class KeyPressure     < Struct.new(:channel, :pitch, :pressure); end;
				class ProgramChange   < Struct.new(:channel, :preset);           end; 
				class ChannelPressure < Struct.new(:channel, :pressure);       end; 
				class Unknown         < Struct.new(:data);                       end;
			end

			class Input
				def self.register(client_name, port_name, source)
					raise "name must be a String!" unless client_name.class == String

					client = API.create_client(client_name) 
					port = API.create_input_port(client, port_name)
					API.connect_source_to_port(API.get_sources.index(source), port)

					while true
						data = API.check_for_new_data
						if data && !data.empty?
							data.each do |packet|
								yield(Packet.parse(packet.data))
							end
						end
						sleep 0.0001
					end
				end
			end

			class Source
				def self.register(client_name, source_name)
					raise "name must be a String!" unless client_name.class == String
					client = API.create_client(client_name) 
					source = API.create_source(client, source_name)
				end
			end
		end
	end
end