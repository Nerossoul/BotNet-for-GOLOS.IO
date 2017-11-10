# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'

botnet_commander = BotNet.new

#puts JSON.pretty_generate(botnet_commander.get_lust_post_data('golos.loto'))

vote = botnet_commander.create_comment_data(parent_permlink, author, permlink, title, body, json_metadata, parent_author)
botnet_commander.sign_transaction(vote, '5KWtX3UPCY6qvuxpYabZPPwiZ7weK3bstSGXyTjWcDkkkXgWjSX')
