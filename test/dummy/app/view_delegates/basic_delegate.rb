class BasicDelegate < PolymorphicDelegate
  view_local :basic_method
  model :basic
  model_array :basics, properties: [:a,:b]
  def basic_method
    'basic method'
  end
end