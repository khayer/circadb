class ProbesetData < ActiveRecord::Base

  belongs_to :assay
  belongs_to :probeset
  has_one :probeset_stat

  def chart_url(chart_width=330,chart_height=180)
    return chart_url_base % [chart_width,chart_height]
  end

end


# == Schema Information
#
# Table name: probeset_datas
#
#  id             :integer(4)      not null, primary key
#  assay_id       :integer(4)
#  probeset_id    :integer(4)
#  assay_name     :string(255)
#  probeset_name  :string(255)
#  time_points    :string(1000)
#  data_points    :string(1000)
#  chart_url_base :string(2000)
#

