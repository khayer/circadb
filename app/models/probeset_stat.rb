class ProbesetStat < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 30
  cattr_reader :pval_filters
  @@pval_filters = []
  ["jtk", "JTK", "cosopt", "Lomb Scargle", "fisherg", "DeLichtenberg" ].each_slice(2) do |id,txt|
    @@pval_filters += [["#{txt} P-value","#{id}_p_value"],
                       ["#{txt} Q-value","#{id}_q_value"] ]
  end

  belongs_to :assay
  belongs_to :probeset
  belongs_to :probeset_data

  # full text index using sphinx
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
end


# == Schema Information
#
# Table name: probeset_stats
#
#  id                    :integer(4)      not null, primary key
#  assay_id              :integer(4)
#  probeset_id           :integer(4)
#  probeset_data_id      :integer(4)
#  cosopt_p_value        :float
#  cosopt_q_value        :float
#  cosopt_period_length  :float
#  cosopt_phase          :float
#  fisherg_p_value       :float
#  fisherg_q_value       :float
#  fisherg_period_length :float
#  assay_name            :string(255)
#  probeset_name         :string(255)
#  jtk_p_value           :float
#  jtk_q_value           :float
#  jtk_period_length     :float
#  jtk_lag               :float
#  jtk_amp               :float
#

