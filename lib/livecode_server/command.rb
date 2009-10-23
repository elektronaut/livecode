require 'rubygems'
require 'optparse'
require 'pathname'
require 'daemons'

require 'livecode_server'

module LivecodeServer
	class Command
		class << self

			def version
				"Livecode server " + File.read(File.join(File.dirname(__FILE__), '../../VERSION'))
			end

			# Run command
			def run!(*args)
				options = {}
				optparse = OptionParser.new do |opts|
					opts.banner  = "Usage: #{File.basename($0)} [command] [options]\n\n"
					opts.banner += "  Server control commands:\n"
					opts.banner += "    start                            Start the server as a daemon\n"
					opts.banner += "    stop                             Stop the server\n"
					opts.banner += "    restart                          Restart the server\n"
					opts.banner += "    run                              Start the server and stay on top\n"
					opts.banner += "    status                           Show server status\n"
					opts.banner += "\n"
					opts.banner += "  Client control commands:\n"
					opts.banner += "    connect                          Connect to remote server\n"
					opts.banner += "    disconnect                       Disconnect from remote server\n"
					opts.banner += "\n"
					opts.banner += "  Other commands:\n"
					opts.banner += "    update_textmate                  Update TextMate bundle\n"
					opts.banner += "\n"
					opts.banner += "  Options:"
					opts.on('-h', '--help', 'Show this message') do
						puts opts
						exit
					end
					opts.on('-v', '--version', 'Show version') do
						puts self.version
						exit
					end
				end
				optparse.parse!
				
				if ARGV.length > 0
					command = self.new(options)
					run_command = ARGV.shift
					unless command.dispatch!(run_command, *ARGV)
						puts "ERROR! Invalid command: #{run_command}\n\n"
						puts optparse
					end
				else
					puts optparse
				end
			end
		end
		
		protected

			def daemon_group
				daemon_options = {
					:mode     => :proc,
					:multiple => false,
					:ontop    => @options[:ontop] ? true : false,
					:dir_mode => :normal,
					:dir      => LivecodeServer::CONFIG_DIR
				}
				daemon_options[:proc] = proc do
					LivecodeServer.make_dir!
					server = LivecodeServer::Daemon.new
					DRb.start_service nil, server
					LivecodeServer.register_uri DRb.uri
					puts "Started Livecode server on #{DRb.uri}"
					puts "Press ^C to exit"
					trap_proc = proc{ 
						puts "Exiting..."
						LivecodeServer.register_shutdown
						exit 
					}
					%w{SIGINT TERM}.each{|s| trap s, trap_proc}
					DRb.thread.join
				end
				unless @daemon_group
					@daemon_group = Daemons::ApplicationGroup.new(@app_name, daemon_options)
					@daemon_group.setup
				end
				@daemon_group
			end
			
			def server_running?
				(daemon_group.applications.length > 0) ? true : false
			end

		public

			def initialize(options)
				@app_name = "livecode"
				@options = {}.merge(options)
			end
		
			# Dispatch a command
			def dispatch!(command, *args)
				if (self.public_methods - Object.methods - ['dispatch!']).include?(command)
					begin
						self.send(command.to_sym, *args)
					rescue ArgumentError => e
						puts "Error: #{e}"
					end
					return command
				else
					return nil
				end
			end
			
			# Start the server
			def start(*args)
				if server_running?
					puts "Livecode server is already running on #{LivecodeServer.uri}"
				else
					daemon_group.new_application.start
					sleep(2)
					puts "Started Livecode server on #{LivecodeServer.uri}"
				end
			end
		
			# Start the server and stay on top
			def run(*args)
				@options[:ontop] = true
				if server_running?
					puts "Livecode server is already running on #{LivecodeServer.uri}"
				else
					daemon_group.new_application.start
				end
			end

			# Stop the server
			def stop(*args)
				if server_running?
					daemon_group.stop_all
					puts "Livecode server stopped."
				else
					puts "Livecode server isn't running, nothing to stop."
				end
			end
			
			# Restart the server
			def restart
				if server_running?
					puts "Restarting server.."
					daemon_group.stop_all
					sleep(1)
					daemon_group.start_all
					sleep(2)
					puts "Livecode server is now running on #{LivecodeServer.uri}"
				else
					puts "Livecode server isn't running, nothing to restart."
				end
			end
			
			# Show server status
			def status
				if server_running?
					puts "Livecode server is running on #{LivecodeServer.uri}"
				elsif LivecodeServer.running?
					puts "Remote connected to server on #{LivecodeServer.uri}"
				else
					puts "Livecode server isn't running."
				end
			end

			# Connect to a remote server
			def connect(url, *args)
				if url =~ /^drb:\/\/.+/
					if server_running?
						daemon_group.stop_all
						sleep(1)
					end
					LivecodeServer.register_uri url
					puts "Now connected to server on #{url}"
				else
					puts "Error: Not a valid server url"
				end
			end
			
			# Disconnect from remote server
			def disconnect
				if server_running?
					puts "Livecode server running as daemon, shutdown to disconnect."
				elsif LivecodeServer.running?
					puts "Livecode server disconnected."
					LivecodeServer.register_shutdown
				else
					puts "Not connected to any Livecode servers."
				end
			end
			
			# Update TextMate bundle
			def update_textmate
				update_bundle       = true
				bundle_path         = File.join(File.dirname(__FILE__), '../../extras/textmate/Ruby Livecode.tmbundle')
				bundle_path         = Pathname.new(bundle_path).realpath.to_s
				escaped_bundle_path = bundle_path.gsub(/\s/, '\ ')
				target_path         = '/Library/Application Support/TextMate/Bundles/Ruby Livecode.tmbundle'
				escaped_target_path = target_path.gsub(/\s/, '\ ')

				# Handle existing files
				if File.exists?(target_path)
					if File.symlink?(target_path)
						if Pathname.new(target_path).realpath.to_s == bundle_path
							puts "TextMate bundle is already up to date."
							update_bundle = false
						else
							puts "Existing symlink found:\n\n"
							puts "- " + Pathname.new(target_path).realpath.to_s
							puts "+ " + bundle_path
							print "\nReplace? [y/n] "
						end
					else
						puts "Existing bundle found, are you sure you want to replace it? [y/n] "
					end
					if update_bundle
						if STDIN.readline.chomp =~ /^y/i
							`sudo rm #{escaped_target_path}`
						else
							update_bundle = false
						end
					end
				end
				
				if update_bundle
					unless File.exists?("/Library/Application Support/TextMate/Bundles")
						`sudo mkdir -p /Library/Application\\ Support/TextMate/Bundles`
					end
					puts "Updating Textmate bundle.."
					`sudo ln -s #{escaped_bundle_path} #{escaped_target_path}`
					`osascript -e 'tell app "TextMate" to reload bundles'`
				end
			end
		
	end
end