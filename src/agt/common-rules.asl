find_shops(ItemId,[],[]).
find_shops(ItemId,[ShopId|List],[ShopId|Result]) :- shop(ShopId, _, _, _, ListItems) & .member(item(ItemId,_,_,_,_,_),ListItems) & find_shops(ItemId,List,Result).
find_shops(ItemId,[ShopId|List],Result) :- shop(ShopId, _, _, _, ListItems) & not .member(item(ItemId,_,_,_,_,_),ListItems) & find_shops(ItemId,List,Result).

closest_facility(List, Facility) :- role(Role, _, _, _, _) & actions.closest(Role, List, Facility).
closest_facility(List, Facility1, Facility2) :- role(Role, _, _, _, _) & actions.closest(Role, List, Facility1, Facility2).
closest_facility(List, Lat, Lon, Facility2) :- role(Role, _, _, _, _) & actions.closest(Role, List, Lat, Lon, Facility2).

enough_battery(FacilityId1, FacilityId2, Result) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityId1, RouteLen1) & actions.route(Role, Speed, FacilityId1, FacilityId2, RouteLen2) & charge(Battery) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery(Lat, Lon, FacilityId2, Result) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, Lat, Lon, _, _, _, RouteLen1) & actions.route(Role, Speed, Lat, Lon, FacilityId2, _, RouteLen2) & charge(Battery) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery2(FacilityAux, FacilityId1, FacilityId2, Result, Battery) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityAux, FacilityId1, RouteLen1) & actions.route(Role, Speed, FacilityId1, FacilityId2, RouteLen2) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery2(FacilityAux, Lat, Lon, FacilityId2, Result, Battery) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityAux, Lat, Lon, RouteLen1) & actions.route(Role, Speed, Lat, Lon, FacilityId2, _, RouteLen2) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery_charging(FacilityId, Result) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityId, RouteLen) & charge(Battery) & ((Battery > ((RouteLen * 10) + 10) & Result = true) | (Result = false)).
enough_battery_charging2(FacilityAux, FacilityId, Result, Battery) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityAux, FacilityId, RouteLen) & ((Battery > ((RouteLen * 10) + 10) & Result = true) | (Result = false)).

select_bid([],bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),bid(BidWinner,BidAgentWinner,ShopIdWinner,ItemWinner)) :- BidWinner = AuxBid & BidAgentWinner = AuxBidAgent & ShopIdWinner = AuxShopId  & ItemWinner = AuxItem.
select_bid([bid(Bid,BidAgent,ShopId,item(ItemId,Qty))|Bids],bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),BidWinner) :- Bid \== -1 & Bid < AuxBid & ( ((not awarded(BidAgent,_,_)) )  | (awarded(BidAgent,ShopId,_) & item(ItemId,Volume,_,_) & .term2string(BidAgent,BidAgentS) & load(BidAgentS,Load) & Load >= Volume*Qty ) ) & select_bid(Bids,bid(Bid,BidAgent,ShopId,item(ItemId,Qty)),BidWinner).
select_bid([bid(Bid,BidAgent,ShopId,Item)|Bids],bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),BidWinner) :- select_bid(Bids,bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),BidWinner).

select_bid_mission([],bid(AuxAgent,AuxDistance),bid(AgentWinner,DistanceWinner)) :- AgentWinner = AuxAgent & DistanceWinner = AuxDistance.
select_bid_mission([bid(Agent,Distance)|Bids],bid(AuxAgent,AuxDistance),BidWinner) :- Distance \== -1 & Distance < AuxDistance & select_bid_mission(Bids,bid(Agent,Distance),BidWinner).
select_bid_mission([bid(Agent,Distance)|Bids],bid(AuxAgent,AuxDistance),BidWinner) :- select_bid_mission(Bids,bid(AuxAgent,AuxDistance),BidWinner).

find_shops_id([],Temp,Result) :- Result = Temp.
find_shops_id([shop(ShopId,_)|List],Temp,Result) :- find_shops_id(List,[ShopId|Temp],Result).

getFacility(FacilityId,Flat,Flon,LatAux,LonAux):- shop(FacilityId, LatAux, LonAux,_,_) & Flat=LatAux & Flon=LonAux.
getFacility(FacilityId,Flat,Flon,LatAux,LonAux):- storage(FacilityId, LatAux, LonAux,_,_,_) & Flat=LatAux & Flon=LonAux.
getFacility(FacilityId,Flat,Flon,LatAux,LonAux):- dump(FacilityId,LatAux,LonAux) & Flat=LatAux & Flon=LonAux.
getFacility(FacilityId,Flat,Flon,LatAux,LonAux):- workshop(FacilityId,LatAux,LonAux) & Flat=LatAux & Flon=LonAux.

