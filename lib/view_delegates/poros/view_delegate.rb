module ViewDelegates
  # Base class for delegates
  class ViewDelegate
    # This property will contain all the methods the view delegate
    # will execute to add as view locals
    @@view_locals = []
    # All models this view delegate will contain
    @@ar_models = []
    # Initialize method
    # @param [Hash] view_data hash containing all delegate properties
    def initialize(view_data = {})
      @@ar_models.each do |t|
        send("#{t}=", view_data[t]) if view_data[t]
      end
    end

    # Renders as a string the view passed as params
    # @param [Symbol] view
    def render(view)
      locals = {}
      @@view_locals.each do |method|
        locals[method] = send(method)
      end
      ar_models = {}
      @@ar_models.each do |ar_model|
        ar_models[ar_model] = instance_variable_get(:"@#{ar_model}")
      end
      locals = locals.merge(ar_models)
      ViewDelegateController.render(self.class.view_path + '/' + view.to_s,
                                    locals: locals)
    end
    class << self

        # Gets the path for the delegate views
        def view_path
          @view_path ||= to_s.sub(/Delegate/, ''.freeze).underscore
        end

        # Marks a method as a view local
        # @param [Symbol] method
        def view_local(method)
          @@view_locals << method
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
            model_delegate = model_delegate.new(*initialize_hash)
            # set the struct to instance model
            instance_variable_set(:"@#{method}", model_delegate)
          end
        end
      end
  end
end
