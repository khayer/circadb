# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20101111205706) do

  create_table "assays", force: :cascade do |t|
    t.string  "slug",         limit: 255
    t.string  "name",         limit: 255
    t.string  "description",  limit: 255
    t.integer "gene_chip_id", limit: 4
  end

  add_index "assays", ["gene_chip_id"], name: "index_assays_on_gene_chip_id", using: :btree
  add_index "assays", ["slug"], name: "index_assays_on_slug", unique: true, using: :btree

  create_table "gene_chips", force: :cascade do |t|
    t.string "slug", limit: 255
    t.string "name", limit: 255
  end

  add_index "gene_chips", ["slug"], name: "index_gene_chips_on_slug", unique: true, using: :btree

  create_table "probeset_datas", force: :cascade do |t|
    t.integer "assay_id",       limit: 4
    t.integer "probeset_id",    limit: 4
    t.string  "assay_name",     limit: 255
    t.string  "probeset_name",  limit: 255
    t.string  "time_points",    limit: 1000
    t.string  "data_points",    limit: 1000
    t.string  "chart_url_base", limit: 2000
  end

  add_index "probeset_datas", ["assay_id"], name: "index_probeset_datas_on_assay_id", using: :btree
  add_index "probeset_datas", ["assay_name"], name: "index_probeset_datas_on_assay_name", using: :btree
  add_index "probeset_datas", ["probeset_id"], name: "index_probeset_datas_on_probeset_id", using: :btree
  add_index "probeset_datas", ["probeset_name"], name: "index_probeset_datas_on_probeset_name", using: :btree

  create_table "probeset_stats", force: :cascade do |t|
    t.integer "assay_id",              limit: 4
    t.integer "probeset_id",           limit: 4
    t.integer "probeset_data_id",      limit: 4
    t.float   "cosopt_p_value",        limit: 24
    t.float   "cosopt_q_value",        limit: 24
    t.float   "cosopt_period_length",  limit: 24
    t.float   "cosopt_phase",          limit: 24
    t.float   "fisherg_p_value",       limit: 24
    t.float   "fisherg_q_value",       limit: 24
    t.float   "fisherg_period_length", limit: 24
    t.string  "assay_name",            limit: 255
    t.string  "probeset_name",         limit: 255
    t.float   "jtk_p_value",           limit: 24
    t.float   "jtk_q_value",           limit: 24
    t.float   "jtk_period_length",     limit: 24
    t.float   "jtk_lag",               limit: 24
    t.float   "jtk_amp",               limit: 24
  end

  add_index "probeset_stats", ["assay_id"], name: "index_probeset_stats_on_assay_id", using: :btree
  add_index "probeset_stats", ["assay_name"], name: "index_probeset_stats_on_assay_name", using: :btree
  add_index "probeset_stats", ["cosopt_p_value"], name: "index_probeset_stats_on_cosopt_p_value", using: :btree
  add_index "probeset_stats", ["cosopt_q_value"], name: "index_probeset_stats_on_cosopt_q_value", using: :btree
  add_index "probeset_stats", ["fisherg_p_value"], name: "index_probeset_stats_on_fisherg_p_value", using: :btree
  add_index "probeset_stats", ["fisherg_q_value"], name: "index_probeset_stats_on_fisherg_q_value", using: :btree
  add_index "probeset_stats", ["jtk_p_value"], name: "index_probeset_stats_on_jtk_p_value", using: :btree
  add_index "probeset_stats", ["jtk_q_value"], name: "index_probeset_stats_on_jtk_q_value", using: :btree
  add_index "probeset_stats", ["probeset_data_id"], name: "index_probeset_stats_on_probeset_data_id", using: :btree
  add_index "probeset_stats", ["probeset_id"], name: "index_probeset_stats_on_probeset_id", using: :btree
  add_index "probeset_stats", ["probeset_name"], name: "index_probeset_stats_on_probeset_name", using: :btree

  create_table "probesets", force: :cascade do |t|
    t.integer "gene_chip_id",                  limit: 4
    t.string  "probeset_name",                 limit: 255
    t.string  "genechip_name",                 limit: 255
    t.string  "species",                       limit: 255
    t.string  "annotation_date",               limit: 255
    t.string  "sequence_type",                 limit: 255
    t.string  "sequence_source",               limit: 255
    t.string  "transcript_id",                 limit: 255
    t.text    "target_description",            limit: 65535
    t.string  "representative_public_id",      limit: 255
    t.string  "archival_unigene_cluster",      limit: 255
    t.string  "unigene_id",                    limit: 255
    t.string  "genome_version",                limit: 255
    t.text    "alignments",                    limit: 65535
    t.text    "gene_title",                    limit: 65535
    t.string  "gene_symbol",                   limit: 255
    t.string  "chromosomal_location",          limit: 255
    t.string  "unigene_cluster_type",          limit: 255
    t.string  "ensembl",                       limit: 255
    t.string  "entrez_gene",                   limit: 255
    t.string  "swissprot",                     limit: 255
    t.string  "ec",                            limit: 255
    t.string  "omim",                          limit: 255
    t.string  "refseq_protein_id",             limit: 255
    t.string  "refseq_transcript_id",          limit: 255
    t.string  "flybase",                       limit: 255
    t.string  "agi",                           limit: 255
    t.string  "wormbase",                      limit: 255
    t.string  "mgi_name",                      limit: 255
    t.string  "rgd_name",                      limit: 255
    t.string  "sgd_accession_number",          limit: 255
    t.text    "go_biological_process",         limit: 65535
    t.text    "go_cellular_component",         limit: 65535
    t.text    "go_molecular_function",         limit: 65535
    t.string  "pathway",                       limit: 255
    t.string  "interpro",                      limit: 255
    t.text    "trans_membrane",                limit: 65535
    t.string  "qtl",                           limit: 255
    t.text    "annotation_description",        limit: 65535
    t.text    "annotation_transcript_cluster", limit: 65535
    t.string  "transcript_assignments",        limit: 255
    t.text    "annotation_notes",              limit: 65535
  end

  add_index "probesets", ["gene_chip_id", "probeset_name"], name: "index_probesets_on_gene_chip_id_and_probeset_name", unique: true, using: :btree
  add_index "probesets", ["gene_symbol"], name: "index_probesets_on_gene_symbol", using: :btree
  add_index "probesets", ["probeset_name"], name: "index_probesets_on_probeset_name", using: :btree
  add_index "probesets", ["refseq_protein_id"], name: "index_probesets_on_refseq_protein_id", using: :btree
  add_index "probesets", ["refseq_transcript_id"], name: "index_probesets_on_refseq_transcript_id", using: :btree
  add_index "probesets", ["transcript_id"], name: "index_probesets_on_transcript_id", using: :btree
  add_index "probesets", ["unigene_id"], name: "index_probesets_on_unigene_id", using: :btree

end
