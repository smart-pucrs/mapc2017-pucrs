!triggerFuturePlan.

+!triggerFuturePlan
	: default::step(Step) & ::futurePlans(Event,StepFuture) & (StepFuture <= Step) 
<-
//	.print("Triggering plan ",Event," at step ",Step);
    !!Event;
    -::futurePlans(Event,StepFuture);
    !triggerFuturePlan;
	.
+!triggerFuturePlan
<-
	.wait({+default::step(Step)});
	!triggerFuturePlan;
	.

+default::winner(TaskList, assist(Storage, Assembler, JobId))
	: default::auction(JobId,_,_,Start,_,_,_,Time,_)
<-
	.print("I won the auction tasks(",JobId,") ",TaskList);
	+::futurePlans(figure_out_auction_winning(JobId,massist),Start+Time+1);
	.
+default::winner(TaskList, assemble(Storage, JobId))
	: default::auction(JobId,_,_,Start,_,_,_,Time,_)
<-
	.print("I won the auction tasks to assemble ",TaskList," and deliver to ",Storage," for ",JobId);
	+::futurePlans(figure_out_auction_winning(JobId,massemble),Start+Time+1);
	.
		
+!figure_out_auction_winning(JobId,Mission)
	: default::auction(JobId, Storage, Reward, Start, End, Fine, Bid, Time, Items) & default::joined(org,OrgId) & metrics::jobHaveWorked(Jobs)
<-
	!strategies::not_free;	
	.print("We win auction ",JobId);
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
