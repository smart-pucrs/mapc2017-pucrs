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
	+bases([]);
	for ( .member(Item,Bases) ) {
		?bases(L);
		.concat(L,Item,New);
		-+bases(New);
	}
	?bases(B);
	-bases(B);
	?default::separateItemTool(B,ListTools,ListItems);
	?default::removeDuplicateTool(ListTools,ListToolsNew);
	+number_of_tasks(.length(ListItems)+.length(ListToolsNew));
	for ( .member(item(ItemId,Qty),ListItems) ) {
		!!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Quad);
	}
	for ( .member(item(ItemId,Qty),ListToolsNew) ) {
		!!announce(item(ItemId,Qty),Deadline,NumberOfAgents,Quad);
	}
	.member(agent(Agent,workshop),Members);
	+awarded_assemble(Agent,Items,Storage);
	.
	
@selectBids[atomic]
+bids(item(_,_),_)
	: .count(initiator::bids(_,_),NumberOfBids) & number_of_tasks(NumberOfTasks) & NumberOfBids == NumberOfTasks
<-
	-number_of_tasks(NumberOfTasks);
	for ( bids(item(ItemId,Qty),Bids) ) {
		if (.substring("tool",ItemId)) {
			-bids(item(ItemId,Qty),Bids);
			?default::select_bid_tool(Bids,bid(99999,99999),bid(Agent,Bid));
			if (Bid \== 99999) {
				getLoad(Agent,Load);
				?default::item(ItemId,Volume,_,_);
		    	addLoad(Agent,Load-Volume*Qty);
				if (not initiator::awarded(Agent,tool,_)) {
					+awarded(Agent,tool,[item(ItemId,Qty)]);
				}
				else {
					?awarded(Agent,tool,List);
		    		-awarded(Agent,tool,List);
		    		.concat(List,[item(ItemId,Qty)],NewList);
		    		+awarded(Agent,tool,NewList);
				}
			}
			else { +impossible_task }
		}
	}
	for ( bids(item(ItemId,Qty),Bids) ) {
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
				?awarded(Agent,_,List);
	    		-awarded(Agent,_,List);
	    		.concat(List,[item(ItemId,Qty)],NewList);
	    		+awarded(Agent,Shop,NewList);
			}
		}
		else { +impossible_task }
	}
	if (not impossible_task) {
		?awarded_assemble(AgentA,Items,Storage);
		.send(AgentA,tell,winner(Items,Storage));
		for (awarded(Agent,Shop,List)) {
	    	.send(Agent,tell,winner(List));
			-awarded(Agent,Shop,List);	
		}
	}
	else { -impossible_task; .print("Impossible job, aborting it."); }
	.	