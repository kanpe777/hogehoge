def rails_root
  require "pathname"
  Pathname.new(__FILE__) + "../../"
end

worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3) # 子プロセスいくつ立ち上げるか
working_directory rails_root.realpath.to_s

# 同一マシンでNginxとプロキシ組むならsocketのが高速ぽい(後述ベンチ)
listen "/tmp/unicorn.sock"
listen 3000

timeout 60 #60秒Railsが反応しなければWorkerをkillしてタイムアウト

pid rails_root.realpath.to_s + "/tmp/pids/unicorn.pid"

stderr_path 'log/unicorn_err.log'
stdout_path 'log/unicorn_out.log'

preload_app true

before_fork do |server, worker|
  old_pid = "#{ server.config[:pid] }.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      # 古いマスターがいたら死んでもらう
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
