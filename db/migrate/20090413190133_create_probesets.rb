class CreateProbesets < ActiveRecord::Migration
  def self.up
    create_table :probesets do |t|
      t.integer :gene_chip_id
      t.string :probeset_name
      t.string :genechip_name
      t.string :species
      t.string :annotation_date
      t.string :sequence_type
      t.string :sequence_source
      t.string :transcript_id
      t.text :target_description
      t.string :representative_public_id
      t.string :archival_unigene_cluster
      t.string :unigene_id
      t.string :genome_version
      t.text :alignments
      t.text :gene_title
      t.string :gene_symbol
      t.string :chromosomal_location
      t.string :unigene_cluster_type
      t.string :ensembl
      t.string :entrez_gene
      t.string :swissprot
      t.string :ec
      t.string :omim
      t.string :refseq_protein_id
      t.string :refseq_transcript_id
      t.string :flybase
      t.string :agi
      t.string :wormbase
      t.string :mgi_name
      t.string :rgd_name
      t.string :sgd_accession_number
      t.text :go_biological_process
      t.text :go_cellular_component
      t.text :go_molecular_function
      t.string :pathway
      t.string :interpro
      t.text :trans_membrane
      t.string :qtl
      t.text :annotation_description
      t.text :annotation_transcript_cluster
      t.string :transcript_assignments
      t.text :annotation_notes
    end
    add_index :probesets, [:gene_chip_id, :probeset_name], :unique => true
    add_index :probesets, :probeset_name
    add_index :probesets, :transcript_id
    add_index :probesets, :unigene_id
    add_index :probesets, :gene_symbol
    add_index :probesets, :refseq_protein_id
    add_index :probesets, :refseq_transcript_id
  end

  def self.down
    remove_index :probesets, :column => [:gene_chip_id, :probeset_name]
    remove_index :probesets, :probeset_name
    remove_index :probesets, :transcript_id
    remove_index :probesets, :unigene_id
    remove_index :probesets, :gene_symbol
    remove_index :probesets, :refseq_protein_id
    remove_index :probesets, :refseq_transcript_id
    drop_table :probesets
  end
end

