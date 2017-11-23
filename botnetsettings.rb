
MAX_THREADS = 10 # this const need to get_permission_to_run_thead method in botnet class
OFTEN_LOTTERY_NUMBERS = [1, 8, 9, 10, 16, 14 ,28, 31, 32, 33]
FIRST_PAYOUT_PERIOD = 24 #hours
GOLOSOPTIONS = {
                chain: :golos,
                url: 'https://api.golos.cf',
                failover_urls: [
                  'https://ws.golos.io'
                              ]
                }
# error_texts
DUPLICATE_TRANSACTION_ERROR = 'Duplicate transaction check failed'
