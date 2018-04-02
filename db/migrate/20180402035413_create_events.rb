class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :category
      t.string :function_area
      t.string :function_level
      t.string :category_m
      t.text   :steps
      t.string :jelly_bean
      t.string :grl
      t.string :event_level
      t.string :regression_level
      t.text   :expected_result

      t.timestamps
    end
  end
end
