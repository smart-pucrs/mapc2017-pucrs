package coalition;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

import cartago.AgentId;
import cartago.AgentIdCredential;
import cartago.Artifact;
import cartago.GUARD;
import cartago.OPERATION;

public class CFArtefact extends Artifact {
	private final Logger mLogger = Logger.getLogger(CFArtefact.class.getName()); 
	
	private final String obsRunning 				= "runningAlgorithm";
	private final String obsWaitingInput 			= "waitingForInputs";
	
	private int mNmbAgents, mNmbPconstraints, mNmbNconstraints, mNmbMCRules;
	private List<String> mOwners = new ArrayList<String>();
	
	private cfCoalitionStructure mCoalitionStructure;
	private List<String> 				mAgentsTypes			= new ArrayList<String>();
	private List<cfAgent> 				mSetAgents 				= new ArrayList<cfAgent>();
	private List<cfBasicConstraint> 	mSetPositiveConstraints = new ArrayList<cfBasicConstraint>();
	private List<cfBasicConstraint> 	mSetNegativeConstraints = new ArrayList<cfBasicConstraint>();	
	private List<cfQuantityConstraint> 	mSetSizeConstraints 	= new ArrayList<cfQuantityConstraint>();
	private List<cfRule> 				mSetRules 				= new ArrayList<cfRule>();
	
	private Map<String, AgentId> agentIds;
	
	private ICoalitionFormationArtifact iSolver;
	
	void init(String owner, String algorithm, int nmbAgents, int nmbPconstraints, int nmbNconstraints, int nmbMCRules) {	
		mLogger.info("Creating the Coalition Formation Artefact");
		mNmbAgents 			= nmbAgents;
		mNmbPconstraints 	= nmbPconstraints;
		mNmbNconstraints 	= nmbNconstraints;
		mNmbMCRules			= nmbMCRules;
		
		addOwner(owner);
		
		initialiseAlgorithm(algorithm);
		
		agentIds = new ConcurrentHashMap<String, AgentId>();
		
		mLogger.info("The Coalition Formation Artefact was created");
	}
	
	@OPERATION
	void putAgents(Object[] names){	//no types
		for(String s: Arrays.copyOf(names, names.length, String[].class))
			addAgent(s,"");
	}
	@OPERATION
	void putAgent(String name,String type){
		addAgent(name, type);
	}
	private void addAgent(String name, String type){
		cfAgent agent = new cfAgent(name, type);
		if(!mSetAgents.contains(agent))
			mSetAgents.add(agent);
		agentIds.put(name, getCurrentOpAgentId());
	}
	
	@OPERATION (guard="hasAllInputs")
	void runAlgorithm() {	
//	void runAlgorithm(boolean sendSignal) {			
//		if (sendSignal)
//			mLogger.info("Must send signal");
		
		mLogger.info("Running...");
		defineObsProperty(obsRunning);		

		cfAgent[] agents 					= mSetAgents.toArray(new cfAgent[mSetAgents.size()]);
		cfQuantityConstraint[] sizeConstr 	= mSetSizeConstraints.toArray(new cfQuantityConstraint[mSetSizeConstraints.size()]);
		cfBasicConstraint[] negConstr 		= mSetNegativeConstraints.toArray(new cfBasicConstraint[mSetNegativeConstraints.size()]);
		cfBasicConstraint[] posConstr 		= mSetPositiveConstraints.toArray(new cfBasicConstraint[mSetPositiveConstraints.size()]);
		cfRule[] rules 						= mSetRules.toArray(new cfRule[mSetRules.size()]);		
		
		cfCoalitionStructure cs = iSolver.solveCoalitionStructureGeneration(agents, posConstr, negConstr, sizeConstr, rules);
		
		updateCoalitionStructure(cs);
		
		removeObsProperty(obsRunning);
		removeObsProperty(obsWaitingInput);
		mLogger.info("The Constrained Coalition Formation Algorithm is finished");
	}
	@GUARD
	boolean hasAllInputs(){
		boolean ready = true;
	
		if (getObsProperty(obsWaitingInput) == null)
			defineObsProperty(obsWaitingInput);
		
		ready = 	(mSetAgents.size() >= mNmbAgents) 
				& 	(mSetPositiveConstraints.size() >= mNmbPconstraints) 
				& 	(mSetNegativeConstraints.size() >= mNmbNconstraints)
				& 	(mSetRules.size() >= mNmbMCRules);
		
		return ready;
	}
	
