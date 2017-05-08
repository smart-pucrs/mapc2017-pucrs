package pucrs.agentcontest2017;

import java.io.IOException;

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
					Server.main(new String[] {"-conf", "conf/SampleConfig.json", "--monitor"});
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}).start();

		try {			
			JaCaMoLauncher.main(new String[] { "test/pucrs/agentcontest2017/scenario.jcm"});
		} catch (JasonException e) {
			System.out.println("Exception: "+e.getMessage());
			e.printStackTrace();
		}

	}

	@Test
	public void run() {
	}

}
