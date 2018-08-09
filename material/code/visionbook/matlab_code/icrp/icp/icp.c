/***************************************************************
 *
 *		Iterative Closest (Reciprocal) Point Algoritmus
 *
 *		Basic functions
 *
 *		C file: 	icp.c
 *
 *		Author:		Pavel Kucera
 *
 *		Language:	C
 *
 *		09/11/96
 *
 ***************************************************************/

#define TIMING
#undef MATRIXL
#undef PSETLIST
#undef DMSLIST
#define ICPOUT
#undef VECTOR

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <string.h>
#ifdef TIMING
#include <time.h>
#endif


#include "icp.h"

void IcpMemError(void)
/********************************************************************
 * Message in case of low memory									*
 ********************************************************************/
{
	printf("Memory allocation failed! \n");
	exit(1);
}

void IcpPrintPointArray(long n,PointsT pnt)
/********************************************************************
 * Prints n points of array											*
 * n 	- number of points to print									*
 * pnt	- array of points											*
 ********************************************************************/
{
	long i;
	int j;

	for (i=0;i<n;i++)
	{
		for (j=0;j<3;j++) printf("%f ",pnt[i][j]);
		printf("\n");
	}
}

void IcpCompRotMatrix(DoubleT q[],DoubleT rotM[][3])
/********************************************************************
 * Computes rotation matrix											*
 * q[0..3]	- unit quaternion (rotation vector)						*
 * rotM		- rotation matrix (3x3)									*
 ********************************************************************/
{	rotM[0][0]=q[0]*q[0]+q[1]*q[1]-q[2]*q[2]-q[3]*q[3];
	rotM[0][1]=2*(q[1]*q[2]-q[0]*q[3]);
	rotM[0][2]=2*(q[1]*q[3]+q[0]*q[2]);
	rotM[1][0]=2*(q[1]*q[2]+q[0]*q[3]);
	rotM[1][1]=q[0]*q[0]+q[2]*q[2]-q[1]*q[1]-q[3]*q[3];
	rotM[1][2]=2*(q[2]*q[3]-q[0]*q[1]);
	rotM[2][0]=2*(q[1]*q[3]-q[0]*q[2]);
	rotM[2][1]=2*(q[2]*q[3]+q[0]*q[1]);
	rotM[2][2]=q[0]*q[0]+q[3]*q[3]-q[1]*q[1]-q[2]*q[2];
}


void IcpApplyRegistration(DoubleT t[],DoubleT rotMx[][3],PointSetT *pset,PointsT rPnts)
/************************************************************************
 * Applies registration on point set									*
 * t[]          translation vector (3 vector)							*
 * rotMx        rotation matrix											*
 * pset         point set registration is applyed on					*
 * resPnts      resulting points										*
 ************************************************************************/
{
	long i;
	int j;

	for (i=0;i<pset->n;i++)
		for (j=0;j<3;j++)	rPnts[i][j]=(rotMx[j][0]*pset->ps[i][0])+(rotMx[j][1]*pset->ps[i][1])+(rotMx[j][2]*pset->ps[i][2])+t[j];
}


void IcpTransformPset(PointSetT *psetin,PointSetT *psetout,DoubleT q[])
/********************************************************************
 * Transforms given point set by transformation vector q.			*
 * psetin	- given point set										*
 * psetout	- resulting point set									*
 * q		- transformation vector (0-3 rotation, 4-6 translation)	*
 ********************************************************************/
{
	DoubleT rotM[3][3];
	PointsT pnt;
	long i;
	int j;

	if ((pnt=(PointsT) malloc((psetin->n)*3*sizeof(DoubleT)))==NULL) IcpMemError();
	IcpCompRotMatrix(q,rotM);
	IcpApplyRegistration(q+4,rotM,psetin,pnt);
	for (i=0;i<psetin->n;i++) for (j=0;j<3;j++) psetout->ps[i][j]=pnt[i][j];
	free(pnt);
}


