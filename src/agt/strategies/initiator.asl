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
	getBidsJob(Bids) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0) {		
		.print("Got bids (",.length(Bids),") for task ",CNPBoardName," List ",Bids);
		?default::select_bid_mission(Bids,bid(99999,99999),bid(Agent,Distance));
		if ( Distance \== 99999 ) { .send(Agent,tell,winner(mission(Id, Storage, Reward, Start, End, Fine, Items))); }
		else { .print("Ignoring mission ",Id," because it is impossible at the moment.") }
	}
	else {
		.print("No bids.");
	}
	clear(CNPBoardName);
	.
	
+!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Quad)
<- 
	announce(item(ItemId,Qty),Deadline,NumberOfAgents,CNPBoardName,Quad);
//	.print("Created cnp ",CNPBoardName," for task #",Qty," of ",ItemId);
	getBidsTask(Bids) [artifact_name(CNPBoardName)];
	if (.length(Bids) \== 0) {		
		.print("Got bids (",.length(Bids),") for task #",Qty," ",ItemId," Bids: ",Bids);
		+bids(item(ItemId,Qty),Bids);
	}
	else {
		.print("No bids.");
	}
	clear(CNPBoardName,Quad);
	.
	
+!separate_tasks(mission(Id, Storage, Reward, Start, End, Fine, Items))
	: new::max_bid_time(Deadline) & coalition::coalition(Quad,Members,_) & NumberOfAgents = .length(Members)
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
	
@selectBids[atomic]
+bids(item(_,_),_)
	: .count(initiator::bids(_,_),NumberOfBids) & number_of_tasks(NumberOfTasks) & NumberOfBids == NumberOfTasks
<-
	.print("@@@@@@@@@@@ Finished getting all bids, time to select and award.");
	-number_of_tasks(NumberOfTasks);
	for ( bids(item(ItemId,Qty),Bids) ) {
		if (.substring("item",ItemId)) {
			-bids(item(ItemId,Qty),Bids);
			?default::select_bid(Bids,bid(99999,99999,99999),bid(Agent,Distance,Shop));
			if (Distance \== 99999) {
				getLoad(Agent,Load);
				?default::item(ItemId,Volume,_,_);
		    	addLoad(Agent,Load-Volume*Qty);
				if (not initiator::awarded(Agent,_,_)) {
					+awarded(Agent,Shop,[item(ItemId,Qty)]);
				}
				else {
					?awarded(Agent,Shop,List);
		    		-awarded(Agent,Shop,List);
		    		.concat(List,[item(ItemId,Qty)],NewList);
		    		+awarded(Agent,Shop,NewList);
				}
			}
			else { .print("Impossible task detected!") }
		}
	}
	for ( bids(item(ItemId,Qty),Bids) ) {
		-bids(item(ItemId,Qty),Bids);
//		?default::select_bid_tool(Bids,bid(99999,99999,99999,99999),bid(Agent,Distance,Shop,TaskId));
//		if (not initiator::awarded(Agent,TaskId,_)) {
//			+awarded(Agent,TaskId,[item(ItemId,Qty)]);
//		}
	}
    for (awarded(Agent,Shop,List)) {
    	.send(Agent,tell,winner(List,Shop));
		-awarded(Agent,Shop,List);	
	}	
	.	