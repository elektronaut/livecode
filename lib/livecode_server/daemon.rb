module LivecodeServer

	# LivecodeServer daemon
	class Daemon
		attr_reader :scope

		def initialize(scope=nil)
			@scope = Scope.new(self)
			@output = ""
		end
		
		def output(string, prefix=nil)
			@output += string + "\n"
			puts (prefix) ? "#{prefix} #{string}" : string
			return nil
		end

		def run(code)
			code = code.strip
			@output = ""
			puts
			begin
				puts "--- #{Time.now}:"
				puts ">> #{code}" 
				result = eval(code, @scope.get_binding)
				puts "=> #{result}" 
			rescue Exception => e
				output "#{e.class}: #{e}", "!!"
			end
			return @output
		end
	end
end