void IcpReadParamFile(char paramFileName[],char dataFileName[],long *ndat1,long *ndat2,RepresentationT *drep,char modelFileName[],long *nmod1,long *nmod2,RepresentationT *mrep,DoubleT *q,RegParametersT *param)
/****************************************************************************
 * Reads file with registration parameters									*
 * paramFileName- name of parameters file to be read						*
 * dataFileName	- name of file(s) containing data shape						*
 * ndat1,ndat2  - numbers of data elements (0,points or triangles,vertices) *
 * drep         - representation type of data shape                         *
 * modelFileName- name of file(s) containing model shape					*
 * nmod1,nmod2	- numbers of model elements (0,points or triangles,vertices)*
 * mrep         - representation type of model shape	
 * q            - initial transformation 					*
 * param	- registration parameters structure							*
 ****************************************************************************/
{
	FILE *fr;
	char s[90];
	int j;

	if ((fr=fopen(paramFileName,"r"))==NULL)
	{
		printf("Unable to open the file '%s'! \n",paramFileName);
		exit(1);
	}
	while (fscanf(fr,"%s",s) != EOF)
	{
		if (s[0]=='#')
		{
			fgets(s,90,fr);
			continue;
		}
		if (strcmp(s,"datafilename")==0)
		{
			fscanf(fr,"%s",s);
			strcpy(dataFileName,s);
			continue;
		} else
		if (strcmp(s,"inittrans")==0)
		{
		      fscanf(fr,"%lf %lf %lf %lf %lf %lf %lf",&q[0],&q[1],&q[2],&q[3],&q[4],&q[5],&q[6]);
		       continue;
		} else
                if (strcmp(s,"rangesearch")==0)
		{
			fscanf(fr,"%d",&IcpRangeSearchFlag);
			continue;
		}

		else
			if (strcmp(s,"threshold")==0)
			{
				fscanf(fr,"%lf",&(param->thr));
				continue;
			}
			else
				if (strcmp(s,"global")==0)
				{
					fscanf(fr,"%d",&(param->global));
					continue;
				}
				else
					if (strcmp(s,"iidepth")==0)
					{
						fscanf(fr,"%d",&(param->iidepth));
						continue;
					}
					else
						if (strcmp(s,"fastercp")==0)
						{
							fscanf(fr,"%d",&(param->fastercp));
							continue;
						}
						else
							if (strcmp(s,"correspinfo")==0)
							{
								fscanf(fr,"%d",&(param->correspinfo));
								continue;
							}
							else
								if (strcmp(s,"searchedpart")==0)
								{
									fscanf(fr,"%lf",&(param->searchedpart));
									continue;
								}
								else
									if (strcmp(s,"modelfilename")==0)
									{
										fscanf(fr,"%s",s);
										strcpy(modelFileName,s);
										continue;
									}
									else
										if (strcmp(s,"modelelements")==0)
										{
											fscanf(fr,"%ld %ld",nmod1,nmod2);
											continue;
										}
										else
											if (strcmp(s,"dataelements")==0)
											{
												fscanf(fr,"%ld %ld",ndat1,ndat2);
												continue;
											}
											else
												if (strcmp(s,"centering")==0)
												{
													fscanf(fr,"%d",&(param->center));
													continue;
												}
												else
													if (strcmp(s,"eliminate")==0)
													{
														fscanf(fr,"%d",&(param->eliminate));
														continue;
													}
													else
														if (strcmp(s,"datarepr")==0)
														{
															fscanf(fr,"%s",s);
															if (strcmp(s,"TSET")==0) *drep=TSET;
															else
																if (strcmp(s,"PSET")==0) *drep=PSET;
															continue;
														}
														else
															if (strcmp(s,"modelrepr")==0)
															{
																fscanf(fr,"%s",s);
																if (strcmp(s,"TSET")==0) *mrep=TSET;
																else
																	if (strcmp(s,"PSET")==0) *mrep=PSET;
															}
															else
																if (strcmp(s,"elimit")==0)
																{
																	fscanf(fr,"%lf",&(param->elimit));
																	continue;
																}
	}
	fclose(fr);
}

void IcpReadTsetFiles(char fileName[],long tnum,long pnum,ShapeT *shp)
/****************************************************************************
 * Reads file with triangle set and fills structure shp with its contents.	*
 * fileName	- name of files containing triangle set shape 					*
 * 			  (without extensions .vtx and .tri)							*
 * tnum		- number of triangles											*
 * pnum		- number of vertices											*
 * shp		- shape structure												*
 ****************************************************************************/
{
	long i;
	int j;
	DoubleT h;
	FILE *fr;
	char fName[256];
	TriangSetT *tset;
	PointSetT *pset;
	TrianglesT trng;
	PointsT pnt;

	if ((tset=(TriangSetT *) malloc(sizeof(TriangSetT)))==NULL) IcpMemError();
	if ((pset=(PointSetT *) malloc(sizeof(PointSetT)))==NULL) IcpMemError();
	pset->n=pnum;
	if ((pnt=(PointsT) malloc(pnum*3*sizeof(DoubleT)))==NULL) IcpMemError();
	pset->ps=pnt;
	strcpy(fName,fileName);
	strcat(fileName,".vtx");
	if ((fr=fopen(fileName,"r"))==NULL)
	{
		printf("Unable to open the file '%s'! \n",fileName);
		exit(1);
	}
	for (i=0;i<pnum;i++) for (j=0;j<3;j++) fscanf(fr,"%lf ",*(pnt+i)+j);
	tset->n=tnum;
	strcat(fName,".tri");
	if ((fr=fopen(fName,"r"))==NULL)
	{
		printf("Unable to open the file '%s'! \n",fName);
		exit(1);
	}
	if ((trng=(TrianglesT) malloc(tnum*3*sizeof(long)))==NULL) IcpMemError();
	tset->ts=trng;
	for (i=0;i<tnum;i++)
	{
		for (j=0;j<3;j++)
		{
			fscanf(fr,"%lf ",&h);
			trng[i][j]=(long) h;
		}
	}
	shp->repr=TSET;
	shp->tset=tset;
	shp->pset=pset;
	fclose(fr);
}


void IcpReadPsetFile(char fileName[],long num,ShapeT *shp)
/************************************************************************
 * Reads file with point set and fills structure shp with its contents	*
 * fileName	- name of file containing point set shape					*
 * 			  (without extension .vtx)									*
 * num		- number of points											*
 * shp		- shape structure											*
 ************************************************************************/
{
	long i;
	int j;
	FILE *fr;
	PointSetT *pset;
	PointsT pnt;

	if ((pset=(PointSetT *) malloc(sizeof(PointSetT)))==NULL) IcpMemError();
	strcat(fileName,".vtx");
	if ((fr=fopen(fileName,"r"))==NULL)
	{
		printf("Unable to open the file '%s'! \n",fileName);
		exit(1);
	}
	pset->n=num;
	if ((pnt=(PointsT) malloc(num*3*sizeof(DoubleT)))==NULL) IcpMemError();
	pset->ps=pnt;
	for (i=0;i<num;i++)	for (j=0;j<3;j++) fscanf(fr,"%lf ",*(pnt+i)+j);
	shp->repr=PSET;
	shp->pset=pset;
	fclose(fr);
}

void IcpWritePsetFile(char fileName[],long np,PointsT ps)
/****************************************************************
 * Writes ascii file with points' coordinates					*
 * fileName	- name of resulting file							*
 * np		- number of points									*
 * ps		- array of points									*
 ****************************************************************/
{
	long i;
	int j;
	FILE *fw;

	if ((fw=fopen(fileName,"w"))==NULL)
	{
		printf("Unable to open the file '%s'! \n",fileName);
		exit(1);
	}
	for (i=0;i<np;i++)
	{
		for (j=0;j<3;j++) fprintf(fw,"%f ",ps[i][j]);
		fprintf(fw,"\n");
	}
	fclose(fw);
}


