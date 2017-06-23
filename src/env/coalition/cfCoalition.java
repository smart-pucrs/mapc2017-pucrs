package coalition;

import java.util.ArrayList;
import java.util.List;

import coalition.CFArtefact.cfAgent;

public class cfCoalition {
//	private List<String> 	agents;
	private List<cfAgent> 	agents;
	private String 			name;
	
	public cfCoalition(String name){
		this.agents = new ArrayList<>();
		this.name 	= name;
	}
	/*public void addAgent(cfAgent agent) {
		this.agents.add(agent.name);
	}*/
	public void addAgent(cfAgent agent) {
		this.agents.add(agent);
	}
	/*public String[] getAgents() {
		return this.agents.toArray(new String[this.agents.size()]);
	}*/
	public String[] getAgentsArray() {
		String[] names = new String[agents.size()];
		for(int i=0; i<agents.size(); i++)
			names[i] = agents.get(i).name;
		return names;
	}
	public List<cfAgent> getAgents() {
		return agents;
	}
	public String getCoalitionName(){
		return this.name;
	}
}