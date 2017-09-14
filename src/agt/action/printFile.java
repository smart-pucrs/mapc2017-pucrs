package action;

import java.io.File;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;


public class printFile extends DefaultInternalAction {

	/**
	 * 
	 */
	private static final long serialVersionUID = 5444574937658709099L;


	//private static final long serialVersionUID = 432843279812342L;
	
	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {

//		String agente=args[2].toString();
//		if (agente.equals("vehicle1"))
		
//		System.out.println("args"+args.toString());
//		System.out.println("un"+un.toString());
//		System.out.println("ts"+ts.toString());
		
//		{
//		System.out.println("--------------EXECUTE -------------");
//		System.out.println("args[0]:"+args[0].toString());
//		System.out.println("args[1]:"+args[1].toString());
//		System.out.println("args[2]:"+args[2].toString());
//		System.out.println("args[3]:"+args[3].toString());
//		}

		//int argSize=args.length;
		
		String line="";
		for (int i = 0; i < args.length; i++) {
			line=line+args[i].toString();
		}
		
		saveFile(args[0].toString(),line);
		//saveFile(args[0].toString(),args[1].toString());
		
//		ListTerm ids = (ListTerm) args[0];
//
//		
//		for (Term term : ids) {
//			String candidate = term.toString();
//			System.out.println("To: "+candidate);
//		}
//			ListTerm all = new ListTermImpl();
//	    ListTerm tail = all;
//        for (int i = 1; i < 3; i++)
//            tail = tail.append(Literal.parseLiteral("xx"));
        
     //   return un.unifies(args[3], all);	
        return true;
	}
	
	
	public void saveFile(String fileName, String data)
   {	
     
		try{
    	String content = data;
        //Specify the file name and path here
    	File file =new File("//home//tbasegio//projects//MASTest//"+fileName+".txt");
    	//File file =new File("C://temp//MASTest//"+fileName+".txt");

    	/* This logic is to create the file if the
    	 * file is not already present
    	 */
    	if(!file.exists()){
    	   file.createNewFile();
    	}

    	//Here true is to append the content to file
    	FileWriter fw = new FileWriter(file,true);
    	//BufferedWriter writer give better performance
    	BufferedWriter bw = new BufferedWriter(fw);
    	bw.write(content);
    	bw.newLine();
    	bw.flush();
    	//Closing BufferedWriter Stream
    	bw.close();

	//System.out.println("Data successfully appended at the end of file");

      }catch(IOException ioe){
         System.out.println("Exception occurred:");
    	 ioe.printStackTrace();
       }
   }
}