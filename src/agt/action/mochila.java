package action;
import java.util.Arrays;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;

public class mochila extends DefaultInternalAction {

	int[] peso;
	int[] valor;
	String[] task;
	String[] taskRoot;
	int n;

	int[] memoriza = new int[100];

	int capacidade;
	
	
	private static final long serialVersionUID = 3044142657303654485L;

	@Override
	//public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		
//		int[] peso;
//		int[] valor;
//		String[] task;
//		int n;
//
//		int[] memoriza = new int[100];
//
//		int capacidade;
		
		
		String agente=args[2].toString();
		
		//if (agente.equals("ag1"))
		{
		//-System.out.println("--------------EXECUTE -------------");
//		System.out.println("args[2]:"+args[2].toString());
//		System.out.println("args[0]:"+args[0].toString());
//		System.out.println("args[1]:"+args[1].toString());
		//System.out.println("args[2]:"+args[2].toString());
//		System.out.println("args[3]:"+args[3].toString());
		}
		
		ListTerm ids = (ListTerm) args[0];
		n=ids.size();
		//-System.out.println("n:"+n);
		//-System.out.println("ids:"+ids.toString());
		
				
		//ListTerm capacity = (ListTerm) args[1];
		capacidade=Integer.parseInt(args[1].toString());
//		if (agente.equals("ag1")) {
//		System.out.println("capacidade: "+capacidade);
//		System.out.println("n(size): "+n);
//		}
		
		peso = new int[n+1];
		valor = new int[n+1];
		task = new String[n+1];
		taskRoot = new String[n+1];
		
		//System.out.println("peso.length:"+peso.length);
		//System.out.println("peso:"+Arrays.toString(peso));
		
//		peso = new int[n];
//		valor = new int[n];
//		task = new String[n];

//		if (agente.equals("ag4"))
//		{
//		System.out.println("peso.length:"+peso.length);
//		System.out.println("valor.length:"+valor.length);
//		System.out.println("task.length:"+task.length);
//		System.out.println("taskRoot.length:"+taskRoot.length);
//		System.out.println("\nPESO[I] : ");
//	      for (int i = 0; i < n; i++)
//	          System.out.print(peso[i] +" ");
//	      System.out.println("======================");
//		}
		
		String closest = null;

		
     	int cont=1;
		for (Term term : ids) {
			String candidate = term.toString();
			
			//candidate(3, t5, g2,4).
			//if (agente.equals("ag4"))
			//{
			//System.out.println("Candidate: "+candidate);
			//}
			String part1 = candidate.substring(10,candidate.length()-1);
			//System.out.println("Part1: "+part1);
			String part2[] = part1.split(",");
			int pesox = Integer.parseInt(part2[3]);
			int valorx = Integer.parseInt(part2[0]);
			String taskx = part2[1];
			String taskRootx = part2[2];
			
			
//			if (agente.equals("ag0"))
//			{
//			System.out.println("cont: "+cont);
//			System.out.println("taskx: "+taskx);
//			System.out.println("taskRootx: "+taskRootx);
//			System.out.println("pesox: "+pesox);
//			System.out.println("valorx: "+valorx);
//			System.out.println("peso[cont]: "+peso[cont]);
//			}
			peso[cont] = pesox;
			valor[cont] = valorx;
			
			//System.out.println("taskx 1:"+taskx);
			//if(taskx.contains("\\"))
			//	taskx.replace("\\", "");
			//System.out.println("taskx 2:"+taskx);
			if(taskx.contains("\""))
				taskx= taskx.replace("\"", "");
			if(taskRootx.contains("\""))
				taskRootx= taskRootx.replace("\"", "");
			//System.out.println("taskx 3:"+taskx);
			
			task[cont] = taskx;
			taskRoot[cont] = taskRootx;

			
			
			closest = candidate;
			cont++;
		}

		boolean ret = true;
		
		String[] tasksSelected;
		String[] tasksRootSelected;
		//int total = 0;
		//total = Mochila_old(0,capacidade);
		//System.out.println("Total: "+total);
		
//		  	System.out.println("peso:"+Arrays.toString(peso));
//	        System.out.println("valor:"+Arrays.toString(valor));
//	        System.out.println("capacidade:"+capacidade);
//	        System.out.println("n:"+n);
		
