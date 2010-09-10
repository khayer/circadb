# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100819183627) do

  create_table "assays", :force => true do |t|
    t.string "slug"
    t.string "name"
    t.string "description"
  end

  add_index "assays", ["slug"], :name => "index_assays_on_slug", :unique => true

  create_table "gene_chips", :force => true do |t|
    t.string "slug"
    t.string "name"
  end

  add_index "gene_chips", ["slug"], :name => "index_gene_chips_on_slug", :unique => true

  create_table "probeset_datas", :force => true do |t|
    t.integer "assay_id"
    t.integer "probeset_id"
    t.string  "assay_name"
    t.string  "probeset_name"
    t.string  "time_points",    :limit => 1000
    t.string  "data_points",    :limit => 1000
    t.string  "chart_url_base", :limit => 2000
  end

  add_index "probeset_datas", ["assay_id"], :name => "index_probeset_datas_on_assay_id"
  add_index "probeset_datas", ["assay_name"], :name => "index_probeset_datas_on_assay_name"
  add_index "probeset_datas", ["probeset_id"], :name => "index_probeset_datas_on_probeset_id"
  add_index "probeset_datas", ["probeset_name"], :name => "index_probeset_datas_on_probeset_name"

  create_table "probeset_stats", :force => true do |t|
    t.integer "assay_id"
    t.integer "probeset_id"
    t.integer "probeset_data_id"
    t.float   "cosopt_p_value"
    t.float   "cosopt_q_value"
    t.float   "cosopt_period_length"
    t.float   "cosopt_phase"
    t.float   "fisherg_p_value"
    t.float   "fisherg_q_value"
    t.float   "fisherg_period_length"
    t.string  "assay_name"
    t.string  "probeset_name"
    t.float   "jtk_p_value"
    t.float   "jtk_q_value"
    t.float   "jtk_period_length"
    t.float   "jtk_lag"
    t.float   "jtk_amp"
  end

  add_index "probeset_stats", ["assay_id"], :name => "index_probeset_stats_on_assay_id"
  add_index "probeset_stats", ["assay_name"], :name => "index_probeset_stats_on_assay_name"
  add_index "probeset_stats", ["cosopt_p_value"], :name => "index_probeset_stats_on_cosopt_p_value"
  add_index "probeset_stats", ["cosopt_q_value"], :name => "index_probeset_stats_on_cosopt_q_value"
  add_index "probeset_stats", ["fisherg_p_value"], :name => "index_probeset_stats_on_fisherg_p_value"
  add_index "probeset_stats", ["fisherg_q_value"], :name => "index_probeset_stats_on_fisherg_q_value"
  add_index "probeset_stats", ["jtk_p_value"], :name => "index_probeset_stats_on_jtk_p_value"
  add_index "probeset_stats", ["jtk_q_value"], :name => "index_probeset_stats_on_jtk_q_value"
  add_index "probeset_stats", ["probeset_data_id"], :name => "index_probeset_stats_on_probeset_data_id"
  add_index "probeset_stats", ["probeset_id"], :name => "index_probeset_stats_on_probeset_id"
  add_index "probeset_stats", ["probeset_name"], :name => "index_probeset_stats_on_probeset_name"

  create_table "probesets", :force => true do |t|
    t.integer "gene_chip_id"
    t.string  "probeset_name"
    t.string  "genechip_name"
    t.string  "species"
    t.string  "annotation_date"
    t.string  "sequence_type"
    t.string  "sequence_source"
    t.string  "transcript_id"
    t.text    "target_description"
    t.string  "representative_public_id"
    t.string  "archival_unigene_cluster"
    t.string  "unigene_id"
    t.string  "genome_version"
    t.text    "alignments"
    t.text    "gene_title"
    t.string  "gene_symbol"
    t.string  "chromosomal_location"
    t.string  "unigene_cluster_type"
    t.string  "ensembl"
    t.string  "entrez_gene"
    t.string  "swissprot"
    t.string  "ec"
    t.string  "omim"
    t.string  "refseq_protein_id"
    t.string  "refseq_transcript_id"
    t.string  "flybase"
    t.string  "agi"
    t.string  "wormbase"
    t.string  "mgi_name"
    t.string  "rgd_name"
    t.string  "sgd_accession_number"
    t.text    "go_biological_process"
    t.text    "go_cellular_component"
    t.text    "go_molecular_function"
    t.string  "pathway"
    t.string  "interpro"
    t.text    "trans_membrane"
    t.string  "qtl"
    t.text    "annotation_description"
    t.text    "annotation_transcript_cluster"
    t.string  "transcript_assignments"
    t.text    "annotation_notes"
  end

  add_index "probesets", ["gene_chip_id", "probeset_name"], :name => "index_probesets_on_gene_chip_id_and_probeset_name", :unique => true
  add_index "probesets", ["gene_symbol"], :name => "index_probesets_on_gene_symbol"
  add_index "probesets", ["probeset_name"], :name => "index_probesets_on_probeset_name"
  add_index "probesets", ["refseq_protein_id"], :name => "index_probesets_on_refseq_protein_id"
  add_index "probesets", ["refseq_transcript_id"], :name => "index_probesets_on_refseq_transcript_id"
  add_index "probesets", ["transcript_id"], :name => "index_probesets_on_transcript_id"
  add_index "probesets", ["unigene_id"], :name => "index_probesets_on_unigene_id"

end
