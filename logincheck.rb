# Ckeck golos login free or busy
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

login_to_check = "qwer"

api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
response = api.get_accounts([login_to_check])
#puts JSON.pretty_generate(response['result'])
if response['result'] == [] then
  puts "\n\r#{login_to_check}"
  puts 'свободен'
else
  puts "\n\r#{login_to_check}\n\r"
  puts 'занят'
end
