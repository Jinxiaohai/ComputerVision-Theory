/***************************************************************
 *
 *		Range find based closest point finding
 *
 *		Code
 *
 *		Author:			Jan Kybic
 *
 *		Language:		C
 *
 *		25/11/96
 *
 ***************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <math.h> 
#include <string.h>
 
#define TIMING

#ifdef TIMING
#include <time.h>
#endif

#include "icp.h"


int IcpRangeSearchFlag=0 ;  
 /* use fast, range based cl. pt. searching (1 yes, 0 no) */


static NodeT *treeptr ;
static PointsT arrbeg ;

static int qcompare0(void *a,void *b)
{
 DoubleT ax,bx ;
 ax=(**(PointsT *)a)[0] ;  bx=(**(PointsT *)b)[0] ; 
 
 if (ax>bx) return 1 ;
 if (ax<bx) return -1 ;
 return 0 ;
} 

static int qcompare1(void *a,void *b)
{
 DoubleT ax,bx ;
 ax=(**(PointsT *)a)[1] ;  bx=(**(PointsT *)b)[1] ; 
 
 if (ax>bx) return 1 ;
 if (ax<bx) return -1 ;
 return 0 ;
} 

static int qcompare2(void *a,void *b)
{
 DoubleT ax,bx ;
 ax=(**(PointsT *)a)[2] ;  bx=(**(PointsT *)b)[2] ; 
 
 if (ax>bx) return 1 ;
 if (ax<bx) return -1 ;
 return 0 ;
} 

typedef int (*comparT)() ;
static comparT qcomparr[]={qcompare0,qcompare1,qcompare2} ;

/* makes one node */
static NodeT *makenode(PointsT *buf,int len,int level)
{
 PointsT *aveptr,*p; DoubleT *ave ; NodeT *root ;
 int nextlevel ; DoubleT max[3],min[3] ;

#if 0
 printf("makenode called: buf=%p len=%d level=%d\n",buf,len,level) ;
#endif 
 if (len<=0) return NULL ;
 if (len<=1) 
   { treeptr->p[0]=(**buf)[0] ;
     treeptr->p[1]=(**buf)[1] ;
     treeptr->p[2]=(**buf)[2] ;
     treeptr->left=treeptr->right=NULL ;
     treeptr->l=level ;
     treeptr->ind=(*buf-arrbeg) ;
     return treeptr++ ;
   }       
 
 
 /* select level as a coordinate with the maximum difference */
 max[0]=min[0]=(**buf)[0] ;  
 max[1]=min[1]=(**buf)[1] ;  
 max[2]=min[2]=(**buf)[2] ;  

 for(p=buf;p<buf+len;p++)
  { if ((**p)[0]>max[0]) max[0]=(**p)[0] ;
    if ((**p)[1]>max[1]) max[1]=(**p)[1] ;
    if ((**p)[2]>max[2]) max[2]=(**p)[2] ;
    if ((**p)[0]<min[0]) min[0]=(**p)[0] ;
    if ((**p)[1]<min[1]) min[1]=(**p)[1] ;
    if ((**p)[2]<min[2]) min[2]=(**p)[2] ;
  }
 max[0]-=min[0] ; max[1]-=min[1] ; max[2]-=min[2] ;   

#if 1
 if (max[0]>max[1])
   if (max[0]>max[2]) level=0 ; else level=2 ;
  else
   if (max[1]>max[2]) level=1 ; else level=2 ; 
#endif
   
 /* find the median in a given coordinate */  
 qsort(buf,len,sizeof(PointsT),qcomparr[level]) ;
 aveptr=buf+len/2 ; treeptr->ind=*aveptr-arrbeg ;
 ave=**aveptr ; 
 
 treeptr->p[0]=ave[0] ; treeptr->p[1]=ave[1] ; treeptr->p[2]=ave[2] ;
 treeptr->min=(**buf)[level] ; treeptr->max=(**(buf+len-1))[level] ;

 root=treeptr++ ; nextlevel=(level+1)%3 ;

 root->l=level ; 
 root->left=makenode(buf,aveptr-buf,nextlevel) ;
 root->right=makenode(aveptr+1,len-(aveptr-buf)-1,nextlevel) ; 
 
 return root ;
} 

static int nrange ; static float nvis,nq ; 


