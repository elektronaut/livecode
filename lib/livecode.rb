require 'pathname'

# = The Livecode library
#
# To get started, require and include Livecode:
# 
#  require 'livecode'
#  include Livecode
#
# For your main loop, have a look at Timer, Delay or the more sophisticated Clock class.

module Livecode
	unless self.const_defined?('LIBRARY_PATH')
		LIBRARY_PATH = Pathname.new(File.join(File.dirname(__FILE__))).realpath.to_s
	end
	unless self.const_defined?('Loader')
		$:.unshift LIBRARY_PATH
	end
end

# Bootstrap loader
(bootstrap = %w{livecode/loader livecode/extensions/main}).each{|l| require l}
self.send(:include, Livecode::Extensions::Main)
(bootstrap + [__FILE__]).each{|l| Livecode.loader.add_reloadable(l)}

# These should all be safe to load multiple times
%w{ 
	clock
	clock_recipients
	delay
	extensions/numeric
	extensions/object
	extensions/string
	midi
	silenceable
	timer
}.each{|l| live_require "livecode/#{l}"}

# Apply extensions
Numeric.send(:include, Livecode::Extensions::Numeric)
Object.send(:include, Livecode::Extensions::Object)
String.send(:include, Livecode::Extensions::String)
 
class NilClass #:nodoc:
	def chance?; false; end; alias :c? :chance?
end
class FalseClass #:nodoc:
	def chance?; false; end; alias :c? :chance?
end
class TrueClass #:nodoc:
	def chance?; true; end; alias :c? :chance?
end