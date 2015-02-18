task :cron => :environment do
  puts "Pulling new requests..."
  #  HeartbeatCheckerTask.check
  puts "done."
end