package coalition;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import cartago.AgentId;
import cartago.Artifact;
import cartago.GUARD;
import cartago.OPERATION;

public class CFArtefact extends Artifact {
	private final Logger mLogger = Logger.getLogger(CFArtefact.class.getName()); 
	
	private String[] obsCS = null;
	
	private final String obsRunning 				= "runningAlgorithm";
	private final String obspSetAgents 				= "setOfAgents";
	private final String obspSetSizeConstraints 	= "setOfSizeConstraints";
	
	private int mNmbAgents, mNmbPconstraints, mNmbNconstraints;
	
	private static List<String[]> 	mCoalitionStructure		= new ArrayList<String[]>();
	private static List<String> 	mSetAgents 				= new ArrayList<String>();
	private static List<Object[]> 	mSetPositiveConstraints = new ArrayList<Object[]>();
	private static List<Object[]> 	mSetNegativeConstraints = new ArrayList<Object[]>();
	
	private ICoalitionFormationArtifact iSolver;
	private ICharacteristicFunction 	iCharacteristicFunction;
	
	private boolean mRunning = false;
	
	void init(String owner, String algorithm, String characteristFunction, int nmbAgents, int nmbPconstraints, int nmbNconstraints) {
		mLogger.info("The Coalition Formation Artefact was created");
		
		mNmbAgents 			= nmbAgents;
		mNmbPconstraints 	= nmbPconstraints;
		mNmbNconstraints 	= nmbNconstraints;
		
		initialiseAlgorithm(algorithm);
		initialiseCharacteristicFunction(algorithm);
		
		obsCS = iSolver.getObservableProperties();
		
		for(int i=0; i<obsCS.length; i++)
			defineObsProperty(obsCS[i], new ArrayList<String[]>());	
	}
	
	@OPERATION
	void putAgents(Object[] names){	
		for(String s: Arrays.copyOf(names, names.length, String[].class))
			addAgent(s);
			
		updateSetOfAgents();
	}
	@OPERATION
	void putAgent(String name){
		addAgent(name);
		
		updateSetOfAgents();
	}
	private void addAgent(String name){
		mSetAgents.add(name);
	}
	
	@OPERATION (guard="everythingOk")
	void runAlgorithm() {			
		mLogger.info("Running...");
		defineObsProperty(obsRunning);
		
		int[] positiveConstraints = new int[mSetPositiveConstraints.size()];
		for (int i=0; i<mSetPositiveConstraints.size(); i++){
			positiveConstraints[i] = convertRuleIntoMaskInt(mSetPositiveConstraints.get(i));
		}
		
		int[] negativeConstraints = new int[mSetNegativeConstraints.size()];
		for (int i=0; i<mSetNegativeConstraints.size(); i++){
			negativeConstraints[i] = convertRuleIntoMaskInt(mSetNegativeConstraints.get(i));
		}
		
		List<Integer> coalitionStructure = iSolver.solveCoalitionStructureGeneration(mSetAgents.size(), iCharacteristicFunction, positiveConstraints, negativeConstraints, null);
		
		updateCoalitionStructure(coalitionStructure);
		
		removeObsProperty(obsRunning);
		mLogger.info("The Constrained Coalition Formation Algorithm is finished");
	}
	@GUARD
	boolean everythingOk(){
		boolean ready = true;
		
		ready = 	(mSetAgents.size() >= mNmbAgents) 
				& 	(mSetPositiveConstraints.size() >= mNmbPconstraints) 
				& 	(mSetNegativeConstraints.size() >= mNmbNconstraints);
		
		return ready;
	}
	
	private void updateSetOfAgents(){
		getObsProperty(obspSetAgents).updateValue(mSetAgents.toArray());
	}
	
