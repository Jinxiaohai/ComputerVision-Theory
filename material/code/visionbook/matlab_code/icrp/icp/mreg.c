/* Multiple point sets registration algorithm */
/* based on article of A.J.Stoddard, A.Hilton in Proceedings of ICRP'96 */
/* and an ICP implementation by P. Kucera, FEL CVUT, Prague */

/* Implemented by Jan Kybic (xkybic@sun.felk.cvut.cz) */

/* Program expects on standard input the number of views on the first line */
/* Then a file name, number of points and an initial transformation vector (7D) */
/* for each view */

/* This version includes adaptive step-size modification based on step doubling */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>
#include <string.h>

#include "mreg.h" 	/* This includes also clrange.h and icp.h */

#define MATLABOUT 1     /* generate Matlab output */
#define REGISTER  1     /* register if 1, if 0 assume i<->i */
#define SCROUT    0     /* write the transformations on the screen as */

static int flag_scrout ;

#define MAXERR 1e-3     /* an absolute error boundary used in Compute for step-size control */

#if MATLABOUT
FILE *matf ;
#endif

#define DEBUG 1

ViewT view[MAXNVIEWS] ;
int nviews=0 ;          /* actual number of views */

/* whether to use elimination and at what distance */
BoolT eliminate=1 ; 
DoubleT elimdist=10.0 ;

DoubleT dt=0.0001 ;   /* time increment --- initial value */
DoubleT sumsqd ; /* sum of the squares of the distances between corr. pts. */
int numsqd ;


/* precision limit for inner and outer loop of iteration */
#define INNERLIM (0.0001)
#define OUTERLIM (0.1)

/* number of iterations in Compute */
#define NITIN 5000
#define NITOUT 50

DoubleT g,G ;  /* linear and rotational drag */


int main()
{
#if DEBUG
  puts("mreg started.") ;
#endif

#if MATLABOUT
 if ((matf=fopen("mreg.out","w"))==NULL)
   perror("Cannot open mreg.out for writing.") ;
#endif MATLABOUT   

 InitViews() ;
 flag_scrout=SCROUT ; /* should Display print ? */
 Compute() ;
 flag_scrout=1 ;
 Display() ;
 CloseViews() ;

#if MATLABOUT
 fclose(matf) ;
#endif 

#if DEBUG
  puts("Finished.") ;
#endif

 return 0 ;
}

void InitViews() /* read and initialize views */
{
 int i ; DoubleT rmax=0.0 ;
 
 scanf("%d",&nviews) ;
 if (nviews<2 || nviews>MAXNVIEWS)
   { fprintf(stderr,"Wrong number of views.\n") ;
     exit(1) ;
   }
 #if DEBUG
 printf("Number of views: %d\n",nviews) ;
 #endif
 
 for(i=0;i<nviews;i++)
  { 
#if DEBUG
    printf("Reading view %d.\n",i) ;
#endif      
    ReadView(&view[i]) ;
    SetupView(&view[i]) ;
    if (rmax<view[i].rms) rmax=view[i].rms ;
  }
  
 /* recommended parameter settings from the article */ 
 g=1.0 ; G=0.5*g*rmax*rmax ; 
}

