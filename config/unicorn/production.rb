app_path = "#{ENV['APP_PATH']}/current"

listen ENV['UNICORN_PORT']
worker_processes 4
timeout 120

stderr_path "#{ENV['APP_PATH']}/shared/unicorn.stderr.log"
stdout_path "#{ENV['APP_PATH']}/shared/unicorn.stderr.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

working_directory app_path
pid "#{app_path}/public/system/unicorn.pid"

before_fork do |server,worker|
  ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Failed to send signal to old master"
    end
  end
end

after_fork do |server,worker|
  ActiveRecord::Base.establish_connection
end
