evaluateBid(Reward,0,MyBid) 			:- MyBid = Reward-6.
evaluateBid(Reward,CurrentBid,MyBid) 	:- MyBid = CurrentBid-6.

!triggerFuturePlan.

+!triggerFuturePlan
	: default::step(Step) & ::futurePlans(Event,StepFuture) & (StepFuture <= Step) 
<-
	.print("Triggering plan ",Event," at step ",Step);
    !!Event;
    -::futurePlans(Event,StepFuture);
    .print("Triggered");
    !triggerFuturePlan;
	.
+!triggerFuturePlan
//	: ::futurePlans(_,_)
<-
//	.wait({+step(Step)});
	.wait({+default::step(Step)});
	!triggerFuturePlan;
	.
//+!triggerFuturePlan.

// USE O DECOMPOSE
+!analyse_auction_job(Id)	
	: default::auction(Id,_,Reward,Start,_,_,0,Time,Items)	
<-
	.print("Analysing auction job");	
	
	?default::decomposeRequirements(Items,[],Bases);
	+::bases([],Id);
	for ( .member(Item,Bases) ) {
		?::bases(L,Id);
		.concat(L,Item,New);
		-+::bases(New,Id);
	}
	?::bases(B,Id);
	-::bases(B,Id);
	if (.substring("tool",B)) {
		?default::separateItemTool(B,ListTools,ListItems); 
		?default::removeDuplicateTool(ListTools,ListToolsNew);
	}
	else { ListToolsNew = []; ListItems = B; }
	?default::check_price(ListToolsNew,ListItems,0,ResultP);
	Limit = math.ceil(ResultP*1.8);
	-+::bidding(Id,0,Limit);
	.print("Limit is ",Limit);
	.print("Reward is ",Reward);
	
	+::futurePlans(free_for_next_auction(Id),Start+Time);
//	if (not .desire(triggerFuturePlan)){
//		.print("Not counting future plans");
//		!!triggerFuturePlan;
//	}	
	!send_a_bid(Id);
//	!strategies::free;
	.
+!analyse_auction_job(Id)	
	: default::auction(Id,_,_,_,_,_,_,_,_)	
<-
	.print("Analysing auction job");	
	!send_a_bid(Id);
	.
+!analyse_auction_job(Id)	
	: true
<-
	.print("Job is not an auction");
	.

+!send_a_bid(Id)
	: default::auction(Id,_,Reward,_,_,_,Bid,_,_) & ::bidding(Id,_,Limit) & (Limit >= Reward)
<-
	.print("Limit ",Limit," is greater or equal to Reward ",Reward);
//	!strategies::free;
	!strategies::not_reasoning;
	.
+!send_a_bid(Id)
	: default::auction(Id,_,_,_,_,_,Bid,_,_) & ::bidding(Id,CurrentBid,Limit) & (Bid \== 0) & (CurrentBid > 0) & (Bid < Limit)
<-
	.print("Bid ",Bid," is lower than the limit of ",Limit);
//	!strategies::free;
	!strategies::not_reasoning;
	.
+!send_a_bid(Id)
	: default::auction(Id,_,Reward,_,_,_,Bid,_,_) & ::bidding(Id,_,Limit)	
<-
	?::evaluateBid(Reward,Bid,NewBid);
//	NewBid = Limit+1;
	
	if (NewBid >= Limit){
		.print("Posting bid of ",NewBid);	
		-+::bidding(Id,NewBid,Limit);
		!action::bid_for_job(Id,NewBid);	
	}
	else{
		.print("CounterBid ",NewBid," is lower than the limit of ",Limit);
//		!strategies::free;
		!strategies::not_reasoning;
	}
	.
	
+!free_for_next_auction(AuctionId) 
	: ::bidding(AuctionId,_,_) 
<- 
	-::bidding(AuctionId,_,_);
	. 
	