void IcpNormalizeVector(DoubleT q[],int n)
/************************************************************************
 * Normalizes vector q[0..n-1] so that its size can be 1.00000.			*
 * q	- given vector													*
 * n 	- size of vector q												*
 ************************************************************************/
{
	DoubleT x=0;
	int i;

	for (i=0;i<n;i++) x+=q[i]*q[i];
	x=sqrt(x);
	for (i=0;i<n;i++) q[i]=q[i]/x;
}


void IcpGenInitStates(DoubleT qinit[][4])
/************************************************************************
 * Generates 40 initial rotation states.								*
 * qinit	- list of resulting rotations								*
 ************************************************************************/
{
	DoubleT q[]={1,1,1,1};
	int i,j;

	for (i=0;i<40;i++)
	{
	for (j=0;j<4;j++) qinit[i][j]=q[j];
	q[3]--;
	if (q[3]<-1)
	{
	    q[3]=1;
	    q[2]--;
	    if (q[2]<-1)
	    {
		q[2]=1;
		q[1]--;
		if (q[1]<-1)
		{
		    q[1]=1;
		    q[0]--;
		}
	    }
	}
	IcpNormalizeVector(qinit[i],4);
	}
}


DoubleT IcpTriangClosestPoint(DoubleT point[],long tr[],PointsT modPnt,DoubleT rPoint[])
/********************************************************************
 * Computes the closest point on a given triangle to a given point.	*
 * Returns distance between them.									*
 * point        - given point (3 vector)							*
 * tr           - given triangle (3 vector of vertices' indices)	*
 * modPnt       - array of vertices of triangles					*
 * rPoint       - resulting point									*
 ********************************************************************/
{
	int i,j,maxi=0,i1,i2;
	DoubleT a=0,b=0,c=0,d=0,e=0,u,v,w,p2v[3],max=0,f=0,g=0,t;

	for (i=0;i<3;i++)
	{
		a+=(modPnt[tr[0]][i]-modPnt[tr[2]][i])*(modPnt[tr[0]][i]-modPnt[tr[2]][i]);
		b+=(modPnt[tr[0]][i]-modPnt[tr[2]][i])*(modPnt[tr[1]][i]-modPnt[tr[2]][i]);
		c+=(modPnt[tr[2]][i]-point[i])*(modPnt[tr[0]][i]-modPnt[tr[2]][i]);
		d+=(modPnt[tr[1]][i]-modPnt[tr[2]][i])*(modPnt[tr[1]][i]-modPnt[tr[2]][i]);
		e+=(modPnt[tr[2]][i]-point[i])*(modPnt[tr[1]][i]-modPnt[tr[2]][i]);
	}
	u=(b*e-c*d)/(a*d-b*b);
	v=-(e+b*u)/d;
	w=1-u-v;
	if (u<0 || u>1 || v<0 || v>1 || w<0 || w>1)
	{
		for (i=0;i<3;i++)
		{
			p2v[i]=0;
			for (j=0;j<3;j++)
				p2v[i]+=(modPnt[tr[i]][j]-point[j])*(modPnt[tr[i]][j]-point[j]);
			if (p2v[i]>max)
			{
				max=p2v[i];
				maxi=i;
			}
		}
		if (maxi==2) {i1=0;i2=1;}
		else
			if (maxi==1) {i1=0;i2=2;}
			else
				{i1=1;i2=2;}
		for (i=0;i<3;i++)
		{
			f+=(modPnt[tr[i1]][i]-point[i])*(modPnt[tr[i1]][i]-modPnt[tr[i2]][i]);
			g+=(modPnt[tr[i2]][i]-modPnt[tr[i1]][i])*(modPnt[tr[i2]][i]-modPnt[tr[i1]][i]);
		}
		t=f/g;
		if (t<0) t=0;
		else if (t>1) t=1;
		for (i=0;i<3;i++) rPoint[i]=(1-t)*modPnt[tr[i1]][i]+t*modPnt[tr[i2]][i];
	}
	else for (i=0;i<3;i++) rPoint[i]=u*modPnt[tr[0]][i]+v*modPnt[tr[1]][i]+w*modPnt[tr[2]][i];
	return((rPoint[0]-point[0])*(rPoint[0]-point[0])+(rPoint[1]-point[1])*(rPoint[1]-point[1])+(rPoint[2]-point[2])*(rPoint[2]-point[2]));
}


DoubleT IcpNoEdgeTriangClosestPoint(DoubleT point[],long tr[],PointsT modPnt,DoubleT rPoint[])
/************************************************************************
 * Computes the closest point on a given triangle to a given point.		*
 * Returns distance between them. In case that the closest point isn't	*
 * found inside of triangle returns DBL_MAX.							*
 * point        - given point (3 vector)								*
 * tr           - given triangle (3 vector of vertices' indices)		*
 * modPnt       - array of vertices of triangles						*
 * rPoint       - resulting point										*
 ************************************************************************/
{
	int i;
	DoubleT a=0,b=0,c=0,d=0,e=0,u,v,w;

	for (i=0;i<3;i++)
	{
		a+=(modPnt[tr[0]][i]-modPnt[tr[2]][i])*(modPnt[tr[0]][i]-modPnt[tr[2]][i]);
		b+=(modPnt[tr[0]][i]-modPnt[tr[2]][i])*(modPnt[tr[1]][i]-modPnt[tr[2]][i]);
		c+=(modPnt[tr[2]][i]-point[i])*(modPnt[tr[0]][i]-modPnt[tr[2]][i]);
		d+=(modPnt[tr[1]][i]-modPnt[tr[2]][i])*(modPnt[tr[1]][i]-modPnt[tr[2]][i]);
		e+=(modPnt[tr[2]][i]-point[i])*(modPnt[tr[1]][i]-modPnt[tr[2]][i]);
	}
	u=(b*e-c*d)/(a*d-b*b);
	v=-(e+b*u)/d;
	w=1-u-v;
	if (u>=0 && u<=1 && v>=0 && v<=1 && w>=0 && w<=1)
	{
		for (i=0;i<3;i++) rPoint[i]=u*modPnt[tr[0]][i]+v*modPnt[tr[1]][i]+w*modPnt[tr[2]][i];
		return((rPoint[0]-point[0])*(rPoint[0]-point[0])+(rPoint[1]-point[1])*(rPoint[1]-point[1])+(rPoint[2]-point[2])*(rPoint[2]-point[2]));
	}
	else return(DBL_MAX);
}


