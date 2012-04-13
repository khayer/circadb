class AddStatJtkIndexes < ActiveRecord::Migration
  def self.up
    add_index :probeset_stats, :jtk_p_value
    add_index :probeset_stats, :jtk_q_value
  end

  def self.down
    remove_index :probeset_stats, :jtk_p_value
    remove_index :probeset_stats, :jtk_q_value
  end
end