	private void updateCoalitionStructure(List<Integer> cs){
		mCoalitionStructure.clear();
		
		if (cs != null){		
			mLogger.info("Coalition Structure was found");
			for(int i=0; i<cs.size(); i++){
				int[] curCoalition = convertCombinationFromBitToByteFormat(cs.get(i), mSetAgents.size());
				
				String[] coalition = new String[curCoalition.length];
				for(int j=0; j<curCoalition.length; j++){
					coalition[j] = mSetAgents.get(curCoalition[j]-1);
				}
				
				mLogger.info("Coalition: "+coalition);
				mCoalitionStructure.add(coalition);		
			}
		}
		else{
			mLogger.info("There is no coalition structure");
		}
		
		
//		getObsProperty(obsCS).updateValue(mCoalitionStructure.toArray());
	}

	@OPERATION
	void setPositiveConstraint(Object[] constraint){
		mSetPositiveConstraints.add(constraint);
	}
	
	@OPERATION
	void setNegativeConstraint(Object[] constraint){
		mSetNegativeConstraints.add(constraint);
	}
		
	@OPERATION
	void setMCRule(Object[] posRule, Object[] negRule, double value){
		Rule rule = new Rule(convertRuleIntoMaskInt(posRule), convertRuleIntoMaskInt(negRule), value);
		iCharacteristicFunction.putAdditionalInformation(rule);
	}	
	
	@OPERATION 
	void clear() {
		mSetAgents.clear();
		mSetPositiveConstraints.clear();
		mSetNegativeConstraints.clear();
		
		iCharacteristicFunction.clear();
	}
	
	private int convertRuleIntoMaskInt(Object[] rule){
		int maskInt = 0;
		
		for(Object agent : rule)
			maskInt = (maskInt | (1 << (mSetAgents.indexOf(String.valueOf(agent)))));			
		
		return maskInt;
	}	
	private int[] convertCombinationFromBitToByteFormat( int combinationInBitFormat, int numOfAgents )
	{
		int combinationSize = Integer.bitCount(combinationInBitFormat);		
		int[] combinationInByteFormat = new int[ combinationSize ];		
		int j=0;
		
		for(int i=0; i<numOfAgents; i++){
			if ((combinationInBitFormat & (1<<i)) != 0){ 
				combinationInByteFormat[j]= (int)(i+1);
				j++;
			}
		}
		
		return( combinationInByteFormat );
	}

	boolean checkRunning(){
		return !mRunning;
	}
		
	private void checkPermission(AgentId id){
		if (!hasPermission(id))
			failed("Permission denied");
	}
	private boolean hasPermission(AgentId id){
		return getCreatorId().equals(id);
	}	
	
	private void initialiseAlgorithm(String algorithm){
		String tempAlgorithm = algorithm.toUpperCase();
		
		if (tempAlgorithm.equals("QUADRANTE"))
			iSolver = new QuadCoalition();		
		
		iSolver.initialization();
	}
	private void initialiseCharacteristicFunction(String algorithm){
		String tempAlgorithm = algorithm.toUpperCase();
		
		if (tempAlgorithm.equals("QUADRANTE"))
			iCharacteristicFunction = new CharacteristicFunction();			
	}
	
	public interface ICharacteristicFunction {
		public void generateValues(int numOfAgents);
		public double getCoalitionValue(int coalitionInBitFormat);
		public double[] getCoalitionValues();
		public void putAdditionalInformation(Object...information);
		public void removeAdditionalInformation(Object information);
		
		public void storeToFile(String fileName);
		public void readFromFile(String fileName);
		
		public void clear();
	}
	
	public interface ICoalitionFormationArtifact {
		public String[] getObservableProperties();
		public void keepAnyTimeStatistics(boolean keep);
		public void initialization();
		public List<Integer> solveCoalitionStructureGeneration(int numberOfAgents, ICharacteristicFunction characteristicFunction, int[] positiveConstraintsAsMasks, int[] negativeConstraintsAsMasks, int[] sizeConstraints);
		public void clear();
	}
	
	public class Rule {
		int positiveRule = 0;
		int negativeRule = 0;
		double value = 0;
		boolean hasNegation = false;
		
		public Rule(int positiverule, int negativerule, double value){
			this.positiveRule = positiverule;
			this.value = value;
			this.negativeRule = negativerule;
		}
	}
}