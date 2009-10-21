require 'drb'
require 'etc'

[:daemon, :scope, :client].each do |f| 
	require File.join(File.dirname(__FILE__), "livecode_server/#{f}")
end

module LivecodeServer
	CONFIG_DIR = File.join(Etc.getpwuid.dir, '.config/livecode')
	URI_FILE   = File.join(CONFIG_DIR, 'livecode_server.uri')
	
	class << self

		def uri
			if File.exists?(URI_FILE)
				File.read(URI_FILE)
			else
				false
			end
		end
		
		def make_dir!
			FileUtils.mkdir_p(CONFIG_DIR)
		end

		def running?
			uri ? true : false
		end
	
		def register_uri(uri)
			File.open(URI_FILE, 'w'){|fh| fh.write uri}
		end

		def register_shutdown
			File.unlink(URI_FILE)
		end
	end
	
end

