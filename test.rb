require('rubygems')
require('bud')


module Ping
	state do
		# ephmeral table 
		# scratch function - just think as declaration
		scratch :star, [:from, :to]
		# Interfaces are just scratches, only one direction
		# @ for address, where wthe tuple should be, if not own, send others
		channel :ping, [:@to, :from, :id]
		channel :pong, [:@to, :from, :id] 
		channel :pung, [:@to, :from, :id] 

	end 

	bloom do 
		# squiggly: try at some time in future, =: immediately, + at next rebl , - make not true at next 
		# ping is channel

		ping <~ star{|b| [b.to, b.from, Time.new.strftime("%I:%M.%S.%3N")]}
		pong <~ ping{|x| [x.from, x.to, Time.new.strftime("%I:%M.%S.%3N")]}
		pung <~ pong{|r| [r.from, r.to, Time.new.strftime("%I:%M.%S.%3N")]}
		ping <~ pung{|t| [t.to, t.from, Time.new.strftime("%I:%M.%S.%3N")]}
		#ping <~ pong{|t| [t.to, t.from, t.id*2]}
		stdio <~ ping.inspected 
		stdio <~ pong.inspected 
		stdio <~ pung.inspected 
	end 

end 


class Pinger
	include Bud 
	include Ping
end 


# Ruby :port 
ping1 = Pinger.new(:port => 12345)
ping2 = Pinger.new(:port => 23456)
ping3 = Pinger.new(:port => 34567)

#Running in bg
ping1.run_bg
ping2.run_bg
ping3.run_bg


# When running bloom thing, cant do immediately
# Observe -> Think -> Act 
#Inserting one record, but doing "set"
ping1.star <+ [["localhost:12345", "localhost:23456"]]
ping2.star <+ [["localhost:23456", "localhost:34567"]]

ping1.tick
ping2.tick
sleep 1


# How does it pick which one to hit next 
# Grows quickly, doing a lot of pinging 
# Why does it go to 23456 twice





