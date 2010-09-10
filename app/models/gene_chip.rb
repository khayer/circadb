class GeneChip < ActiveRecord::Base
  has_many :probesets
end


# == Schema Information
#
# Table name: gene_chips
#
#  id   :integer(4)      not null, primary key
#  slug :string(255)
#  name :string(255)
#