		int[] selectedTasks;
		selectedTasks = Mochila(peso, valor, capacidade,n);
		
//        for (int i = 1; i < selectedTasks.length; i++)
//            if (selectedTasks[i] == 1)
//                System.out.print(task[i] +" ");
        
        ListTerm all = new ListTermImpl();
	    ListTerm tail = all;
        for (int i = 1; i < selectedTasks.length; i++)
            if (selectedTasks[i] == 1)
            {
            	//System.out.println("task[i]:"+task[i]);
        		//if(task[i].contains("\"))
            	//tail = tail.append(Literal.parseLiteral(task[i]));
            	//-System.out.println("task[i]:"+task[i]);
            	//-System.out.println("taskRoot[i]:"+taskRoot[i]);
            	tail = tail.append(Literal.parseLiteral("selected("+task[i]+","+taskRoot[i]+")"));
            }
        //tail = tail.append(Literal.parseLiteral("xx"));
        
        return un.unifies(args[3], all);	
			
		
	}
	
	
    //from knap4.java
	//public static void mochila(int[] peso, int[] valor, int W, int N)
	public int[] Mochila(int[] peso, int[] valor, int W, int N)
    {
        int NEGATIVE_INFINITY = Integer.MIN_VALUE;
        
      //-System.out.println("peso:"+Arrays.toString(peso));
      //-System.out.println("valor:"+Arrays.toString(valor));
      //-System.out.println("W:"+W);
      //-System.out.println("N:"+N);
         
        
        int[][] m = new int[N + 1][W + 1];
        int[][] sol = new int[N + 1][W + 1];
//        int[][] m = new int[N + 1][N + 1];
//        int[][] sol = new int[N + 1][N + 1];

      //-System.out.println("m:"+m[0].length);
      //-System.out.println("sol:"+sol[0].length);
        
        for (int i = 1; i <= N; i++)
        {
            for (int j = 0; j <= W; j++)
            //for (int j = 0; j <= N; j++)
            {
                int m1 = m[i - 1][j];
                int m2 = NEGATIVE_INFINITY; 
                if (j >= peso[i])
                    m2 = m[i - 1][j - peso[i]] + valor[i];

                /** select max of m1, m2 **/
                m[i][j] = Math.max(m1, m2);
                sol[i][j] = m2 > m1 ? 1 : 0;
            }
        }        
        
        /** make list of what all items to finally select **/
        int[] selected = new int[N + 1];
        for (int n = N, w = W; n > 0; n--)
        //for (int n = N, w = N; n > 0; n--)        	
        {
            if (sol[n][w] != 0)
            {
                selected[n] = 1;
                w = w - peso[n];
            }
            else
                selected[n] = 0;
        }

        /** Print finally selected items **/

//        System.out.println("\nItems selected : ");
//        for (int i = 1; i < N + 1; i++)
//            if (selected[i] == 1)
//                System.out.print(i +" ");
//        System.out.println();
		
     return selected;
    }

  
	
	public int Mochila_old(int objetoAtual,int capacidade) {
	
		//System.out.println("objetoAtual: "+objetoAtual);
			
		if(objetoAtual==n) return 0;
		 
		 if (memoriza[objetoAtual]!=0) //já foi calculado então 
		 //memoriza[objetoAtual][weight]
		 return memoriza[objetoAtual];
		 int r1 = 0, r2 = 0;
		 //Tentar colocar o objeto de índice objetoAtual na mochila se ainda tiver espaço para ele.
		 if(peso[objetoAtual] <= capacidade) //então
		 r1 = valor[objetoAtual]+Mochila_old(objetoAtual+1,capacidade-peso[objetoAtual]);
		 //Agora calcular a melhor resposta sem usar objetoAtual, simplesmente ignorando-o:
		 r2 =Mochila_old(objetoAtual+1,capacidade);
		 int resposta;
		 if(r1 >r2) {
			 resposta=r1;
			 //System.out.println("objetoAtual: "+objetoAtual+" - "+resposta);
		 }
		 else {
			 resposta=r2;
			 //System.out.println("objetoAtual: "+objetoAtual+" - "+resposta);
		 }
		 //System.out.println("task: "+task[objetoAtual]+" - "+resposta);
		 memoriza[objetoAtual]= resposta;
		 return resposta;		
	}
	
	
}