long IcpPsetClosestPoint(DoubleT pnt1[],ShapeT *shp,DoubleT rPoint[])
/************************************************************************
 * Computes the closest point on a point set shape shp to a given point	*
 * pnt1		- given point												*
 * shp		- given shape												*
 * rPoint	- resulting point											*
 ************************************************************************/
{
	long j,n,idxmin=0;
	PointsT ps;
	DoubleT d,dmin=DBL_MAX;

	n=(shp->pset)->n;
	ps=(shp->pset)->ps;
	
	for (j=0;j<n;j++)
	{
		d=(ps[j][0]-pnt1[0])*(ps[j][0]-pnt1[0])+(ps[j][1]-pnt1[1])*(ps[j][1]-pnt1[1])+(ps[j][2]-pnt1[2])*(ps[j][2]-pnt1[2]);
		if (d<dmin)
		{
			dmin=d;
			idxmin=j;
		}
	}
	rPoint[0]=ps[idxmin][0];rPoint[1]=ps[idxmin][1];rPoint[2]=ps[idxmin][2];
	return(idxmin);
}



long IcpTsetClosestPoint(DoubleT point[],ShapeT *shp,DoubleT yps[])
/********************************************************************
 * Finds the closest point on a triangle set shape to a given point.*
 * point	- given point											*
 * shp		- shape in triangle set form							*
 * yps		- resulting point										*
 ********************************************************************/
{
	long j,idxmin;
	DoubleT dist,dmin=DBL_MAX,p[3];
	PointsT modPnt;

	modPnt=(shp->pset)->ps;
	for (j=0;j<(shp->tset)->n;j++)
	{
		dist=IcpTriangClosestPoint(point,(shp->tset)->ts[j],modPnt,p);
		if (dist<dmin)
		{
			dmin=dist;
			idxmin=j;
			yps[0]=p[0];yps[1]=p[1];yps[2]=p[2];
		}
	}
	return(idxmin);
}


long IcpGradTsetClosestPoint(DoubleT point[],ShapeT *shp,DoubleT yps[],SurroundT surr,long couple)
/************************************************************************
 * Finds the closest point on a triangle set shape to a given point.	*
 * Starts searching on a 'couple' triangle and searches shape 			*
 * by finding minimum on surrounding triangles							*
 * point	- given point												*
 * shp		- shape in triangle set form								*
 * yps		- resulting point											*
 * surr		- list of surrounding triangles for each triangle of shape	*
 * couple	- index of starting triangle								*
 ************************************************************************/
{
	long n,idxmin,nextidxm,surrsize;
	int j,found;
	DoubleT d,dmin,p[3];
	PointsT modPnt;

	modPnt=(shp->pset)->ps;
	n=(shp->tset)->n;
	dmin=IcpTriangClosestPoint(point,(shp->tset)->ts[couple],modPnt,p);
	yps[0]=p[0];yps[1]=p[1];yps[2]=p[2];
	idxmin=couple;
	do
	{
		found=0;
		surrsize=surr[idxmin][0];
		for (j=1;j<=surrsize;j++)
		{
			d=IcpTriangClosestPoint(point,(shp->tset)->ts[surr[idxmin][j]],modPnt,p);
			if (d<dmin)
			{
				dmin=d;
				nextidxm=surr[idxmin][j];
				yps[0]=p[0];yps[1]=p[1];yps[2]=p[2];
				found=1;
			}
		}
		if (found) idxmin=nextidxm;
	}
	while (found);
	return(idxmin);
}


long IcpPartTsetClosestPoint(DoubleT point[],ShapeT *shp,DoubleT yps[],SurroundT surr,long couple,DoubleT part)
/************************************************************************
 * Finds the closest point on a triangle set to a given point.			*
 * Starts searching on a 'couple' triangle and searches shape until 	*
 * reach given part of all triangles.									*
 * point	- given point												*
 * shp		- shape in triangle set form								*
 * yps		- resulting point											*
 * surr		- list of surrounding triangles for each triangle of shape	*
 * couple	- index of starting triangle								*
 * part		- part of triangles to be searched (0.1 = 10%)				*
 ************************************************************************/
{
	long n,k,lastSelected,lastUnfolded,*selected,mini;
	int j,*info;
	PointsT modPnt;
	DoubleT d,mind,h,p[3];

	n=(shp->tset)->n;
	if ((selected=(long *) malloc(n*sizeof(long)))==NULL) IcpMemError();
	if ((info=(int *) malloc(n*sizeof(int)))==NULL) IcpMemError();
	modPnt=(shp->pset)->ps;
	for (k=0;k<n;k++) info[k]=0;
	selected[0]=couple;
	info[couple]=1;
	lastUnfolded=-1;
	lastSelected=0;
	mind=DBL_MAX;
	do
	{
		lastUnfolded++;
		k=lastSelected;
		d=IcpTriangClosestPoint(point,(shp->tset)->ts[selected[k]],modPnt,p);
		if (d<mind)
		{
			mind=d;
			mini=selected[k];
			yps[0]=p[0];yps[1]=p[1];yps[2]=p[2];
		}
		for (j=1;j<=surr[selected[lastUnfolded]][0];j++)
		{
			if (!info[surr[selected[lastUnfolded]][j]])
			{
				lastSelected++;
				selected[lastSelected]=surr[selected[lastUnfolded]][j];
				info[surr[selected[lastUnfolded]][j]]=1;
			}
		}
		h=(DoubleT) (lastSelected+1)/n;
	}
	while ( h < part && ( lastSelected > lastUnfolded ) );
	free(info);
	free(selected);
	return(mini);
}


