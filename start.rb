# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

require 'tiny_tds'



botnet_commander = BotNet.new




=begin
client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
puts 'Connecting to SQL Server'

if client.active? == true then puts 'Done' end



tsql0 = "SELECT author, permlink FROM TxComments WHERE parent_author = '' AND json_metadata LIKE '%ru--apvot50-50%'"

tsql10 = "SELECT memo FROM TxTransfers WHERE type = 'transfer' AND [to] = 'nerossoul'"

join_sql = "SELECT TOP 5 * FROM TxVotes INNER JOIN TxComments ON TxVotes.voter = 'upvot50-50' AND TxVotes.author = TxComments.author AND TxVotes.permlink = TxComments.permlink"

tsql = "SELECT * FROM TxComments LIMIT 5"
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
  TABLE_NAME = 'TxTransfers'
ORDER BY
  ORDINAL_POSITION ASC;"
result = client.execute(tsql10)

result.each do |row|
    puts row
    puts "**************************************************************"
end

client.close
=end
