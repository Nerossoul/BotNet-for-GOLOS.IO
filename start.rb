# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

min_ = 5
next_= min_ + 1
 100.times do |i|
   next_= min_ + 1 + i
   puts next_
 end



=begin
def get_account_history_max_number(user_name)
  options = GOLOSOPTIONS.merge({url: 'https://api.golos.cf'})
  api = Radiator::Api.new(options)
  puts "geting #{user_name.brown} account history max number"
  got_max_number = false

    begin
      response = api.get_account_history(user_name, 800_000_000_000, 0)
      puts JSON.pretty_generate(response)
      max_number = response['result'][0][0]
      got_max_number = true
    rescue Exception => e
      puts "GET_BLOCK_NUMBER ERROR".red
      puts e # e.message.red
      print e.backtrace.join("\n")
    end

  #sleep(1)
  puts "#{user_name.brown} account history max number is #{max_number}"
  return max_number
end


puts get_account_history_max_number('golos.loto')


def create_reblog_data(user_name, author, permlink)
  data = [
    :reblog, {
      account: user_name,
      author: author,
      permlink: permlink
    }
  ]

  reblog_custom_json = {
    type: :custom_json,
    id: 'follow',
    required_auths: [],
    required_posting_auths: [user_name],
    json: data.to_json
  }
  return reblog_custom_json
end
author = 'goldenbogdan'
permlink = 'rai-i-ad'
reblog_data = create_reblog_data(rebloger.user_name, author, permlink)
BotNet.sign_transaction(reblog_data, rebloger.post_key, rebloger)


array_start = [{"author"=>"romkos", "permlink"=>"27s6ur-anekdot-50-50", "timestamp"=>"2017-12-11T17:39:12"},
{"author"=>"luh", "permlink"=>"mnogo-eshyo-vremeni-proidet", "timestamp"=>"2017-12-11T18:41:45"},
{"author"=>"karmoputnik", "permlink"=>"bez-smekha-i-religiya-mertva", "timestamp"=>"2017-12-11T18:32:48"},
{"author"=>"karmoputnik", "permlink"=>"religiya-okno-a-ne-nebo", "timestamp"=>"2017-12-11T18:32:30"},
{"author"=>"luh", "permlink"=>"11-dkabrya", "timestamp"=>"2017-12-11T18:32:21"},
{"author"=>"karmoputnik", "permlink"=>"kak-zhit-dalshe-budem", "timestamp"=>"2017-12-11T18:31:54"},
{"author"=>"irina123321", "permlink"=>"pravila-obrezki-roz", "timestamp"=>"2017-12-11T18:30:33"},
{"author"=>"retoldname", "permlink"=>"ls69p-otdykh-v-yuzhnom-gorode-sochi", "timestamp"=>"2017-12-11T18:23:36"},
{"author"=>"retoldname", "permlink"=>"ls69p-otdykh-v-yuzhnom-gorode-sochi", "timestamp"=>"2017-12-11T18:21:48"},
{"author"=>"retoldname", "permlink"=>"ls69p-otdykh-v-yuzhnom-gorode-sochi", "timestamp"=>"2017-12-11T18:20:12"},
{"author"=>"retoldname", "permlink"=>"otdykh-v-yuzhnom-gorode-sochi", "timestamp"=>"2017-12-11T18:15:54"},
{"author"=>"retoldname", "permlink"=>"otdykh-v-yuzhnom-gorode-sochi", "timestamp"=>"2017-12-11T18:14:15"},
{"author"=>"sinilga", "permlink"=>"ya-idu-po-oskolkam-illyuzii", "timestamp"=>"2017-12-11T18:09:06"},
{"author"=>"dmitryvoice", "permlink"=>"6nzhqi-vopros-po-busteram", "timestamp"=>"2017-12-11T18:07:30"},
{"author"=>"retoldname", "permlink"=>"ls69p-otdykh-v-yuzhnom-gorode-sochi", "timestamp"=>"2017-12-11T18:02:36"},
{"author"=>"bitclabnetwork", "permlink"=>"1-bitcoin-konec-2018-goda-raven-bmw-x5-96000eur", "timestamp"=>"2017-12-11T17:59:24"},
{"author"=>"ohoneyinvest", "permlink"=>"ico-trade-io", "timestamp"=>"2017-12-11T17:47:18"},
{"author"=>"karmoputnik", "permlink"=>"kak-zhit-dalshe-budem", "timestamp"=>"2017-12-11T17:45:21"},
{"author"=>"karmoputnik", "permlink"=>"kak-zhit-dalshe-budem", "timestamp"=>"2017-12-11T17:44:18"},
{"author"=>"karmoputnik", "permlink"=>"kak-zhit-dalshe-budem", "timestamp"=>"2017-12-11T17:43:36"},
{"author"=>"romkos", "permlink"=>"27s6ur-anekdot-50-50", "timestamp"=>"2017-12-11T17:39:12"}
]
=end


#puts BotNet.get_max_block_number
# result1 = BotNet.post_array_uniqalization(array_start)
# result2 = BotNet.delete_old_posts_from_array(result1)
# puts result2
# BotNet.save_to_file_posts_array(result2)

# botnet_commander = BotNet.new

# botnet_commander.get_post_information('dr2073', 'metaiskra')

# BotNet.get_block(12_026_530)

# max_block_number = BotNet.get_max_block_number
# BotNet.save_block_number_to_file(max_block_number)
# puts "-"
# puts BotNet.get_lust_max_block_number_from_file


# "parent_author": "",
# "author": "marfa",
# "permlink": "re-ohlamoon-re-marfa-6ezzfu-golos-art-awards-marina-20171211t111203808z",
# "json_metadata": "{\"tags\":[\"ru--fotografiya\"],\"app\":\"golos.io/0.1\"}"





=begin
require 'tiny_tds'
client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
puts 'Connecting to SQL Server'

if client.active? == true then puts 'Done' end

tsql = "SELECT TOP 2 * FROM TxComments"
# вывести все имена таблиц
tsql2 = "SELECT * FROM INFORMATION_SCHEMA.TABLES"


# вывести поля таблицы
tsql3 ="SELECT
   ORDINAL_POSITION
  ,COLUMN_NAME
  ,DATA_TYPE
  ,CHARACTER_MAXIMUM_LENGTH
  ,IS_NULLABLE
  ,COLUMN_DEFAULT
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  TABLE_NAME = 'Transactions'
ORDER BY
  ORDINAL_POSITION ASC;"
result = client.execute(tsql3)

result.each do |row|
    puts row
    puts "**************************************************************"
end


client.close
=end
