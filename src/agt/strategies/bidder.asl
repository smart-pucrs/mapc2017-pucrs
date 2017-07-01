+default::task(Task,CNPBoard,TaskId)
	: .my_name(Me) & new::coalition_leaders(Leaders) & .sublist([Me],Leaders)
<- 
	lookupArtifact(CNPBoard,BoardId);
	focus(BoardId);
    !make_bid(Task,BoardId,TaskId);
  	.
  	
+!make_bid(mission(Id, Storage, Reward, Start, End, Fine, Items),BoardId,TaskId)
	: .my_name(Me)
<-
	!create_bid_mission(Storage,Items,QuadShop,QuadStorage,Distance);
	bid(QuadShop,QuadStorage,Distance,Me)[artifact_id(BoardId)];
	.
	
+!create_bid_mission(Storage,Items,QuadShop,QuadStorage,Distance)
	: coalition::coalition(Quad, _, _) & default::getFacility(Storage,StLat,StLon,Aux1,Aux2)
<-
	if (default::checkQuadrant(Quad,StLat,StLon)) { QuadStorage = 1 }
	else { QuadStorage = 0 }
	QuadShop = 0;
	Distance = 0;
	.