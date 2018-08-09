EXE=ComputerVision.pdf
SRC=ComputerVision.tex
BIB=ComputerVision.aux

$(EXE):$(SRC)
	xelatex $(SRC)

.PHONY.:look
look:
	evince ComputerVision.pdf

.PHONY.:clean
clean:
	$(RM) ComputerVision.aux ComputerVision.log ComputerVision.pdf ComputerVision.dvi ComputerVision.bbl ComputerVision.blg ComputerVision.toc ComputerVision.out ComputerVision.nav ComputerVision.snm ComputerVision.thm ComputerVision.lot ComputerVision.lof
