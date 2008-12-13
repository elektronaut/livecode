module Livecode
	class Scale
		include Enumerable
		attr_accessor :root, :scale, :octaves, :notes

		# Diatonic modes
		IONIAN     = [0,2,4,5,7,9,11] # C D E F G A B
        DORIAN     = [0,1,3,5,7,8,10] # E F G A B C D
		PHRYGIAN   = [0,2,3,5,7,9,10] # D E F G A B C
		LYDIAN     = [0,2,4,6,7,9,11] # F G A B C D E
		MIXOLYDIAN = [0,2,4,5,7,9,10] # G A B C D E F
		AEOLIAN    = [0,2,3,5,7,8,10] # A B C D E F G
		LOCRIAN    = [0,1,3,5,6,9,11] # B C D E F G A

        # Western scales
        MAJOR          = [0,2,4,5,7,9,11]
        HARMONIC_MAJOR = [0,2,4,5,7,8,11]
		MINOR          = [0,2,3,5,7,8,10]
		HARMONIC_MINOR = [0,2,3,5,7,8,11]
		MELODIC_MINOR  = [0,2,3,5,7,9,11]
		
		# Chords
		CHORD_FIFTH = [0,7]
		CHORD_MAJ   = [0,4,7]
		CHORD_MAJ7  = [0,4,7,11]
		CHORD_MIN   = [0,3,7]
		CHORD_MIN7  = [0,3,7,10]
		CHORD_AUG   = [0,4,8] # Augmented triad
		CHORD_DIM   = [0,3,6] # Diminished triad

		def initialize(root, scale, octaves=1)
			@root = root
			@octaves = octaves
			self.scale = scale
		end
		
		def scale=(scale)
			notes = []
			@octaves.times do |i|
				oct = 12 * i
				scale.each do |n|
					notes << (@root + n + oct)
				end
			end
			@notes = notes
		end
		
		def each
			notes.each{ |n| yield n }
		end
		
		def length
			notes.length
		end
		
        # Transpose scale by a number of semitones.
		def transpose!(interval)
		    @notes = @notes.map{|n| n + interval}
		    self
	    end
	    
	    # Returns a scale transposed by number of semitones.
	    def transpose(interval)
	        self.dup.transpose!(interval)
        end
        
        # 
        def correct()
        end
		
        # Returns the note for a given index. 
        # The index is modulated with the scale length,
        # which means that any integer will yield a result.
		def [](index)
			notes[index%length]
		end

	end
end