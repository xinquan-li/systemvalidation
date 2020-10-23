 #define N 2
 #define L 6
 bit init_data[L]; 
 
 proctype proc (byte my_id, next_id, previous_id; chan to_next, from_previous, to_receiver)
 { bit my_init_data[N]; byte i=0;
/* here declare more variables */
bit  full_data[L]; byte a=0; byte b=0; byte z=0; byte c=0; byte d=0; byte g=0; bit my_pswd[N];
/* the 4 lines below initialise local arrays in PrA, PrB and PrC */
 do
  :: i<N -> my_init_data[i] = init_data[my_id*N + i];full_data[my_id*N+i]= init_data[my_id*N + i]; i++;
  :: else -> break
  od

 do
  :: a<N -> to_next ! my_init_data[a]; a++;
:: else -> break;
  od

  do
   :: b<N -> from_previous ? full_data[previous_id*N+b]; b++;
 :: else -> break;
  od

 do
  :: c<N -> to_next ! full_data[previous_id*N+c];c++;
 :: else -> break;
 od
 do
 :: d<N -> from_previous ? full_data[next_id*N+d]; d++;
 :: else -> break;
  od 


end1:
 do
 ::z<2*N->my_pswd[z] =  full_data[z] || (full_data[z+2] && full_data[z+4]);    
 progress1: to_receiver ! my_pswd[z];
z++;
 od; 
}
 proctype receiver (chan from_A, from_B, from_C)
 { bit pswd[L] ; byte w=0; byte psw,id; byte pos=0;
   bit location[L]; location[0]=0;
do
:: from_A ? psw -> id=0->
                                 if
                                  ::(location[pos] ==0)-> pswd[id*N+w]=psw;w++;location[pos]=1;pos++
                                 ::(w<2*N ||pos>N-1) ->break
                                 fi

:: from_B? psw -> id=1->
                                 if
                                  ::(location[pos] ==0)-> pswd[id*N+w]=psw;w++;location[pos]=1;pos++
                                 ::(w<2*N || pos>N-1) ->break
                                 fi
:: from_C? psw -> id=2->
                                 if
                                  ::(location[pos] ==0)-> pswd[id*N+w]=psw;w++;location[pos]=1;pos++
                                 ::(w<2*N || pos>N-1) ->break
                                 fi
od
	
 }
 
 init {
 chan AtoB = [N] of { bit }; chan BtoC = [N] of { bit }; chan CtoA = [N] of { bit };
chan AtoR = [N] of { bit }; chan BtoR = [N] of { bit }; chan CtoR = [N] of { bit };
 atomic
 {
init_data[0]=1; init_data[1]=0; init_data[2]=1; /* change these values to   */
  init_data[3]=1; init_data[4]=1; init_data[5]=0; /* generate other passwords */
  run proc (0,1,2,AtoB,CtoA,AtoR);
 run proc (1,2,0,BtoC,AtoB,BtoR);
  run proc (2,0,1,CtoA,BtoC,CtoR);
 run receiver(AtoR,BtoR,CtoR)
 }
 }
