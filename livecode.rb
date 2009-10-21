
# Bootstrap loader
(bootstrap = %w{livecode/loader livecode/extensions/main}).each{ |l| require l }
self.send( :include, Livecode::Extensions::Main )
(bootstrap + [__FILE__]).each{ |l| Livecode.loader.add_reloadable( l ) }


# These should all be safe to load multiple times
%w{ 
	clock 
	step_sequencer 
	scale 
	markov_chain 
	midi
	extensions/numeric
	extensions/object
	extensions/string
}.each{ |l| live_require "livecode/#{l}" }


# Apply extensions
Numeric.send( :include, Livecode::Extensions::Numeric )
Object.send( :include, Livecode::Extensions::Object )
String.send( :include, Livecode::Extensions::String )

class NilClass; def chance?; false; end; alias :c? :chance?; end
class FalseClass; def chance?; false; end; alias :c? :chance?; end
class TrueClass; def chance?; true; end; alias :c? :chance?; end