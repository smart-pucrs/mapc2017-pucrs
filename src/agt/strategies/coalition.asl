countCenter(0).

@minLon[atomic]
+default::minLon(Lon) : X = Lon + 0.001 & countCenter(I) <- -minLon(Lon); +minLonReal(X); -+countCenter(I+1).
@maxLon[atomic]
+default::maxLon(Lon) : X = Lon - 0.00001 & countCenter(I) <- -maxLon(Lon); +maxLonReal(X); -+countCenter(I+1).
@minLat[atomic]
+default::minLat(Lat) : X = Lat + 0.001 & countCenter(I)  <- -minLat(Lat); +minLatReal(X); -+countCenter(I+1).
@maxLat[atomic]
+default::maxLat(Lat) : X = Lat - 0.00001 & countCenter(I)  <- -maxLat(Lat); +maxLatReal(X); -+countCenter(I+1).

+countCenter(4) 
	: minLonReal(MinLon) & maxLonReal(MaxLon) & minLatReal(MinLat) & maxLatReal(MaxLat)  
<- 
	-countCenter(4);
	+mapCenter(math.ceil(((MinLat+MaxLat)/2) * 100000) / 100000,math.ceil(((MinLon+MaxLon)/2) * 100000) / 100000);
	?mapCenter(CLat,CLon);
	+quad1(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	+quad2(math.ceil(((MaxLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);
	+quad3(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MinLon+CLon)/2) * 100000) / 100000);
	+quad4(math.ceil(((MinLat+CLat)/2) * 100000) / 100000,math.ceil(((MaxLon+CLon)/2) * 100000) / 100000);
	.

+quad1(Lat,Lon) : default::role(Role, Speed, _, _, _)
<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad1 is: ",Route).
+quad1(Lat,Lon) <- .print("quad1").
+quad2(Lat,Lon) : default::role(Role, Speed, _, _, _)
<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad2 is: ",Route).
+quad2(Lat,Lon) <- .print("quad2").
+quad3(Lat,Lon) : default::role(Role, Speed, _, _, _)
<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad3 is: ",Route).
+quad3(Lat,Lon) <- .print("quad2").
+quad4(Lat,Lon) : default::role(Role, Speed, _, _, _)
<- actions.routeLatLon(Role,Speed,Lat,Lon,Route); .print("My route length to quad4 is: ",Route).
+quad4(Lat,Lon) <- .print("quad4").