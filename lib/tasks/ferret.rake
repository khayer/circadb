namespace :ferret do
  desc "Rebuild the Ferret index"
  task :index => :environment do 
    print "Building Ferret index ... "
    ProbesetStat.rebuild_index
    puts "done."
  end
end