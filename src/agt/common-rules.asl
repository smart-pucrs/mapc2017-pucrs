find_shops(ItemId,[],[]).
find_shops(ItemId,[ShopId|List],[ShopId|Result]) :- shop(ShopId, _, _, _, ListItems) & .member(item(ItemId,_,_,_,_,_),ListItems) & find_shops(ItemId,List,Result).
find_shops(ItemId,[ShopId|List],Result) :- shop(ShopId, _, _, _, ListItems) & not .member(item(ItemId,_,_,_,_,_),ListItems) & find_shops(ItemId,List,Result).

closest_facility(List, Facility) :- role(Role, _, _, _, _) & actions.closest(Role, List, Facility).
closest_facility(List, Facility1, Facility2) :- role(Role, _, _, _, _) & actions.closest(Role, List, Facility1, Facility2).
closest_facility(List, Lat, Lon, Facility2) :- role(Role, _, _, _, _) & actions.closest(Role, List, Lat, Lon, Facility2).
//closest_facility_from_center(CenterLat, CenterLon, List, ShopId) :- Role = "Drone" & actions.closest(Role, CenterLat, CenterLon, List, ShopId).

//route(FacilityId, RouteLen) :- role(Role, _, _, _, _) & actions.route(Role, FacilityId, RouteLen).
//route(FacilityId1, FacilityId2, RouteLen) :- role(Role, _, _, _, _) & actions.route(Role, FacilityId1, FacilityId2, RouteLen).
//route_drone_from_center(CenterLat, CenterLon, FacilityId, RouteLen) :- Role = "Drone" & actions.route(Role, CenterLat, CenterLon, FacilityId, RouteLen).
//route_car_from_center(CenterLat, CenterLon, FacilityId, RouteLen) :- Role = "Car" & actions.route(Role, CenterLat, CenterLon, FacilityId, RouteLen).

enough_battery(FacilityId1, FacilityId2, Result) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityId1, RouteLen1) & actions.route(Role, Speed, FacilityId1, FacilityId2, RouteLen2) & charge(Battery) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery(Lat, Lon, FacilityId2, Result) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, Lat, Lon, _, _, _, RouteLen1) & actions.route(Role, Speed, Lat, Lon, FacilityId2, _, RouteLen2) & charge(Battery) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery2(FacilityAux, FacilityId1, FacilityId2, Result, Battery) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityAux, FacilityId1, RouteLen1) & actions.route(Role, Speed, FacilityId1, FacilityId2, RouteLen2) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery2(FacilityAux, Lat, Lon, FacilityId2, Result, Battery) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityAux, Lat, Lon, RouteLen1) & actions.route(Role, Speed, Lat, Lon, FacilityId2, _, RouteLen2) & ((Battery > ((RouteLen1 * 10) + (RouteLen2 * 10) + 10) & Result = true) | (Result = false)).
enough_battery_charging(FacilityId, Result) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityId, RouteLen) & charge(Battery) & ((Battery > ((RouteLen * 10) + 10) & Result = true) | (Result = false)).
enough_battery_charging2(FacilityAux, FacilityId, Result, Battery) :- role(Role, Speed, _, _, _) & actions.route(Role, Speed, FacilityAux, FacilityId, RouteLen) & ((Battery > ((RouteLen * 10) + 10) & Result = true) | (Result = false)).

select_bid([],bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),bid(BidWinner,BidAgentWinner,ShopIdWinner,ItemWinner)) :- BidWinner = AuxBid & BidAgentWinner = AuxBidAgent & ShopIdWinner = AuxShopId  & ItemWinner = AuxItem.
select_bid([bid(Bid,BidAgent,ShopId,item(ItemId,Qty))|Bids],bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),BidWinner) :- Bid \== -1 & Bid < AuxBid & ( ((not awarded(BidAgent,_,_)) )  | (awarded(BidAgent,ShopId,_) & product(ItemId,Volume,BaseList) & .term2string(BidAgent,BidAgentS) & load(BidAgentS,Load) & Load >= Volume*Qty ) ) & select_bid(Bids,bid(Bid,BidAgent,ShopId,item(ItemId,Qty)),BidWinner).
select_bid([bid(Bid,BidAgent,ShopId,Item)|Bids],bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),BidWinner) :- select_bid(Bids,bid(AuxBid,AuxBidAgent,AuxShopId,AuxItem),BidWinner).

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