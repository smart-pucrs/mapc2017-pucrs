package coalition;

import java.util.ArrayList;
import java.util.List;

import coalition.CFArtefact.ICharacteristicFunction;
import coalition.CFArtefact.ICoalitionFormationArtifact;
import coalition.CFArtefact.cfAgent;
import coalition.CFArtefact.cfConstraint;
import coalition.CFArtefact.cfSizeConstraint;
import jason.stdlib.foreach;

public class QuadCoalition implements ICoalitionFormationArtifact{

	@Override
	public String[] getObservableProperties() {		
		return new String[]{"coalition1","coalition2","coalition3","coalition4"};
	}

	@Override
	public void keepAnyTimeStatistics(boolean keep) {
		
	}
	
	@Override
	public boolean isMaskEncoded() {
		return false;
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
	public List<String[]> solveCoalitionStructureGeneration(cfAgent[] Agents,
			ICharacteristicFunction characteristicFunction, cfConstraint[] positiveConstraintsAsMasks,
			cfConstraint[] negativeConstraintsAsMasks, cfSizeConstraint[] sizeConstraints) {
	
		cfAgent[] drones = getAgentsByType(Agents, "drones");
		
		for(cfAgent drone : drones){
			for(cfSizeConstraint size : sizeConstraints){
				cfAgent[] tempAgents = getAgentsByType(Agents, size.type);
//				for(int i=0; i){
//					//sort
//					//take i agents
//				}
			}
		}
		
		return null;
	}

	@Override
	public List<Integer> solveCoalitionStructureGeneration(int nmbAgents,
			ICharacteristicFunction characteristicFunction, int[] positiveConstraintsAsMasks,
			int[] negativeConstraintsAsMasks, int[] sizeConstraints, int[] agentTypes) {
		// TODO Auto-generated method stub
		return null;
	}

	private cfAgent[] getAgentsByType(cfAgent[] agents, String type){
		ArrayList<cfAgent> agentByType = new ArrayList<>();
		
		for(cfAgent agent : agents)
			if (agent.type.equals(type))
				agentByType.add(agent);
		
		return agentByType.toArray(new cfAgent[agentByType.size()]);
	}

}
