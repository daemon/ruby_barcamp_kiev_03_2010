namespace :parser do

  desc "Parse mega.genn.org using delayed_job"
  task :dj => :environment do
    Delayed::Job.enqueue(DelayedParser.new)
  end

end