DoubleT IcpPsetSize(PointSetT *pset)
/********************************************************************
 * Computes rough estimate of size of object defined by point set 	*
 * by computing trace of covariance matrix of given point set.		*
 * pset		- given point set										*
 ********************************************************************/
{
	DoubleT mi[3]={0,0,0},trace=0,covarM[3][3]={{0,0,0},{0,0,0},{0,0,0}};
	long i,n;
	int j,k;
	PointsT pnt;

	n=pset->n;
	pnt=pset->ps;
	for (j=0;j<3;j++)
	{
		for (i=0;i<n;i++)
		{
			mi[j]+=pnt[i][j];
			for (k=0;k<3;k++) covarM[j][k]+=pnt[i][j]*pnt[i][k];
		}
		mi[j]/=n;
	}
	for (j=0;j<3;j++)
		for (k=0;k<3;k++)
		{
			covarM[j][k]/=n;
			covarM[j][k]-=mi[j]*mi[k];
		}
	for (j=0;j<3;j++) trace+=covarM[j][j];
	return(sqrt(trace));
}


void IcpCompRegistration(PointSetT *pset,PointsT y,PointsT pk,RegResultsT *res,int elim[],long nact)
/********************************************************************************
 * Computes and applies registration											*
 * pset		- data point set													*
 * y		- closest points of model shape										*
 * pk		- points after registration											*
 * res      - results of registration											*
 * elim		- array defining which points to use (0) and which to eliminate (1)	*
 * nact 	- number of actualy used (not eliminated) points					*
 ********************************************************************************/
{
	DoubleT trace=0,mip[3]={0,0,0},miy[3]={0,0,0},crossCovarM[3][3]={{0,0,0},{0,0,0},{0,0,0}},qsymM[4][4];
	DoubleT matrix[10],vectors[16],values[4];
	DoubleT rotM[3][3]={{1,0,0},{0,1,0},{0,0,1}},maxEV=0;
	int j,k,l=0,maxEVix=0;
	long n,i;
	PointsT pnt;

	n=pset->n;
	pnt=pset->ps;
	for (j=0;j<3;j++)
	{
		for (i=0;i<n;i++)
		{
			if (!elim[i])
			{
				mip[j]+=pnt[i][j];
				miy[j]+=y[i][j];
				for (k=0;k<3;k++)
					crossCovarM[j][k]+=pnt[i][j]*y[i][k];
			}
		}
		mip[j]/=nact;
		miy[j]/=nact;
	}
	for (j=0;j<3;j++)
	for (k=0;k<3;k++)
	{
		crossCovarM[j][k]/=nact;
		crossCovarM[j][k]-=mip[j]*miy[k];
	}
/*
	printf("Cross-covariance matrix:\n");
	for (i=0;i<3;i++)
	{
		for (j=0;j<3;j++)
		printf("%f ",crossCovarM[i][j]);
		printf("\n");
	}
	printf("miP - x: %f y: %f z: %f\n",mip[0],mip[1],mip[2]);
	printf("miY - x: %f y: %f z: %f\n",miy[0],miy[1],miy[2]);
	getchar();
*/
	for (j=0;j<3;j++) trace+=crossCovarM[j][j];
	qsymM[0][1]=qsymM[1][0]=crossCovarM[1][2]-crossCovarM[2][1];
	qsymM[0][2]=qsymM[2][0]=crossCovarM[2][0]-crossCovarM[0][2];
	qsymM[0][3]=qsymM[3][0]=crossCovarM[0][1]-crossCovarM[1][0];
	for (j=1;j<4;j++)
	{
		for (k=j;k<4;k++)
		{
			qsymM[j][k]=qsymM[k][j]=crossCovarM[j-1][k-1]+crossCovarM[k-1][j-1]-((j==k)?trace:0);
		}
	}
	qsymM[0][0]=trace;

#ifdef MATRIXL
	printf("Q sym matrix:\n");
	for (i=0;i<4;i++)
	{
		for (j=0;j<4;j++) printf("%f ",qsymM[i][j]);
		printf("\n");
	}
#endif
	for (j=0;j<4;j++)
		for (k=0;k<=j;k++)
			matrix[l++]=qsymM[j][k];

	eigens(matrix,vectors,values,4);
	for (j=0;j<4;j++)
	{
#ifdef MATRIXL
		printf("Eig.val. - %d. : %f\n",j,values[j]);
#endif
		if ((values[j])>maxEV)
		{
			maxEV=(values[j]);
			maxEVix=j;
		}
	}
#ifdef MATRIXL
	printf("Max EV index: %d\n",maxEVix);
	/*getchar();*/
#endif
	for (j=0;j<4;j++)
	{
		res->q[j]=vectors[4*maxEVix+j]*((vectors[4*maxEVix]>0) ? 1 : -1);
#ifdef VECTOR
		printf("%f ",res->q[j]);
#endif
	}
#ifdef VECTOR
	printf("\n");
#endif
	/*getchar();*/
	IcpCompRotMatrix(res->q,rotM);
	for (j=0;j<3;j++)
		res->q[j+4]=miy[j]-(rotM[j][0]*mip[0]+rotM[j][1]*mip[1]+rotM[j][2]*mip[2]);
	IcpApplyRegistration(res->q+4,rotM,pset,pk);
}


