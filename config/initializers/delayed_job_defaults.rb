Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 5.hours

#Hack! Hack! Hack!
#Latest Rails + DJ throws and error like
#Expected .../vendor/plugins/delayed_job/lib/delayed_job.rb to define DelayedJob
module DelayedJob
end