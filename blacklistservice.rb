require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'blacklist.rb'


users = BotNet.read_users_data_from_file
service_user = GolosUser.new(users[105][:user_name], users[105][:post_key], '')

loop do
  last_post = BlackList.get_last_post(service_user.user_name)
  comments_to_last_post =  BlackList.get_comments(last_post[0]["author"], last_post[0]["permlink"])
  BlackList.service_responce(comments_to_last_post, service_user)
  BlackList.new_service_post(service_user)
  1.upto(100) do |i|
    delitel = 100/20
    progress = "#" * (i/delitel) unless i < delitel
    printf("\rPause: [%-20s] %d/100sec", progress, i)
    sleep(1)
  end
  puts
end
