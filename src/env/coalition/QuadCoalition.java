package coalition;

import java.util.ArrayList;
import java.util.List;

import coalition.CFArtefact.ICharacteristicFunction;
import coalition.CFArtefact.ICoalitionFormationArtifact;
import coalition.CFArtefact.cfAgent;
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
	public void initialization() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<Integer> solveCoalitionStructureGeneration(cfAgent[] Agents,
			ICharacteristicFunction characteristicFunction, int[] positiveConstraintsAsMasks,
			int[] negativeConstraintsAsMasks, cfSizeConstraint[] sizeConstraints) {		
		List<Integer> cs = new ArrayList<Integer>();
		
		for (int i=0; i<=sizeConstraints.length; i++){		
			String seat[] = new String[sizeConstraints[i].size];
			for (int j=0; j<=Agents.length; j++){
				if (sizeConstraints[i].type.equals(Agents[j].type)){
					
				}
			}
		}
		
		for (int i=1; i<=positiveConstraintsAsMasks.length; i++){
			characteristicFunction.ge
			for (int j=1; j<=numberOfAgents; j++){
				int ag = 1<<j;
			}
		}
		
		return cs;
	}

	@Override
	public void clear() {
		// TODO Auto-generated method stub
		
	}

}
