countCenter(0).
dronesList([vehicle1,vehicle2,vehicle3,vehicle4]).
 
removeTakenQuad([], Temp, Result) :- Result=Temp.
removeTakenQuad([going(_,Q)|ListGoing], Temp, Result) :- .delete(quad(_,Q),Temp,NewTemp) & removeTakenQuad(ListGoing, NewTemp, Result).
getMyQuad([], Going, Result) :- .my_name(Me) & .member(going(Me,Quad),Going) & Result=Quad.
getMyQuad([Agent | ListAgents], Going, Result) :- default::dronesDistance(Route)[source(Agent)] & removeTakenQuad(Going, Route, NewRoute) & .sort(NewRoute,SortedQuads) & .nth(0,SortedQuads,quad(_,Q)) & getMyQuad(ListAgents,[going(Agent,Q)|Going],Result).

@minLon[atomic]
+default::minLon(Lon) : X = Lon + 0.001 & countCenter(I) <- -minLon(Lon); +minLonReal(X); -+countCenter(I+1).
@maxLon[atomic]
+default::maxLon(Lon) : X = Lon - 0.00001 & countCenter(I) <- -maxLon(Lon); +maxLonReal(X); -+countCenter(I+1).
@minLat[atomic]
+default::minLat(Lat) : X = Lat + 0.001 & countCenter(I)  <- -minLat(Lat); +minLatReal(X); -+countCenter(I+1).
@maxLat[atomic]
+default::maxLat(Lat) : X = Lat - 0.00001 & countCenter(I)  <- -maxLat(Lat); +maxLatReal(X); -+countCenter(I+1).

+countCenter(4) 
<- 
	-countCenter(4);
	!!calc;
	.

+!calc
	: minLonReal(MinLon) & maxLonReal(MaxLon) & minLatReal(MinLat) & maxLatReal(MaxLat) & default::role(drone, _, _, _, _)
