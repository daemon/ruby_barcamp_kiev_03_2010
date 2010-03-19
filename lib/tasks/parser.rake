namespace :parser do

  desc "Parse mega.genn.org using delayed_job"
  task :dj => :environment do
    Delayed::Job.enqueue(DelayedParser.new)
  end

  desc "Parse mega.genn.org using loops"
  task :loops => :environment do
    p = LoopsParser.new
    p.exchange.publish('http://mega.genn.org/', :key => 'genn.pages')
    p.exchange.publish('http://mega.genn.org/page/2/', :key => 'genn.pages')
  end

end