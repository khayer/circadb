class CreateProbesetStats < ActiveRecord::Migration
  def self.up
    create_table :probeset_stats do |t|
      t.integer :assay_id
      t.integer :probeset_id
      t.integer :probeset_data_id
      t.float :cosopt_p_value
      t.float :cosopt_q_value
      t.float :cosopt_period_length
      t.float :cosopt_phase
      t.float :fisherg_p_value
      t.float :fisherg_q_value
      t.float :fisherg_period_length
      t.string :assay_name
      t.string :probeset_name
      t.references :assay
      t.references :probeset
      t.references :probeset_data
    end
    add_index :probeset_stats, :probeset_name
    add_index :probeset_stats, :assay_name
    add_index :probeset_stats, :assay_id
    add_index :probeset_stats, :probeset_id
    add_index :probeset_stats, :probeset_data_id
    add_index :probeset_stats, :cosopt_q_value
    add_index :probeset_stats, :cosopt_p_value
    add_index :probeset_stats, :fisherg_q_value
    add_index :probeset_stats, :fisherg_p_value
  end

  def self.down
    remove_index :probeset_stats, :probeset_data_id
    remove_index :probeset_stats, :probeset_id
    remove_index :probeset_stats, :assay_id
    remove_index :probeset_stats, :probeset_name
    remove_index :probeset_stats, :assay_name
    remove_index :probeset_stats, :cosopt_q_value
    remove_index :probeset_stats, :cosopt_p_value
    remove_index :probeset_stats, :fisherg_q_value
    remove_index :probeset_stats, :fisherg_p_value
    drop_table :probeset_stats
  end
end
