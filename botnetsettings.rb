
MAX_THREADS = 10 # this const need to get_permission_to_run_thead method in botnet class
OFTEN_LOTTERY_NUMBERS = [1, 8, 9, 10, 16, 14 ,28, 31, 32, 33]
GOLOS_LOTO_LUNCH_TIME = [[17,20],[20,20],[0,20],[2,20],[6,7]]
MOMENTLOTO_LUNCH_TIME = [[6,00], [11,00], [14,00], [17,00], [21,00], [02,00]]
FIRST_PAYOUT_PERIOD = 24 #hours
GOLOSOPTIONS = {
                chain: :golos,
                url:  'https://api.golos.cf',
                failover_urls: [
                  'https://ws.goldvoice.club/',
                  #'https://api.golos.cf',
                  #'https://ws.golos.io'
                              ]
                }
MIN_VOTING_POWER = 99.6
MAX_VOTING_POWER = 99.9
# error_texts
DUPLICATE_TRANSACTION_ERROR = 'Duplicate transaction check failed'
CHECK_MAX_BLOCK_AGE_ERROR = '!check_max_block_age(_max_block_age)'
