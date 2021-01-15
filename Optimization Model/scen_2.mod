/*********************************************
 * OPL 12.6.3.0 Model
 * Author: mmr
 * Creation Date: 08/12/2016 at 9:28:26 AM
 *********************************************/

 // Network nodes
int     NN      = ...; 		//total number of nodes
int		NJ		= ...; 		//number of SCNs
int     NO		= ...; 		//number of ONUs
int 	NM		= ...; 		//number of splitters
// int	C	= NN;		// GPON is always defined as the last node. 



//Define sets
range   V = 1..NN;				//number of Total nodes, n
range   J = 1..NJ;	 			//number of SCNs, k
//range	O = NJ+1..NJ+NO;    	//number of ONUs
//range	M = NJ+NO+1..NJ+NO+NM;    //number of Splitters


//sets
tuple   edge   {int u; int v;float c;}		// Link Set Definition
{edge} E = ...;


//Parameters
int R[k in J,n in V] = ...;				    // Flow of Demand on SCN k of node n.
int D[k in J] = ...;						// Demands of SCNs (Mbps) 
int NodePower[n in V]=...;					// Power Consumption of any Nodes (Watt)
int RL[e in E] = ...;						// Radio Links 
int MaxCap[e in E] =... ;					// Capacity of Radio Links

 


// Decision Variables
dvar boolean af[J,E]; //flow of demand j on edge e
dvar boolean ar[J,E]; //flow of demand j on edge e
dvar boolean b[J,E]; //indicate if link e is used
dvar boolean alpha[E]; //indicate if link e is used

dvar int Ce[E];  //capacity on each edge
dvar float+ Pn[V] ; //power at each node
dvar float+ Pe[E] ; //power at each radio link


/*****************************************************************************
 *
 * MODEL
 * 
 *****************************************************************************/

// Objective
//minimize sum(e in E)Pe[e] +sum(n in V)Pn[n] ;
// minimize sum(k in J, e in E)a[k,e];
// minimize sum(e in E)Ce[e];
minimize sum(n in V)Pn[n] + sum(e in E)Pe[e];
//minimize sum(e in E)alpha[e];



subject to {
     //flow conservation
   forall(k in J, n in V)
   		sum(e in E:e.u==n)af[k,e] + sum(e in E:e.v==n)ar[k,e] - (sum(e in E:e.v==n)af[k,e] + sum(e in E:e.u==n)ar[k,e]) == R[k,n];

	forall(k in J, e in E)
	  	b[k,e] == af[k,e] + ar[k,e] ;
	//forall(k in J, e in E)
//	  	af[k,e] + ar[k,e] <=1;    
	  	  		
   //capacity calculation
   forall(e in E)
     Ce[e] == sum(k in J)D[k]*(af[k,e]+ar[k,e]);
  
   //capacity constraints
   forall(e in E)
     Ce[e] <= MaxCap[e];
   
  //radio link power calculation
  forall(e in E)
     Pe[e] == RL[e]*Ce[e];
   
   //determine if edge e is used
   forall(k in J, e in E)
     alpha[e] >= af[k,e] + ar[k,e];
   forall(e in E)
     alpha[e] <= sum(k in J)(af[k,e]+ ar[k,e]);
   
   // node power calculation 
   forall(n in V,e in E:e.v==n) 
   		Pn[n] == alpha[e]*NodePower[n];
  
       	
 }   