void IcpLocalReg(ShapeT *datashp,ShapeT *modelshp,PointsT pk,RegParametersT *par,RegResultsT *res,SurroundT surrm,SurroundT surrd,long couples[],PointsT y,int elim[],FILE *fwreg,FILE *fwdms)
/************************************************************************
 * Registers two given shapes											*
 * datashp	- data shape												*
 * modelshp - model shape												*
 * pk		- array of points used as array containing registered 		*
 *			  points of data shape in each iteration					*
 * par 		- parameters of registration								*
 * res 		- results of registration									*
 * surrm    - list of neighbouring triangles of model shape				*
 * surrd	- list of neighbouring triangles of data shape				*
 * couples  - array of indices used as array containing index of 		*
 *			  closest point of model shape found in last iteration for 	*
 *			  each point of data shape									*
 * y		- array of points used as array of closest points			*
 * elim		- used as array containing info	which points to eliminate	*
 * fwreg	- file pointer for writing registration state vector q 		*
 * fwdms	- file pointer for writing ms error 						*
 ************************************************************************/
{
	int k=0,steps=0,j;
	long n,i,nact=0,numCorr,(*corresp)[2];
	DoubleT dk=0,vec[3],correspdms=0,alldms,elimit,i1,i2,admsk,cdmsk;
	ShapeT *pkshape;
	PointSetT *pkpset;
	long (*DataClosestPoint)(),(*DataFasterClosestPoint)();
	long (*ModelClosestPoint)(),(*ModelFasterClosestPoint)();
	FILE *fr;
	TreeT *modeltree,*datatree ;

#ifdef TIMING
	clock_t st,en;
#endif

	n=(datashp->pset)->n;
	if ((pkshape=(ShapeT *) malloc(sizeof(ShapeT)))==NULL) IcpMemError();
	if ((pkpset=(PointSetT *) malloc(sizeof(PointSetT)))==NULL) IcpMemError();
	pkshape->repr=datashp->repr;
	pkshape->pset=pkpset;
	pkpset->ps=pk;
	pkpset->n=n;
	pkshape->tset=datashp->tset;
	
	switch (modelshp->repr)
	{
		case PSET : ModelClosestPoint=IcpPsetClosestPoint;break;
		case TSET : ModelClosestPoint=IcpTsetClosestPoint;ModelFasterClosestPoint=IcpPartTsetClosestPoint;break;
	}
	switch (datashp->repr)
	{
		case PSET : DataClosestPoint=IcpPsetClosestPoint;break;
		case TSET : DataClosestPoint=IcpTsetClosestPoint;DataFasterClosestPoint=IcpPartTsetClosestPoint;break;
	}
	
	if (IcpRangeSearchFlag) modeltree=IcpRangeSearchInit(modelshp) ; 
		
	res->dms=DBL_MAX;
	alldms=DBL_MAX;
	if (par->correspinfo)
	{
		correspdms=DBL_MAX;
		if ((fr=fopen("corresp","r"))==NULL)
		{
			printf("Unable to open the file '%s'! \n","corresp");
			exit(1);
		}
		fscanf(fr,"%ld",&numCorr);
		printf("Number of corresponding points: %ld\n",numCorr);
		if ((corresp=(long (*)[]) malloc(numCorr*2*sizeof(long)))==NULL) IcpMemError();
		for (i=0;i<numCorr;i++)
		{
			fscanf(fr,"%lf %lf",&i1,&i2);
			corresp[i][0]=(long) i1;
			corresp[i][1]=(long) i2;
		}
		fclose(fr);
	}
	elimit=(par->elimit)*(par->elimit);
	do
	{
#ifdef TIMING
		st=clock();
#endif
		nact=0;
		if (IcpRangeSearchFlag && par->eliminate) 
		  datatree=IcpRangeSearchInit(pkshape) ; 
		
		for (i=0;i<n;i++)
		{
			elim[i]=0;
			if (k==0 || !par->fastercp || modelshp->repr==PSET)	
			  {  if (IcpRangeSearchFlag) 
			        couples[i]=IcpPsetRangeClosestPoint(pk[i],modelshp,y[i],modeltree);
			 else   couples[i]=ModelClosestPoint(pk[i],modelshp,y[i]);
			  }
			else couples[i]=ModelFasterClosestPoint(pk[i],modelshp,y[i],surrm,couples[i],par->searchedpart);
	  		if (par->eliminate)
	  		  {
		  	    if (!par->fastercp || datashp->repr==PSET)	
		  	      { if (IcpRangeSearchFlag)
	                       	  IcpPsetRangeClosestPoint(y[i],pkshape,vec,datatree) ;  	      
	  	           else DataClosestPoint(y[i],pkshape,vec);
		  	      }
		  		else DataFasterClosestPoint(y[i],pkshape,vec,surrd,i,par->searchedpart);
		  		
			    elim[i]=(((vec[0]-pk[i][0])*(vec[0]-pk[i][0])+(vec[1]-pk[i][1])*(vec[1]-pk[i][1])+(vec[2]-pk[i][2])*(vec[2]-pk[i][2]))>elimit);
			  }
	  		if (!elim[i]) nact++;
		}
		if (IcpRangeSearchFlag && par->eliminate) 
		  IcpRangeSearchClose(datatree) ;

#ifdef TIMING
		en=clock();
		printf("TIME - Closest Points: %.2f sec.\n",(DoubleT) (en-st)/CLK_TCK);
#endif
		res->dms=0;
		admsk=alldms;
		alldms=0;
		for (i=0;i<n;i++)
		{
			for (j=0;j<3;j++) vec[j]=y[i][j]-pk[i][j];
			alldms+=vec[0]*vec[0]+vec[1]*vec[1]+vec[2]*vec[2];
			if (!elim[i]) res->dms+=vec[0]*vec[0]+vec[1]*vec[1]+vec[2]*vec[2];
		}
		alldms/=n;
		res->dms/=nact;
		if (par->correspinfo)
		{
			cdmsk=correspdms;
			correspdms=0;
			for (i=0;i<numCorr;i++)
			{
				for (j=0;j<3;j++) vec[j]=(modelshp->pset)->ps[corresp[i][1]][j]-pk[corresp[i][0]][j];
				correspdms+=vec[0]*vec[0]+vec[1]*vec[1]+vec[2]*vec[2];
			}
			correspdms/=numCorr;
		}
#ifdef PSETLIST
		printf("Closest points:\n");
		IcpPrintPointArray(n,y);
#endif
#ifdef TIMING
		st=clock();
#endif
		IcpCompRegistration(datashp->pset,y,pk,res,elim,nact);
#ifdef TIMING
		en=clock();
		printf("TIME - Registration: %.2f sec.\n",(DoubleT) (en-st)/CLK_TCK);
#endif
		dk=0;
		for (i=0;i<n;i++)
		{
			for (j=0;j<3;j++) vec[j]=y[i][j]-pk[i][j];
			if (!elim[i])
			{
				for (j=0;j<3;j++) vec[j]=y[i][j]-pk[i][j];
				dk+=vec[0]*vec[0]+vec[1]*vec[1]+vec[2]*vec[2];
			}
		}
		dk/=nact;
		fprintf(fwdms,"%f %ld %f %f %f %f\n",res->dms,nact,correspdms,alldms,sqrt(elimit),res->dms-dk);
		printf("cDMS: %f; aDMS: %f; elimit: %f; nact: %ld; dms-dk: %f\n",correspdms,alldms,sqrt(elimit),nact,res->dms-dk);
		for (i=0;i<7;i++) fprintf(fwreg,"%f ",res->q[i]);
	    fprintf(fwreg,"\n");
		k++;
		printf("%d DMS: %f\n",k,res->dms);
#ifdef PSETLIST
		printf("Registered points: \n");
		IcpPrintPointArray(n,pk);
#endif
		steps=par->iidepth==0 ? -1 : k;
	}
	while ((res->dms-dk > par->thr) && (steps < par->iidepth));
	
	if (IcpRangeSearchFlag) IcpRangeSearchClose(modeltree) ;
	
	res->n=k;
}


