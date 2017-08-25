evaluateBid(Reward,0,BaseBid,MyBid) 			:- MyBid = Reward-(BaseBid+6).
evaluateBid(Reward,CurrentBid,BaseBid,MyBid) 	:- MyBid = CurrentBid-(BaseBid+6).

checkPossibleBid(Reward,CurrentBid,BaseBid,Limit) 		:- ::evaluateBid(Reward,Bid,BaseBid,NewBid) & (Limit <= NewBid).
checkLimit(Reward,0,Limit) 								:- (Limit < Reward).
checkLimit(Reward,CurrentBid,Limit) 					:- (Limit < Reward) & (Limit < CurrentBid).
checkStillGoodAuction(Reward,CurrentBid,BaseBid,Limit) 	:- checkLimit(Reward,CurrentBid,Limit) & checkPossibleBid(Reward,CurrentBid,BaseBid,Limit).

!triggerFuturePlan.

+!triggerFuturePlan
	: default::step(Step) & ::futurePlans(Event,StepFuture) & (StepFuture <= Step) 
<-
	.print("Triggering plan ",Event," at step ",Step);
    !!Event;
    -::futurePlans(Event,StepFuture);
    !triggerFuturePlan;
	.
+!triggerFuturePlan
<-
	.wait({+default::step(Step)});
	!triggerFuturePlan;
	.

+!first_analysis(Id)	
	: default::auction(Id,_,Reward,Start,_,_,0,Time,Items) & default::step(S)
<-
	.print("First analysis auction job at step ",S);	
	!initiator::decompose(Items,ListItems,ListToolsNew,Id);

	?default::check_price(ListToolsNew,ListItems,0,ResultP);
	Limit = math.ceil(ResultP*1.8);	
//	.print("Limit is ",Limit);
//	.print("Reward is ",Reward);
	
	if (Limit < Reward) {
		+::bidding(Id,0,0,Limit);
//		+::futurePlans(further_analysis(Id),Start+Time-1);
		!::choose_between_auctions_at_same_step(Id,Start+Time-1);
		+::futurePlans(free_for_next_auction(Id),Start+Time);			
	}
	else{
		.print("Expected limit to bid ",Limit," is greater than the reward ",Reward);
	}
	.
	
+!choose_between_auctions_at_same_step(AuctionId,StartTime)
	: ::futurePlans(further_analysis(Id),StartTime)
<- 
	.print("There is other auction ",Id," at the same future step ",StartTime);
	
	?default::auction(Id,_,RewardOld,_,_,_,_,_,_);
	?default::auction(AuctionId,_,RewardCurrent,_,_,_,_,_,_);
	
	if (RewardCurrent > RewardOld){
		-::futurePlans(further_analysis(Id),StartTime);
		+::futurePlans(further_analysis(AuctionId),StartTime);
	}
	.
+!choose_between_auctions_at_same_step(AuctionId,StartTime)
<- 
	+::futurePlans(further_analysis(AuctionId),StartTime);
	.

//+!further_analysis(Id)	
//	: default::auction(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)	& ::bidding(Id,_,BaseBid,Limit) & ::checkStillGoodAuction(Reward,Bid,BaseBid,Limit) & default::step(S)
//<-
//	!strategies::not_free;
//	+action::hold_action(Id);
//	+::hasSetFree;
//	.print("Final analysis for ",Id," at step ",S);	
//	
//	!initiator::evaluate_job(Items, End, Storage, Id, Reward);
//	.
//+!further_analysis(Id)	
//<-
//	.print(Id," is not a good auctionJob anymore");	
//	.
+!further_analysis(Id)
<- 
	+action::hold_action(Id);
	!strategies::not_free;	
	+::hasSetFree;
	!check_further_analysis(Id);
	.
+!check_further_analysis(Id)	
	: action::action(S) & default::step(S) & metrics::missBidAuction(M)
<-	
	-action::hold_action(Id);
	!::has_set_to_free;
	
	.print("¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ We lost the action at step ",S," we cannot bid for ",Id," anymore");	
	-+metrics::missBidAuction(M+1);
	.
+!check_further_analysis(Id)	
	: default::auction(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)	& ::bidding(Id,_,BaseBid,Limit) & ::checkStillGoodAuction(Reward,Bid,BaseBid,Limit) & default::step(S)
