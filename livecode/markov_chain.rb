# This is very far from complete

module Livecode
	class MarkovChain
		attr_accessor :state, :length, :orders, :seed
		attr_accessor :table

		def initialize( length, options={} )
			@length = length
			@orders = options[:orders] || 1
			@seed   = options[:seed] || nil
			generate
		end

		def generate
			@table = {}
		end
		
		def normalized_random_table( len )
			t = []
			len.times{ t << random }
			sum = t.inject(0) { |s,e| s + e }
			t = t.map{ |i| i / sum }
		end
		
		def random
			old_seed = srand( @seed ) if @seed
			number = rand
			srand( old_seed ) if @seed
			number
		end

	end
end