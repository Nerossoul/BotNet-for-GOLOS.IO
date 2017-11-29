# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

#bots = BotNet.new

3.times do
  puts "start1".green
  2.times do
    puts "start2"
    if true
      puts "Each user reach minimum voting power! HERE MUST BE BREAK".green.reverse_color
      10.times {puts "BREAK DONE".green.reverse_color}
      break
    end
    puts "end2"
  end
  puts "end1".green
end
