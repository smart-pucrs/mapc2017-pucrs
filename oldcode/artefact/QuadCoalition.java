package old.coalition.artefact;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import old.coalition.artefact.CFArtefact.ICoalitionFormationArtifact;
import old.coalition.artefact.CFArtefact.cfAgent;
import old.coalition.artefact.CFArtefact.cfBasicConstraint;
import old.coalition.artefact.CFArtefact.cfQuantityConstraint;
import old.coalition.artefact.CFArtefact.cfRule;

public class QuadCoalition implements ICoalitionFormationArtifact{
//	private final Logger mLogger = Logger.getLogger(QuadCoalition.class.getName()); 

	@Override
	public void keepAnyTimeStatistics(boolean keep) {
		
	}

	@Override
	public void initialization() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void clear() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public cfCoalitionStructure solveCoalitionStructureGeneration(cfAgent[] agents,
			cfBasicConstraint[] positiveConstraints, cfBasicConstraint[] negativeConstraints,
			cfQuantityConstraint[] sizeConstraints, cfRule[] rules) {
		
		cfCoalitionStructure cs 	= new cfCoalitionStructure("");
		List<cfAgent> agentsFree 	= new ArrayList<cfAgent>(Arrays.asList(agents));
		
		List<cfRule> orderedRules = Arrays.asList(rules);
		orderedRules.sort((o1, o2) -> Double.compare(o1.value, o2.value));		
			
		List<cfAgent> drones = getAgentsByType(agentsFree, "drone");
			
		for(cfAgent drone : drones){
			cfCoalition c = new cfCoalition("coalition");
//			c.addAgent(drone);
//			agentsFree.remove(drone);			
			
			for(cfQuantityConstraint size : sizeConstraints){
				List<cfAgent> agentsType 		= getAgentsByType(agentsFree, size.type);
				cfAgent[] agentsSameCoalition 	= getBestAgents(drone, agentsType, size.size, orderedRules);
				
				for(cfAgent temp : agentsSameCoalition){
					c.addAgent(temp);
					agentsFree.remove(temp);
				}
			}
			
			cs.addCoalition(c);
		}
		
		return cs;
	}	
	
	private List<cfAgent> getAgentsByType(List<cfAgent> agents, String type){
		ArrayList<cfAgent> agentByType = new ArrayList<>();
		
		for(cfAgent agent : agents)
			if (agent.type.equals(type))
				agentByType.add(agent);
		
		return agentByType;
	}	
	private cfAgent[] getBestAgents(cfAgent baseAgent, List<cfAgent> agents, int howMany, List<cfRule> rules){
		ArrayList<cfAgent> bestAgents = new ArrayList<>();
		
		for(cfRule rule : rules){
			if (containsAgents(rule.positiveRule,baseAgent)){
				for(cfAgent agent : agents)
					if (containsAgents(rule.positiveRule,agent))
						bestAgents.add(agent);			
			}
			
			if (bestAgents.size() == howMany)
				break;
		}		
		
		return bestAgents.toArray(new cfAgent[bestAgents.size()]);
	}
	private boolean containsAgents(String[] constraint, cfAgent agent){
		for(String tempConst : constraint)
			if(tempConst.equals(agent.name))
				return true;
		return false;
	}

	

}
