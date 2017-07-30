// CArtAgO artifact code for project dyn-scheme

package org;

import cartago.*;
import moise.os.*;

public class CreateOS extends Artifact {

    @OPERATION
    void create(String file) throws Exception {
        OSBuilder b = new OSBuilder();
        b.addScheme("st", "job_delivered");

        b.addGoal("st", "job_delivered", "phase1, phase2");
        b.addGoal("st", "phase1", "assistp1 || assemblep1");
        b.addGoal("st", "phase2", "assistp2 || assemblep2");
        b.addGoal("st", "assistp1", "buy_items");
        b.addGoal("st", "assemblep1", "go_to_workshop");
        b.addGoal("st", "assistp2", "assist_assemble");
        b.addGoal("st", "assemblep2", "do_assemble, stop_assist_assemble");

        b.addMission("st", "massemble", "go_to_workshop, do_assemble");
        b.addMission("st", "massist", "buy_items, assist_assemble, stop_assist_assemble");

        b.getOS().getNS().setProperty("mission_permission", "ignore");

        b.save("scheme/"+file);
    }
}