void ReadView(ViewT *v) /* read one view */
{
  int c ; char *p ;
  
  while ((c=getchar())==' ' || c=='\n' || c=='\r' || c=='\t') ;
  
  p=v->filename ; *p++=c ;
  
  while (!isspace(c=getchar()) && p<v->filename+FILENAMELEN-1) *p++=c ;
  *p='\0' ;
  
#if DEBUG
  printf("filename: %s\n",v->filename) ;
#endif

  scanf("%d %lf %lf %lf %lf %lf %lf %lf",&v->n,
        &v->itransf[0],&v->itransf[1],&v->itransf[2],&v->itransf[3],
        &v->itransf[4],&v->itransf[5],&v->itransf[6]) ;

#if DEBUG
  printf("num=%d itransf=(%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f)\n",v->n,
        v->itransf[0],v->itransf[1],v->itransf[2],v->itransf[3],
        v->itransf[4],v->itransf[5],v->itransf[6]) ;
#endif
  
  IcpNormalizeVector(v->itransf,4) ;
  IcpReadPsetFile(v->filename,v->n,&v->shp) ;

#if DEBUG  
  puts("File read.") ;
#endif
    
}      
            
  
void SetupView(ViewT *v) /* precomputes cm, rms and sets R,T */
{ int i ;

  if ((v->corr=malloc(v->n * sizeof(int)))==NULL) IcpMemError() ;
  if ((v->tp=malloc(v->n * sizeof(VectorT)))==NULL) IcpMemError() ;

  v->cm[0]=v->cm[1]=v->cm[2]=0.0 ;  
  
  for(i=0;i<v->n;i++) 
   { v->cm[0]+=v->shp.pset->ps[i][0] ; 
     v->cm[1]+=v->shp.pset->ps[i][1] ;
     v->cm[2]+=v->shp.pset->ps[i][2] ;
   }
  v->cm[0]/=v->n ; v->cm[1]/=v->n ; v->cm[2]/=v->n ;

  
#define DIST(x) (((x)[0]-v->cm[0]) * ((x)[0]-v->cm[0]) +\
        ((x)[1]-v->cm[1]) * ((x)[1]-v->cm[1]) +\
        ((x)[2]-v->cm[2]) * ((x)[2]-v->cm[2]))
               
  
  v->rms=0.0 ;  
  
  for(i=0;i<v->n;i++) v->rms+=DIST(v->shp.pset->ps[i]) ;
   
  v->rms=sqrt(v->rms/v->n) ; 

#if DEBUG
  printf("Center of mass=(%.3f,%.3f,%.3f), rmsdist=%.3f\n",
  v->cm[0],v->cm[1],v->cm[2],v->rms) ;
#endif  
 
  IcpCompRotMatrix(v->itransf,v->R) ;
  v->T[0]=v->itransf[4] ;    v->T[1]=v->itransf[5] ;    v->T[2]=v->itransf[6] ;  
}   
         
void CloseViews()
{ int i ;

#if DEBUG
  puts("Deallocating memory") ;
#endif
  
  for(i=0;i<nviews;i++)
    { free(view[i].shp.pset->ps) ;
      free(view[i].shp.pset) ;
      free(view[i].tp) ;
      free(view[i].corr) ;
    }
}                 

void TransformAllSets()          
{ int i ;
  for(i=0;i<nviews;i++)    
    {
     #if DEBUG
     printf("Transforming set %d.\n",i) ;
     #endif    
     IcpApplyRegistration(view[i].T,view[i].R,view[i].shp.pset,view[i].tp) ;
    }   
}      

void RegisterAllSets()
{ int i,j ;

  sumsqd=0.0 ; numsqd=0 ;
  
  for(i=0;i<nviews;i++)
    for(j=i+1;j<nviews;j++)
      { 
       #if DEBUG
       printf("Registering %d versus %d.\n",i,j) ;
       #endif             
       Register(&view[i],&view[j]) ; Register(&view[j],&view[i]) ;
       if (eliminate)
         { 
          #if DEBUG
          printf("Eliminate %d versus %d.\n",i,j) ;
          #endif
          Eliminate(&view[i],&view[j]) ; Eliminate(&view[j],&view[i]) ; 
          #if DEBUG
          printf("We shall use %d points in %d and %d in %d\n",
               view[i].nu,i,view[j].nu,j) ;
          #endif 
         } 
       #if DEBUG
       puts("Computing averages and correlation matrices.") ;
       #endif 
       ComputeAQ(i,j) ; ComputeAQ(j,i) ;
      }
  printf("Average square distance: %f\n",sumsqd/numsqd) ;    
}         

#undef DEBUG
#define DEBUG 1

DoubleT ComputeAllForces()
/* returns the sum of the squares of magnitudes of all F and tor */
{ int i,j ;

  DoubleT sum ;

  for(i=0;i<nviews;i++) 
   { view[i].F[0]=view[i].F[1]=view[i].F[2]=0.0 ;
     view[i].tor[0]=view[i].tor[1]=view[i].tor[2]=0.0 ;
   }
     
  for(i=0;i<nviews;i++)
   for(j=0;j<nviews;j++)
    if (i!=j)
     {
      #if 0
      printf("Computing forces induced on view %d by view %d.\n",i,j) ;
      #endif   
      ComputeForces(i,j) ;
     }    

  sum=0.0 ;        
  for(i=0;i<nviews;i++)
   {
    #if 0
    printf("view %d - F=(%.3f,%.3f,%.3f) tor=(%.3f,%.3f,%.3f)\n",i,
      view[i].F[0],view[i].F[1],view[i].F[2],
      view[i].tor[0],view[i].tor[1],view[i].tor[2]) ;
    #endif
    for(j=0;j<3;j++)
     sum+=view[i].F[j]*view[i].F[j]+view[i].tor[j]*view[i].tor[j] ;
   }

#if 0
  printf("dt=%g sum=%.5f\n",dt,sum) ;
#endif  
  return sum ;     
}
#undef DEBUG
#define DEBUG 0


