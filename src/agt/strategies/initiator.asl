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
	
+!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Quad)
<- 
	announce(item(ItemId,Qty),Deadline,NumberOfAgents,CNPBoardName,Quad);
	.print("Created cnp ",CNPBoardName," for task #",Qty," of ",ItemId);
	getBids(Bids) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0) {		
		.print("Got bids (",.length(Bids),") for task ",CNPBoardName," List ",Bids);
		+bids(item(ItemId,Qty),Bids);
////		?default::select_bid_mission(Bids,bid(99999,99999),bid(Agent,Distance));
////		.send(Agent,tell,winner(mission(Id, Storage, Reward, Start, End, Fine, Items)));
	}
	else {
		.print("No bids.");
	}
	clear(CNPBoardName,Quad);
	.
	
+!separate_tasks(mission(Id, Storage, Reward, Start, End, Fine, Items))
	: new::max_bid_time(Deadline) & coalition::coalition(Quad,Members,_) & NumberOfAgents = .length(Members)+1
<-
	?default::decomposeRequirements(Items,[],Bases);
	+number_of_tasks(0);
	for ( .member(Lists,Bases) ) { 
		?number_of_tasks(NumberOfTasks); 
		-+number_of_tasks(NumberOfTasks+.length(Lists));
	}
	for ( .member(Item,Bases) ) {
		for ( .member(item(ItemId,Qty),Item) ) {
			!!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Quad);
		}
	}
	.
	
+bids(item(ItemId,Qty),Bids)
	: .count(initiator::bids(_,_),NumberOfBids) & number_of_tasks(NumberOfTasks) & NumberOfBids == NumberOfTasks
<-
	.print("@@@@@@@@@@@ Finished getting all bids, time to select and award.");
	.abolish(initiator::bids(_,_));
	-number_of_tasks(NumberOfTasks);
	.	