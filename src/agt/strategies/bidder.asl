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
	
@create_bid_mission[atomic]
+!create_bid_mission(Storage,Items,QuadShop,QuadStorage,Distance)
	: coalition::coalition(Quad, _, _) & default::getFacility(Storage,StLat,StLon,Aux1,Aux2) & new::shopList(SList)
<-
	if (default::checkQuadrant(Quad,StLat,StLon)) { QuadStorage = 1 }
	else { QuadStorage = 0 }
	?default::decomposeRequirementsNoTools(Items,[],Bases);
	for ( .member(ItemId,Bases) ) {
		+break(ItemId,"false");
		?default::find_shops(ItemId,SList,Shops);
		for ( .member(Shop,Shops) ) {
			if ( break(ItemId,"false") ) {
				?default::getFacility(Shop,ShLat,ShLon,AuxSh1,AuxSh2);
				if (default::checkQuadrant(Quad,ShLat,ShLon)) { -break(ItemId,"false"); +break(ItemId,"true"); }
			}
		}
	}
	.length(Bases,N);
	if (.count(bidder::break(_,"true"),N) ) { QuadShop = 1 }
	else { QuadShop = 0 }
	.abolish(bidder::break(_,_));
	Distance = 0;
	.