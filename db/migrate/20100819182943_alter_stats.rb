class AlterStats < ActiveRecord::Migration
  def self.up
   add_column :probeset_stats, :jtk_p_value        , :float
   add_column :probeset_stats, :jtk_q_value        , :float
   add_column :probeset_stats, :jtk_period_length  , :float
   add_column :probeset_stats, :jtk_lag            , :float
   add_column :probeset_stats, :jtk_amp            , :float
  end

  def self.down
    remove_column :probeset_stats, :jtk_p_value       
    remove_column :probeset_stats, :jtk_q_value       
    remove_column :probeset_stats, :jtk_period_length 
    remove_column :probeset_stats, :jtk_lag           
    remove_column :probeset_stats, :jtk_amp           
  end
end
