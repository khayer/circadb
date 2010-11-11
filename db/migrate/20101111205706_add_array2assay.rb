class AddArray2assay < ActiveRecord::Migration
  def self.up
    add_column :assays, :gene_chip_id, :integer
    add_index :assays, :gene_chip_id
  end

  def self.down
    remove_index :assays, :gene_chip_id
    remove_column :assays, :gene_chip_id
  end
end
