class CreateGeneChips < ActiveRecord::Migration
  def self.up
    create_table :gene_chips do |t|
      t.string :slug
      t.string :name
    end
    add_index :gene_chips, :slug, :unique => true
  end

  def self.down
    remove_index :gene_chips, :slug
    drop_table :gene_chips
  end
end