void UpdateAllTransforms(DoubleT dt)
{ int i,k ;
  VectorT a,b,c ; DoubleT q[4],angle,sina ;
  ViewT *v ; MatrixT rm,om ;
  
  for(i=0;i<nviews;i++)
   { 
     #if DEBUG
     printf("Updating transformations for view %d.\n",i) ;
     #endif
     
     v=&view[i] ;
  
     for(k=0;k<3;k++) q[k+1]=dt*v->tor[k] ;
     angle=sqrt(q[1]*q[1]+q[2]*q[2]+q[3]*q[3]) ;
     if (angle>1e-20)
       { q[0]=0.0 ;
         IcpNormalizeVector(q,4) ; }
     q[0]=cos(angle/2) ;
     sina=sin(angle/2) ;
     for(k=0;k<3;k++) q[k+1]*=sina ;     
     IcpCompRotMatrix(q,rm) ;
     memcpy(om,v->R,sizeof(MatrixT)) ;
     MatrixTimesMatrix(v->R,rm,om) ;
     for(k=0;k<3;k++) a[k]=dt * v->F[k] ;
     VectorSub(c,v->T,v->cm) ;
     MatrixTimesVector(b,rm,c) ;
     VectorAdd(c,b,v->cm) ;
     VectorAdd(v->T,c,a) ;
   } 
}   
#undef DEBUG
#define DEBUG 0

void Compute()  /* performs the computation */
{ int nitout,nitin ; /* outer/inner iteration counters */
  
  DoubleT sum,prevsum,osum,dif,rat ; 
 
 #if 1
 puts("Starting the computation") ;
 #endif  
 
 nitout=0 ; sum=0.0 ;
 do { 
    nitout++ ; osum=sum ;
    #if 1
    printf("Iteration no.:%d\n",nitout) ;
    #endif  
    TransformAllSets() ;
    RegisterAllSets() ;
    Display() ;
         
   nitin=0 ; sum=1e50 ;
   do
    { nitin++ ; prevsum=sum ;

      /* save the current position to slot 0*/    
      SaveAllTransforms(0) ;
      Display() ;

      try_again:
      /* make one full size step */
      sum=ComputeAllForces() ;
      UpdateAllTransforms(dt) ;
      SaveAllTransforms(1) ;

      /* now make two half size steps */
      RestoreAllTransforms(0) ;
      sum=ComputeAllForces() ;
      UpdateAllTransforms(dt/2) ;
      sum=ComputeAllForces() ;
      UpdateAllTransforms(dt/2) ;

      /* what is the difference between smaller and bigger steps ? */
      dif=MaxDiff(1) ;       
#if DEBUG 
      printf("half size / full size step dif=%g\n",dif) ;
#endif 

      rat=dif/MAXERR ;
      if (rat>1) 
        { dt/= (rat > 10.0) ? 10.0 : rat ;
#if DEBUG
          printf("Reducing dt to %g\n",dt) ;
#endif
          RestoreAllTransforms(0) ;
          goto try_again ; /* redo the step */
        }  
       else 
        { if (rat<0.1) dt/=10 ; else dt/=rat  ;
#if DEBUG
          printf("Enlarging dt to %g\n",dt) ;
#endif
          /* no need to redo the last step */
        }
    }  while(nitin<NITIN && ABS(sum-prevsum)>INNERLIM) ;
    
   if (nitin>=NITIN)
     printf("Total number of inner iteration exceeded %d\n",nitin) ;          
  } while(nitout<2 || (nitout<NITOUT && ABS(sum-osum)>OUTERLIM)) ;

#if 1
   if (nitout>=NITOUT)
     printf("Total number of outer iteration exceeded %d\n",nitout) ;          

 puts("Calculation finished.") ;
#endif   
}     

