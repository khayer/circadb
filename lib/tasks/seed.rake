desc "Bootstrap a site from the web"
namespace :bootstrap do
  desc "Resets the database"
  task :resetdb => ["db:drop", "db:create", "db:migrate"]

  desc "Download DB data from AWS"
  task :download_db => :environment do
    require 'net/http'
    unless File.exists? "#{Rails.root}/circadb.mysql.dmp"
      uri = URI('http://s3.amazonaws.com/itmat.circadb/circadb.mysql.dmp.gz')
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri.request_uri

        http.request request do |response|
          open "#{Rails.root}/circadb.mysql.dmp.gz", 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
      system("gunzip circadb.mysql.dmp.gz")
    end
  end
  desc "insert DB data from downloaded MySQL dump"
  task :insert_data => :environment do
    unless File.exists? "#{Rails.root}/circadb.mysql.dmp"
      puts "Need to download data first, use \"rake bootstrap:download_db\" task"
      exit(0)
    end
    cfg = ActiveRecord::Base.configurations[Rails.env]
    system("mysql -u #{cfg["username"]} #{ cfg["password"] ? "-p" + cfg["password"] : "" } " +
           " #{ "-h " + cfg["host"] if cfg["host"] } #{cfg["database"]} < circadb.mysql.dmp")
  end

  desc "Build the sphinx index"
  task :build_sphinx => ["ts:stop", "ts:config", "ts:rebuild", "ts:start"]

  desc "Bootstrap the system"
  task :all => [:resetdb, :download_db, :insert_data, :build_sphinx]
end



######
     #
######


