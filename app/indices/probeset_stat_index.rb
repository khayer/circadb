ThinkingSphinx::Index.define :probeset_stat, :with => :active_record do
  indexes probeset.probeset_name, :as => :probeset_name


  has assay_id, cosopt_p_value, cosopt_q_value, cosopt_period_length,
    cosopt_phase, fisherg_p_value, fisherg_q_value, fisherg_period_length,
    jtk_p_value, jtk_q_value, jtk_period_length, jtk_lag, jtk_amp
end



#define_index do
  #  %w{probeset_name
  #    transcript_id
  #    representative_public_id
  #    unigene_id
  #    gene_symbol
  #    gene_title
  #    entrez_gene
  #    swissprot
  #    refseq_protein_id
  #    refseq_transcript_id
  #    target_description}.map do |m|
  #      eval <<-EOF
  #      indexes probeset.#{m}, :as => :#{m}
  #      EOF
  #  end
  #  # define filter attributes
  #  has assay_id, cosopt_p_value, cosopt_q_value, cosopt_period_length,
  #    cosopt_phase, fisherg_p_value, fisherg_q_value, fisherg_period_length,
  #    jtk_p_value, jtk_q_value, jtk_period_length, jtk_lag, jtk_amp
  #end