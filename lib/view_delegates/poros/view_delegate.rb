module ViewDelegates
  class ViewDelegate
    @@view_locals = []
    @@ar_models = []
    def initialize view_data = {}
      @@ar_models.each do |t|
        if view_data[t]
          send("#{t}=", view_data[t])
        end
      end
    end
    def render view
      locals = {}
      for method in @@view_locals
        locals[method] = send(method)
      end
      ar_models = {}
      for ar_model in @ar_models
        ar_models[ar_model] = send(:"@#{ar_model}")
      end
      locals = locals.merge(ar_models)
      ViewDelegateController.render( self.class.view_path+ '/' + view, locals: locals)
    end
    class << self
        def view_path
          @view_path ||= self.to_s.sub(/Delegate/, "".freeze).underscore
        end
        def view_local method
            @@view_locals << method
        end
        def ar_model method, properties = []
          attr_accessor method
          @@ar_models << method
          define_method ("#{method}=") { |val|
              model_delegate =  nil
              if properties.any?
                model_delegate = Struct.new(*properties)
              else
                model_delegate = Struct.new(*val.attributes.keys)
              end
              model_delegate = model_delegate.new(*model_delegate.members.map{|k| val.send(k)})
              instance_variable_set(:"@#{method}", model_delegate)
          }
        end
      end
  end
end