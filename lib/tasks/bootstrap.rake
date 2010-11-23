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