void IcpTsetNeighbours(ShapeT *shp,SurroundT surr)
/****************************************************************************
 * Creates list of neighbouring triangles for each triangle on given shape.	*
 * shp		- given shape													*
 * surr		- resulting list												*
 ****************************************************************************/
{
	long i,j,nt,np,index[50];
	int k,l,m,ntri,max=0,min=32767,yesk;
	TrianglesT tr;
	DoubleT sumsurr=0;

	nt=(shp->tset)->n;
	np=(shp->pset)->n;
	tr=(shp->tset)->ts;
	for(j=0;j<nt;j++)
	{
		if ((surr[j]=(long *) malloc((50+1)*sizeof(long)))==NULL) IcpMemError();
		surr[j][0]=0;
	}
	for(i=0;i<np;i++)
	{
		ntri=0;
		for(j=0;j<nt;j++)
		{
			for(k=0;k<3;k++)
			{
				if (tr[j][k]==i)
				{
					index[ntri]=j;
					ntri++;
					break;
				}
			}
		}
		for(m=0;m<ntri;m++)
		{
			for(k=0;k<ntri;k++)
			{
				if(m!=k)
				{
					yesk=0;
					for(l=1;l<surr[index[m]][0];l++)
					{
						if (surr[index[m]][l]==index[k])
						{
							yesk=1;
							break;
						}
					}
					if (!yesk)
					{
						surr[index[m]][0]++;
						surr[index[m]][surr[index[m]][0]]=index[k];
					}
				}
			}
		}
	}
	for(j=0;j<nt;j++)
	{
		if ((surr[j]=(long *) realloc(surr[j],(surr[j][0]+1)*sizeof(long)))==NULL) IcpMemError();
		sumsurr+=surr[j][0];
		if (surr[j][0]>max) max=surr[j][0];
		if (surr[j][0]<min) min=surr[j][0];
	}
	printf("Average memebers of a surround: %f.\n",sumsurr/nt);
	printf("Maximum memebers of a surround: %d.\n",max);
	printf("Minimum memebers of a surround: %d.\n",min);
}


void IcpCenterPointArrays(long nd,PointsT dpnt,long nm,PointsT mpnt)
/********************************************************************
 * Centers points dpnt to match centers of mass of dpnt and mpnt.	*
 * dpnt		- points to be centered									*
 * mpnt		- second array of points								*
 * nd		- number of dpnt points									*
 * nm		- number of mpnt points									*
 ********************************************************************/
{
	int j;
	long i;
	DoubleT mid[3]={0,0,0},mim[3]={0,0,0},trans[3];

	for (j=0;j<3;j++)
	{
		for (i=0;i<nd;i++) mid[j]+=dpnt[i][j];
		mid[j]/=nd;
	}
	for (j=0;j<3;j++)
	{
		for (i=0;i<nm;i++) mim[j]+=mpnt[i][j];
		mim[j]/=nm;
		trans[j]=mim[j]-mid[j];
	}
	for (j=0;j<3;j++) for (i=0;i<nd;i++) dpnt[i][j]+=trans[j];
}


void IcpRegister(ShapeT *datashp,
                 ShapeT *modelshp,
                 RegParametersT *par,
                 DoubleT *qInitial, 
                 RegResultsT *res,
                 int ident)
