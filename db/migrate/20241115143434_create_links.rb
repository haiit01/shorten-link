class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.string :original_url, null: false
      t.string :short_url, null: false

      t.timestamps
    end
  end
end
