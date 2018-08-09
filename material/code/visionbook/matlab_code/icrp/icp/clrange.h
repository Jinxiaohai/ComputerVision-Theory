/***************************************************************
 *
 *		Range find based closest point finding
 *
 *		Shared declarations and definitions
 *
 *		Header file: 	clrange.h
 *
 *		Author:			Jan Kybic
 *
 *		Language:		C
 *
 *		25/11/96
 *
 ***************************************************************/

#ifndef _CLRANGE_H

#define _CLRANGE_H

typedef struct nodestruct  { struct nodestruct *left,*right ;
                     DoubleT p[3],min,max ;
                     int l ;
                     int ind ;
                   } NodeT ;  

/* one item of a queue */
typedef struct queuestruct { NodeT *node ; DoubleT dist ; } QueueT ;

typedef struct treestruct { NodeT *root ;
			    QueueT *queue ;
			  } TreeT ;

			  
extern int IcpRangeSearchFlag ;  
 /* use fast, range based closest. pt. searching (1 yes, 0 no) */
 
long IcpPsetRangeClosestPoint(DoubleT pnt1[],ShapeT *shp,DoubleT rPoint[],TreeT *tree) ;

/* Prepare resp. close the internal representation of the point set
   to speed up consecutive searches */
    
TreeT *IcpRangeSearchInit(ShapeT *shp) ;

void IcpRangeSearchClose(TreeT *t) ;

#endif
