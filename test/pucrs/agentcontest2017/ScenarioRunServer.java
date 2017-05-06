package pucrs.agentcontest2017;

import java.io.IOException;

import org.junit.Before;
import org.junit.Test;

import jacamo.infra.JaCaMoLauncher;
import jason.JasonException;


public class ScenarioRunServer {

	@Before
	public void setUp() {

		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					Runtime.getRuntime().exec("java -jar server-2017-0.2-jar-with-dependencies.jar --monitor");
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}).start();

//		try {
//			JaCaMoLauncher runner = new JaCaMoLauncher();
//			runner.init(new String[] { "test/pucrs/agentcontest2017/scenario.jcm" });
//			runner.getProject().addSourcePath("./src/pucrs/agentcontest2017/agt");
//			runner.create();
//			runner.finish();
//		} catch (JasonException e) {
//			e.printStackTrace();
//		}

	}

	@Test
	public void run() {
	}

}
