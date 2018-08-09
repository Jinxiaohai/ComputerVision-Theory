/* Multiple point sets registration algorithm */
/* based on article of A.J.Stoddard, A.Hilton in Proceedings of ICRP'96 */
/* and an ICP implementation by P. Kucera, FEL CVUT, Prague */

/* Implemented by Jan Kybic (xkybic@sun.felk.cvut.cz) */

#ifndef _MREG_H
#define _MREG_H

#include "icp.h"
#include "clrange.h"

typedef DoubleT VectorT[3] ;
typedef DoubleT MatrixT[3][3] ;
typedef unsigned char BoolT ;

#define FILENAMELEN 200
#define MAXNVIEWS 100 /* maximum number of views */

#define NOLDS 3       /* number of old views to be saved */

typedef struct viewstruct  
{ char filename[FILENAMELEN] ;
  
  ShapeT shp ;
  PointsT tp ; /* transformed points */
  int n,nu ;     /* total number of points, number of points used */
  int *corr ; /* corr[i] contains the partner's number or -1 */
  
  MatrixT R,Rold[NOLDS], Q[MAXNVIEWS] ; /* matrix of rotation and correlation */
  VectorT T,Told[NOLDS],avg[MAXNVIEWS],cm,F,tor ; 
    /* translation, average, center of mass, mforce, torque */
  DoubleT itransf[7] ; /* initial transform */
  DoubleT rms ; /* root mean square distance from CM */
} ViewT ;


extern int nviews ;
extern DoubleT elimdist ;
extern BoolT eliminate ;
extern DoubleT g,G ;  /* linear and rotational drag */

void InitViews() ;
void ReadView(ViewT *v) ;
void SetupView(ViewT *v) ;
void CloseViews() ;
void Compute() ;
void Register(ViewT *v,ViewT *w) ;
void Eliminate(ViewT *v,ViewT *w) ;
void ComputeAQ(int  i,int j) ;
void ComputeForces(int i,int j) ;
void VectorProd(VectorT c,VectorT a,VectorT b) ;
void MatrixTimesVector(VectorT b,MatrixT m,VectorT a) ;
void VectorAdd(VectorT c,VectorT a,VectorT b) ;
void VectorSub(VectorT c,VectorT a,VectorT b) ;
DoubleT EvQForm(VectorT l,MatrixT Q,VectorT r) ;
void MatrixTimesMatrix(MatrixT c,MatrixT a,MatrixT b) ;
void Display() ;
void SaveAllTransforms(int i) ;
void RestoreAllTransforms(int i) ;
DoubleT MaxDiff(int i) ;
void MatrixInv(MatrixT a,MatrixT b) ;
void MatrixToQuatern(MatrixT R,DoubleT q[4]) ;



#define ABS(x) ((x)>0 ? (x) : -(x))

#define SGN(x) ((x)>0 ? 1 : -1 )

#endif