DoubleT MaxDiff(int j) 
/* returns the maximum (in absolute value) difference between the 
   parameters of the current transformation and the one saved in slot j 
   for all views */
{ ViewT *v ;
  int i,k,l ;
  DoubleT maxdif,dif ;

  maxdif=0 ;
  for(i=0;i<nviews;i++)
   { v=&view[i] ;
     for(k=0;k<3;k++)
       { dif=ABS(v->T[k] - v->Told[j][k]) ;
         if (dif>maxdif) maxdif=dif ;
         
         for(l=0;l<3;l++)
	   { dif=ABS(v->R[k][l] - v->Rold[j][k][l]) ;
             if (dif>maxdif) maxdif=dif ;
           }
       }
   }

 return maxdif ;  
}

void SaveAllTransforms(int j)
{ ViewT *v ;
  int i ;
  
  for(i=0;i<nviews;i++)
   { v=&view[i] ;
     memcpy(v->Rold[j],v->R,sizeof(MatrixT)) ;
     memcpy(v->Told[j],v->T,sizeof(VectorT)) ;
   }  
}


void RestoreAllTransforms(int j)
{ ViewT *v ;
  int i ;
  
  for(i=0;i<nviews;i++)
   { v=&view[i] ;
     memcpy(v->R,v->Rold[j],sizeof(MatrixT)) ;
     memcpy(v->T,v->Told[j],sizeof(VectorT)) ;
   }  
}


void Register(ViewT *v,ViewT *w)
/* for all points in v, find their closest partners from w */
{
 TreeT *tree; int i,j ; ShapeT s ; PointSetT pset ; VectorT dummy ;
 
 s.repr=PSET ; s.pset=&pset ; 
 pset.n=w->n ; pset.ps=w->tp ;
 
 tree=IcpRangeSearchInit(&s) ;
 
 for(i=0;i<v->n;i++)
  { 
   v->corr[i]=j=
#if REGISTER   
   IcpPsetRangeClosestPoint((DoubleT *)(v->tp+i),&s,
    (DoubleT *)&dummy,tree) ;
#else
   i ;
#endif
   
   sumsqd+=(v->tp[i][0]-w->tp[j][0])*(v->tp[i][0]-w->tp[j][0])+
           (v->tp[i][1]-w->tp[j][1])*(v->tp[i][1]-w->tp[j][1])+
           (v->tp[i][2]-w->tp[j][2])*(v->tp[i][2]-w->tp[j][2]) ;
   numsqd++ ;        
       
#if 0    
   printf("%d->%d,",i,v->corr[i]) ; 
#endif   
  } 

 v->nu=v->n ; 
 IcpRangeSearchClose(tree) ;
} 

void Eliminate(ViewT *v,ViewT *w)
/* from view v eliminate all points that do not have partners in w */
{
  int i,j ; VectorT *vp,*wp ; DoubleT eds ;
  
  eds=elimdist*elimdist ; 
  
  for(i=0;i<v->n;i++)
   { vp=v->tp+i ; j=w->corr[v->corr[i]] ;
     if (j<0) j=-j-1 ;
     wp=v->tp+j ;
     if ((*vp[0]-*wp[0])*(*vp[0]-*wp[0])+(*vp[1]-*wp[1])*(*vp[1]-*wp[1])+
         (*vp[2]-*wp[2])*(*vp[2]-*wp[2])>eds) 
           { v->corr[i]=-(v->corr[i]+1) ; v->nu-- ; }
   }                  
}

void ComputeAQ(int i,int j)
/* compute average value and correlation matrix of views i with respect to j */
{ int k,l,ii,jj ; ViewT *v,*w ; PointsT p,q ; MatrixT *m ;
  VectorT iv,jv,*av ;

  v=&view[i] ; w=&view[j] ; p=v->shp.pset->ps ; q=w->shp.pset->ps ;
  m=&(v->Q[j]) ; 
  
  av=&(v->avg[j]) ;
  
  *av[0]=*av[1]=*av[2]=0.0 ;
  for(i=0;i<v->n;i++) 
   if (v->corr[i]>=0) 
     { *av[0]+=p[i][0] ; *av[1]+=p[i][1] ; *av[2]+=p[i][2] ; } 
  *av[0]=*av[0]/v->nu-v->cm[0] ; 
  *av[1]=*av[1]/v->nu-v->cm[1] ; 
  *av[2]=*av[2]/v->nu-v->cm[2] ; 

  /* Initialize the appropriate correlation Q matrix */
  for(k=0;k<3;k++) 
    for(l=0;l<3;l++) (*m)[k][l]=0.0 ;
    
  for(ii=0;ii<v->n;ii++)
    { if ((jj=v->corr[ii])<0) continue ;
      iv[0]=p[ii][0] - v->cm[0] ; 
      iv[1]=p[ii][1] - v->cm[1] ; 
      iv[2]=p[ii][2] - v->cm[2] ; ;
    
      jv[0]=q[jj][0] - w->cm[0] ; 
      jv[1]=q[jj][1] - w->cm[1] ; 
      jv[2]=q[jj][2] - w->cm[2] ; 
          
      for(k=0;k<3;k++)
        for(l=0;l<3;l++)
          (*m)[k][l]+=iv[k]*jv[l] ;
    }

  for(k=0;k<3;k++) 
    for(l=0;l<3;l++) 
      (*m)[k][l]/=v->nu ;
    
    
  #if DEBUG
  printf("Average is (%.3f,%.3f,%.3f), Q=\n",*av[0],*av[1],*av[2]) ;
  for(k=0;k<3;k++) 
    { for(l=0;l<3;l++) printf("%9.3f ",(*m)[k][l]) ;
      putchar('\n') ;
    }  
  #endif    
}       


