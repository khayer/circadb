class CreateAssays < ActiveRecord::Migration
  def self.up
    create_table :assays do |t|
      t.integer :gene_chip_id
      t.string :slug, :uniq => true
      t.string :name
      t.string :description
    end
    # add_index :assays, :slug, :unique => true
    add_index :assays, :gene_chip_id
  end

  def self.down
    remove_index :assays, :slug
    remove_index :assays, :gene_chip_id
    drop_table :assays
  end
end
