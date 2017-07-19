{begin namespace(lEndRound, local)}

+!end_round
	: .my_name(Me)
<-
	.print("---------------- END OF THE ROUND ----------------");
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
	!new::new_round;
	.
@change[atomic]
+!change_round
	: true
<-
	!end_round;
	!new::new_round;
	.	

{end}

+default::simEnd 
<- 
	!lEndRound::change_round;
	.