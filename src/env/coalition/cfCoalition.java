package coalition;

import java.util.ArrayList;
import java.util.List;

import coalition.CFArtefact.cfAgent;

public class cfCoalition {
	private List<String> 	agents;
	private String 			name;
	
	public cfCoalition(String name){
		this.agents = new ArrayList<>();
		this.name 	= name;
	}
	public void addAgent(cfAgent agent) {
		this.agents.add(agent.name);
	}
	public String[] getAgents() {
		return this.agents.toArray(new String[this.agents.size()]);
	}
	public String getCoalitionName(){
		return this.name;
	}
}