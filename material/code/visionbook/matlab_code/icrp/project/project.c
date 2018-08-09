/* This is a source code for 'project' program
   by Jan Kybic, 1996. It projects a set of 3D points into a plane.
   
   It is to be invoked by 'project x y z', where (x,y,z) is 
   a vector of real numbers perpendicular to the project plane.
   It then reads data from standard input, each line representing one point 
   in 3D space containing three real numbers - coordinates x,y,z.
   For each input line it produces an output line consisting of a pair
   of real numbers - coordinates u,v of the projected point in the plane.
   
   The normal vector does not define the projecting function entirely,
   however, while any such a function is satisfactory for the intended
   application, I prefer to leave the detailed choice to the program.
*/

#include <stdio.h>
#include <stdlib.h>

#define EPS 1e-50    /* smaller than this is zero */

typedef double vector[3] ;

double product(vector a,vector b) /* dot product of two vectors */
{ 
  return a[0]*b[0]+a[1]*b[1]+a[2]*b[2] ;
}


void times(vector c,vector a,vector b) 
/* vector product c of two vectors a,b */
{
  c[0]= a[1]*b[2]-a[2]*b[1] ;
  c[1]=-a[0]*b[2]+a[2]*b[0] ;
  c[2]= a[0]*b[1]-a[1]*b[0] ;
}


double mag(vector a) /* square of a magnitude of a vector */
{ return product(a,a) ;
}


vector n,k,l ;
double n2,k2,l2 ;

int init()  /* given vector n, compute k,l */   
{
  if ((n2=mag(n))<EPS)
    { fputs("!!! project: Vector is too small.\n",stderr) ;
      return -1 ;
    }
  
  /* Create vector k, perpendicular to n */
  if (abs(n[0])>abs(n[1]))
    if (abs(n[0])>abs(n[2]))
         { k[0]=-n[1]/n[0] ; k[1]=1 ; k[2]=0 ; }
     else 
         { k[0]=0 ; k[1]=1 ; k[2]=-n[1]/n[2] ; }
   else      
    if (abs(n[2])>abs(n[1]))
         { k[0]=0 ; k[1]=1 ; k[2]=-n[1]/n[2] ; }
      else    
         { k[0]=0 ; k[1]=-n[2]/n[1] ; k[2]=1 ; }
         
  times(l,k,n) ;
  k2=mag(k) ; l2=mag(l) ;
           
  return 0 ;
} 

#define BUFLEN 256

int main(int argc, char *argv[])
{
  vector q ; char buf[BUFLEN] ;

  if (argc!=4)
    { fputs("!!! project: Usage: 'project x y z'\n",stderr) ;
      return 1 ;
    }
 
  n[0]=atof(argv[1]) ; n[1]=atof(argv[2]) ; n[2]=atof(argv[3]) ;
       
  if (init()) return 1 ;
  
  while(fgets(buf,BUFLEN,stdin)!=NULL)
    { if (sscanf(buf,"%lf %lf %lf",&q[0],&q[1],&q[2])==3)
               printf("%g %g\n",product(k,q)/k2,product(l,q)/l2) ;    
        else { fprintf(stderr,"!!! project: Real number expected: %s\n",buf) ;
               return 1 ;
             }
             
    }
  
    
  return 0 ;    
}      
      
      
          