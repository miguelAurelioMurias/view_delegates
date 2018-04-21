module ViewDelegates
  # Base class for delegates
  class ViewDelegate
    # This property will contain all the methods the view delegate will execute to add as view locals
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
      @@view_locals.each {|method|
        locals[method] = send(method)
      }
      ar_models = {}
      @@ar_models.each {|ar_model|
        ar_models[ar_model] = instance_variable_get(:"@#{ar_model}")
      }
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
        # @param [Array] properties The model properties to extract from the active record model
        def model(method, properties: [])
          attr_accessor method
          @@ar_models << method
          define_method ("#{method}=") do |val|
            model_delegate = nil
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
            instance_variable_set(:"@#{method}", model_delegate)
          end
        end
      end
  end
end
