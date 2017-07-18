

{begin namespace(lEndRound, local)}

abolishNotPercepts(Suffix,29).
abolishNotPercepts(Suffix,Id) :- .concat(Suffix,Id,AgentName) & .term2string(TermName,AgentName) & .abolish(_::_[source(TermName)]) & abolishNotPercepts(Suffix,Id+1).

+!end_round
	: true
<-
	.print("-------------------- END OF THE ROUND ----------------");
	.abolish(_::_[source(self)]);
//	.abolish(_::_[source(X)]);
	?abolishNotPercepts("vehicle",1);
    .drop_all_intentions;
    .drop_all_desires;
    .drop_all_events;	
	.

+!change_round
	: true
<-
	!end_round;
	
	setMap;
	.wait(500);
	
	!new::new_round;
	.

{end}

{begin namespace(gEndRound, global)}

{end}

+default::simEnd 
<- 
	!lEndRound::change_round;
	.
	
+default::bye 
<- 
	.print("################# ACABOU POHAAA!!! ");
	.

