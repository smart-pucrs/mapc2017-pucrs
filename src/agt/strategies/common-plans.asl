{ include("action/actions.asl",action) }

+default::actionID(X) 
//	: X \== 0
<-
	!strategies::choose_my_action(X);
	.

+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>> I have done ",Count+1," noActions.");
	.
	
+default::resourceNode(ResourceId,Lat,Lon,Resource)
<- .print("@@@@@@ ResourceID ",ResourceId," Lat ",Lat," Long ",Lon," Resource ",Resource).

+!choose_my_action(Step)
	: default::routeLength(R) & R \== 0
<-
//	.print("I'm going to continue my movement at step ",Step);
	!action::continue;
	.
+!choose_my_action(Step)
	: true
<-
//	.print("I'm doing nothing at step ",Step);
	!action::skip;
	.