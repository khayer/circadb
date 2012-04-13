class CreateProbesetDatas < ActiveRecord::Migration
  def self.up
    create_table :probeset_datas do |t|
      t.integer :assay_id
      t.integer :probeset_id
      t.string :assay_name
      t.string :probeset_name
      t.string :time_points, :limit => 1000
      t.string :data_points, :limit => 1000
      t.string :chart_url_base, :limit => 2000
      t.references :assay
      t.references :probeset
    end
    add_index :probeset_datas, :probeset_name
    add_index :probeset_datas, :assay_name
    add_index :probeset_datas, :assay_id
    add_index :probeset_datas, :probeset_id
  end

  def self.down
    remove_index :probeset_datas, :probeset_id
    remove_index :probeset_datas, :assay_id
    remove_index :probeset_datas, :assay_name
    remove_index :probeset_datas, :probeset_name
    drop_table :probeset_datas
  end
end
