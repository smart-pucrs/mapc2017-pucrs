package coalition;

import java.util.List;

import coalition.CFArtefact.ICharacteristicFunction;
import coalition.CFArtefact.ICoalitionFormationArtifact;
import jason.stdlib.foreach;

public class QuadCoalition implements ICoalitionFormationArtifact{

	@Override
	public String[] getObservableProperties() {		
		return new String[]{"quad1","quad2","quad3","quad4"};
	}

	@Override
	public void keepAnyTimeStatistics(boolean keep) {
		
	}

	@Override
	public void initialization() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<Integer> solveCoalitionStructureGeneration(int numberOfAgents,
			ICharacteristicFunction characteristicFunction, int[] positiveConstraintsAsMasks,
			int[] negativeConstraintsAsMasks, int[] sizeConstraints) {		
		int tempNumberOfQuad = 4;
		
		for (int i=1; i<=tempNumberOfQuad; i++){
			for (int j=1; j<=numberOfAgents; j++){
				
			}
		}
		
		return null;
	}

	@Override
	public void clear() {
		// TODO Auto-generated method stub
		
	}

}
