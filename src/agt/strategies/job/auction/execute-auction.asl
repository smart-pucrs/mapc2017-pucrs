::teste.

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
	
+default::winner(TaskList, assist(Storage, Assembler, JobId))
	: default::auction(AuctionId,_,_,Start,_,_,_,Time,_)
<-
	.print("I won the auction tasks(",JobId,") ",TaskList);
	+::futurePlans(figure_out_auction_winning(AuctionId),Start+Time);
	!!start_auction_tasks(JobId,massist);
	.
+default::winner(TaskList, assemble(Storage, JobId))
	: default::auction(AuctionId,_,_,Start,_,_,_,Time,_)
<-
	.print("I won the auction tasks to assemble ",TaskList," and deliver to ",Storage," for ",JobId);
	+::futurePlans(figure_out_auction_winning(AuctionId),Start+Time);
	!!start_auction_tasks(JobId,massemble);
	.
	
+!start_auction_tasks(JobId,Mission)
	: default::joined(org,OrgId)
<-
	.suspend;
	!strategies::not_free;
	.print("Starting my auction task ",Mission);
	lookupArtifact(JobId,SchArtId)[wid(OrgId)];
	org::focus(SchArtId)[wid(OrgId)];
	org::commitMission(Mission)[artifact_id(SchArtId)];
	.
	
+!figure_out_auction_winning(AuctionId)
	: default::auction(AuctionId, Storage, Reward, Start, End, Fine, Bid, Time, Items)	
<-	
	-initiator::bidding(AuctionId,_);
	.print("We win auction ",AuctionId);	
	.resume(::start_auction_tasks(_,_));
	.
+!figure_out_auction_winning(AuctionId) 
<- 
	-initiator::bidding(AuctionId,_); 
	.print("We lost auction ",AuctionId);
	.drop_desire(::start_auction_tasks(_,_));
	-default::winner(_,_)[source(_)];
	!strategies::empty_load;
	!strategies::free;
	.

