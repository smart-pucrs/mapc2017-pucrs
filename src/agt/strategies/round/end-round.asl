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
	.abolish(_::_[source(_)]);
	+default::focused(vehicleart,team_artifact,Id1);
	+default::focused(vehicleart,ArtMe,Id2);
	+default::joined(vehicleart,Id3);
	+default::joined(main,Id4);
    .drop_all_intentions;
    .drop_all_desires;
    .drop_all_events;	
	.

+!change_round
	: .my_name(vehicle1)
<-
	!end_round;
	setMap;
	.wait(500);
	!new::new_round;
	.
+!change_round
	: true
<-
	!end_round;
	.wait(500);
	!new::new_round;
	.	

{end}

+default::simEnd 
<- 
	!lEndRound::change_round;
	.