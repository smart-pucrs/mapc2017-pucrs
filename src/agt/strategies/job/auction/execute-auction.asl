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
	
// ERA IMPORTANTE POIS ESTAVAMOS LANÇANDO BIDS DESDE O INICIO, AGORA SÓ FAZEMOS ISSO NO ULTIMO PASSO DA BID
//+default::winner(TaskList, assist(Storage, Assembler, JobId))
//	: default::auction(JobId,_,_,Start,_,_,_,Time,_)
//<-
//	.print("I won the auction tasks(",JobId,") ",TaskList);
//	+::futurePlans(figure_out_auction_winning(JobId),Start+Time);
//	!!start_auction_tasks(JobId,massist);
//	.
//+default::winner(TaskList, assemble(Storage, JobId))
//	: default::auction(JobId,_,_,Start,_,_,_,Time,_)
//<-
//	.print("I won the auction tasks to assemble ",TaskList," and deliver to ",Storage," for ",JobId);
//	+::futurePlans(figure_out_auction_winning(JobId),Start+Time);
//	!!start_auction_tasks(JobId,massemble);
//	.
//	
//+!start_auction_tasks(JobId,Mission)
//	: default::joined(org,OrgId)
//<-
////	.suspend;
//	.print("vai suspender");
//	.suspend(::start_auction_tasks(_,_));
//	!strategies::not_free;
//	.print("Starting my auction task ",Mission);
//	lookupArtifact(JobId,SchArtId)[wid(OrgId)];
//	org::focus(SchArtId)[wid(OrgId)];
//	org::commitMission(Mission)[artifact_id(SchArtId)];
//	.
//	
//+!figure_out_auction_winning(AuctionId)
//	: default::auction(AuctionId, Storage, Reward, Start, End, Fine, Bid, Time, Items)	
//<-	
//	.print("We win auction ",AuctionId);	
//	.resume(::start_auction_tasks(_,_));	
//	.resume(execution_auction::start_auction_tasks(_,_));	
//	.print("resumiu ");
//	.
//+!figure_out_auction_winning(AuctionId) 
//<- 
//	.print("We lost auction ",AuctionId);
//	-default::winner(_,_)[source(_)];
//	.drop_desire(::start_auction_tasks(_,_));	
//	!strategies::empty_load;
//	!strategies::free;
//	.

+default::winner(TaskList, assist(Storage, Assembler, JobId))
	: default::auction(JobId,_,_,Start,_,_,_,Time,_)
<-
	.print("I won the auction tasks(",JobId,") ",TaskList);
	+::futurePlans(figure_out_auction_winning(JobId,massist),Start+Time);
	.
+default::winner(TaskList, assemble(Storage, JobId))
	: default::auction(JobId,_,_,Start,_,_,_,Time,_)
<-
	.print("I won the auction tasks to assemble ",TaskList," and deliver to ",Storage," for ",JobId);
	+::futurePlans(figure_out_auction_winning(JobId,massemble),Start+Time);
	.
		
+!figure_out_auction_winning(JobId,Mission)
	: default::auction(JobId, Storage, Reward, Start, End, Fine, Bid, Time, Items) & default::joined(org,OrgId) & metrics::jobHaveWorked(Jobs)
<-
	!strategies::not_free;	
	.print("We win auction ",JobId);
	.print("Starting my auction task ",Mission);
	-+metrics::jobHaveWorked(Jobs+1);
	lookupArtifact(JobId,SchArtId)[wid(OrgId)];
	org::focus(SchArtId)[wid(OrgId)];
	org::commitMission(Mission)[artifact_id(SchArtId)];
	.
+!figure_out_auction_winning(JobId,Mission) 
<- 
	.print("We lost auction ",JobId);
	-default::winner(_,_)[source(_)];	
	!strategies::empty_load;
	!strategies::free;
	.
