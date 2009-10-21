require 'helper'

class TestLivecodeServer < Test::Unit::TestCase
	context "A client" do
		setup do
			@client = LivecodeServer::Client.new
		end
		should "connect" do
			assert @client.run("true")
		end
		should "evaluate puts commands to strings" do
			assert_equal "Hello world!\n", @client.run('puts "Hello world!"')
		end
		should "not crash on undefined methods" do
			assert @client.run('this_is_an_undefined_method')
		end
		should "not crash on open parenthesis" do
			assert_raise LocalJumpError, @client.run('(1')
		end
		should "not crash on open bracket" do
			assert_raise LocalJumpError, @client.run('[1')
		end
		should "not crash on open method" do
			assert_raise LocalJumpError, @client.run('def hi; puts "yo"')
		end
		should "not crash on open class" do
			assert_raise LocalJumpError, @client.run('class MyClass')
		end
	end
end
