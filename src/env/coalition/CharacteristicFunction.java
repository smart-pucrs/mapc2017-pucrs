package coalition;

import java.util.ArrayList;
import java.util.Arrays;

import coalition.CFArtefact.ICharacteristicFunction;
import coalition.CFArtefact.cfRule;

public class CharacteristicFunction implements ICharacteristicFunction
{
	private double[] coalitionValues; 
    private ArrayList<cfRule> rules;
    
    public CharacteristicFunction() {
    	rules = new ArrayList<cfRule>();
    }
    
    public void putAdditionalInformation(Object...information) {
    	rules.add((cfRule)information[0]);
    }
    @Override
	public void removeAdditionalInformation(Object information) {
		rules.remove(information);
	}
    
    public void generateValues(int numOfAgents) {
    	coalitionValues = new double [(int) ((Math.pow(2, numOfAgents)-1))];
    	Arrays.fill(coalitionValues, -1);
    }
    
    public void clear() {
        coalitionValues = null;
        rules.clear();
    }
    
    public double getCoalitionValue(int coalitionInBitFormat) {    	
    	if (coalitionValues[coalitionInBitFormat] == -1)
    		coalitionValues[coalitionInBitFormat] = applyRules(coalitionInBitFormat);    	
    		
        return coalitionValues[coalitionInBitFormat];
    }    
    
    private double applyRules(int coalitionInBitFormat){
    	double value = 0;    	
    	
    	for(cfRule rule : rules)
    		if (((rule.positiveRule | coalitionInBitFormat) == coalitionInBitFormat) && (rule.negativeRule & coalitionInBitFormat) == 0)
    			value += rule.value;    	
    	
    	return value;
    }

	@Override
	public double[] getCoalitionValues() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void storeToFile(String fileName) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void readFromFile(String fileName) {
		// TODO Auto-generated method stub
		
	}	
}