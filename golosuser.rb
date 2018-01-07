require 'radiator'
require 'json'
require_relative 'botnetsettings.rb'

class GolosUser

  attr_reader(:user_name, :post_key, :activ_key, :golos, :golos_power, :gbg,
              :gests, :voting_power , :last_vote_time, :actual_voting_power)
  attr_accessor(:voiting_credit, :signing_transaction_now, :future_voting_power)

  def initialize(user_name, post_key, activ_key)
    @user_name = user_name
    @post_key = post_key
    @activ_key = activ_key
    @signing_transaction_now = false
    @golos = 0.0
    @golos_power = 0.0
    @gbg = 0.0
    @gests = 0.0
    @voting_power = 0.0
    @last_vote_time = nil
    @actual_voting_power = 0.0
    @voiting_credit = 0.0
    puts "Creating user #{user_name.brown}"
    get_user_info
    @future_voting_power = @voting_power
    end

    def get_actual_voting_power(voting_power, timestamp)
      timestamp = timestamp.split('T')
      timestamp_date_array = timestamp[0].split('-')
      timestamp_time_array = timestamp[1].split(':')
      timestamp_converted = Time.new(timestamp_date_array[0], timestamp_date_array[1], timestamp_date_array[2], timestamp_time_array[0], timestamp_time_array[1], timestamp_time_array[2], "+00:00")
      actual_voting_power = voting_power + ((Time.now.utc - timestamp_converted.utc) / 60 * 20 / 24 / 60)
      if actual_voting_power > 100.0 then
        return [100.0 , (actual_voting_power - 100).round(2)]
      else
        return [actual_voting_power.round(2), 0.0]
      end
    end

  def get_user_info
    print "    ►►Getting #{user_name.brown} info "
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    got_user_info = false
    while got_user_info != true
      begin
        response = api.get_accounts([@user_name])
        got_user_info = true
      rescue Exception => e
        puts "get_user_info ERROR".red
        puts e # e.message.red
        print e.backtrace.join("\n")
        sleep(5)
      end
    end
    golos_power = response['result'][0]['vesting_shares'].split(' ')
    #puts response['result'][0]['name']
    @golos = response['result'][0]['balance']
    @golos_power = (golos_power[0].to_f * get_steem_per_mvests / 1_000_000)
    @gbg = response['result'][0]['sbd_balance']
    @gests = response['result'][0]['vesting_shares']
    @voting_power = response['result'][0]['voting_power'] / 100.0
    @last_vote_time = response['result'][0]['last_vote_time']
    actual_vp_and_voting_credit_in_array = get_actual_voting_power(@voting_power, @last_vote_time)
    @actual_voting_power = actual_vp_and_voting_credit_in_array[0]
    @voiting_credit = actual_vp_and_voting_credit_in_array[1]
    #puts '*******************************************'
    #puts 'Golos: ' + @golos.to_s
    #puts 'Golos Power: ' + @golos_power.to_s
    #puts 'Golos Gold: ' + @gbg.to_s
    #puts 'Gests: ' + @gests.to_s
    #puts 'Voting_power: ' + @voting_power.to_s
    #puts '*******************************************'
    puts "✔".green.bold
  end

  def get_steem_per_mvests
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    api.get_dynamic_global_properties do |properties|
      steem_per_mvests = 1_000_000.0 * properties.total_vesting_fund_steem.split[0].to_f / properties.total_vesting_shares.split[0].to_f
      format('%.3f', steem_per_mvests).to_f
    end
  end
end

=begin
/home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/net/http.rb:906:in `rescue in block in connect': Failed to open TCP connection to api.golos.cf:443 (Network is unreachable - connect(2) for "api.golos.cf" port 443) (Errno::ENETUNREACH)
	from /home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/net/http.rb:903:in `block in connect'
	from /home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/timeout.rb:93:in `block in timeout'
	from /home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/timeout.rb:103:in `timeout'
	from /home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/net/http.rb:902:in `connect'
	from /home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/net/http.rb:887:in `do_start'
	from /home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/net/http.rb:876:in `start'
	from /home/nerossoul/.rvm/rubies/ruby-2.4.0/lib/ruby/2.4.0/net/http.rb:1407:in `request'
	from /home/nerossoul/.rvm/gems/ruby-2.4.0/gems/radiator-0.3.15/lib/radiator/api.rb:624:in `request'
	from /home/nerossoul/.rvm/gems/ruby-2.4.0/gems/radiator-0.3.15/lib/radiator/api.rb:446:in `block in method_missing'
	from /home/nerossoul/.rvm/gems/ruby-2.4.0/gems/radiator-0.3.15/lib/radiator/api.rb:425:in `loop'
	from /home/nerossoul/.rvm/gems/ruby-2.4.0/gems/radiator-0.3.15/lib/radiator/api.rb:425:in `method_missing'
	from /home/nerossoul/botnet/golosuser.rb:71:in `get_steem_per_mvests'
	from /home/nerossoul/botnet/golosuser.rb:50:in `get_user_info'
	from /home/nerossoul/botnet/botnet.rb:585:in `block in vote_by_each_user_for_upvote_list'
	from /home/nerossoul/botnet/botnet.rb:584:in `each'
	from /home/nerossoul/botnet/botnet.rb:584:in `vote_by_each_user_for_upvote_list'
	from upvote5050ver2.rb:26:in `block in <main>'
	from upvote5050ver2.rb:16:in `loop'
	from upvote5050ver2.rb:16:in `<main>'
=end
