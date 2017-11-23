# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

#bots = BotNet.new

message = '10 assert_exception: Assert Exception
(skip & skip_transaction_dupe_check) || trx_idx.indices().get<by_trx_id>().find(trx_id) == trx_idx.indices().get<by_trx_id>().end(): Duplicate transaction check failed
    {"trx_ix":"f1ade51b29daee7d192027dc821240067c4a961a"}
    th_a  database.cpp:3324 _apply_transaction

    {"trx":{"ref_block_num":24358,"ref_block_prefix":2641815415,"expiration":"2017-11-22T21:43:24","operations":[["vote",{"voter":"charles","author":"naminutku","permlink":"chosp","weight":10000}]],"extensions":[],"signatures":["1b5b4d357d4027cf823bfb15ed4a88518dd3d923e86cb2b62e465029e5837ce0256cfe435a9f0abd4d126c591b9f40493bde1545c7bff10a403639cbc32331e24b"]}}
    th_a  database.cpp:3409 _apply_transaction

    {"trx":{"ref_block_num":24358,"ref_block_prefix":2641815415,"expiration":"2017-11-22T21:43:24","operations":[["vote",{"voter":"charles","author":"naminutku","permlink":"chosp","weight":10000}]],"extensions":[],"signatures":["1b5b4d357d4027cf823bfb15ed4a88518dd3d923e86cb2b62e465029e5837ce0256cfe435a9f0abd4d126c591b9f40493bde1545c7bff10a403639cbc32331e24b"]}}
    th_a  database.cpp:774 push_transaction

    {"call.method":"call","call.params":["network_broadcast_api","broadcast_transaction_synchronous",[{"expiration":"2017-11-22T21:43:24","ref_block_num":24358,"ref_block_prefix":2641815415,"operations":[["vote",{"voter":"charles","author":"naminutku","permlink":"chosp","weight":10000}]],"extensions":[],"signatures":["1b5b4d357d4027cf823bfb15ed4a88518dd3d923e86cb2b62e465029e5837ce0256cfe435a9f0abd4d126c591b9f40493bde1545c7bff10a403639cbc32331e24b"]}]]}
    th_a  websocket_api.cpp:124 on_message
'
dup_transaction_text = 'Duplicate transaction check failed'
puts message.include? dup_transaction_text
