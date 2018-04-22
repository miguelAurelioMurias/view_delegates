module ViewDelegates
  class Cache
    CacheEntry = Struct.new(:key, :value)
    attr_accessor :entries
    def initialize(max_size: 10)
      @entries = []
      @max_size = max_size
    end

    def add(key:, value:)
      @entries << CacheEntry.new(key, value)
      if @entries.length > @max_size
        @entries.delete_at 0
      end
    end

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