	private void updateCoalitionStructure(cfCoalitionStructure cs){
		if (cs == null){			
			if (mCoalitionStructure != null)
				if (mCoalitionStructure.getCSName().equals(""))
					removeObsProperty(mCoalitionStructure.getCSName());
				else
					for(cfCoalition c : mCoalitionStructure.getCoalitions())
						removeObsProperty(c.getCoalitionName());
		}
		else{
			mLogger.info("Coalition Structure was found");
			cfCoalition[] coalitions = cs.getCoalitions();

			String[] tasks = new String[]{"shoporganiser","shop","shop","shop","shop","workshop","shop"};
//			String[] tasks = new String[]{"first","second","explore","shop","shop","workshop","resource"};
			/*for (cfCoalition c : coalitions)
			{				
				c.getAgents().sort((o1, o2) -> o1.type.compareTo(o2.type));	
						
				for (int i=0; i<c.getAgents().size(); i++){
					signal(agentIds.get(c.getAgents().get(i).name), c.getCoalitionName(),c.getAgentsArray(),tasks[i]);
				}
			}*/			
			for (cfCoalition c : coalitions)
			{	
				String[] agentTask = new String[c.getAgents().size()];
				c.getAgents().sort((o1, o2) -> o1.type.compareTo(o2.type));	
						
				for (int i=0; i<c.getAgents().size(); i++){
					agentTask[i] = "agent("+c.getAgents().get(i).name+","+tasks[i]+")";
				}
				for (int i=0; i<c.getAgents().size(); i++){
					signal(agentIds.get(c.getAgents().get(i).name), c.getCoalitionName(),agentTask,tasks[i]);
				}
			}
		}
		
		mCoalitionStructure = cs;
	}
	/*private void updateCoalitionStructure(cfCoalitionStructure cs){
		if (cs == null){			
			if (mCoalitionStructure != null)
				if (mCoalitionStructure.getCSName().equals(""))
					removeObsProperty(mCoalitionStructure.getCSName());
				else
					for(cfCoalition c : mCoalitionStructure.getCoalitions())
						removeObsProperty(c.getCoalitionName());
		}
		else{
			cfCoalition[] coalitions = cs.getCoalitions();
			
			if (coalitions.length > 0){		
				mLogger.info("Coalition Structure was found");
				
				if (cs.getCSName().equals("")){
					for(cfCoalition coalition: coalitions){							
//						defineObsProperty(coalition.getCoalitionName(), new Object[] {coalition.getAgents()});	
						signal(coalition.getCoalitionName(), new Object[] {coalition.getAgents()});
					}
				}
				else{
					Object[] tempCs = new Object[coalitions.length];					
					for (int i=0; i<coalitions.length; i++)
						tempCs[i] = coalitions[i].getAgents();
//					defineObsProperty(cs.getCSName(), tempCs);	
					signal(cs.getCSName(), tempCs);	
				}
			}
			else{
				mLogger.info("There is no coalition structure");
			}
		}
		
		mCoalitionStructure = cs;
	}*/

	@OPERATION
	void putType(String type){
		mAgentsTypes.add(type);
	}
	@OPERATION
	void setPositiveConstraint(Object[] constraint){
		mSetPositiveConstraints.add(new cfBasicConstraint((String[])constraint));
	}
	
	@OPERATION
	void setNegativeConstraint(Object[] constraint){
		mSetNegativeConstraints.add(new cfBasicConstraint((String[])constraint));
	}
	
	@OPERATION
	void setSizeConstraint(int size, String type){
		mSetSizeConstraints.add(new cfQuantityConstraint(size, type));
	}
		
	@OPERATION
	void setMCRule(Object[] posRule, Object[] negRule, double value){		
		cfRule rule = new cfRule(Arrays.copyOf(posRule, posRule.length, String[].class), 
								 Arrays.copyOf(negRule, negRule.length, String[].class), 
								 value);
		mSetRules.add(rule);
	}	
	
	@OPERATION 
	void clear() {
		mSetAgents.clear();
		mSetPositiveConstraints.clear();
		mSetNegativeConstraints.clear();
		mSetRules.clear();
		
		updateCoalitionStructure(null);
	}
		
	private void checkPermission(AgentId id){
		if (mOwners.size() > 0){
			if (!mOwners.get(0).equals(id))
				failed("Permission denied");
		}
	}
	
	private void addOwner(String id){
		if (id.equals(""))
			return;
		
		if (!mOwners.contains(id))
			mOwners.add(id);
	}
	
	private void initialiseAlgorithm(String algorithm){
		String tempAlgorithm = algorithm.toUpperCase();
		
		if (tempAlgorithm.equals("QUADRANTE"))
			iSolver = new QuadCoalition();		
		
		iSolver.initialization();
	}
	
	public interface ICoalitionFormationArtifact {
		public void keepAnyTimeStatistics(boolean keep);
		public void initialization();
		public cfCoalitionStructure solveCoalitionStructureGeneration(cfAgent[] agents, cfBasicConstraint[] positiveConstraints, cfBasicConstraint[] negativeConstraints, cfQuantityConstraint[] sizeConstraints, cfRule[] rules);
		public void clear();
	}
	
	public class cfRule {
		String[] positiveRule = null;
		String[] negativeRule = null;
		double value = 0;
		boolean hasNegation = false;
		
		public cfRule(String[] positiverule, String[] negativerule, double value){
			this.positiveRule 	= positiverule;
			this.value 			= value;
			this.negativeRule 	= negativerule;
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
	public class cfQuantityConstraint {
		int size 	= 0;
		String type = "";
		
		public cfQuantityConstraint(int size, String type){
			this.size = size;
			this.type = type;
		}
	}
	public class cfBasicConstraint {
		String[] agents = null;
		
		public cfBasicConstraint(String[] agents){
			this.agents = agents;
		}
	}
}