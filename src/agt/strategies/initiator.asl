@mission[atomic]
+default::mission(Id, Storage, Reward, Start, End, Fine, _, _, Items)[source(X)]
	: new::max_bid_time(Deadline) & new::job_bidders(NumberOfAgents)
<- 
	.print("Creating cnp for mission ",Id," deliver to ",Storage," for ",Reward," starting at ",Start," to ",End," or pay ",Fine);
	.print("Items required: ",Items);
	!!announce(mission(Id, Storage, Reward, Start, End, Fine, Items),Deadline,NumberOfAgents);
	.
+default::mission(Id, Storage, Reward, Start, End, Fine, _, _, Items)[source(X)]
<-
	.print("Mission dumped!");
	-default::mission(Id, Storage, Reward, Start, End, Fine, _, _, Items)[source(X)]
	.
	
+!announce(mission(Id, Storage, Reward, Start, End, Fine, Items),Deadline,NumberOfAgents)
<- 
	announce(mission(Id, Storage, Reward, Start, End, Fine, Items),Deadline,NumberOfAgents,CNPBoardName);
	getBids(Bids) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0) {		
		.print("Got bids (",.length(Bids),") for task ",CNPBoardName," List ",Bids);
		?default::select_bid_mission(Bids,bid(99999,99999),bid(Agent,Distance));
		.send(Agent,tell,winner(mission(Id, Storage, Reward, Start, End, Fine, Items)));
	}
	else {
		.print("No bids.");
	}
	clear(CNPBoardName);
	.