/* in this function we prepare the search tree */
TreeT *IcpRangeSearchInit(ShapeT *shp) 
{ 
 NodeT *root ; QueueT *queue ; TreeT *tree ; PointsT *buf ;
 int n,i ;

 n=shp->pset->n ; arrbeg=shp->pset->ps ;
 
 if ((tree=malloc(sizeof(TreeT)))==NULL) IcpMemError() ;
 
 if ((buf=malloc(n*sizeof(PointsT)))==NULL) IcpMemError() ;
 
 if ((root=(NodeT *)malloc(n*sizeof(NodeT)))==NULL)  IcpMemError() ;

 if ((queue=(QueueT *)malloc(n*sizeof(QueueT)))==NULL) IcpMemError() ;

 tree->root=root ; tree->queue=queue ;

 /* inicialni stav bufferu */
 for (i=0;i<n;i++) *(buf+i)=shp->pset->ps+i ;  
 
 treeptr=root ;
 makenode(buf,n,0) ;

 free(buf) ;

 nrange=0 ; nvis=0.0 ; nq=0.0 ;
 return(tree) ; 
}

void IcpRangeSearchClose(TreeT *t) 
{ 

  printf("Range called: %d times, avnodvis=%.1f avinq=%.1f\n",
    nrange,nvis/nrange,nq/nrange) ;
  free(t->root) ;  /* free the tree itself */
  free(t->queue) ; /* free the queue */
  free(t) ;
}



long IcpPsetRangeClosestPoint(DoubleT pnt1[],ShapeT *shp,
        DoubleT rPoint[],TreeT *tree) 
/************************************************************************
 * Computes the closest point on a point set shape shp to a given point	*
 * Uses a fast, range search based algorithm.
 * pnt1		- given point												*
 * shp		- given shape												*
 * rPoint	- resulting point											*
 ************************************************************************/
{
 int level,n ;
 PointsT ps ;
 /* due to a bug in a gcc compiler, we must define the following
    variables as volatile otherwise the program segfaults when compiled
    with -O2 */
 volatile DoubleT dr,dl ;
 DoubleT df,pnl,dmin,dif ;       
        
 QueueT *queue,*head,*tail,*ptr,*ptr2 ; NodeT *act ; /* the queue */
 NodeT *minn ;

#define DIST(x) (((x)->p[0]-pnt1[0]) * ((x)->p[0]-pnt1[0]) +\
      ((x)->p[1]-pnt1[1]) * ((x)->p[1]-pnt1[1]) +\
      ((x)->p[2]-pnt1[2]) * ((x)->p[2]-pnt1[2])) 

 int nexam=0,ninq=0 ;
  
  
 n=(shp->pset)->n ; ps=(shp->pset)->ps;

 head=queue=tail=tree->queue ;
 
 minn=tree->root ;
 head->dist=dmin=DIST(minn) ;
 (head++)->node=minn ;                        
                        
 while(head>tail)
  { /* Take one item from the queue */
    nexam++ ; ninq+=head-tail ;
    
    act=(tail++)->node ; 
    /* Compute its distance and update the minimum distance if necessary */

    level=act->l ;
    /* If applicable, insert left/right son into a queue */
    dif=(pnl=pnt1[level]) - act->p[level] ;
    if (act->left) 
      { dl=DIST(act->left) ;
        if (dl<dmin) { dmin=dl ; minn=act->left ; }
      }  
    if (act->right) 
      { dr=DIST(act->right) ;
        if (dr<dmin) { dmin=dr ; minn=act->right ; }
      }
    if (act->left)  
      if ((dif<0 && ((df=act->min-pnl)<0 || df*df<dmin)) || dmin>dif*dif) 
        { head->dist=dl ; 
	  for(ptr=tail;ptr->dist<dl;ptr++) ; 
	  for(ptr2=head-1;ptr2>=ptr;ptr2--)
	    { (ptr2+1)->dist=ptr2->dist ; (ptr2+1)->node=ptr2->node ; }
	  head++ ; 
	  ptr->node=act->left ; ptr->dist=dl ; 
        }  
    if (act->right) 
      if ((dif>0 && ((df=pnl-act->max)<0 || df*df<dmin)) || dmin>dif*dif) 
        { head->dist=dr ;
	  for(ptr=tail;ptr->dist<dr;ptr++) ; 
	  for(ptr2=head-1;ptr2>=ptr;ptr2--)
	    { (ptr2+1)->dist=ptr2->dist ; (ptr2+1)->node=ptr2->node ; }
	  head++ ; 
	  ptr->node=act->right ; ptr->dist=dr ; 
        }  
  } /* while */
  
 rPoint[0]=minn->p[0] ;  rPoint[1]=minn->p[1] ;  rPoint[2]=minn->p[2] ; 

#if 0
 printf("%d nodes examined, %f avg in queue\n",nexam,((float)ninq)/nexam) ;
#endif 
 nrange++ ; nvis+=nexam ; nq+=((float)ninq)/nexam ;

 return minn->ind ;
}
