require 'radiator'
require 'json'

class GolosUser

  attr_reader(:user_name, :post_key, :activ_key, :golos, :golos_power, :gbg,
              :gests, :voting_power)

  def initialize(user_name, post_key, activ_key)
    @user_name = user_name
    @post_key = post_key
    @activ_key = activ_key
    @golos = 0.0
    @golos_power = 0.0
    @gbg = 0.0
    @gests = 0.0
    @voting_power = 0.0
    puts "Creating user #{user_name.brown}"
    #get_user_info
    end

  def get_user_info
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
    response = api.get_accounts([@user_name])
    golos_power = response['result'][0]['vesting_shares'].split(' ')
    #puts response['result'][0]['name']
    @golos = response['result'][0]['balance']
    @golos_power = (golos_power[0].to_f * get_steem_per_mvests / 1_000_000)
    @gbg = response['result'][0]['sbd_balance']
    @gests = response['result'][0]['vesting_shares']
    @voting_power = response['result'][0]['voting_power'] / 100.0
    #puts '*******************************************'
    #puts 'Golos: ' + @golos.to_s
    #puts 'Golos Power: ' + @golos_power.to_s
    #puts 'Golos Gold: ' + @gbg.to_s
    #puts 'Gests: ' + @gests.to_s
    #puts 'Voting_power: ' + @voting_power.to_s
    #puts '*******************************************'
  end

  def get_steem_per_mvests
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
    api.get_dynamic_global_properties do |properties|
      steem_per_mvests = 1_000_000.0 * properties.total_vesting_fund_steem.split[0].to_f / properties.total_vesting_shares.split[0].to_f
      format('%.3f', steem_per_mvests).to_f
    end
  end
end
