module ViewDelegates
  # View cache class
  class Cache
    # Internal struct to save all the values
    CacheEntry = Struct.new(:key, :value)
    # Accessor for the current entries
    # Entries is an array, the most recent elements are at the end of the array
    attr_accessor :entries
    # Initializer
    # @param [Integer] max_size
    def initialize(max_size: 10)
      @entries = []
      @max_size = max_size
    end
    # Add a new entry
    # @param [Symbol] key
    # @param [String] value
    def add(key:, value:)
      @entries << CacheEntry.new(key, value)
      # If the array is full, remove the first element, since its the oldest
      @entries.delete_at 0 if @entries.length > @max_size
    end
    # Get an entry
    # @param [Symbol] key
    def get(key)
      result = nil
      index = @entries.index { |e| e.key == key }
      if index
        result = @entries[index].value
        update_element index
      end
      result
    end

    private
    # Put the element at index one step to the right
    # @param [Integer] index
    def update_element(index)
      before = index - 1
      start = []
      start = @entries[0..before] unless before.negative?
      @entries = start, @entries[index..(index + 1)].reverse,
                 @entries[(index + 2)..-1]
      @entries = @entries.flatten.uniq
    end
  end
end