desc "Seed database using raw data"
namespace :seed do
  require "ar-extensions"
  require "fastercsv"

  task :genechips => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from gene_chips"

    g  = GeneChip.new(:slug => "Mouse_1.OST", :name => "Affymetrix for GeneChip MoGene-1_0-st-v1.na32.mm9 transcript (Affymetrix)")
    g.save
    g  = GeneChip.new(:slug => "Mouse430_2", :name => "Mouse Genome 430 2.0 (Affymetrix)")
    g.save
    g  = GeneChip.new(:slug => "GNF1M", :name => "Mouse GNF1M (GNF)")
    g.save
    g  = GeneChip.new(:slug => "U74Av1", :name => "Affymetrix GeneChip Mouse Genome U74A-B-C_2 (Affymetrix)")
    g.save
    g  = GeneChip.new(:slug => "HuGene1_0", :name => "Affymetrix for GeneChip HuGene-1_0 transcript (Affymetrix)")
    g.save
  end

  desc "Seed probeset annotations"
  task :u74av1_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?","U74Av1"])
    count = 0
    buffer = []
    puts "=== Begin u74av1 Probeset insert ==="
    FasterCSV.foreach("#{RAILS_ROOT}/seed_data/prepared_MG_U74Av2.na31.annot.csv", :headers=> true ) do |ps|
      count += 1
      buffer << [g.id] + ps.values_at
      if count % 1000 == 0
        Probeset.import(fields,buffer)
        buffer = []
        puts count
      end
    end
    Probeset.import(fields,buffer)
    puts count
    puts "=== End u74av1 Probeset insert ==="
  end


  desc "Seed probeset annotations"
  task :mouse430_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    count = 0
    buffer = []
    puts "=== Begin Mouse430_2 Probeset insert ==="
    FasterCSV.foreach("#{RAILS_ROOT}/seed_data/prepared_Mouse430_2.na28.annot.csv" ) do |ps|
      count += 1
      buffer << [g.id] + ps[0..-1]

      if count % 1000 == 0
        Probeset.import(fields,buffer)
        buffer = []
        puts count
      end
    end
    Probeset.import(fields,buffer)
    puts count
    puts "=== End Mouse430_2 Probeset insert ==="
  end

  desc "Seed gnf annotations"
  task :gnf1m_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?", "GNF1M"])
    count = 0
    buffer = []
    puts "=== Begin GNF1M Probeset insert ==="
    FasterCSV.foreach("#{RAILS_ROOT}/seed_data/prepared_gnf1m.annot2007.csv", :headers=> true ) do |ps|
      count += 1
      buffer << [g.id] + ps.values_at
      if count % 1000 == 0
        Probeset.import(fields,buffer)
        buffer = []
        puts count
      end
    end
    Probeset.import(fields,buffer)
    puts count
    puts "=== End GNF1M Probeset insert ==="
  end

  desc "Seed HuGene annotations"
  task :hugene_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?", "HuGene1_0"])
    count = 0
    buffer = []
    puts "=== Begin HuGene1_0 Probeset insert ==="
    FasterCSV.foreach("#{RAILS_ROOT}/seed_data/prepared_HuGene-1_0-st-v1.na32.hg19.transcript.csv", :headers=> true ) do |ps|
      count += 1
      buffer << [g.id] + ps.values_at
      if count % 1000 == 0
        Probeset.import(fields,buffer)
        buffer = []
        puts count
      end
    end
    Probeset.import(fields,buffer)
    puts count
    puts "=== End HuGene1_0 Probeset insert ==="
  end

  desc "Seed MoGene annotations"
  task :mogene_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?", "Mouse_1.OST"])
    count = 0
    buffer = []
    puts "=== Begin Mouse_1.OST Probeset insert ==="
    FasterCSV.foreach("#{RAILS_ROOT}/seed_data/prepared_MoGene-1_0-st-v1.na32.mm9.transcript.csv", :headers=> true ) do |ps|
      count += 1
      buffer << [g.id] + ps.values_at
      if count % 1000 == 0
        Probeset.import(fields,buffer)
        buffer = []
        puts count
      end
    end
    Probeset.import(fields,buffer)
    puts count
    puts "=== End Mouse_1.OST  Probeset insert ==="
  end


  desc "Seed assays"
  task :assays => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from assays"
    f = %w{ slug name description }
    affy_id = GeneChip.find(:first,:conditions => ["slug like ?","Mouse430_2"]).id
    gnf_id = GeneChip.find(:first, :conditions => ["slug like ?","GNF1M"]).id
    u74av1_id = GeneChip.find(:first, :conditions => ["slug like ?","U74Av1"]).id
    hugene_id = GeneChip.find(:first, :conditions => ["slug like ?","HuGene1_0"]).id
    mogene_id = GeneChip.find(:first, :conditions => ["slug like ?","Mouse_1.OST"]).id

    v = [["adrenal_gland","Mouse 1.OST Adrenal Gland (Affymetrix)", mogene_id],
         ["aorta","Mouse 1.OST Aorta (Affymetrix)", mogene_id],
         ["brown_adipose","Mouse 1.OST Brown Adipose (Affymetrix)", mogene_id],
         ["brain_stem","Mouse 1.OST Brain Stem (Affymetrix)", mogene_id],
         ["cerebellum","Mouse 1.OST Cerebellum (Affymetrix)", mogene_id],
         ["heart","Mouse 1.OST Heart (Affymetrix)", mogene_id],
         ["hypothalamus","Mouse 1.OST Hypothalamus (Affymetrix)", mogene_id],
         ["kidney","Mouse 1.OST Kidney (Affymetrix)", mogene_id],
         ["mogene_liver","Mouse 1.OST Liver (Affymetrix)", mogene_id],
         ["lung","Mouse 1.OST Lung (Affymetrix)", mogene_id],
         ["skeletal_muscle","Mouse 1.OST Skeletal Muscle (Affymetrix)", mogene_id],
         ["white_adipose","Mouse 1.OST White Adipose (Affymetrix)", mogene_id],
         ["liver","Mouse Liver 48 hour Hughes 2009 (Affymetrix)", affy_id],
         ["pituitary","Mouse Pituitary 48 hour Hughes 2009 (Affymetrix)",affy_id],
         ["NIH3T3","Mouse NIH 3T3 Immortilized Cell Line 48 hour Hughes 2009 (Affymetrix)",affy_id],
         ["U2OS","Human U2 OS Hughes 2009 (Affymetrix)", hugene_id],
         ["WT_liver","Mouse Wild Type Liver (GNF microarray)", gnf_id],
         ["WT_muscle","Mouse Wild Type Muscle (GNF microarray)",gnf_id],
         ["WT_SCN","Mouse Wild Type SCN (GNF microarray)", gnf_id],
         ["panda_liver","Mouse Liver Panda 2002 (Affymetrix)",u74av1_id],
         ["panda_SCN_MAS4","Mouse SCN MAS4 Panda 2002 (Affymetrix)", u74av1_id],
         ["panda_SCN_gcrma","Mouse SCN gcrma Panda 2002 (Affymetrix)", u74av1_id]]

         # adrenal_gland aorta brown_adipose brain_stem cerebellum heart hypothalamus kidney mogene_liver lung skeletal_muscle white_adipose

    #Adr Aorta BFAT BS Heart Kidney Mus WFAT
    #v = []
    Assay.import(f,v)
    puts "=== 18 Assay inserted ==="

  end

  ########### MY CHANGES ##########
  task :datas => :environment do
    ## OK start the imports
    puts "=== Raw Data insert starting ==="
    # fields = %w{ assay_id assay_name probeset_name time_points data_points chart_url_base }
    fields = %w{ assay_id assay_name probeset_id probeset_name time_points data_points chart_url_base }

    # Hughes 2009
    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    %w{ liver pituitary NIH3T3 }.each do |etype|
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Raw Data #{etype} insert starting ==="

      File.open("#{RAILS_ROOT}/seed_data/hughes_#{etype}_data","r" ).each do |line|
        count += 1
        line = line.split("@")
        time_points = line[1].split(",").map {|element| element}
        data_points = line[2].split(",").map {|element| element}
        cubase = line[3]
        psid = probesets[line[0]]
        buffer << [a.id(), a.slug, psid, line[0], time_points.to_json, data_points.to_json,cubase]

        if count % 1000 == 0
          ProbesetData.import(fields,buffer)
          puts count
          buffer = []
        end
      end
      ProbesetData.import(fields,buffer)
      puts "=== Raw Data #{etype} end (count= #{count}) ==="
    end

    # Panda 2002
    g  = GeneChip.find(:first, :conditions => ["slug like ?","U74Av1"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    %w{ panda_liver panda_SCN_gcrma panda_SCN_MAS4 }.each do |etype|
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Raw Data #{etype} insert starting ==="

      File.open("#{RAILS_ROOT}/seed_data/#{etype}_data","r" ).each do |line|
        count += 1
        line = line.split("@")
        time_points = line[1].split(",").map {|element| element}
        data_points = line[2].split(",").map {|element| element}
        cubase = line[3]
        psid = probesets[line[0]]
        buffer << [a.id(), a.slug, psid, line[0], time_points.to_json, data_points.to_json,cubase]

        if count % 1000 == 0
          ProbesetData.import(fields,buffer)
          puts count
          buffer = []
        end
      end
      ProbesetData.import(fields,buffer)
      puts "=== Raw Data #{etype} end (count= #{count}) ==="
    end

    # GNF1M
    g  = GeneChip.find(:first, :conditions => ["slug like ?","GNF1M"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    %w{ WT_liver WT_muscle WT_SCN }.each do |etype|
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Raw Data #{etype} insert starting ==="

      File.open("#{RAILS_ROOT}/seed_data/#{etype}_data","r" ).each do |line|
        count += 1
        line = line.split("@")
        time_points = line[1].split(",").map {|element| element}
        data_points = line[2].split(",").map {|element| element}
        cubase = line[3]
        psid = probesets[line[0]]
        buffer << [a.id(), a.slug, psid, line[0], time_points.to_json, data_points.to_json,cubase]

        if count % 1000 == 0
          ProbesetData.import(fields,buffer)
          puts count
          buffer = []
        end
      end
      ProbesetData.import(fields,buffer)
      puts "=== Raw Data #{etype} end (count= #{count}) ==="
    end

    g  = GeneChip.find(:first, :conditions => ["slug like ?","HuGene1_0"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    buffer = []
    ProbesetData.import(fields,buffer)


    %w{ U2OS }.each do |etype|
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Raw Data #{etype} insert starting ==="

      File.open("#{RAILS_ROOT}/seed_data/hughes_#{etype}_data","r" ).each do |line|
        count += 1
        line = line.split("@")
        time_points = line[1].split(",").map {|element| element}
        data_points = line[2].split(",").map {|element| element}
        cubase = line[3]
        psid = probesets[line[0]]
        buffer << [a.id(), a.slug, psid, line[0], time_points.to_json, data_points.to_json,cubase]

        if count % 1000 == 0
          ProbesetData.import(fields,buffer)
          puts count
          buffer = []
        end
      end
      ProbesetData.import(fields,buffer)
      puts "=== Raw Data #{etype} end (count= #{count}) ==="
    end

    # Mouse_1.OST
    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse_1.OST"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end


    buffer = []
    ProbesetData.import(fields,buffer)
    #puts "=== Raw Data U2OS cells insert ended (count= #{count}) ==="

    %w{ adrenal_gland aorta brown_adipose brain_stem cerebellum heart hypothalamus kidney mogene_liver lung skeletal_muscle white_adipose }.each do |etype|
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Raw Data #{etype} insert starting ==="

      File.open("#{RAILS_ROOT}/seed_data/mogene_#{etype}_data","r" ).each do |line|
        count += 1
        line = line.split("@")
        time_points = line[1].split(",").map {|element| element}
        data_points = line[2].split(",").map {|element| element}
        cubase = line[3]
        psid = probesets[line[0]]
        buffer << [a.id(), a.slug, psid, line[0], time_points.to_json, data_points.to_json,cubase]

        if count % 1000 == 0
          ProbesetData.import(fields,buffer)
          puts count
          buffer = []
        end
      end
      ProbesetData.import(fields,buffer)
      puts "=== Raw Data MoGene #{etype} end (count= #{count}) ==="
    end


    buffer = []
    ProbesetData.import(fields,buffer)

    puts "=== Raw Data insert ended ==="
  end

  task :stats => :environment do
    puts "=== Stat Data insert starting ==="

    fields = %w{  assay_id assay_name probeset_id probeset_data_id probeset_name cosopt_p_value cosopt_q_value cosopt_period_length cosopt_phase fisherg_p_value fisherg_q_value fisherg_period_length jtk_p_value jtk_q_value jtk_period_length jtk_lag jtk_amp}
    # liver and pituitary

    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    probesets = {}

    g.probesets.each do |p|
      p.probeset_name
      probesets[p.probeset_name]= p.id
    end

    %w{ liver pituitary NIH3T3 }.each do |etype|
      #liver
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Stat Data #{etype} start ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/hughes_#{etype}_stats") do |row|
        count += 1
        aslug, psname = 0,row[0].to_i
        psid = probesets[row[0]]
        buffer << [a.id, a.slug,psid, psid, psname] + row[1..-1].to_a
        if count % 1000 == 0
          ProbesetStat.import(fields,buffer)
          buffer = []
          puts count
        end
      end
      ProbesetStat.import(fields,buffer)
      puts "=== Stat Data #{etype} end (count = #{count}) ==="
    end


    # GNF1M
    g  = GeneChip.find(:first, :conditions => ["slug like ?","GNF1M"])
    probesets = {}

    g.probesets.each do |p|
      p.probeset_name
      probesets[p.probeset_name]= p.id
    end

    %w{ WT_liver WT_SCN WT_muscle }.each do |etype|
      #liver
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Stat Data #{etype} start ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/#{etype}_stats") do |row|
        count += 1
        aslug, psname = 0,row[0].to_i
        psid = probesets[row[0]]
        buffer << [a.id, a.slug,psid, psid, psname] + row[1..-1].to_a
        if count % 1000 == 0
          ProbesetStat.import(fields,buffer)
          buffer = []
          puts count
        end
      end
      ProbesetStat.import(fields,buffer)
      puts "=== Stat Data #{etype} end (count = #{count}) ==="
    end

    # Panda 2002
    g  = GeneChip.find(:first, :conditions => ["slug like ?","U74Av1"])
    probesets = {}

    g.probesets.each do |p|
      p.probeset_name
      probesets[p.probeset_name]= p.id
    end

    %w{ panda_liver panda_SCN_gcrma panda_SCN_MAS4 }.each do |etype|
      #liver
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Stat Data #{etype} start ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/#{etype}_stats") do |row|
        count += 1
        aslug, psname = 0,row[0].to_i
        psid = probesets[row[0]]
        buffer << [a.id, a.slug,psid, psid, psname] + row[1..-1].to_a
        if count % 1000 == 0
          ProbesetStat.import(fields,buffer)
          buffer = []
          puts count
        end
      end
      ProbesetStat.import(fields,buffer)
      puts "=== Stat Data #{etype} end (count = #{count}) ==="
    end

    g  = GeneChip.find(:first, :conditions => ["slug like ?","HuGene1_0"])
    probesets = {}

    g.probesets.each do |p|
      p.probeset_name
      probesets[p.probeset_name]= p.id
    end

    %w{ U2OS }.each do |etype|
      #liver
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Stat Data #{etype} start ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/hughes_#{etype}_stats") do |row|
        count += 1
        aslug, psname = 0,row[0].to_i
        psid = probesets[row[0]]
        buffer << [a.id, a.slug,psid, psid, psname] + row[1..-1].to_a
        if count % 1000 == 0
          ProbesetStat.import(fields,buffer)
          buffer = []
          puts count
        end
      end
      ProbesetStat.import(fields,buffer)
      puts "=== Stat Data #{etype} end (count = #{count}) ==="
    end

    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse_1.OST"])
    probesets = {}

    g.probesets.each do |p|
      p.probeset_name
      probesets[p.probeset_name]= p.id
    end

    %w{ adrenal_gland aorta brown_adipose brain_stem cerebellum heart hypothalamus kidney mogene_liver lung skeletal_muscle white_adipose }.each do |etype|
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Stat Data mogene #{etype} start ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/mogene_#{etype}_stats") do |row|
        count += 1
        aslug, psname = 0,row[0].to_i
        psid = probesets[row[0]]
        buffer << [a.id, a.slug,psid, psid, psname] + row[1..-1].to_a
        if count % 1000 == 0
          ProbesetStat.import(fields,buffer)
          buffer = []
          puts count
        end
      end
      ProbesetStat.import(fields,buffer)
      puts "=== Stat Data mogene #{etype} end (count = #{count}) ==="
    end

    puts "=== Stat Data END ==="
  end

  desc "Backfills in references for FKs to probeset_stats to probeset_datas."
  task :refbackfill =>  :environment do
    puts "=== Back filling FK probeset_stats.probset_data_id  ==="
    c = ActiveRecord::Base.connection
    c.execute "update probeset_stats s set s.probeset_data_id = (select d.id from probeset_datas d where d.probeset_id = s.probeset_id and d.assay_id = s.assay_id limit 1)"
  end

  desc "Loads all seed data into the DB"
  task :all => [:delete_from_all, :genechips, :mouse430_probesets, :gnf1m_probesets, :u74av1_probesets,
    :assays, :datas, :stats, :clock_mutant_stats, :refbackfill] do
  end

  task :delete_from_data => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from probeset_datas"
  end

  task :delete_from_probesets => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from probesets"
    puts "=== delete_from_probesets done!"
  end

  task :delete_from_stats => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from probeset_stats"
  end

  desc "Warning: Deletes all content"
  task :delete_from_all => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from gene_chips"
    c.execute "delete from assays"
    c.execute "delete from probesets"
    c.execute "delete from probeset_stats"
    c.execute "delete from probeset_datas"
    puts "=== delete_from_all done!"
  end

  desc "Build the sphinx index"
  task :build_sphinx => ["ts:stop", "ts:config", "ts:rebuild", "ts:start"]

  desc "Fill database from scratch"
  task :fill => [:delete_from_all, :genechips,
    :mouse430_probesets, :u74av1_probesets, :gnf1m_probesets, :hugene_probesets,
    :mogene_probesets, :assays, :datas, :stats, :refbackfill, :build_sphinx]

  desc "Refill Probesets"
  task :refill_probesets => [:delete_from_probesets, :mouse430_probesets,
    :u74av1_probesets, :gnf1m_probesets, :hugene_probesets, :mogene_probesets,
    :build_sphinx]

  desc "Reset the source data"
  task :reset_data => [:delete_from_data, :assays, :datas, :refbackfill,
    :build_sphinx] do
  end

  desc "Reset the source stats"
  task :reset_stats => [:delete_from_stats,  :stats, :refbackfill,
    :build_sphinx] do
  end

  desc "Reset assays and genechips"
  task :reset_assays => [:assays, :genechips, :refbackfill,
    :build_sphinx] do
  end



end
