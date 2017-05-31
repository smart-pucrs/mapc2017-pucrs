{ include("$jacamoJar/templates/common-cartago.asl") }

{begin namespace(privTask, local)}

findTools([],Temp, Result) :- Result = Temp.
findTools([Tool | ListOfTools],Temp,Result) :- .member(item(Tool,_),Temp) & findTools(ListOfTools, Temp,Result).
findTools([Tool | ListOfTools],Temp,Result) :- not .member(item(Tool,_),Temp) & findTools(ListOfTools, [item(Tool,1) | Temp],Result).
findParts(Qtd,[],Temp, Result) :- Result = Temp.
findParts(Qtd,[[PartName,PartQtd] | ListOfPart],Temp,Result) :- (NewQtd = Qtd*PartQtd) & item(PartName,_,tools(Tools),parts(Parts)) & decomposeItem(PartName,NewQtd,Tools,Parts,Temp,ListItensJob) & findParts(Qtd,ListOfPart,ListItensJob,Result).
decomposeItem(Item,Qtd,[],[],Temp,ListItensJob) :- ListItensJob = [item(Item,Qtd) | Temp].
decomposeItem(Item,Qtd,Tools,Parts,Temp,ListItensJob) :- findTools(Tools,Temp,NewTempTools) & findParts(Qtd,Parts,NewTempTools,NewTempParts) & ListItensJob = NewTempParts.

decomposeRequirements([],Temp,Result):- Result = Temp.
//decomposeRequirements([required(Item,Qtd) | Requirements],Temp,Result):- item(Item,_,tools(Tools),parts(Parts)) & decomposeItem(Item,Qtd,Tools,Parts,Temp,ListItensJob) & decomposeRequirements(Requirements,ListItensJob,Result).
decomposeRequirements([required(Item,Qtd) | Requirements],Temp,Result):- item(Item,_,tools(Tools),parts(Parts)) & decomposeItem(Item,Qtd,Tools,Parts,[],ListItensJob) & decomposeRequirements(Requirements,ListItensJob,Result).

{end}

{begin namespace(globalTask, global)}

{end}

