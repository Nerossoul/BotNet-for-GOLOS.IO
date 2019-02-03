# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'
require_relative 'blacklist.rb'
require 'tiny_tds'



# Print 1 to 100 percent in place in the console using "dynamic output"
# technique
# Prints a combination of the progress bar, spinner, and percentage examples.
# Prints a text-based progress bar representing 0 to 100 percent. Each "="
# sign represents 5 percent.

#puts (Time.now.utc + 3*60*60).strftime("%Y-%m-%d %H:%M:%S")

#puts BlackList.get_post_reward_time("upbank", "my-zapuskaemsya-mobi-dik-nachinaet-rabotu-segodnya")

#BlackList.is_last_post_too_old?('upvot50-50')
puts BlackList.get_post_paid_status('nerossoul')
=begin
client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
puts 'Connecting to SQL Server'

if client.active? == true then puts 'Done' end



tsql0 = "SELECT TOP 3 * FROM TxComments WHERE parent_author = '' AND json_metadata LIKE '%\"ru--apvot50-50\"%' AND author = 'goldvoice'"
tsql00 = "SELECT TOP 3 * FROM TxComments WHERE parent_author = '' AND json_metadata LIKE '%\"ru--apvot50-50\"%'"
tsql10 = "SELECT memo FROM TxTransfers WHERE type = 'transfer' AND [to] = 'nerossoul'"

join_sql = "SELECT TOP 5 * FROM TxVotes INNER JOIN TxComments ON TxVotes.voter = 'upvot50-50' AND TxVotes.author = TxComments.author AND TxVotes.permlink = TxComments.permlink"

tsql = "SELECT * FROM TxComments LIMIT 5"
# вывести все имена таблиц
tsql2 = "SELECT * FROM INFORMATION_SCHEMA.TABLES"
tsql333 = "SELECT TOP 10 * FROM TxVotes WHERE voter='nerossoul' AND weight > 0  ORDER BY id DESC"

tsql444 = "SELECT TOP 3 * FROM TxComments WHERE parent_author = '' AND author = 'ieshua' AND permlink = 'konkurs-s-mega-prizom-ogromnyi-chernyi-brilliant-vesom-8-2-karat-vse-chestno'"
# вывести поля таблицы

tsql555 = "SELECT TOP 1 * FROM VOAuthorRewards WHERE author = 'ieshua' AND permlink = 'konkurs-s-mega-prizom-ogromnyi-chernyi-brilliant-vesom-8-2-karat-vse-chestno'"

tsql666 = "SELECT TOP 10 author, permlink, timestamp FROM TxVotes WHERE voter='nerossoul' AND weight > 0 "

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
  TABLE_NAME = 'VOAuthorRewards'
ORDER BY
  ORDINAL_POSITION ASC;"
result = client.execute(tsql666)

#2017-09-12 17:36:57 +0700
#2017-09-14 02:29:03 +0700

result.each do |row|
    puts row
    puts "**************************************************************"
end

client.close


#BotNet.get_time_object_from_golos_timestamp(last_post['timestamp'].to_datetime.to_s)
=end
