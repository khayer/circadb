class CreateProbesetDatas < ActiveRecord::Migration
  def self.up
    create_table :probeset_datas do |t|
      t.integer :assay_id
      t.integer :probeset_id
      t.float :jtk_p_value
      t.float :jtk_q_value
      t.float :jtk_period_length
      t.float :jtk_lag 
      t.float :jtk_amp
      t.float :cosopt_p_value
      t.float :cosopt_q_value
      t.float :cosopt_period_length
      t.float :cosopt_phase
      t.float :fisherg_p_value
      t.float :fisherg_q_value
      t.float :fisherg_period_length
      t.string :time_points, :limit => 1000
      t.string :data_points, :limit => 1000
      t.string :chart_url_base, :limit => 2000
    end
    add_index :probeset_datas, :assay_id
    add_index :probeset_datas, :probeset_id
    add_index :probeset_stats, :jtk_p_value
    add_index :probeset_stats, :jtk_q_value
    add_index :probeset_stats, :cosopt_q_value
    add_index :probeset_stats, :cosopt_p_value
    add_index :probeset_stats, :fisherg_q_value
    add_index :probeset_stats, :fisherg_p_value
  end

  def self.down
    remove_index :probeset_datas, :probeset_id
    remove_index :probeset_datas, :assay_id
    remove_index :probeset_stats, :jtk_p_value
    remove_index :probeset_stats, :jtk_q_value
    remove_index :probeset_stats, :cosopt_q_value
    remove_index :probeset_stats, :cosopt_p_value
    remove_index :probeset_stats, :fisherg_q_value
    remove_index :probeset_stats, :fisherg_p_value
    drop_table :probeset_datas
  end
end
