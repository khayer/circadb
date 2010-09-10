class CreateAssays < ActiveRecord::Migration
  def self.up
    create_table :assays do |t|
      t.string :slug
      t.string :name
      t.string :description
    end
    add_index :assays, :slug, :unique => true
  end

  def self.down
    remove_index :assays, :slug
    drop_table :assays
  end
end
