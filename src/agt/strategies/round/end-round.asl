{begin namespace(lEndRound, local)}

+!end_round
	: .my_name(Me)
<-
	.print("---------------- END OF THE ROUND ----------------");
	!print_metrics;	
	?default::focused(vehicleart,team_artifact,Id1);
	.concat("eis_art_",Me,ArtMeS);
	.term2string(ArtMe,ArtMeS);
	?default::focused(vehicleart,ArtMe,Id2);
	?default::joined(vehicleart,Id3);
	?default::joined(main,Id4);
	if (Me == vehicle1) { ?initiator::task_id(TaskId); }
	.abolish(_::_[source(_)]);
	+default::focused(vehicleart,team_artifact,Id1);
	+default::focused(vehicleart,ArtMe,Id2);
	+default::joined(vehicleart,Id3);
	+default::joined(main,Id4);
	if (Me == vehicle1) { +initiator::task_id(TaskId); }
    .drop_all_intentions;
    .drop_all_desires;
    .drop_all_events;	
	.
	
@changeV1[atomic]
+!change_round
	: .my_name(vehicle1)
<-
	!end_round;
	setMap;
	.wait(500);
	clearMaps;
	!new::new_round;
	.
@change[atomic]
+!change_round
	: true
<-
	!end_round;
	!new::new_round;
	.	

@metrics[atomic]
+!print_metrics
	: .my_name(vehicle1) 
<-
	.print("--- Some Metrics ---");
	?metrics::money(Money);
	.print("Total amount of money: ",Money); // Ok
	?metrics::completedJobs(JobsCompleted);
	.print("Number of completed jobs: ",JobsCompleted); 
	?metrics::failedJobs(JobsFailed);
	.print("Number of failed jobs: ",JobsFailed); 	
	?metrics::completedAuctions(AuctionsCompleted);
	.print("Number of completed auctions: ",AuctionsCompleted); 
	?metrics::failedAuctions(AuctionsFailed);
	.print("Number of failed auctions: ",AuctionsFailed); 	
	?metrics::completedMissions(MissionsCompleted);
	.print("Number of completed missions: ",MissionsCompleted); 
	?metrics::failedMissions(MissionsFailed);
	.print("Number of failed missions: ",MissionsFailed); 
	?metrics::finePaid(Fine);
	.print("Fine paid: ",Fine); 
	!print_common_metrics;
	.print("--------------------");
	.	
+!print_metrics
<-
	.print("--- Some Metrics ---");
	!print_common_metrics;
	.print("--------------------");
	.
+!print_common_metrics
<-
	?metrics::noAction(NoActions); // Ok
	.print("Number of no actions: ",NoActions);
	?metrics::held_actions(HeldActions); // Ok
	.print("Number of held actions: ",HeldActions);
	?metrics::jobHaveWorked(Jobs);
	.print("Jobs I have worked: ",Jobs);
	?metrics::jobCompletedMyPart(JobsMyPart);
	.print("Jobs I have completed my part: ",JobsMyPart);
	.


{end}

+default::simEnd 
<- 
	!lEndRound::change_round;
	.