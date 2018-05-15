class CreateDummyModels < ActiveRecord::Migration[5.1]
  def change
    create_table :dummy_models do |t|
      t.string :a
      t.string :b
      t.timestamps
    end
  end
end