void VectorProd(VectorT c,VectorT a,VectorT b)
/* calculates vector product c=a x b */
{ c[0]=a[1]*b[2]-a[2]*b[1] ;
  c[1]=a[2]*b[0]-a[0]*b[2] ;
  c[2]=a[0]*b[1]-a[1]*b[0] ;
}  

void MatrixTimesVector(VectorT b,MatrixT m,VectorT a)
/* calculates b= m a, where m is 3x3 matrix */
{ int k ;
  for(k=0;k<3;k++)
   b[k]=m[k][0]*a[0]+m[k][1]*a[1]+m[k][2]*a[2] ;
}

void VectorAdd(VectorT c,VectorT a,VectorT b)
{ int k ;
  for(k=0;k<3;k++) c[k]=a[k]+b[k] ;
}  

void VectorSub(VectorT c,VectorT a,VectorT b)
{ int k ;
  for(k=0;k<3;k++) c[k]=a[k]-b[k] ;
}  

DoubleT EvQForm(VectorT l,MatrixT Q,VectorT r)
/* evaluate l*Q*r */
{ VectorT c ;
  MatrixTimesVector(c,Q,r) ;
  return l[0]*c[0]+l[1]*c[1]+l[2]*c[2] ;
}  

void ComputeForces(int i,int j)
/* compute force and torque induced on view i by view j */
{ ViewT *v,*w ; int k ;
  VectorT a,b,c ; MatrixT inv ;

  v=&view[i] ; w=&view[j] ;
 
  VectorAdd(a,v->avg[j],v->cm) ;
  MatrixTimesVector(b,v->R,a) ;
  VectorAdd(c,b,v->T) ;
  VectorAdd(a,w->avg[i],w->cm) ;
  MatrixTimesVector(b,w->R,a) ;
  VectorAdd(a,b,w->T) ;
  VectorSub(b,c,a) ;
  MatrixInv(inv,v->R) ;
  MatrixTimesVector(a,inv,b) ;
   
  for(k=0;k<3;k++) v->F[k]+=(-2) * a[k] ;

  MatrixTimesVector(a,v->R,v->cm) ;
  VectorAdd(a,a,v->T) ;
  MatrixTimesVector(b,w->R,w->cm) ;
  VectorAdd(b,b,w->T) ;
  VectorSub(a,a,b) ;
  MatrixTimesVector(b,v->R,v->avg[j]) ;
  VectorProd(c,b,a) ;
  
  b[0]=EvQForm(v->R[1],v->Q[j],w->R[2]) - EvQForm(v->R[2],v->Q[j],w->R[1]) ;
  b[1]=EvQForm(v->R[2],v->Q[j],w->R[0]) - EvQForm(v->R[0],v->Q[j],w->R[2]) ;
  b[2]=EvQForm(v->R[0],v->Q[j],w->R[1]) - EvQForm(v->R[1],v->Q[j],w->R[0]) ;
        
  for(k=0;k<3;k++) v->tor[k]+=(-2) * c[k] + 2 * b[k] ;      
}     

