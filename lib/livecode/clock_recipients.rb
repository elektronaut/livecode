module Livecode

	# = ClockRecipients
	#
	# ClockRecipients is used internally by Clock to handle it's recipients.

	class ClockRecipients
		include Enumerable

		def initialize
			@collection = {}
		end
		
		def each
			@collection.each{|key,r| yield r}
		end
		
		def each_with_index
			@collection.each{|key,r| yield key, r}
		end
		
		def keys
			@collection.map{|k,o| k}
		end
		
		def has_key?(key)
			(@collection.keys.map{|k| k}.include?(key.to_sym)) ? true : false
		end
		
		def set(key, obj=nil, &block)
			obj = block if block_given?
			if obj
				@collection[key.to_sym] = Silenceable.apply( obj )
			elsif has_key?(key)
				@collection.delete(key.to_sym)
			end
		end
		alias :add :set
		alias :attach :set
		alias :[]= :set
		
		def get(key)
			return nil unless self.has_key?(key)
			@collection[key.to_sym]
		end
		alias :[] :get
		
		def method_missing(method_sym, *args, &block)
			method_name = method_sym.to_s
			if method_name =~ /=$/
				self.set(method_name.gsub(/=$/, ''), *args)
			elsif block_given?
				self.set(method_name, *args, &block)
			else
				return nil unless self.has_key?(method_name)
				self.get(method_name)
			end
		end
		
		def silence(*keys)
			keys.each{|k| self[k].silenced = true}
		end
		alias :mute :silence
		
		def silence_all
			each_with_index{|k,o| self[k].silenced = true}
		end
		alias :mute_all :silence_all
		
		def solo(*keys)
			silence_all
			keys.each{|k| self[k].silenced = false}
		end
		alias :play :solo
		
		def enable_all
			each_with_index{|k,o| self[k].silenced = false}
		end
		alias :play_all :enable_all
		alias :unsolo   :enable_all
		
	end
end