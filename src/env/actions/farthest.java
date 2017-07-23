package actions;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import massim.scenario.city.data.Route;
import env.MapHelper;

public class farthest extends DefaultInternalAction {

	private static final long serialVersionUID = 5552929201215381277L;

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		String role = args[0].toString();
		String type = "road";
		String farthest = null;
		double len = 0;
		if(role.equals("drone")){
			type = "air";
		}
		ListTerm ids = (ListTerm) args[1];
		String from = ts.getUserAgArch().getAgName();
		for (Term term : ids) {
			String to = term.toString();
			Route route = MapHelper.getInstance().getNewRoute(from, to, type);
			if(route.getRouteLength() > len){
				farthest = to;
				len = route.getRouteLength();
			}
		}
		boolean ret = true;
		if(farthest != null){
			ret = un.unifies(args[args.length - 1], Literal.parseLiteral(farthest)); 
		}
		return ret;
	}
}
