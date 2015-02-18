task :cron => :environment do
  puts "Checking health..."
  HeartbeatCheckerTask.check
  puts "done."
end