checkQuadrant(quad1,Lat,Lon) :- coalition::minLonReal(MinLon) & coalition::maxLonReal(MaxLon) & coalition::minLatReal(MinLat) & coalition::maxLatReal(MaxLat) & coalition::mapCenter(CenterLat,CenterLon) & (Lat < MaxLat & Lat > CenterLat & Lon < CenterLon & Lon > MinLon).
checkQuadrant(quad2,Lat,Lon) :- coalition::minLonReal(MinLon) & coalition::maxLonReal(MaxLon) & coalition::minLatReal(MinLat) & coalition::maxLatReal(MaxLat) & coalition::mapCenter(CenterLat,CenterLon) & (Lat < MaxLat & Lat > CenterLat & Lon < MaxLon & Lon > CenterLon).
checkQuadrant(quad3,Lat,Lon) :- coalition::minLonReal(MinLon) & coalition::maxLonReal(MaxLon) & coalition::minLatReal(MinLat) & coalition::maxLatReal(MaxLat) & coalition::mapCenter(CenterLat,CenterLon) & (Lat < CenterLat & Lat > MinLat & Lon < CenterLon & Lon > MinLon).
checkQuadrant(quad4,Lat,Lon) :- coalition::minLonReal(MinLon) & coalition::maxLonReal(MaxLon) & coalition::minLatReal(MinLat) & coalition::maxLatReal(MaxLat) & coalition::mapCenter(CenterLat,CenterLon) & (Lat < CenterLat & Lat > MinLat & Lon < MaxLon & Lon > CenterLon).

convertListString2Term([],Temp,Result) :- Result = Temp.
convertListString2Term([String | ListString],Temp,Result) :- .term2string(Term,String) & convertListString2Term(ListString,[Term|Temp],Result).

findTools([],Temp, Result) :- Result = Temp.
findTools([Tool | ListOfTools],Temp,Result) :- .member(item(Tool,_),Temp) & findTools(ListOfTools, Temp,Result).
findTools([Tool | ListOfTools],Temp,Result) :- not .member(item(Tool,_),Temp) & findTools(ListOfTools, [item(Tool,1) | Temp],Result).
findParts(Qtd,[],Temp, Result) :- Result = Temp.
findParts(Qtd,[[PartName,PartQtd] | ListOfPart],Temp,Result) :- (NewQtd = Qtd*PartQtd) & item(PartName,_,tools(Tools),parts(Parts)) & decomposeItem(PartName,NewQtd,Tools,Parts,Temp,ListItensJob) & findParts(Qtd,ListOfPart,ListItensJob,Result).
decomposeItem(Item,Qtd,[],[],Temp,ListItensJob) :- ListItensJob = [item(Item,Qtd) | Temp].
decomposeItem(Item,Qtd,Tools,Parts,Temp,ListItensJob) :- findTools(Tools,Temp,NewTempTools) & findParts(Qtd,Parts,NewTempTools,NewTempParts) & ListItensJob = NewTempParts.
findPartsNoTools([],Temp, Result) :- Result = Temp.
findPartsNoTools([[PartName,_] | ListOfPart],Temp,Result) :- item(PartName,_,_,parts(Parts)) & decomposeItemNoTools(PartName,Parts,Temp,ListItensJob) & findPartsNoTools(ListOfPart,ListItensJob,Result).
decomposeItemNoTools(Item,[],Temp,ListItensJob) :- ListItensJob = [Item | Temp].
decomposeItemNoTools(Item,Parts,Temp,ListItensJob) :- findPartsNoTools(Parts,[],NewTempParts) & ListItensJob = NewTempParts.

decomposeRequirements([],Temp,Result):- Result = Temp.
//decomposeRequirements([required(Item,Qtd) | Requirements],Temp,Result):- item(Item,_,tools(Tools),parts(Parts)) & decomposeItem(Item,Qtd,Tools,Parts,Temp,ListItensJob) & decomposeRequirements(Requirements,ListItensJob,Result).
decomposeRequirements([required(Item,Qtd) | Requirements],Temp,Result):- item(Item,_,tools(Tools),parts(Parts)) & decomposeItem(Item,Qtd,Tools,Parts,[],ListItensJob) & decomposeRequirements(Requirements,[ListItensJob|Temp],Result).
decomposeRequirementsNoTools([],Temp,Result):- Result = Temp.
decomposeRequirementsNoTools([required(Item,_) | Requirements],Temp,Result):- item(Item,_,_,parts(Parts)) & decomposeItemNoTools(Item,Parts,[],ListItensJob) & .union(ListItensJob,Temp,New) & decomposeRequirementsNoTools(Requirements,New,Result).

getQuadLatLon(quad1,QLat,QLon) :- coalition::quad1(QLat,QLon).
getQuadLatLon(quad2,QLat,QLon) :- coalition::quad2(QLat,QLon).
getQuadLatLon(quad3,QLat,QLon) :- coalition::quad3(QLat,QLon).
getQuadLatLon(quad4,QLat,QLon) :- coalition::quad4(QLat,QLon).