/********************************************************************
 * Registers two given shapes										*
 * datashp	- data shape											*
 * modelshp - model shape											*
 * par 		- parameters of registration							*
 * res 		- results of registration								*
 * ident	- number identifying current registration				*
 * 			  used in names of files created by IcpRegister			*
 ********************************************************************/
{
	DoubleT rotM[3][3],qmin[7],dmsmin=DBL_MAX;
	PointSetT *dpset;
	PointsT y,pini;
	long **surrm,**surrd,*couples,i,k;
	DoubleT *q,psetsize,mi[3],mi2[3];
	int j,*elim,depth;
	FILE *fwreg,*fwdms;
	char regFileName[256],dmsFileName[256];
#ifdef TIMING
	clock_t st,en;
#endif
	
	dpset=datashp->pset;
	psetsize=IcpPsetSize(dpset);
	printf("Pset size: %f\n",psetsize);
	if ((q=(DoubleT *) malloc(7*sizeof(DoubleT)))==NULL) IcpMemError();
	q[0]=1;for (j=1;j<7;j++)q[j]=0;
	if ((pini=(PointsT) malloc((dpset->n)*3*sizeof(DoubleT)))==NULL) IcpMemError();
	if ((couples=(long *) malloc((dpset->n)*sizeof(long)))==NULL) IcpMemError();
	if ((elim=(int *) malloc((dpset->n)*sizeof(int)))==NULL) IcpMemError();
	if ((y=(PointsT) malloc((dpset->n)*3*sizeof(DoubleT)))==NULL) IcpMemError();
	if (par->fastercp==1 && modelshp->repr==TSET)
	{
		if ((surrm=(long **) malloc(((modelshp->tset)->n)*sizeof(long *)))==NULL) IcpMemError();
#ifdef TIMING
		st=clock();
#endif
		IcpTsetNeighbours(modelshp,surrm);
#ifdef TIMING
		en=clock();
		printf("TIME - Neighbours finding: %.2f sec.\n",(DoubleT) (en-st)/CLK_TCK);
#endif
	}
	if (par->eliminate==1 && par->fastercp==1 && datashp->repr==TSET)
	{
		if ((surrd=(long **) malloc(((datashp->tset)->n)*sizeof(long *)))==NULL) IcpMemError();
#ifdef TIMING
		st=clock();
#endif
		IcpTsetNeighbours(datashp,surrd);
#ifdef TIMING
		en=clock();
		printf("TIME - Neighbours finding: %.2f sec.\n",(DoubleT) (en-st)/CLK_TCK);
#endif
	}
	if (par->global==0)
	{
		q = qInitial;
                IcpCompRotMatrix(q,rotM);
		IcpApplyRegistration(q+4,rotM,dpset,pini);
		if (par->center) IcpCenterPointArrays(dpset->n,pini,(modelshp->pset)->n,(modelshp->pset)->ps);
	}
	else
	{
		for (i=0;i<N_INIT;i++)
		{
	        for (j=0;j<3;j++)
			{
				mi[j]=0;
				for (k=0;k<dpset->n;k++) mi[j]+=dpset->ps[k][j];
				mi[j]/=dpset->n;
			}
			IcpCompRotMatrix(par->qinit[i],rotM);
	    	for (j=0;j<4;j++) q[j]=par->qinit[i][j];
			IcpApplyRegistration(q+4,rotM,dpset,pini);
			for (j=0;j<3;j++)
			{
				mi2[j]=0;
				for (k=0;k<dpset->n;k++) mi2[j]+=pini[k][j];
				mi2[j]/=dpset->n;
				q[4+j]=mi[j]-mi2[j];
			}
			for (j=0;j<3;j++) for (k=0;k<dpset->n;k++) pini[k][j]+=q[4+j];

			if (par->center) IcpCenterPointArrays(dpset->n,pini,(modelshp->pset)->n,(modelshp->pset)->ps);
#ifdef ICPOUT
	    	printf("********Inicial rotation #: %ld*********\n",i);
#endif
			sprintf(regFileName,"iter%d_%d.reg",ident,(int) i);
			sprintf(dmsFileName,"iter%d_%d.dms",ident,(int) i);
			if ((fwreg=fopen(regFileName,"w"))==NULL)
			{
				printf("Unable to open the file '%s'! \n",regFileName);
				exit(1);
			}
			if ((fwdms=fopen(dmsFileName,"w"))==NULL)
			{
				printf("Unable to open the file '%s'! \n",dmsFileName);
				exit(1);
			}
	    	IcpLocalReg(datashp,modelshp,pini,par,res,surrm,surrd,couples,y,elim,fwreg,fwdms);
	   		fclose(fwreg);
			fclose(fwdms);
			if (res->dms < dmsmin)
	    	{
				dmsmin=res->dms;
				for (j=0;j<7;j++) qmin[j]=res->q[j];
	    	}
#ifdef ICPOUT
	    	printf("DMS: %f\n",(res->dms));
#endif
/*            printf("Current state vector:\n");
	    	for (j=0;j<7;j++) printf("[%d]: %f\n",j,res->q[j]);
	    	printf("Current min. st. vec.\n");
	    	for (j=0;j<7;j++) printf("[%d]: %f\n",j,qmin[j]);*/
		}
#ifdef ICPOUT
		printf("Minimal DMS: %f\n",dmsmin);
#endif
		IcpCompRotMatrix(qmin,rotM);
		IcpApplyRegistration(qmin+4,rotM,dpset,pini);
#ifdef ICPOUT
		printf("*******Final Registration********\n");
#endif
	}
	depth=par->iidepth;
	par->iidepth=0;
	sprintf(regFileName,"final%d.reg",ident);
	sprintf(dmsFileName,"final%d.dms",ident);
	if ((fwreg=fopen(regFileName,"w"))==NULL)
	{
		printf("Unable to open the file '%s'! \n",regFileName);
		exit(1);
	}
	if ((fwdms=fopen(dmsFileName,"w"))==NULL)
	{
		printf("Unable to open the file '%s'! \n",dmsFileName);
		exit(1);
	}
	IcpLocalReg(datashp,modelshp,pini,par,res,surrm,surrd,couples,y,elim,fwreg,fwdms);
	fclose(fwreg);
	fclose(fwdms);
	par->iidepth=depth;
	free(pini);
	if (par->fastercp==1 && modelshp->repr==TSET) free(surrm);
	if (par->eliminate==1 && par->fastercp==1 && datashp->repr==TSET) free(surrd);
	free(couples);
	free(y);
	free(elim);
}

