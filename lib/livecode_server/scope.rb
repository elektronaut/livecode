module LivecodeServer
	class Scope
		def initialize(server=nil)
			@__server = server
		end
		def get_binding
			@__scope_binding ||= Proc.new {}
		end

		def puts(string)
			@__server.output string
		end
	end
end