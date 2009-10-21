module LivecodeServer
	class ConnectionError < StandardError; end

	class Client
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

		def run(code)
			server.run code
		end
	end
end