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
		table :next_hop, [:from, :to]

	end 

# Constructor : intialization 
bootstrap do
	next_hop <+ [["localhost:12345", "localhost:23456"], 
				["localhost:23456", "localhost:34567"],
				["localhost:34567", "localhost:12345"]]

	end 	
	bloom do 
		# pairs of records from each - * 
		ping <~ (star*next_hop).pairs(:from => :from){|s,n|
			[n.to, n.from, 0]
		}
		ping <~ (ping*next_hop).pairs(:to => :from){|p,n|
			[n.to, n.from, p.id+1]
			}
		stdio <~ ping.inspected

	
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
sleep 5


# How does it pick which one to hit next 
# Grows quickly, doing a lot of pinging 
# Why does it go to 23456 twice

