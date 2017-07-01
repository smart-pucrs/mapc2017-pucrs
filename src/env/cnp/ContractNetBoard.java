package cnp;

import jason.asSyntax.Literal;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import cartago.*;

public class ContractNetBoard extends Artifact {
	
	private Logger logger = null;
	
	private List<Bid> bids;
	
	void init(String taskDescr, long duration, int agents){
		logger = Logger.getLogger(""+this.getId());
		this.defineObsProperty("state","open");
		bids = new ArrayList<Bid>();
		this.execInternalOp("checkDeadline", duration);
		this.execInternalOp("checkAllBids", agents);
	}
	
	@OPERATION void bid(int shopQuad, int storageQuad, int distance, String agent){
		if (getObsProperty("state").stringValue().equals("open")){
			bids.add(new Bid(agent,shopQuad,storageQuad,distance));
		} else {
			this.failed("cnp_closed");
		}
	}
	
	@INTERNAL_OPERATION void checkDeadline(long dt){
		await_time(dt);
		if(!isClosed()){
			getObsProperty("state").updateValue("closed");
			logger.info("bidding stage closed by deadline.");
		}
		removeObsProperty("state");
	}
	
	@INTERNAL_OPERATION void checkAllBids(int agents){
		while(!isClosed() && !allAgentsMadeTheirBid(agents)){
			await_time(50);
		}
		if(!isClosed()){
			getObsProperty("state").updateValue("closed");
			logger.info("bidding stage closed by all agents bids.");
		}
	}
	
	@OPERATION void getBids(OpFeedbackParam<Literal[]> bidList){
		await("biddingClosed");
		int i = 0;
		Literal[] aux= new Literal[bids.size()];
		for (Bid p: bids){
			aux[i] = Literal.parseLiteral("bid("+p.getAgent()+","+p.getShopQuad()+","+p.getStorageQuad()+","+p.getDistance()+")");
			i++;
		}
		bidList.set(aux);
	}	
	
	@GUARD boolean biddingClosed(){
		return isClosed();
	}
	
	private boolean isClosed(){
		return this.getObsProperty("state").stringValue().equals("closed");		
	}
	
	private boolean allAgentsMadeTheirBid(int agents){
		 return bids.size() == agents;
	}
	
	static public class Bid {
		
		private String agent;
		private int shopQuad;
		private int storageQuad;
		private int distance;
		
		public Bid(String agent, int shopQuad, int storageQuad, int distance){
			this.agent = agent;
			this.shopQuad = shopQuad;
			this.storageQuad = storageQuad;
			this.distance = distance;
		}
		
		public String getAgent(){ return agent; }
		public int getShopQuad(){ return shopQuad; }
		public int getStorageQuad(){ return storageQuad; }
		public int getDistance(){ return distance; }
	}
	
}
