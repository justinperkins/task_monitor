namespace :task_monitor do
  task :monitored_environment => :setup do |t|
    invokee = t.application.top_level_tasks.first
    TaskMonitor.with_job invokee do
      TaskMonitor.alive
    end
  end

  task :report => :setup do |t|
    TaskMonitor.report
  end
end
