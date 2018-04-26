module ViewDelegates
  # Base class for delegates
  class ViewDelegate
    class << self
      attr_accessor :polymorph_function
      attr_accessor :delegate_cache
    end
    class_attribute :view_locals
    class_attribute :models
    class_attribute :ar_models
    class_attribute :properties
    # View delegate cache system
    # @return [ViewDelegates::Cache]
    def self.delegate_cache
      @delegate_cache
    end

    def self.polymorph_function
      @polymorph_function
    end

    # Initialize method
    # @param [Hash] view_data hash containing all delegate properties
    def initialize(view_data = {})
      self.class.ar_models&.each do |t|
        send("#{t}=", view_data[t]) if view_data[t]
      end
      self.class.properties&.each do |t|
        send("#{t}=", view_data[t]) if view_data[t]
      end
    end

    # Renders as a string the view passed as params
    # @param [Symbol] view
    def render(view, local_params: {}, &block)
      locals = {}
      self.class.view_locals&.each do |method|
        locals[method] = send(method)
      end
      self.ar_models = {}
      self.class.ar_models&.each do |ar_model|
        self.ar_models[ar_model] = instance_variable_get(:"@#{ar_model}")
      end
      self.class.properties&.each do |property|
        locals[property] = instance_variable_get "@#{property}"
      end
      locals = locals.merge(self.ar_models).merge(local_params)
      result = ViewDelegateController.render(self.class.view_path + '/' + view.to_s,
                                             locals: locals)

      if block
        block.call(result)
      else
        result
      end
    end

    private

    def model_to_struct model, struct
      initialize_hash = {}
      struct_members = struct.members
      struct_members.each do |k|
        initialize_hash[k] = model.send k
      end
      struct.new(*initialize_hash.values_at(*struct_members))
    end


    # Override the new, we may need polymorphism
    # @param [Hash] args
    def self.new *args
      if @polymorph_function
        command = super(*args)
        klazz = command.instance_eval(&@polymorph_function)
        if klazz == self
          super(*args)
        else
          klazz.new(*args)
        end
      else
        super
      end
    end

    # Activates cache on the view delegate
    # option must be true/false
    # size is an optional parameter, controls the max size of the cache array
    # @param [Boolean] option
    # @param [Integer] size
    def self.cache(option, size: 50)
      if option
        render_method = instance_method :render
        @delegate_cache = ViewDelegates::Cache.new(max_size: size)
        define_method(:render) do |view, local_params: {}, &block|
          value_key = "#{hash}#{local_params.hash}#{view.to_s}"
          result = self.class.delegate_cache.get value_key
          if result.nil?
            result = render_method.bind(self).call(view, local_params: local_params)
            self.class.delegate_cache.add key: value_key, value: result
          end
          if block
            block.call(result)
          else
            result
          end
        end
      end
    end

    # Gets the path for the delegate views
    def self.view_path
      @view_path ||= to_s.sub(/Delegate/, ''.freeze).underscore
    end

    # Marks a method as a view local
    # @param [Symbol] method
    def self.view_local(*methods)
      self.view_locals = [] if view_locals.nil?
      self.view_locals += methods
    end

    # View properties
    # @param [Symbol] method
    def self.property(*methods)
      self.properties = [] if self.properties.nil?
      methods.each do |method|
        attr_accessor method
      end
      self.properties += methods
    end

    # Polymorphism method
    # The block must return the class we must use
    # @param [Proc] block
    def self.polymorph &block
      @polymorph_function = block
    end

    # The models this delegate will use
    # @param [method] method The variable name this model will use
    # @param [Array] properties The model properties to extract
    # from the active record model
    def self.model(method, properties: [])
      attr_accessor method
      self.ar_models = [] if self.ar_models.nil?
      # Add the method name to the array of delegate models
      self.ar_models += [method]
      # Define a setter for the model
      define_method "#{method}=" do |val|
        # Create a struct with the model properties
        model_delegate = if properties.any?
                           Struct.new(*properties)
                         else
                           Struct.new(*val.attributes.keys)
                         end
        model_delegate = model_to_struct(val, model_delegate)
        # set the struct to instance model
        instance_variable_set(:"@#{method}", model_delegate)
      end
    end

    def self.model_array method, properties: []
      attr_accessor method
      # Add the method name to the array of delegate models
      self.ar_models = [] if self.ar_models.nil?
      self.ar_models += [method]
      # Define a setter for the model
      define_method "#{method}=" do |model_array|
        # Create a struct with the model properties
        model_delegate = if properties.any?
                           Struct.new(*properties)
                         else
                           Struct.new(*val.attributes.keys)
                         end
        model_array.map! {|e| model_to_struct(e, model_delegate)}
        instance_variable_set(:"@#{method}", model_array)
      end
    end
  end
end
