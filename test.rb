require 'yaml'
require 'time'
require 'iron_worker'
require 'abt'

@config = YAML::load_file(File.expand_path(File.join("~", "Dropbox", "configs", "abt", "test", "config.yml")))
IronWorker.configure do |config|
  config.token = @config['iron_worker']['token']
  config.project_id = @config['iron_worker']['project_id']
end

@iron_mq_config = YAML::load_file(File.expand_path(File.join("~", "Dropbox", "configs", "iron_mq_ruby", "test", "config.yml")))
worker = Abt::AbtWorker.new
worker.git_url = "git://github.com/iron-io/iron_mq_ruby.git"
worker.test_config = @iron_mq_config
worker.add_notifier(:hip_chat_notifier, :config=>{"token"=>@config["hip_chat"]["token"], "room_name"=>@config["hip_chat"]['room_name']})
worker.add_notifier(File.join(File.dirname(__FILE__), 'console_notifier'), :class_name=>'ConsoleNotifier')
worker.queue
status = worker.wait_until_complete
p status
puts "LOG:"
puts worker.get_log
# When it's working, schedule it!
# worker.schedule(:start_at=>Time.now.iso8601, :run_every=>60*30)
