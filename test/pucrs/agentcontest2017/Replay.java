package pucrs.agentcontest2017;

import org.junit.Before;
import org.junit.Test;

import massim.monitor.Monitor;


public class Replay {

	@Before
	public void setUp() {
		try {
			Monitor.main(new String[] {"replays/2017-09-14-21-16-46-2017-SampleSimulation"});					
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Test
	public void run() {
	}

}
