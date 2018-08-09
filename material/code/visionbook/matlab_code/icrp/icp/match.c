/***************************************************************
 *
 *		Iterative Closest (Reciprocal) Point Algoritmus
 *
 *		Main program 
 *
 *		C file: 	match.c
 *
 *		Author:		Pavel Kucera
 *
 *		Language:	C
 *
 *		09/11/96
 *
 ***************************************************************/


/* Altered by Jan Kybic, 1996 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "icp.h"

int main(void)
{
	ShapeT *modelShape;
	ShapeT *dataShape;
	RegParametersT *params;
	RegResultsT *rst;
	DoubleT q[]={1,0,0,0,0,0,0};
        DoubleT qInitial[]={1,0,0,0,0,0,0};
	DoubleT mat[3][3];
	clock_t st,en;
	int i,j=0;
	long nmod1,nmod2,ndat1,ndat2;
	char dataFileName[256],modelFileName[256];
	FILE *fw;
	RepresentationT drep,mrep;
	

	if ((modelShape=(ShapeT *) malloc(sizeof(ShapeT)))==NULL) IcpMemError();
	if ((dataShape=(ShapeT *) malloc(sizeof(ShapeT)))==NULL) IcpMemError();
	if ((params=(RegParametersT *) malloc(sizeof(RegParametersT)))==NULL) IcpMemError();
	if ((rst=(RegResultsT *) malloc(sizeof(RegResultsT)))==NULL) IcpMemError();

	IcpReadParamFile("match.prm",dataFileName,&ndat1,&ndat2,&drep,
	                 modelFileName,&nmod1,&nmod2,&mrep,qInitial,params);

	if (drep==PSET)
		{
			IcpReadPsetFile(dataFileName,ndat2,dataShape);
			printf("Number of data points: %ld\n",(dataShape->pset)->n);
		}
		else
			if (drep==TSET)
			{
				IcpReadTsetFiles(dataFileName,ndat1,ndat2,dataShape);
				printf("Number of data points: %ld\n",(dataShape->pset)->n);
				printf("Number of data triangles: %ld\n",(dataShape->tset)->n);
			}
			else
			{
				printf("Unknown or unimplemented representation of data shape.\n");
				exit(1);
			}
	if (mrep==PSET)
		{
			IcpReadPsetFile(modelFileName,nmod2,modelShape);
			printf("Number of model points: %ld\n",(modelShape->pset)->n);
		}
		else
			if (mrep==TSET)
			{
				IcpReadTsetFiles(modelFileName,nmod1,nmod2,modelShape);
				printf("Number of model points: %ld\n",(modelShape->pset)->n);
				printf("Number of model triangles: %ld\n",(modelShape->tset)->n);
			}
			else
			{
				printf("Unknown or unimplemented representation of model shape.\n");
				exit(1);
			}
	printf("\nThreshold: %f\n",params->thr);
	
	if (params->global)
	  {
	    printf("Global matching, %d steps for each initial rotation.\n",params->iidepth);
	 		IcpGenInitStates(params->qinit);
 	  }
	 	else printf("Local matching.\n");
	if (params->fastercp) printf("Faster finding closest points, searched part will be %f.\n",params->searchedpart);
	if (params->center) printf("Used translating of data set to coinside the centers of mass.\n");
	if (params->eliminate)
	  {
	   printf("Eliminating not corresponding points\n");
	   printf("Limit for eliminating is %f\n",params->elimit);
	  }
	
	if (params->correspinfo) printf("Used file with correspondence information.\n");
	printf("____________________________________________\n");

	st=clock();
	IcpRegister(dataShape,modelShape,params,qInitial,rst,j);
	en=clock();

	printf("____________________________________________\n");
	printf("Final DMS: %f\n",rst->dms);
	printf("Translation:");
	for (i=4;i<7;i++) printf(" %.8f ",rst->q[i]);
	printf("\nRotation:");
	for (i=0;i<4;i++) printf(" %.8f ",rst->q[i]);
	printf("\n");
	printf("Time elapsed: %.2f sec.\n",(DoubleT) (en-st)/CLK_TCK);
	if ((fw=fopen("match.res","w"))==NULL)
	  {
	    printf("Unable to open the file '%s'! \n","match.res");
	    exit(1);
	  }
	for (i=0;i<7;i++) fprintf(fw,"%f ",qInitial[i]);
	fprintf(fw,"\n");
	for (i=0;i<7;i++) fprintf(fw,"%f ",rst->q[i]);
	fprintf(fw,"\n");
	IcpCompRotMatrix(rst->q,mat);
	for (i=0;i<3;i++){
	  for(j=0;j<3;j++) 
	    fprintf(fw,"%f ",mat[j][i]);
	  fprintf(fw,"0\n");
	}
	fprintf(fw,"%f %f %f 1\n",rst->q[4],rst->q[5],rst->q[6]);
		fclose(fw);
	
	return(0);
}











