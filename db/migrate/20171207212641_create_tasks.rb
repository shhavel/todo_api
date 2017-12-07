class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :state, default: 'new', null: false

      t.timestamps
    end

    add_index :tasks, :name
    add_index :tasks, :slug, unique: true
    add_index :tasks, :state
  end
end