void MatrixInv(MatrixT a,MatrixT b)
{ DoubleT det ; int i,j ;
 det=b[0][0]*b[1][1]*b[2][2]+b[1][0]*b[2][1]*b[0][2]
    +b[0][1]*b[1][2]*b[2][0]-b[0][2]*b[1][1]*b[2][0]
    -b[0][0]*b[1][2]*b[2][1]-b[2][2]*b[0][1]*b[1][0] ;
 
 for(i=0;i<3;i++)
   for(j=0;j<3;j++) a[i][j]=( (i+j)%2 ? -1 : 1 )/det ;
 a[0][0]*=(b[1][1]*b[2][2]-b[1][2]*b[2][1]) ;
 a[1][0]*=(b[1][0]*b[2][2]-b[1][2]*b[2][0]) ;
 a[2][0]*=(b[1][0]*b[2][1]-b[1][1]*b[2][0]) ;
 a[0][1]*=(b[0][1]*b[2][2]-b[0][2]*b[2][1]) ;
 a[1][1]*=(b[0][0]*b[2][2]-b[0][2]*b[2][0]) ;
 a[2][1]*=(b[0][0]*b[2][1]-b[0][1]*b[2][0]) ;
 a[0][2]*=(b[0][1]*b[1][2]-b[0][2]*b[1][1]) ;
 a[1][2]*=(b[0][0]*b[1][2]-b[0][2]*b[1][0]) ;
 a[2][2]*=(b[0][0]*b[1][1]-b[0][1]*b[1][0]) ;
 
} 
 
   

void MatrixTimesMatrix(MatrixT c,MatrixT a,MatrixT b)
/* multiplies c = a b */
{ int i,j,k ;
  
  for(i=0;i<3;i++)
   for(j=0;j<3;j++)
    { c[i][j]=0.0 ;
      for(k=0;k<3;k++) c[i][j]+=a[i][k]*b[k][j] ;
    }
}


    
  
void Display() /* display the resulting transformation */
{ int i ;
  ViewT *v ; 
  DoubleT q[4] ;
  
  for(i=0;i<nviews;i++)
   { v=&(view[i]) ;
     MatrixToQuatern(v->R,q) ;    

     if (flag_scrout)
     printf("View %d transformed by "
      "(%6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f)\n",
        i,q[0],q[1],q[2],q[3],v->T[0],v->T[1],v->T[2]) ;

#if 0
     fprintf(matf,"%.3f %.3f %.3f %.3f %.3f %.3f %.3f ",
        q[0],q[1],q[2],q[3],v->T[0],v->T[1],v->T[2]) ;
#endif 
#if MATLABOUT
     fprintf(matf,"%g %g %g %g %g %g %g ",
        q[0],q[1],q[2],q[3],v->T[0],v->T[1],v->T[2]) ;
#endif 

   }
#if MATLABOUT
   fprintf(matf,"%f\n",sumsqd/numsqd) ;
#endif      
}    

void MatrixToQuatern(MatrixT R,DoubleT q[4])
{ DoubleT x[2][3]={{1,0,0},{0,1,0}} ;
  DoubleT y[2][3],d,ds,dmax,u,v,angle ;
  VectorT crp,perp ;
  int i,j ;
  
  MatrixTimesVector(y[0],R,x[0]) ;
  MatrixTimesVector(y[1],R,x[1]) ;
  
  j=0 ; dmax=0 ;
  for(i=0;i<2;i++)
   { d=(x[i][0]-y[i][0])*(x[i][0]-y[i][0])+
       (x[i][1]-y[i][1])*(x[i][1]-y[i][1])+
       (x[i][2]-y[i][2])*(x[i][2]-y[i][2]) ;
     if (d>dmax) { dmax=d ; j=i ; }
   }
   
   VectorProd(crp,x[j],y[j]) ;
   d=crp[0]*crp[0]+crp[1]*crp[1]+crp[2]*crp[2] ; ds=sqrt(d) ;   
   
   if (d>1e-50)
     { q[1]=crp[0]/ds ; q[2]=crp[1]/ds ; q[3]=crp[2]/ds ; }
      
   VectorProd(perp,q+1,x[j]) ;
   u=perp[0]*y[j][0]+perp[1]*y[j][1]+perp[2]*y[j][2] ;
   v=x[j][0]*y[j][0]+x[j][1]*y[j][1]+x[j][2]*y[j][2] ;
   angle=atan2(u,v) ;
   q[0]=cos(angle/2) ;
   q[1]*=sin(angle/2) ; q[2]*=sin(angle/2) ;  q[3]*=sin(angle/2) ;
   
}
   
      