<- 
	+mapCenter(math.ceil(((MinLat+MaxLat)/2) * 100000) / 100000,math.ceil(((MinLon+MaxLon)/2) * 100000) / 100000);
	?mapCenter(CLat,CLon);
	+quad1(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	+quad2(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);
	+quad3(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	+quad4(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);	
	
	!broadcast_my_route_to_drones
	.
+!calc
	: minLonReal(MinLon) & maxLonReal(MaxLon) & minLatReal(MinLat) & maxLatReal(MaxLat)  
<- 
	+mapCenter(math.ceil(((MinLat+MaxLat)/2) * 100000) / 100000,math.ceil(((MinLon+MaxLon)/2) * 100000) / 100000);
	?mapCenter(CLat,CLon);
	+quad1(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	+quad2(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);
	+quad3(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	+quad4(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);	
	.

//+quad1(Lat,Lon) : default::role(Role, Speed, _, _, _)
//<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad1 is: ",Route).
//+quad1(Lat,Lon) <- .print("quad1").
//+quad2(Lat,Lon) : default::role(Role, Speed, _, _, _)
//<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad2 is: ",Route).
//+quad2(Lat,Lon) <- .print("quad2").
//+quad3(Lat,Lon) : default::role(Role, Speed, _, _, _)
//<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad3 is: ",Route).
//+quad3(Lat,Lon) <- .print("quad2").
//+quad4(Lat,Lon) : default::role(Role, Speed, _, _, _)
//<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad4 is: ",Route).
//+quad4(Lat,Lon) <- .print("quad4").

+!default::dronesDistance
	: default::step(_) & .findall(routes(Agent,Routes),dronesDistance(Routes)[source(Agent)],ListDistances) & .length(ListDistances,4)
<-	
	.findall(Agent,dronesDistance(_)[source(Agent)],Agents);
	.sort(Agents,SortedAgents);
	
	?getMyQuad(SortedAgents,[],MyQuad);
	
	.my_name(OldMe);
	.broadcast(tell, quadrant(MyQuad));
	.broadcast(achieve, quadrant(MyQuad));
	+default::quadrant(MyQuad)[source(OldMe)];
	!default::quadrant(MyQuad);
	.term2string(OldMe,Me);
	setMCRule([Me],[],5);
	.
-!default::dronesDistance : .findall(routes(Agent,Routes),dronesDistance(Routes)[source(Agent)],ListDistances) & .length(ListDistances,L) & L \== 4.
-!default::dronesDistance <- !default::dronesDistance.

+!default::quadrant(quad1)[source(OldDrone)]
	: default::step(_) & quad1(Lat,Lon) & .my_name(OldMe) & .term2string(OldMe,Me) & .term2string(OldDrone,Drone) & default::role(Role, Speed, _, _, _) & (Role\==drone) & actions.routeLatLon(Role,Speed,Lat,Lon,Route)
<- 
	setMCRule([Me,Drone],[],Route);
	.
-!default::quadrant(quad1)[source(OldDrone)] : default::role(Role, Speed, _, _, _) & (Role==drone).
-!default::quadrant(quad1)[source(OldDrone)] <- !default::quadrant(quad1)[source(OldDrone)].	
+!default::quadrant(quad2)[source(OldDrone)]
	: default::step(_) & quad2(Lat,Lon) & .my_name(OldMe) & .term2string(OldMe,Me) & .term2string(OldDrone,Drone) & default::role(Role, Speed, _, _, _) & (Role\==drone) & actions.routeLatLon(Role,Speed,Lat,Lon,Route)
<- 
	setMCRule([Me,Drone],[],Route);
	.
-!default::quadrant(quad2)[source(OldDrone)] : default::role(Role, Speed, _, _, _) & (Role==drone).
-!default::quadrant(quad2)[source(OldDrone)] <- !default::quadrant(quad2)[source(OldDrone)].
+!default::quadrant(quad3)[source(OldDrone)]
	: default::step(_) & quad3(Lat,Lon) & .my_name(OldMe) & .term2string(OldMe,Me) & .term2string(OldDrone,Drone) & default::role(Role, Speed, _, _, _) & (Role\==drone) & actions.routeLatLon(Role,Speed,Lat,Lon,Route)
<- 
	setMCRule([Me,Drone],[],Route);
	.
-!default::quadrant(quad3)[source(OldDrone)] : default::role(Role, Speed, _, _, _) & (Role==drone).
-!default::quadrant(quad3)[source(OldDrone)] <- !default::quadrant(quad3)[source(OldDrone)].
+!default::quadrant(quad4)[source(OldDrone)]
	: default::step(_) & quad4(Lat,Lon) & .my_name(OldMe) & .term2string(OldMe,Me) & .term2string(OldDrone,Drone) & default::role(Role, Speed, _, _, _) & (Role\==drone) & actions.routeLatLon(Role,Speed,Lat,Lon,Route)
<- 
	setMCRule([Me,Drone],[],Route);
	.
-!default::quadrant(quad4)[source(OldDrone)] : default::role(Role, Speed, _, _, _) & (Role==drone).
-!default::quadrant(quad4)[source(OldDrone)] <- !default::quadrant(quad4)[source(OldDrone)].
+!broadcast_my_route_to_drones
	: default::step(_) & quad1(Lat1,Lon1) & quad2(Lat2,Lon2) & quad3(Lat3,Lon3) & quad4(Lat4,Lon4) & default::role(Role, Speed, _, _, _) & dronesList(Drones) & .my_name(Me) & .delete(Me,Drones,L)
<-	
	actions.routeLatLon(Role,Speed,Lat1,Lon1,Route1);
	actions.routeLatLon(Role,Speed,Lat2,Lon2,Route2);
	actions.routeLatLon(Role,Speed,Lat3,Lon3,Route3);
	actions.routeLatLon(Role,Speed,Lat4,Lon4,Route4);
	for ( .member(Drone,L) ) {
        .send(Drone,tell,dronesDistance([quad(Route1,quad1),quad(Route2,quad2),quad(Route3,quad3),quad(Route4,quad4)]));
        .send(Drone,achieve,dronesDistance);
    }	
    +default::dronesDistance([quad(Route1,quad1),quad(Route2,quad2),quad(Route3,quad3),quad(Route4,quad4)])[source(Me)];
    !default::dronesDistance;
	.
-!broadcast_my_route_to_drones <- !broadcast_my_route_to_drones.

+!introduce_to_the_coalition_artefact
	:.my_name(OldMe) & .term2string(OldMe,Me) & default::role(OldRole, _, _, _, _) & .term2string(OldRole,Role)
<-
	putAgent(Me,Role);
	.

+!setup_coalition_artefact
	:true
<-
	putType("drone");
	putType("motorcycle");
	putType("car");
	putType("truck");
	setSizeConstraint(1, "drone");
	setSizeConstraint(2, "motorcycle");
	setSizeConstraint(2, "car");
	setSizeConstraint(2, "truck");
	runAlgorithm;
	.


+default::coalition(Coalition)
	: .my_name(OldMe) & .term2string(OldMe,Me) & .member(Me,Coalition) & default::quadrant(Quad)[source(OldAgent)] & .term2string(OldAgent,Agent) & .member(Agent,Coalition)
<-
	.print("This is my Quadrant: ",Quad);

	?default::convertListString2Term(Coalition,[],TermCoalition);
	.delete(OldMe,TermCoalition,NewCoalition);
	
	+default::coalition(Quad,NewCoalition,Task);
	!clean_coalition_beliefs;	
	.
	
+!clean_coalition_beliefs
	: true
<-
	.abolish(default::quadrant(_));
	.abolish(default::dronesDistance(_));	
	.