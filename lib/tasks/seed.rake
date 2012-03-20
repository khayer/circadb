desc "Bootstrap a site from the web"
namespace :bootstrap do
  desc "Resets the database"
  task :resetdb => ["db:drop", "db:create", "db:migrate"]

  desc "Download DB data from AWS"
  task :download_db => :environment do
    unless File.exists? "#{Rails.root}/circadb.mysql.dmp"
      require 'curb'
      Curl::Easy.download("http://s3.amazonaws.com/itmat.circadb/circadb.mysql.dmp.gz", "#{Rails.root}/circadb.mysql.dmp.gz")
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

    g  = GeneChip.new(:slug => "Mouse430_2", :name => "Mouse Genome 430 2.0 (Affymetrix)")
    g.save
    g  = GeneChip.new(:slug => "GNF1M", :name => "Mouse GNF1M (GNF)")
    g.save
    g  = GeneChip.new(:slug => "U74Av1", :name => "Affymetrix GeneChip Mouse Genome U74A-B-C_2 (Affymetrix)")
    g.save
  end

  desc "Seed probeset annotations"
  task :u74av1_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?","U74Av1"])
    count = 0
    buffer = []
    puts "=== Begin Probeset insert ==="
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
    puts "=== End Probeset insert ==="
  end


  desc "Seed probeset annotations"
  task :mouse430_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    count = 0
    buffer = []
    puts "=== Begin Probeset insert ==="
    FasterCSV.foreach("#{RAILS_ROOT}/seed_data/prepared_Mouse430_2.na28.annot.csv", :headers=> true ) do |ps|
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
    puts "=== End Probeset insert ==="
  end

  desc "Seed gnf annotations"
  task :gnf1m_probesets => :environment do
    # probes
    fields = %w{ gene_chip_id probeset_name genechip_name species annotation_date sequence_type sequence_source transcript_id target_description representative_public_id archival_unigene_cluster unigene_id genome_version alignments gene_title gene_symbol chromosomal_location unigene_cluster_type ensembl entrez_gene swissprot ec omim refseq_protein_id refseq_transcript_id flybase agi wormbase mgi_name rgd_name sgd_accession_number go_biological_process go_cellular_component go_molecular_function pathway interpro trans_membrane qtl annotation_description annotation_transcript_cluster transcript_assignments annotation_notes }
    g  = GeneChip.find(:first, :conditions => ["slug like ?", "GNF1M"])
    count = 0
    buffer = []
    puts "=== Begin Probeset insert ==="
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
    puts "=== End Probeset insert ==="
  end

  desc "Seed assays"
  task :assays => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from assays"
    f = %w{ slug name description}
    affy_id = GeneChip.find(:first,:conditions => ["slug like ?","Mouse430_2"]).id
    gnf_id = GeneChip.find(:first, :conditions => ["slug like ?","GNF1M"]).id
    u74av1_id = GeneChip.find(:first, :conditions => ["slug like ?","U74Av1"]).id

    v = [["liver_affy","Mouse Liver 48 hour (Affymetrix)", affy_id],
         ["pituitary_affy","Mouse Pituitary 48 hour (Affymetrix)",affy_id],
         ["3t3_affy","NIH 3T3 Immortilized Cell Line 48 hour (Affymetrix)",affy_id],
         ["liver_gnf","Wild Type + Clock Mutant Liver (GNF microarray)", gnf_id],
         ["muscle_gnf","Wild Type + Clock Mutant Muscle (GNF microarray)",gnf_id],
         ["scn_gnf","Wild Type + Clock Mutant SCN (GNF microarray)", gnf_id],
         ["liver_u74av1","Liver Panda 2002 (Affymetrix)", u74av1_id],
         ["muscle_u74av1","SCN MAS4 Panda 2002 (Affymetrix)", u74av1_id],
         ["scn_u74av1","SCN gcrma Panda 2002 (Affymetrix)", u74av1_id]]

    #v = []
    Assay.import(f,v)
    puts "=== 9 Assay inserted ==="

  end

  desc "Seed raw data"
  task :datas => :environment do
    require 'rsruby'
    ## set up R instance and custom functions
    R = RSRuby.instance()
    R.eval_R("scaleData <- function(d,mx) {
      as.vector(round(scale(d, F, mx) * 100 ))
    }")

    R.eval_R("avgData <- function(d) {
      dd <- filter(d,rep(0.33,3))
      dd[1] <- d[1]
      dd[length(dd)] <- d[length(d)]
      dd
    }")

    ## OK start the imports
    puts "=== Raw Data insert starting ==="
    # fields = %w{ assay_id assay_name probeset_name time_points data_points chart_url_base }
    fields = %w{ assay_id assay_name probeset_id probeset_name time_points data_points chart_url_base }

    # Clockmut_liver and wt_liver cells
    #  x-axis => 0:|18||||||||24||||||||30||||||||36||||||||42||||||||48||||||||54||||||||60|||62|
    #  background fill => chf=c,ls,0,CCCCCC,0.136363636,FFFFFF,0.27272727,CCCCCC,0.27272727,FFFFFF,0.27272727,CCCCCC,0.0454545455

    # build a hash of probeset ids for this genechip for gnf1m
    g  = GeneChip.find(:first, :conditions => ["slug like ?","gnf1m"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    %w{ liver scn muscle }.each do |etype|
      count = 0
      buffer = []
      a_clockmut = Assay.find(:first, :conditions => ["slug = ?", "Clockmut_#{etype}"])
      a_wt = Assay.find(:first, :conditions => ["slug = ?", "WT_#{etype}"])

      puts "=== Raw Data Clockmut_#{etype} and WT_#{etype} cells insert starting ==="
      cmf = FasterCSV.open("#{RAILS_ROOT}/seed_data/Clockmut_#{etype}_data.csv")
      wtf = FasterCSV.open("#{RAILS_ROOT}/seed_data/WT_#{etype}_data.csv")

      cmf.each do |cm|
        wt = wtf.readline
        puts cm
        puts "______________"
        next if cm.include?("Probe set")
        #puts wt[0]
        #puts cm[0]
        #exit(1)
        if (wt[0] != cm[0])
          STDERR.puts "WARNING!!!!! The probesets between Clock mutant & WT #{etype} do not match!"
          STDERR.puts "WARNING!!!!! Clock mutant = #{cm[1]} & WT = #{wt[1]} (line #{cm.lineno}) "
          exit(1)
        end

        tp_clockmut = cm[2].split(/\|/).map {|e| e.to_i }
        puts cm[2]
        puts tp_clockmut
        tp_wt = wt[2].split(/\|/).map {|e| e.to_i }
        puts tp_wt
        dp_clockmut = cm[3].split(/,/).map {|e| e.to_f }
        puts dp_clockmut
        dp_wt = wt[3].split(/,/).map {|e| e.to_f }
        puts dp_wt
        exit
        max = R.max(dp_clockmut, dp_wt).to_i
        min = R.min(dp_clockmut, dp_wt).to_i
        mid = (min + max) / 2
        dp_clockmut_s = R.scaleData(dp_clockmut,max).map {|e| e.to_i }
        dp_wt_s = R.scaleData(dp_wt,max).map {|e| e.to_i }
        # construct the google chart URL base
        cubase = "http://chart.apis.google.com/chart?chs=%sx%s&cht=lxy&chxt=x,y&chxl=0:|18||||||||24||||||||30||||||||36||||||||42||||||||48||||||||54||||||||60|||62|1:|#{min}|#{mid}|#{max}&chxp=1,2,50,97&chxr=0,18,62&chls=2,1,0|2,1,0&chf=c,ls,0,CCCCCC,0.136363636,FFFFFF,0.27272727,CCCCCC,0.27272727,FFFFFF,0.27272727,CCCCCC,0.0454545455&chd=t:9.09,18.18,27.27,36.36,45.45,54.54,63.63|#{dp_clockmut_s.join(",")}|-1|#{dp_wt_s.join(",")}&chm=d,FF0000,0,-1,8|d,0000FF,1,-1,8&chco=FF9900,008000&chdl=Clock_mutant|WT&chdlp=rs"
        psid = probesets[wt[1]]
        buffer << [a_clockmut.id, a_clockmut.slug, psid, cm[1], tp_clockmut.to_json, dp_clockmut.to_json, cubase]
        buffer << [a_wt.id, a_wt.slug, psid, wt[1], tp_wt.to_json, dp_wt.to_json, cubase]
        if count % 500 == 0
          ProbesetData.import(fields, buffer)
          puts count
          buffer = []
        end
        count += 1
      end
      ProbesetData.import(fields, buffer)
      buffer = []
      puts "=== Raw Data Clockmut_liver and WT_liver cells insert ended (count = #{count}) ==="
    end


    # LIVER + PITUATARY
    #  x-axis label => 0:|18||||||24||||||30||||||36||||||42||||||48||||||54||||||60|||||65||
    # x-axis range => chxr=0,18,66
    #  background fill => chf=c,ls,0,CCCCCC,0.125,FFFFFF,0.25,CCCCCC,0.25,FFFFFF,0.25,CCCCCC,0.125
    # build a hash of probeset ids for this genechip for Mouse430_2
    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    %w{ liver pituitary }.each do |etype|
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Raw Data #{etype} insert starting ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/#{etype}_data.csv" ) do |psd|
        count += 1
        tp = psd[2].split(/\|/).map {|e| e.to_i }
        dp = psd[3].split(/,/).map {|e| e.to_f }
        dp_min = R.min(dp).to_i
        dp_max = R.max(dp).to_i
        dp_mid = R.mean(dp).to_i
        dp_s = R.scaleData(dp,dp_max).map {|e| e.to_i}
        dp_a = R.avgData(dp_s).map {|e| e.to_i}
        cubase = "http://chart.apis.google.com/chart?chs=%sx%s&cht=lc&chxt=x,y&chxl=0:|18||||||24||||||30||||||36||||||42||||||48||||||54||||||60|||||65||1:|#{dp_min}|#{dp_mid}|#{dp_max}|&chxp=1,2,50,97&chxr=0,18,66&chls=0,0,0|2,1,0&chf=c,ls,0,CCCCCC,0.125,FFFFFF,0.25,CCCCCC,0.25,FFFFFF,0.25,CCCCCC,0.125&chd=t:#{dp_s.join(",")}|#{dp_a.join(",")}&chm=o,555555,0,-1,5"
        psid = probesets[psd[1]]
        buffer << [a.id(), a.slug, psid, psd[1], tp.to_json, dp.to_json,cubase]

        if count % 1000 == 0
          ProbesetData.import(fields,buffer)
          puts count
          buffer = []
        end
      end
      ProbesetData.import(fields,buffer)
      puts "=== Raw Data #{etype} end (count= #{count}) ==="
    end
    # 3T3 cells
    #  x-axis => 0:|20||||24||||||30||||||36||||||42||||||48||||||54||||||60|||||||67||
    #  background fill => chf=c,ls,0,CCCCCC,0.084,FFFFFF,0.25,CCCCCC,0.25,FFFFFF,0.25,CCCCCC,0.165
    count = 0
    buffer = []
    a = Assay.find(:first, :conditions => ["slug = ?", '3t3'])
    puts "=== Raw Data 3T3 cells insert starting ==="
    FasterCSV.foreach("#{RAILS_ROOT}/seed_data/3t3_data.csv" ) do |psd|
      count += 1
      tp = psd[2].split(/\|/).map {|e| e.to_i }
      dp = psd[3].split(/,/).map {|e| e.to_f }
      dp_min = R.min(dp).to_i
      dp_max = R.max(dp).to_i
      dp_mid = R.mean(dp).to_i
      dp_s = R.scaleData(dp,dp_max).map {|e| e.to_i}
      dp_a = R.avgData(dp_s).map {|e| e.to_i}
      cubase = "http://chart.apis.google.com/chart?chs=%sx%s&cht=lc&chxt=x,y&chxl=0:|20||||24||||||30||||||36||||||42||||||48||||||54||||||60|||||||67||1:|#{dp_min}|#{dp_mid}|#{dp_max}|&chxp=1,2,50,97&chxr=0,18,66&chls=0,0,0|2,1,0&chf=c,ls,0,CCCCCC,0.084,FFFFFF,0.25,CCCCCC,0.25,FFFFFF,0.25,CCCCCC,0.165&chd=t:#{dp_s.join(",")}|#{dp_a.join(",")}&chm=o,555555,0,-1,5"
      psid = probesets[psd[1]]
      buffer << [a.id(), a.slug, psid, psd[1], tp.to_json, dp.to_json,cubase]
      if count % 1000 == 0
        ProbesetData.import(fields,buffer)
        puts count
        buffer = []
      end
    end
    ProbesetData.import(fields,buffer)
    puts "=== Raw Data 3T3 cells insert ended (count= #{count}) ==="

    puts "=== Raw Data insert ended ==="
  end

  ########### MY CHANGES ##########
  task :datas2 => :environment do
    ## OK start the imports
    puts "=== Raw Data insert starting ==="
    # fields = %w{ assay_id assay_name probeset_name time_points data_points chart_url_base }
    fields = %w{ assay_id assay_name probeset_id probeset_name time_points data_points chart_url_base }

    # Clockmut_liver and wt_liver cells
    #  x-axis => 0:|18||||||||24||||||||30||||||||36||||||||42||||||||48||||||||54||||||||60|||62|
    #  background fill => chf=c,ls,0,CCCCCC,0.136363636,FFFFFF,0.27272727,CCCCCC,0.27272727,FFFFFF,0.27272727,CCCCCC,0.0454545455

    # build a hash of probeset ids for this genechip for gnf1m
    #g  = GeneChip.find(:first, :conditions => ["slug like ?","gnf1m"])
    #probesets = {}
    #g.probesets.each do |p|
    #  probesets[p.probeset_name]= p.id
    #end
#
    #%w{ liver scn muscle }.each do |etype|
    #  count = 0
    #  buffer = []
    #  a_clockmut = Assay.find(:first, :conditions => ["slug = ?", "Clockmut_#{etype}"])
    #  a_wt = Assay.find(:first, :conditions => ["slug = ?", "WT_#{etype}"])
#
    #  puts "=== Raw Data Clockmut_#{etype} and WT_#{etype} cells insert starting ==="
    #  cmf = FasterCSV.open("#{RAILS_ROOT}/seed_data/Clockmut_#{etype}_data.csv")
    #  wtf = FasterCSV.open("#{RAILS_ROOT}/seed_data/WT_#{etype}_data.csv")
#
    #  cmf.each do |cm|
    #    wt = wtf.readline
    #    puts cm
    #    puts "______________"
    #    next if cm.include?("Probe set")
    #    #puts wt[0]
    #    #puts cm[0]
    #    #exit(1)
    #    if (wt[0] != cm[0])
    #      STDERR.puts "WARNING!!!!! The probesets between Clock mutant & WT #{etype} do not match!"
    #      STDERR.puts "WARNING!!!!! Clock mutant = #{cm[1]} & WT = #{wt[1]} (line #{cm.lineno}) "
    #      exit(1)
    #    end
#
    #    tp_clockmut = cm[2].split(/\|/).map {|e| e.to_i }
    #    puts cm[2]
    #    puts tp_clockmut
    #    tp_wt = wt[2].split(/\|/).map {|e| e.to_i }
    #    puts tp_wt
    #    dp_clockmut = cm[3].split(/,/).map {|e| e.to_f }
    #    puts dp_clockmut
    #    dp_wt = wt[3].split(/,/).map {|e| e.to_f }
    #    puts dp_wt
    #    exit
    #    max = R.max(dp_clockmut, dp_wt).to_i
    #    min = R.min(dp_clockmut, dp_wt).to_i
    #    mid = (min + max) / 2
    #    dp_clockmut_s = R.scaleData(dp_clockmut,max).map {|e| e.to_i }
    #    dp_wt_s = R.scaleData(dp_wt,max).map {|e| e.to_i }
    #    # construct the google chart URL base
    #    cubase = "http://chart.apis.google.com/chart?chs=%sx%s&cht=lxy&chxt=x,y&chxl=0:|18||||||||24||||||||30||||||||36||||||||42||||||||48||||||||54||||||||60|||62|1:|#{min}|#{mid}|#{max}&chxp=1,2,50,97&chxr=0,18,62&chls=2,1,0|2,1,0&chf=c,ls,0,CCCCCC,0.136363636,FFFFFF,0.27272727,CCCCCC,0.27272727,FFFFFF,0.27272727,CCCCCC,0.0454545455&chd=t:9.09,18.18,27.27,36.36,45.45,54.54,63.63|#{dp_clockmut_s.join(",")}|-1|#{dp_wt_s.join(",")}&chm=d,FF0000,0,-1,8|d,0000FF,1,-1,8&chco=FF9900,008000&chdl=Clock_mutant|WT&chdlp=rs"
    #    psid = probesets[wt[1]]
    #    buffer << [a_clockmut.id, a_clockmut.slug, psid, cm[1], tp_clockmut.to_json, dp_clockmut.to_json, cubase]
    #    buffer << [a_wt.id, a_wt.slug, psid, wt[1], tp_wt.to_json, dp_wt.to_json, cubase]
    #    if count % 500 == 0
    #      ProbesetData.import(fields, buffer)
    #      puts count
    #      buffer = []
    #    end
    #    count += 1
    #  end
    #  ProbesetData.import(fields, buffer)
    #  buffer = []
    #  puts "=== Raw Data Clockmut_liver and WT_liver cells insert ended (count = #{count}) ==="
    #end


    # LIVER + PITUATARY
    #  x-axis label => 0:|18||||||24||||||30||||||36||||||42||||||48||||||54||||||60|||||65||
    # x-axis range => chxr=0,18,66
    #  background fill => chf=c,ls,0,CCCCCC,0.125,FFFFFF,0.25,CCCCCC,0.25,FFFFFF,0.25,CCCCCC,0.125
    # build a hash of probeset ids for this genechip for Mouse430_2
    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    %w{ liver_affy }.each do |etype|
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
    # 3T3 cells
    #  x-axis => 0:|20||||24||||||30||||||36||||||42||||||48||||||54||||||60|||||||67||
    #  background fill => chf=c,ls,0,CCCCCC,0.084,FFFFFF,0.25,CCCCCC,0.25,FFFFFF,0.25,CCCCCC,0.165
    #count = 0
    #buffer = []
    #a = Assay.find(:first, :conditions => ["slug = ?", '3t3'])
    #puts "=== Raw Data 3T3 cells insert starting ==="
    #FasterCSV.foreach("#{RAILS_ROOT}/seed_data/3t3_data.csv" ) do |psd|
    #  count += 1
    #  tp = psd[2].split(/\|/).map {|e| e.to_i }
    #  dp = psd[3].split(/,/).map {|e| e.to_f }
    #  dp_min = R.min(dp).to_i
    #  dp_max = R.max(dp).to_i
    #  dp_mid = R.mean(dp).to_i
    #  dp_s = R.scaleData(dp,dp_max).map {|e| e.to_i}
    #  dp_a = R.avgData(dp_s).map {|e| e.to_i}
    #  cubase = "http://chart.apis.google.com/chart?chs=%sx%s&cht=lc&chxt=x,y&chxl=0:|20||||24||||||30||||||36||||||42||||||48||||||54||||||60|||||||67||1:|#{dp_min}|#{dp_mid}|#{dp_max}|&chxp=1,2,50,97&chxr=0,18,66&chls=0,0,0|2,1,0&chf=c,ls,0,CCCCCC,0.084,FFFFFF,0.25,CCCCCC,0.25,FFFFFF,0.25,CCCCCC,0.165&chd=t:#{dp_s.join(",")}|#{dp_a.join(",")}&chm=o,555555,0,-1,5"
    #  psid = probesets[psd[1]]
    #  buffer << [a.id(), a.slug, psid, psd[1], tp.to_json, dp.to_json,cubase]
    #  if count % 1000 == 0
    #    ProbesetData.import(fields,buffer)
    #    puts count
    #    buffer = []
    #  end
    #end
    buffer = []
    ProbesetData.import(fields,buffer)
    #puts "=== Raw Data 3T3 cells insert ended (count= #{count}) ==="

    puts "=== Raw Data insert ended ==="
  end

  desc "Seed stats data"
  task :stats => :environment do
    puts "=== Stat Data insert starting ==="

    fields = %w{  assay_id assay_name probeset_id probeset_name cosopt_p_value cosopt_q_value cosopt_period_length cosopt_phase fisherg_p_value fisherg_q_value fisherg_period_length jtk_p_value jtk_q_value jtk_period_length jtk_lag jtk_amp}
    # liver and pituitary

    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end
    %w{ liver pituitary 3t3 }.each do |etype|
      #liver
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Stat Data #{etype} start ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/#{etype}_stats.csv" ) do |r|
        count += 1
        aslug, psname = r.slice!(0,2)
        psid = probesets[psname]
        buffer << [a.id, a.slug,psid, psname] + r.to_a

        if count % 1000 == 0
          ProbesetStat.import(fields,buffer)
          buffer = []
          puts count
        end
      end
      ProbesetStat.import(fields,buffer)
      puts "=== Stat Data #{etype} end (count = #{count}) ==="
    end
    puts "=== Stat Data END ==="
  end

  task :stats2 => :environment do
    puts "=== Stat Data insert starting ==="

    fields = %w{  assay_id assay_name probeset_id probeset_name cosopt_p_value cosopt_q_value cosopt_period_length cosopt_phase fisherg_p_value fisherg_q_value fisherg_period_length jtk_p_value jtk_q_value jtk_period_length jtk_lag jtk_amp}
    # liver and pituitary

    g  = GeneChip.find(:first, :conditions => ["slug like ?","Mouse430_2"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end
    %w{ liver_affy }.each do |etype|
      #liver
      count = 0
      buffer = []
      a = Assay.find(:first, :conditions => ["slug = ?", etype])
      puts "=== Stat Data #{etype} start ==="

      FasterCSV.foreach("#{RAILS_ROOT}/seed_data/test","r" ).each do |row|
        count += 1
        line = line.split("@")
        aslug, psname = 0,line[0]
        psid = probesets[line[0]]
        buffer << [a.id, a.slug,psid, psname] + "cosopt_p_value cosopt_q_value cosopt_period_length cosopt_phase fisherg_p_value fisherg_q_value fisherg_period_length jtk_p_value jtk_q_value jtk_period_length jtk_lag jtk_amp".split(" ")

        if count % 1000 == 0
          ProbesetStat.import(fields,buffer)
          buffer = []
          puts count
        end
      end
      ProbesetStat.import(fields,buffer)
      puts "=== Stat Data #{etype} end (count = #{count}) ==="
    end
    puts "=== Stat Data END ==="
  end

  desc "Seed Clock + WT gnf stats data"
  task :clock_mutant_stats => :environment do
    puts "=== Stat Clock Mutant + WT START ==="

    fields = %w{  assay_id assay_name probeset_id probeset_name cosopt_p_value cosopt_q_value cosopt_period_length cosopt_phase fisherg_p_value fisherg_q_value fisherg_period_length jtk_p_value jtk_q_value jtk_period_length jtk_lag jtk_amp}

    g  = GeneChip.find(:first, :conditions => ["slug like ?","gnf1m"])
    probesets = {}
    g.probesets.each do |p|
      probesets[p.probeset_name]= p.id
    end

    %w{ Clockmut WT }.each do |stype|
      %w{ liver muscle scn }.each do |tissue|
        etype = "#{stype}_#{tissue}"
        count = 0
        buffer = []
        a = Assay.find(:first, :conditions => ["slug = ?", etype])
        puts "=== Stat Data #{etype} start ==="

        FasterCSV.foreach("#{RAILS_ROOT}/seed_data/#{etype}_stats.csv" ) do |r|
          count += 1
          aslug, psname = r.slice!(0,2)
          psid = probesets[psname]
          buffer << [a.id, a.slug,psid, psname] + r.to_a
          if count % 1000 == 0
            ProbesetStat.import(fields,buffer)
            buffer = []
            puts count
          end
        end
        ProbesetStat.import(fields,buffer)
        puts "=== Stat Data #{etype} END (count = #{count}) ==="
      end
    end
    puts "=== Stat Clock Mutant + WT END ==="
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
    c.execute "delete from probeset_stats"
    c.execute "delete from probeset_datas"
  end

  task :delete_from_all => :environment do
    c = ActiveRecord::Base.connection
    c.execute "delete from gene_chips"
    c.execute "delete from assays"
    c.execute "delete from probesets"
    c.execute "delete from probeset_stats"
    c.execute "delete from probeset_datas"
    puts "=== delete_from_all done!"
  end

  task :test => [:delete_from_all, :genechips, :mouse430_probesets,
    :assays, :datas2, :stats2, :refbackfill]

  desc "Reset the source data and stats"
  task :reset_data => [:delete_from_data, :datas2, :stats2, :refbackfill] do
  end

end

