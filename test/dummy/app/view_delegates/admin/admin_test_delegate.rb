module Admin
  class AdminTestDelegate < ViewDelegates::ViewDelegate
    view_local :test_method
    property :my_property
    model :dummy, properties: [:a]
    model_array :dummies, properties: [:b]
    cache true
    def test_method
      'test_method'
    end
  end
end
