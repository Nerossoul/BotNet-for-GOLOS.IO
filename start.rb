# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'


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

result1 = BotNet.post_array_uniqalization(array_start)
result2 = BotNet.delete_old_posts_from_array(result1)
puts result2
BotNet.save_to_file_posts_array(result2)

#botnet_commander = BotNet.new

#BotNet.get_block(12_026_530)

#max_block_number = BotNet.get_max_block_number
#BotNet.save_max_block_number_to_file(max_block_number)
#puts "-"
#puts BotNet.get_lust_max_block_number_from_file


# "parent_author": "",
#   "author": "marfa",
#  "permlink": "re-ohlamoon-re-marfa-6ezzfu-golos-art-awards-marina-20171211t111203808z",
#  "json_metadata": "{\"tags\":[\"ru--fotografiya\"],\"app\":\"golos.io/0.1\"}"