<-
//	!strategies::not_free;
//	+action::hold_action(Id);
//	+::hasSetFree;
	.print("Final analysis for ",Id," at step ",S);	
	
	!initiator::evaluate_job(Items, End, Storage, Id, Reward);
	.
+!check_further_analysis(Id)	
<-
	-action::hold_action(Id);
	!::has_set_to_free;
	.print(Id," is not a good auctionJob anymore");	
	.
	
+!has_set_to_free
	: (not default::winner(_,_) | strategies::waiting) & ::hasSetFree 
<-
	-::hasSetFree;
	!strategies::free;
	.
+!has_set_to_free
	: ::hasSetFree 
<-
	-::hasSetFree;
	.
+!has_set_to_free.
	
+!analyse_bid_posted(Id)
	: ::bidding(Id,0,_,Limit) & default::auction(Id,_,Reward,_,_,_,Bid,_,_)
<-
	.print("Someone post a initial bid ",Bid,", it decreases in ",Reward-Bid);
	-::bidding(Id,0,_,Limit);
	+::bidding(Id,Bid,Reward-Bid,Limit);
	.
+!analyse_bid_posted(Id)
	: ::bidding(Id,LastBestBid,IncreaseBid,Limit) & default::auction(Id,_,_,_,_,_,Bid,_,_)
<-
	.print("Someone post bid",Bid,", it decreases in ",LastBestBid-Bid);
	if ((LastBestBid-Bid) >IncreaseBid){
		-::bidding(Id,LastBestBid,IncreaseBid,Limit);
		+::bidding(Id,Bid,LastBestBid-Bid,Limit);
	}
	else{
		.print("Other team has posted a better bid");
	}
	.

+!send_a_bid(Id)
	: default::auction(Id,_,Reward,Start,_,_,Bid,Time,_) & ::bidding(Id,_,BaseBid,Limit)	
<-
	?::evaluateBid(Reward,Bid,BaseBid,NewBid);
	
	+::futurePlans(figure_out_auction_winning(Id),Start+Time);
	
	.print("Posting bid of ",NewBid);
	-action::hold_action(Id);
	!action::bid_for_job(Id,NewBid);
	.

+!free_for_next_auction(AuctionId) 
	: ::bidding(AuctionId,_,_,_) 
<- 
	-::bidding(AuctionId,_,_,_);
	. 
	
+!figure_out_auction_winning(JobId)
	: default::auction(JobId,_,_,_,_,_,_,_,_) & default::joined(org,OrgId)
<-
	.print("We win auction ",JobId);
	
	org::createScheme(JobId, st, SchArtId)[wid(OrgId)];
	?initiator::awarded_assemble(AgentA,Items,Storage,JobId);
	-initiator::awarded_assemble(AgentA,Items,Storage,JobId);
	
	-initiator::free_trucks_auction(JobId,_);
	-initiator::free_agents_auction(JobId,_);
	
	.print("For ",JobId);
	for ( initiator::awarded(Agent,Shop,List,JobId,TaskCount) ) {
		.send(Agent,tell,winner(List,assist(Storage,AgentA,JobId)));
		-initiator::awarded(Agent,Shop,List,JobId,TaskCount);	
		.print(Agent," ",AgentA," ",List);
	}
	.send(AgentA,tell,winner(Items,assemble(Storage,JobId)));
	.print(AgentA," ",Items);
	.
@loseAuction[atomic]
+!figure_out_auction_winning(JobId) 
<- 
	.print("We lost auction ",JobId);
	
	?initiator::free_trucks_auction(JobId,FreeTrucksAuction);
	-initiator::free_trucks_auction(JobId,FreeTrucksAuction);
	?initiator::free_trucks(FreeTrucksA);			
	.concat(FreeTrucksAuction,FreeTrucksA,FreeTrucksNewA);			
	-+initiator::free_trucks(FreeTrucksNewA);
	
	?initiator::free_agents_auction(JobId,FreeAgentsAuction);
	-initiator::free_agents_auction(JobId,FreeAgentsAuction);
	?initiator::free_agents(FreeAgents);
	.concat(FreeAgentsAuction,FreeAgents,FreeAgentsNew);
	-+initiator::free_agents(FreeAgentsNew);
	
	-job(JobId,_);
	-awarded_assemble(_,_,_,JobId);
	-eval(JobId);
	.abolish(initiator::bids(_,_,JobId));
	.abolish(initiator::awarded(_,_,_,JobId,_));
	.