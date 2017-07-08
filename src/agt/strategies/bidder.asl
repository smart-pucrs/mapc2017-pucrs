+default::task(Task,CNPBoard,TaskId)
	: .my_name(Me) & new::coalition_leaders(Leaders) & .sublist([Me],Leaders)
<- 
	lookupArtifact(CNPBoard,BoardId);
	focus(BoardId);
    !make_bid(Task,BoardId,TaskId);
  	.
  	
+default::task(Task,CNPBoard,TaskId,QuadS)
	: .term2string(Quad,QuadS) & coalition::coalition(Quad, _, _)
<- 
	lookupArtifact(CNPBoard,BoardId);
	focus(BoardId);
    !make_bid(Task,BoardId,TaskId);
  	.
  	
+!make_bid(mission(Id, Storage, Reward, Start, End, Fine, Items),BoardId,TaskId)
	: .my_name(Me)
<-
	if (not default::winner(mission(_,_,_,_,_,_,_))) {
		!create_bid_mission(Storage,Items,Distance);
		if (Distance >= End-Start) {
			bid(Me,-1)[artifact_id(BoardId)];
		}
		else { bid(Me,Distance)[artifact_id(BoardId)]; }
	}
	else { bid(Me,-1)[artifact_id(BoardId)]; }
	.
+!make_bid(item(ItemId, Qty),BoardId,TaskId)
	: .my_name(Me)
<-
	!create_bid_task(item(ItemId, Qty), Bid);
	bid(Me,Bid)[artifact_id(BoardId)];
	.

@create_bid_task[atomic]
+!create_bid_task(item(ItemId, Qty), Bid)
	: default::load(MyLoad) & default::role(Role, Speed, LoadCap, _, Tools) & default::item(ItemId,Vol,_,_) & new::shopList(SList)
<-
    if (.substring("item",ItemId)) {
		if (LoadCap - MyLoad >= Vol * Qty + 15) {
			?default::find_shops(ItemId,SList,Shops);
			actions.closest(Role,Shops,ClosestShop);
			actions.route(Role,Speed,ClosestShop,RouteShop);
			Bid = RouteShop;
		}
		else { Bid = -1 }
	}
	else { 
		if (.sublist([ItemId],Tools)) { 
			Bid = 1;
		}
		else { Bid = -1 }
	}
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
<- 
	.print("I won mission ",Id);
	!initiator::separate_tasks(mission(Id, Storage, Reward, Start, End, Fine, Items));
	.

+default::step(End)
	: default::winner(mission(Id, Storage, Reward, Start, End, Fine, Items))
<-
	-default::winner(mission(Id, Storage, Reward, Start, End, Fine, Items));
	.
