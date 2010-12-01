class ProbesetData < ActiveRecord::Base
  cattr_reader :pval_filters
  @@pval_filters = []
  ["jtk", "JTK", "fisher_g", "Fisher's G-test" ].each_slice(2) do |id,txt|
    @@pval_filters += [["#{txt} P-value","#{id}_p_value"],
                       ["#{txt} Q-value","#{id}_q_value"] ]
  end

  belongs_to :assay
  belongs_to :probeset

  serialize :time_points
  serialize :data_points
  
  define_index do 
    %w{probeset_name 
      transcript_id
      representative_public_id 
      unigene_id 
      gene_symbol 
      gene_title 
      entrez_gene 
      swissprot 
      refseq_protein_id 
      refseq_transcript_id 
      target_description}.map do |m|
        eval <<-EOF
        indexes probeset.#{m}, :as => :#{m}
        EOF
    end

    has assay_id, cosopt_p_value, cosopt_q_value, cosopt_period_length,
      cosopt_phase, fisherg_p_value, fisherg_q_value, fisherg_period_length,
      jtk_p_value, jtk_q_value, jtk_period_length, jtk_lag, jtk_amp
  end
  
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

