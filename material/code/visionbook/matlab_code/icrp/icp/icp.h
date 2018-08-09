/***************************************************************
 *
 *		Iterative Closest (Reciprocal) Point Algoritmus
 *
 *		Shared declarations and definitions
 *
 *		Header file: 	icp.h
 *
 *		Author:			Pavel Kucera
 *
 *		Language:		C
 *
 *		09/11/96
 *
 ***************************************************************/

#ifndef _ICP_
#define _ICP_

#include <stdio.h>

#define N_INIT 40               /*number of initial rotation states*/
#define INIT_ITER_DEPTH 5       /*depth of initial iterations*/

#ifndef CLK_TCK			    /* this is Linux specific */
 #ifdef CLOCKS_PER_SECOND           /* this should be in ANSI C */
  #define CLK_TCK CLOCKS_PER_SECOND
 #else				    /* if neither is defined, we have to guess */	
  #define CLK_TCK (1000000.0)       /* on Sun OS, the clock is in us */
 #endif  
#endif

typedef double DoubleT;

typedef struct reg_results      /*results of registration*/
{
 DoubleT dms;            		/*mean square point matching error*/
 DoubleT q[7];           		/*registration state vector*/
 long nUsedPoints;				/*number of actualy used points*/
 int n;                 		/*number of iterations*/
} RegResultsT;

typedef struct reg_parameters   /*parameters of registration*/
{
 DoubleT thr;                    /*threshold*/
 int global;                    /*global matching (1 yes, 0 no)*/
 int iidepth;                   /*depth of initial iterations - global matching*/
 DoubleT qinit[N_INIT][4];       /*initial registration states (rotation vectors) - global matching*/
 int fastercp;                	/*use faster closest points finding (1 yes, 0 no)*/
 DoubleT searchedpart;          /*how large part of model shape will be searched*/
 int eliminate;					/*eliminate not corresponding points*/
 int center;					/**/
 int correspinfo;              	/**/
 DoubleT elimit;
} RegParametersT;




typedef DoubleT (*PointsT)[3];	/*array of 3-D points*/

typedef long (*TrianglesT)[3];	/*array of triangels*/

typedef long **SurroundT; 		/*array of indexes of surrounding points for each shape point*/

typedef struct point_set      	/*set of points*/
{
 long n;                         /*number of points*/
 PointsT ps;                    /*pointer to array of points*/
} PointSetT;

typedef struct triangle_set     /*set of triangles*/
{
 long n;                         /*number of triangles*/
 TrianglesT ts;         		/*pointer to array of triangls*/
} TriangSetT;

typedef enum					/*type of representation*/
{
 PSET,TSET
} RepresentationT;

typedef struct shape
{
 RepresentationT repr;
 PointSetT *pset;
 TriangSetT *tset;
} ShapeT;

void eigens(double A[],double RR[],double E[],int N) ;

void IcpMemError(void);

void IcpNormalizeVector(DoubleT q[],int n);

void IcpPrintPointArray(long n,PointsT pnt);

void IcpGenInitStates(DoubleT qinit[][4]);

void IcpCompRotMatrix(DoubleT q[],DoubleT rotM[][3]);

void IcpApplyRegistration(DoubleT q[],DoubleT rotMx[][3],PointSetT *pset,PointsT rPnts);

void IcpReadParamFile(char paramFileName[],char dataFileName[],long *ndat1,long *ndat2,RepresentationT *drep,char modelFileName[],long *nmod1,long *nmod2,RepresentationT *mrep,DoubleT *q,RegParametersT *param);

void IcpReadTsetFiles(char fileName[],long tnum,long pnum,ShapeT *shp);

void IcpReadPsetFile(char fileName[],long num,ShapeT *shp);

void IcpWritePsetFile(char fileName[],long np,PointsT ps);

void IcpTransformPset(PointSetT *psetin,PointSetT *psetout,DoubleT q[]);

DoubleT IcpTriangClosestPoint(DoubleT point[],long tr[],PointsT modPnt,DoubleT rPoint[]);

DoubleT IcpNoEdgeTriangClosestPoint(DoubleT point[],long tr[],PointsT modPnt,DoubleT rPoint[]);

long IcpPsetClosestPoint(DoubleT pnt1[],ShapeT *shp,DoubleT rPoint[]);

long IcpTsetClosestPoint(DoubleT point[],ShapeT *shp,DoubleT rPoint[]);

long IcpGradTsetClosestPoint(DoubleT point[],ShapeT *shp,DoubleT yps[],SurroundT surr,long couple);

long IcpPartTsetClosestPoint(DoubleT point[],ShapeT *shp,DoubleT yps[],SurroundT surr,long couple,DoubleT part);

DoubleT IcpPsetSize(PointSetT *pset);

void IcpCompRegistration(PointSetT *pset,PointsT y,PointsT pk,RegResultsT *res,int elim[],long nact);

void IcpLocalReg(ShapeT *datashp,ShapeT *modelshp,PointsT pk,RegParametersT *par,RegResultsT *res,SurroundT surrm,SurroundT surrd,long couples[],PointsT y,int elim[],FILE *fwreg,FILE *fwdms);

void IcpTsetNeighbours(ShapeT *shp,SurroundT surr);

void IcpCenterPointArrays(long nd,PointsT dpnt,long nm,PointsT mpnt);

void IcpRegister(ShapeT *datashp,ShapeT *modelshp, RegParametersT *par, DoubleT *qInitial, RegResultsT *res,int ident);
#endif /* ICP */

#include "clrange.h"
