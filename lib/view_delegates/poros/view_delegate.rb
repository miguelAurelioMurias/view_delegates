module ViewDelegates
  # Base class for delegates
  class ViewDelegate
    # This property will contain all the methods the view delegate
    # will execute to add as view locals
    @@view_locals = []
    # All models this view delegate will contain
    @@ar_models = []
    # Properties
    @@properties = []
    # View delegate cache system
    # @return [ViewDelegates::Cache]
    def delegate_cache
      @@delegate_cache
    end
    # Initialize method
    # @param [Hash] view_data hash containing all delegate properties
    def initialize(view_data = {})
      @@ar_models.each do |t|
        send("#{t}=", view_data[t]) if view_data[t]
      end
      @@properties.each do |t|
        send("#{t}=", view_data[t]) if view_data[t]
      end
    end

    # Renders as a string the view passed as params
    # @param [Symbol] view
    def render(view, local_params: {}, &block)
      locals = {}.merge(local_params)
      @@view_locals.each do |method|
        locals[method] = send(method)
      end
      ar_models = {}
      @@ar_models.each do |ar_model|
        ar_models[ar_model] = instance_variable_get(:"@#{ar_model}")
      end
      @@properties.each do |property|
        locals[property] = instance_variable_get "@#{property}"
      end
      locals = locals.merge(ar_models)
      result = ViewDelegateController.render(self.class.view_path + '/' + view.to_s,
                                    locals: locals)

      if block
        block.call(result)
      else
        result
      end
    end
    class << self

        def new *args
          if defined? @@polymorph_function
            command = super(*args)
            klazz = command.instance_eval(&@@polymorph_function)
            if klazz == self
              super(*args)
            else
             klazz.new(*args)
            end
          else
            super
          end
        end
        def cache(option, size: 50)
          if option
            render_method = instance_method :render
            @@delegate_cache = ViewDelegates::Cache.new(max_size: size)
            define_method(:render) do |view, local_params: {}, &block|
              value_key = "#{hash}#{view.to_s}"
              result = @@delegate_cache.get value_key
              if result.nil?
                result = render_method.bind(self).call(view, local_params)
                @@delegate_cache.add key: value_key, value: result
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
        def view_path
          @view_path ||= to_s.sub(/Delegate/, ''.freeze).underscore
        end

        # Marks a method as a view local
        # @param [Symbol] method
        def view_local(*methods)
          methods.each do |method|
            @@view_locals << method
          end
        end

        # View properties
        # @param [Symbol] method
        def property(*methods)
          methods.each do |method|
            @@properties << method
            attr_accessor method
          end
        end

        def polymorph &block
          @@polymorph_function = block
        end
        # The models this delegate will use
        # @param [method] method The variable name this model will use
        # @param [Array] properties The model properties to extract
        # from the active record model
        def model(method, properties: [])
          attr_accessor method
          # Add the method name to the array of delegate models
          @@ar_models << method
          # Define a setter for the model
          define_method "#{method}=" do |val|
            # Create a struct with the model properties
            model_delegate = if properties.any?
                               Struct.new(*properties)
                             else
                               Struct.new(*val.attributes.keys)
                             end
            initialize_hash = {}
            model_delegate.members.each do |k|
              initialize_hash[k] = val.send k
            end
            model_delegate = model_delegate.new(*initialize_hash.values_at(*model_delegate.members))
            # set the struct to instance model
            instance_variable_set(:"@#{method}", model_delegate)
          end
        end
      end
  end
end
