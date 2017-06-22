package coalition;

import java.util.ArrayList;
import java.util.List;

public class cfCoalitionStructure {
	private List<cfCoalition> coalitions;
	private String name;
	
	public cfCoalitionStructure(String name){
		this.coalitions = new ArrayList<>();
		this.name 		= name;
	}
	
	public void addCoalition(cfCoalition coalition) {
		this.coalitions.add(coalition);
	}
	public cfCoalition[] getCoalitions() {
		return this.coalitions.toArray(new cfCoalition[this.coalitions.size()]);
	}
	public String getCSName(){
		return this.name;
	}		
}