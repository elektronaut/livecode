module LivecodeServer
	
	# Connection error, raised when trying to connect while the server isn't running.
	class ConnectionError < StandardError
	end

	# Livecode server client
	#
	# Usage:
	#  client = LivecodeServer::Client.new
	#  client.run 'puts "Hello world"'
	
	class Client

		# Daemon connection, connects to it if necessary.
		def server
			unless @server
				if LivecodeServer.running?
					DRb.start_service
					@server = DRbObject.new nil, LivecodeServer.uri
				else
					raise ConnectionError, "Server not running", caller
				end
			end
			@server
		end

		# Runs code on the server.
		def run(code)
			server.run code
		end
	end
end