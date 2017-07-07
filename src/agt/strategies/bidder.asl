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
	!create_bid_mission(Storage,Items,Distance);
	if (Distance >= End-Start) {
		bid(Me,-1)[artifact_id(BoardId)];
	}
	else { bid(Me,Distance)[artifact_id(BoardId)]; }
	.
	
@create_bid_mission[atomic]
+!create_bid_mission(Storage,Items,Distance)
	: coalition::coalition(Quad, _, _) & new::shopList(SList) & new::workshopList(WList) & default::getQuadLatLon(Quad,QLat,QLon) & new::vehicle_mission(Role,Speed)
<-
	?default::decomposeRequirementsNoTools(Items,[],Bases);
	actions.closest(Role,WList,Storage,ClosestWorkshop);
	actions.route(Role,Speed,ClosestWorkshop,Storage,RouteStorage);
	+distance(RouteStorage);
	for ( .member(ItemId,Bases) ) {
		?default::find_shops(ItemId,SList,Shops);
		actions.closest(Role,QLat,QLon,Shops,_,ClosestShop);
		actions.route(Role,Speed,QLat,QLon,ClosestShop,_,RouteShop);
		actions.route(Role,Speed,ClosestShop,ClosestWorkshop,RouteWorkshop);
		?distance(D);
		-+distance(D+RouteShop+RouteWorkshop);
	}
	?distance(Dist);
	-distance(Dist);
	Distance = Dist;
	.
	
+default::winner(mission(Id, Storage, Reward, Start, End, Fine, Items))
<- .print("I won mission ",Id).