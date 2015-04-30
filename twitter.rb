# Twitter social network 

# 1. Client - post
# 2. Server 

# 1. Post (server, msg, context : unique_id of where it 
#	is coming from, unique_id, time )

# bit shift k and n : unique client id 

# 2. Get Timeline (Server, Client to show, ) 
# - Timeline(client, msg, context, unique-id, date)
# - show conversation (rule, recursive definition )

# Phase 1: just get client. server working 
# Phase 2:  Construct conversations 
# Phase 3: Master Server, many servers
# Phase 4: Clients getting information from the server,forwarding 

# link [:from, :to]
# path <= link 
# path <= (link*path).pairs(
# 	link.to == path.from)
# 	link.from => path.to

# link(1,2)
# link(2,3)

# Underneath bloom is doing 
# path(1,2)
# path(2,3)
# path(1,3)


require('rubygems')
require('bud')
require('uuidtools')

module Client 
	state do
		table :id, [:id]
		#b is coming from post 
		scratch :post, [:id, :server, :client, :msg, :context, :time]
		scratch :request, [:client, :server, :context, :time]
		channel :client, [:@server, :from, :msg, :context, :time, :id]
		channel :sendRequest, [:@server, :client, :context, :time]
	end 

	bloom do
		client <~ post{|b| [b.server, b.client, b.msg, b.context, b.time, b.id]}
		sendRequest <~ request{|r| [r.server, r.client, r.context, r.time]}
		stdio <~ post.inspected
		stdio <~ sendRequest.inspected
	end 
end 

module Server 
	state do
		table :serverId [:serverId]
		scratch :response, [:id, :server, :client, :msg, :time]
		scratch :conversation, [:from, :context, :time]
		channel :server, [:@to, :from, :unique_id]
		#Need to figure this out
		channel :getResponse, [:@server, :client, :]
		table :posts, [:client, :server, :msg, :context, :time]
	end 

	bloom do 
		public_post <= client 
		#client <~ public_post{|b| [b.server, b.from, Time.new.strftime("%I:%M.%S.%3N")]}
		# How to add message to table
		#tables <
		#stdio <~ public_post.inspected
	end 

end


class Tweeter
	include Bud 
	include Client
end

class ServerTweet
	include Bud
	include Server
end  


# Ruby :port 
tweet1 = Tweeter.new(:port => 12345)
#tweet2 = ServerTweet.new(:port => 23456)


#Running in bg
tweet1.run_bg
#tweet2.run_bg



tweet1.post <+ [["localhost:23456", "localhost:12345", "Hello world", "hellos", Time.new.strftime("%I:%M.%S.%3N"), 1]]
#tweet2.public_post <+ [["localhost:23456", "localhost:34567", "Hello world", "hellos", 2]]

tweet1.tick
#tweet2.tick
sleep 10



