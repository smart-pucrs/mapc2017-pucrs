package pucrs.agentcontest2017;

import org.junit.Before;
import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;

public class ScenarioConnectToServer {

	@Before
	public void setUp() {
		
//		try {
//			JaCaMoLauncher runner = new JaCaMoLauncher();
//			runner.init(new String[] { "test/pucrs/agentcontest2017/scenario.jcm" });
//			runner.getProject().addSourcePath("./src/pucrs/agentcontest2017/agt");
//			runner.create();
//			runner.finish();
//		} catch (JasonException e) {
//			e.printStackTrace();
//		}
		
		try {			
			JaCaMoLauncher.main(new String[] { "test/pucrs/agentcontest2017/scenario.jcm"});
		} catch (JasonException e) {
			e.printStackTrace();
		}
	}

	@Test
	public void run() {
	}

}
