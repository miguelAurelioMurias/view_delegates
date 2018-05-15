class PolymorphicDelegate < ViewDelegates::ViewDelegate
  property :a
  model :b
  view_local :polymorphic_message
  model_array :polis
  polymorph do
    if a == 1
      BasicDelegate
    else
      PolymorphicDelegate
    end
  end
  def polymorphic_message
    'Im a polymorphic class!!'
  end
end
