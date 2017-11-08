require_relative 'golosuser.rb'
class BotNet

  attr_reader(:users)

  def initialize
    @users = []
  end

  def read_users_data_from_file(file_name)
    if File.exist?(file_name)
      f = File.new(file_name, 'r:UTF-8')
      users_array = f.readlines
      f.close
      users_hashs = []
      users_array.each do |user_data|
        user_auth = user_data.split
        users_hashs << { user_name: user_auth[0], post_key: user_auth[1], activ_key: user_auth[2] }
      end
      users_array = nil
      users_hashs
    else
      puts "file #{file_name} not found"
      nil
    end
  end

  def create_users(user_hashs)
    user_hashs.each do |user|
      @users << GolosUser.new(user[:user_name],user[:post_key], user[:activ_key])
    end
  end

  def get_lust_post_data(user_name)
    lust_post_data = []
    max_number = get_account_history_max_number(user_name)
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')

    while max_number > 0 do
      puts "запрос в блокчейн"
      response = api.get_account_history(user_name, max_number, 1999)
      puts JSON.pretty_generate(response)

      response['result'].reverse_each do |result|
        if result[1]['op'][0] == 'comment' then
          if (result[1]['op'][1]['author'] == user_name && result[1]['op'][1]['parent_author'] == '') then
            lust_post_data = result[1]
            max_number = 0
          end
        end
      end
      max_number = max_number - 2000
      sleep(1)
    end

    return lust_post_data
  end

  def get_account_history_max_number(user_name)
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
    response = api.get_account_history(user_name, 800000000000, 0)
    max_number = response['result'][0][0]
    sleep(1)
    return max_number
  end
end
