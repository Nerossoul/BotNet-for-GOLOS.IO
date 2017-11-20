# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

#bots = BotNet.new

#api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
#response = api.get_accounts(["nerossoul"])
#puts response['result'][0]['name']
#puts JSON.pretty_generate(response)

user = GolosUser.new('nerossoul', 'nil', 'nil')
puts user.voting_power
puts user.actual_voting_power
