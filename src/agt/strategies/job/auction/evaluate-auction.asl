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
    .print("Triggered");
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
	.print("First analysing auction job at step ",S);	
	!initiator::decompose(Items,ListItems,ListToolsNew,Id);

	?default::check_price(ListToolsNew,ListItems,0,ResultP);
	Limit = math.ceil(ResultP*1.8);
	+::bidding(Id,0,0,Limit);
	.print("Limit is ",Limit);
	.print("Reward is ",Reward);
	
	+::futurePlans(further_analysis(Id),Start+Time-1);
	+::futurePlans(free_for_next_auction(Id),Start+Time);
	.

+!further_analysis(Id)	
	: default::auction(Id,Storage,Reward,Start,End,Fine,Bid,Time,Items)	& ::bidding(Id,_,BaseBid,Limit) & ::checkStillGoodAuction(Reward,Bid,BaseBid,Limit) & default::step(S)
<-
	+action::hold_action;
	.print("Final analysis for ",Id," at step ",S);	
	
	!initiator::evaluate_job(Items, End - Start, Storage, Id, Reward);
	.
+!further_analysis(Id)	
<-
	.print(Id," is not a good auctionJob anymore");	
	.
	
+!analyse_bid_posted(Id)
	: ::bidding(Id,0,_,Limit) & default::auction(Id,_,Reward,_,_,_,Bid,_,_)
<-
	.print("Someone post a initial bid ",Bid,", it decreases in ",Reward-Bid);
	-+::bidding(Id,Bid,Reward-Bid,Limit);
	.
+!analyse_bid_posted(Id)
	: ::bidding(Id,LastBestBid,IncreaseBid,Limit) & default::auction(Id,_,_,_,_,_,Bid,_,_)
<-
	.print("Someone post bid",Bid,", it decreases in ",LastBestBid-Bid);
	-+::bidding(Id,Bid,LastBestBid-Bid,Limit);
	.

+!analyse_auction_job(Id)	
	: default::auction(Id,_,_,_,_,_,_,_,_)	
<-
	.print("Analysing auction job");	
	!send_a_bid(Id);
	.
+!analyse_auction_job(Id)	
<-
	.print("Job is not an auction");
	.

+!send_a_bid(Id)
	: default::auction(Id,_,Reward,_,_,_,Bid,_,_) & ::bidding(Id,_,BaseBid,Limit)	
<-
	?::evaluateBid(Reward,Bid,BaseBid,NewBid);
	
	.print("Posting bid of ",NewBid);
	!action::bid_for_job(Id,NewBid);

	-action::hold_action;	
	.
	
+!free_for_next_auction(AuctionId) 
	: ::bidding(AuctionId,_,_,_) 
<- 
	-::bidding(AuctionId,_,_,_);
	. 