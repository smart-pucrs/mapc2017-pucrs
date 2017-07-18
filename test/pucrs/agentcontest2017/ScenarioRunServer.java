package pucrs.agentcontest2017;

import org.junit.Before;
import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;
import massim.Server;


public class ScenarioRunServer {

	@Before
	public void setUp() {

		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
//					Server.main(new String[] {"-conf", "conf/SampleConfig.json", "--monitor"});					
					Server.main(new String[] {"-conf", "conf/TwoMapsConfig.json", "--monitor"});
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();

		try {			
			JaCaMoLauncher.main(new String[] {"pucrs-mapc2017.jcm"});
		} catch (JasonException e) {
			System.out.println("Exception: "+e.getMessage());
			e.printStackTrace();
		}

	}

	@Test
	public void run() {
	}

}
