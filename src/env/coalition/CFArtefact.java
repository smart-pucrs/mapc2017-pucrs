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
	private final String obsWaitingInput 			= "waitingForInputs";
//	private final String obspSetAgents 				= "setOfAgents";
//	private final String obspSetSizeConstraints 	= "setOfSizeConstraints";
	
	private int mNmbAgents, mNmbPconstraints, mNmbNconstraints;
	private boolean mHardEncoded;
	
	private List<String[]> 	mCoalitionStructure			= new ArrayList<String[]>();
	private List<String> 	mAgentsTypes				= new ArrayList<String>();
	private List<cfAgent> 	mSetAgents 					= new ArrayList<cfAgent>();
	private List<Object[]> 	mSetPositiveConstraints 	= new ArrayList<Object[]>();
	private List<Object[]> 	mSetNegativeConstraints 	= new ArrayList<Object[]>();
	private List<cfSizeConstraint> 	mSetSizeConstraints = new ArrayList<cfSizeConstraint>();
	
	private ICoalitionFormationArtifact iSolver;
	private ICharacteristicFunction 	iCharacteristicFunction;
	
	private boolean mRunning = false;
	
	void init(String owner, String algorithm, String characteristFunction, int nmbAgents, int nmbPconstraints, int nmbNconstraints) {	
		mNmbAgents 			= nmbAgents;
		mNmbPconstraints 	= nmbPconstraints;
		mNmbNconstraints 	= nmbNconstraints;
		
		initialiseAlgorithm(algorithm);
		initialiseCharacteristicFunction(algorithm);
		
		obsCS 			= iSolver.getObservableProperties();
		mHardEncoded 	= iSolver.isMaskEncoded();
		
		for(int i=0; i<obsCS.length; i++)
			defineObsProperty(obsCS[i], new ArrayList<String[]>());	
		
		mLogger.info("The Coalition Formation Artefact was created");
	}
	
	@OPERATION
	void putAgents(Object[] names){	//no types
		for(String s: Arrays.copyOf(names, names.length, String[].class))
			addAgent(s,"");
			
		updateSetOfAgents();
	}
	@OPERATION
	void putAgent(String name,String type){
		addAgent(name, type);
		
		updateSetOfAgents();
	}
	private void addAgent(String name, String type){
//		mSetAgents.add(name);
		cfAgent agent = new cfAgent(name, type);
		if(!mSetAgents.contains(agent))
			mSetAgents.add(agent);
	}
	
	@OPERATION (guard="hasAllInputs")
	void runAlgorithm() {			
		removeObsProperty(obsWaitingInput);
		mLogger.info("Running...");
		defineObsProperty(obsRunning);		
		
		if (mHardEncoded)
			runAlgorithmHardEncoded();
		else
			runAlgorithmSoftEncoded();
		
		removeObsProperty(obsRunning);
		mLogger.info("The Constrained Coalition Formation Algorithm is finished");
	}
	@GUARD
	boolean hasAllInputs(){
		boolean ready = true;
		
		defineObsProperty(obsWaitingInput);
		
		ready = 	(mSetAgents.size() >= mNmbAgents) 
				& 	(mSetPositiveConstraints.size() >= mNmbPconstraints) 
				& 	(mSetNegativeConstraints.size() >= mNmbNconstraints);
		
		return ready;
	}
	
	private void updateSetOfAgents(){
//		getObsProperty(obspSetAgents).updateValue(mSetAgents.toArray());
	}
	
	private void updateCoalitionStructure(List<String[]> cs){
		mCoalitionStructure.clear();
		
		if (cs != null){		
			mLogger.info("Coalition Structure was found");
//			for
//			for(int i=0; i<cs.size(); i++){
//				int[] curCoalition = convertCombinationFromBitToByteFormat(cs.get(i), mSetAgents.size());
//				
//				String[] coalition = new String[curCoalition.length];
//				for(int j=0; j<curCoalition.length; j++){
//					coalition[j] = mSetAgents.get(curCoalition[j]-1).name;
//				}
//				
//				mLogger.info("Coalition: "+coalition);
//				mCoalitionStructure.add(coalition);		
//			}
		}
		else{
			mLogger.info("There is no coalition structure");
		}
		
		
//		getObsProperty(obsCS).updateValue(mCoalitionStructure.toArray());
	}
	/*private void updateCoalitionStructure(List<Integer> cs){
		mCoalitionStructure.clear();
		
		if (cs != null){		
			mLogger.info("Coalition Structure was found");
			for(int i=0; i<cs.size(); i++){
				int[] curCoalition = convertCombinationFromBitToByteFormat(cs.get(i), mSetAgents.size());
				
				String[] coalition = new String[curCoalition.length];
				for(int j=0; j<curCoalition.length; j++){
					coalition[j] = mSetAgents.get(curCoalition[j]-1).name;
				}
				
				mLogger.info("Coalition: "+coalition);
				mCoalitionStructure.add(coalition);		
			}
		}
		else{
			mLogger.info("There is no coalition structure");
		}
		
		
//		getObsProperty(obsCS).updateValue(mCoalitionStructure.toArray());
	}*/

	@OPERATION
	void setTypes(String type){
		mAgentsTypes.add(type);
	}
	@OPERATION
	void setPositiveConstraint(Object[] constraint){
		mSetPositiveConstraints.add(constraint);
	}
	
	@OPERATION
	void setNegativeConstraint(Object[] constraint){
		mSetNegativeConstraints.add(constraint);
	}
	
