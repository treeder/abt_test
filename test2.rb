require 'yaml'
require 'time'
require 'iron_worker'
require 'abt'

@iron_worker_config = YAML::load_file(File.expand_path(File.join("~", "Dropbox", "configs", "abt", "test", "config.yml")))
IronWorker.configure do |config|
  config.token = @iron_worker_config['iron_worker']['token']
  config.project_id = @iron_worker_config['iron_worker']['project_id']
end

# iron_mq can use the same config as iron_worker
@iron_mq_config = {:iron_mq=>{:token=>@iron_worker_config['iron_worker']['token'],
:project_id=>@iron_worker_config['iron_worker']['project_id']}}

worker = Abt::AbtWorker.new
worker.git_url = "git://github.com/iron-io/iron_mq_ruby.git"
worker.test_config = @iron_mq_config
worker.add_notifier(:hip_chat_notifier, :config=>{"token"=>'MY_HIP_CHAT_TOKEN',  "room_name"=>'MY_HIP_CHAT_ROOM_NAME'})
worker.queue
status = worker.wait_until_complete
p status
puts "LOG:"
puts worker.get_log
# When it's working, schedule it!
# worker.schedule(:start_at=>Time.now.iso8601, :run_every=>60*30)
