package env;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import cartago.*;


public class TeamArtifact extends Artifact {

	private static Logger logger = Logger.getLogger(TeamArtifact.class.getName());
	private static Map<String, Integer> shopItemsPrice = new HashMap<String, Integer>();
	private static Map<String, Integer> shopItemsQty = new HashMap<String, Integer>();
	private static Map<String, String> agentNames = new HashMap<String, String>();
	private static Map<String, Integer> loads = new HashMap<String, Integer>();
	private static List<String> shops = new ArrayList<String>();
	
	void init(){
		logger.info("Team Artifact has been created!");
	}
	
	public synchronized static void addShopItemsPrice(String shopId, String itemsPrice){
		//logger.info("$> Team Artifact (Shop - Items Price): " + shopId);
		if(shops.contains(shopId)){
			
		} else {
			shops.add(shopId);
			String itemsPriceAux = itemsPrice.replaceAll("availableItem\\(", "").replaceAll("\\)", "").replaceAll("\\[", "").replaceAll("\\]", "");
			String[] s = itemsPriceAux.split(",");
			int x = 0;
			String itemId = null;
			for (int i=0; i<s.length; i++) {
				if (x == 0)
					itemId = s[i];
				else if (x == 1) {
					if (shopItemsPrice.containsKey(itemId)) {
						if (shopItemsPrice.get(itemId) < Integer.parseInt(s[i]))
							shopItemsPrice.put(itemId, Integer.parseInt(s[i]));
					}
					else
						shopItemsPrice.put(itemId, Integer.parseInt(s[i]));
				}
				x++;
				if (x == 4)
					x = 0;
			}
//			logger.info("$> Team Artifact (Item - Price): " + shopItemsPrice);		
		}
	}
	
	@OPERATION void addPrices(){
		for (String key : shopItemsPrice.keySet()) {
			this.defineObsProperty("itemPrice",key,shopItemsPrice.get(key));
		}
		
	}
	
	@OPERATION void addServerName(String agent, String agentServer){
		agentNames.put(agent,agentServer);
	}
	
	@OPERATION void getServerName(String agent, OpFeedbackParam<String> agentServer){
		agentServer.set(agentNames.get(agent));
	}
	
	@OPERATION void addLoad(String agent, int load){
		loads.put(agent,load);
	}
	
	@OPERATION void getLoad(String agent, OpFeedbackParam<Integer> load){
		load.set(loads.get(agent));
	}
	
	@OPERATION void addShopItem(String item, int qty){
		shopItemsQty.put(item,qty);
	}
	
	@OPERATION void getShopItem(String item, OpFeedbackParam<Integer> qty){
		qty.set(shopItemsQty.get(item));
	}
	
	public static int getLoad(String agent) {
		return loads.get(agent);
	}
		
	@OPERATION void addResourceNode(String resourceId, double lat, double lon, String resource){
		ObsProperty prop = this.getObsPropertyByTemplate("resNode", resourceId,lat,lon,resource);
		if (prop == null) {
			this.defineObsProperty("resNode",resourceId,lat,lon,resource);
		}
	}
	
	@OPERATION void clearMaps() {
		shopItemsQty.clear();
		agentNames.clear();
		loads.clear();
		
	}
	
}