//	@OPERATION
//	void setSizeConstraint(Object constraint){
//		mSetSizeConstraints.add((cfSizeConstraint)constraint);
//	}
	@OPERATION
	void setSizeConstraint(Integer size, String type){
		mSetSizeConstraints.add(new cfSizeConstraint(size, type));
	}
		
	@OPERATION
	void setMCRule(Object[] posRule, Object[] negRule, double value){
		cfRule rule = new cfRule(convertRuleIntoMaskInt(posRule), convertRuleIntoMaskInt(negRule), value);
		iCharacteristicFunction.putAdditionalInformation(rule);
	}	
	
	@OPERATION 
	void clear() {
		mSetAgents.clear();
		mSetPositiveConstraints.clear();
		mSetNegativeConstraints.clear();
		
		iCharacteristicFunction.clear();
	}
	
	private void runAlgorithmSoftEncoded(){
		
		cfAgent[] agents 				= mSetAgents.toArray(new cfAgent[mSetAgents.size()]);
		cfSizeConstraint[] sizeConstr 	= mSetSizeConstraints.toArray(new cfSizeConstraint[mSetSizeConstraints.size()]);
		cfConstraint[] negConstr 		= mSetNegativeConstraints.toArray(new cfConstraint[mSetNegativeConstraints.size()]);
		cfConstraint[] posConstr 		= mSetPositiveConstraints.toArray(new cfConstraint[mSetPositiveConstraints.size()]);
		
		List<String[]> coalitionStructure = iSolver.solveCoalitionStructureGeneration(agents, iCharacteristicFunction, posConstr, negConstr, sizeConstr);
		
		updateCoalitionStructure(coalitionStructure);
	}
	private void runAlgorithmHardEncoded(){
		int[] positiveConstraints = new int[mSetPositiveConstraints.size()];
		for (int i=0; i<mSetPositiveConstraints.size(); i++){
			positiveConstraints[i] = convertRuleIntoMaskInt(mSetPositiveConstraints.get(i));
		}
		
		int[] negativeConstraints = new int[mSetNegativeConstraints.size()];
		for (int i=0; i<mSetNegativeConstraints.size(); i++){
			negativeConstraints[i] = convertRuleIntoMaskInt(mSetNegativeConstraints.get(i));
		}
			
		List<Integer> coalitionStructure = iSolver.solveCoalitionStructureGeneration(mSetAgents.size(), iCharacteristicFunction, positiveConstraints, negativeConstraints, null, null);
		
//		updateCoalitionStructure(coalitionStructure);
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
		public List<String[]> solveCoalitionStructureGeneration(cfAgent[] Agents, ICharacteristicFunction characteristicFunction, cfConstraint[] positiveConstraintsAsMasks, cfConstraint[] negativeConstraintsAsMasks, cfSizeConstraint[] sizeConstraints);
		public List<Integer> solveCoalitionStructureGeneration(int nmbAgents, ICharacteristicFunction characteristicFunction, int[] positiveConstraintsAsMasks, int[] negativeConstraintsAsMasks, int[] sizeConstraints, int[] agentTypes);
		public boolean isMaskEncoded();
		public void clear();
	}
	
	public class cfRule {
		int positiveRule = 0;
		int negativeRule = 0;
		double value = 0;
		boolean hasNegation = false;
		
		public cfRule(int positiverule, int negativerule, double value){
			this.positiveRule = positiverule;
			this.value = value;
			this.negativeRule = negativerule;
		}
	}	
	public class cfAgent {
		String name = "";
		String type = "";
		
		public cfAgent(String name, String type){
			this.name = name;
			this.type = type;
		}
	}
	public class cfSizeConstraint {
		int size 	= 0;
		String type = "";
		
		public cfSizeConstraint(int size, String type){
			this.size = size;
			this.type = type;
		}
	}
	public class cfConstraint {
		String[] agents = null;
		
		public cfConstraint(String[] agents){
			this.agents = agents;
		}
	}
}