
      SUBROUTINE  IDCLDP(NDP,XD,YD,NCP,IPC)                             ID002720
C THIS SUBROUTINE SELECTS SEVERAL DATA POINTS THAT ARE CLOSEST
C TO EACH OF THE DATA POINT.
C THE INPUT PARAMETERS ARE
C     NDP = NUMBER OF DATA POINTS,
C     XD,YD = ARRAYS OF DIMENSION NDP CONTAINING THE X AND Y
C           COORDINATES OF THE DATA POINTS,
C     NCP = NUMBER OF DATA POINTS CLOSEST TO EACH DATA
C           POINTS.
C THE OUTPUT PARAMETER IS
C     IPC = INTEGER ARRAY OF DIMENSION NCP*NDP, WHERE THE
C           POINT NUMBERS OF NCP DATA POINTS CLOSEST TO
C           EACH OF THE NDP DATA POINTS ARE TO BE STORED.
C THIS SUBROUTINE ARBITRARILY SETS A RESTRICTION THAT NCP MUST
C NOT EXCEED 25.
C THE LUN CONSTANT IN THE DATA INITIALIZATION STATEMENT IS THE
C LOGICAL UNIT NUMBER OF THE STANDARD OUTPUT UNIT AND IS,
C THEREFORE, SYSTEM DEPENDENT.
C DECLARATION STATEMENTS
      IMPLICIT DOUBLE PRECISION (A-D,P-Z)
      DIMENSION   XD(NDP),YD(NDP),IPC(NCP*NDP)
      DIMENSION   DSQ0(25),IPC0(25)
      DATA  NCPMX/25/, LUN/6/
C STATEMENT FUNCTION
      DSQF(U1,V1,U2,V2)=(U2-U1)**2+(V2-V1)**2
C PRELIMINARY PROCESSING
   10 NDP0=NDP
      NCP0=NCP
      IF(NDP0.LT.2)  GO TO 90
      IF(NCP0.LT.1.OR.NCP0.GT.NCPMX.OR.NCP0.GE.NDP0)    GO TO 90
C CALCULATION
   20 DO 59  IP1=1,NDP0
C - SELECTS NCP POINTS.
        X1=XD(IP1)
        Y1=YD(IP1)
        J1=0
        DSQMX=0.0
        DO 22  IP2=1,NDP0
          IF(IP2.EQ.IP1)  GO TO 22
          DSQI=DSQF(X1,Y1,XD(IP2),YD(IP2))
          J1=J1+1
          DSQ0(J1)=DSQI
          IPC0(J1)=IP2
          IF(DSQI.LE.DSQMX)    GO TO 21
          DSQMX=DSQI
          JMX=J1
   21     IF(J1.GE.NCP0)  GO TO 23
   22   CONTINUE
   23   IP2MN=IP2+1
        IF(IP2MN.GT.NDP0)      GO TO 30
        DO 25  IP2=IP2MN,NDP0
          IF(IP2.EQ.IP1)  GO TO 25
          DSQI=DSQF(X1,Y1,XD(IP2),YD(IP2))
          IF(DSQI.GE.DSQMX)    GO TO 25
          DSQ0(JMX)=DSQI
          IPC0(JMX)=IP2
          DSQMX=0.0
          DO 24  J1=1,NCP0
            IF(DSQ0(J1).LE.DSQMX)   GO TO 24
            DSQMX=DSQ0(J1)
            JMX=J1
   24     CONTINUE
   25   CONTINUE
C - CHECKS IF ALL THE NCP+1 POINTS ARE COLLINEAR.
   30   IP2=IPC0(1)
        DX12=XD(IP2)-X1
        DY12=YD(IP2)-Y1
        DO 31  J3=2,NCP0
          IP3=IPC0(J3)
          DX13=XD(IP3)-X1
          DY13=YD(IP3)-Y1
          IF((DY13*DX12-DX13*DY12).NE.0.0)    GO TO 50
   31   CONTINUE
C - SEARCHES FOR THE CLOSEST NONCOLLINEAR POINT.
   40   NCLPT=0
        DO 43  IP3=1,NDP0
          IF(IP3.EQ.IP1)       GO TO 43
          DO 41  J4=1,NCP0
            IF(IP3.EQ.IPC0(J4))     GO TO 43
   41     CONTINUE
          DX13=XD(IP3)-X1
          DY13=YD(IP3)-Y1
          IF((DY13*DX12-DX13*DY12).EQ.0.0)    GO TO 43
          DSQI=DSQF(X1,Y1,XD(IP3),YD(IP3))
          IF(NCLPT.EQ.0)       GO TO 42
          IF(DSQI.GE.DSQMN)    GO TO 43
   42     NCLPT=1
          DSQMN=DSQI
          IP3MN=IP3
   43   CONTINUE
        IF(NCLPT.EQ.0)    GO TO 91
        DSQMX=DSQMN
        IPC0(JMX)=IP3MN
C - REPLACES THE LOCAL ARRAY FOR THE OUTPUT ARRAY.
   50   J1=(IP1-1)*NCP0
        DO 51  J2=1,NCP0
          J1=J1+1
          IPC(J1)=IPC0(J2)
   51   CONTINUE
   59 CONTINUE
      RETURN
C ERROR EXIT
   90 WRITE (LUN,2090)
      GO TO 92
   91 WRITE (LUN,2091)
   92 WRITE (LUN,2092)  NDP0,NCP0
      IPC(1)=0
      RETURN
C FORMAT STATEMENTS FOR ERROR MESSAGES
 2090 FORMAT(1X/41H ***   IMPROPER INPUT PARAMETER VALUE(S).)
 2091 FORMAT(1X/33H ***   ALL COLLINEAR DATA POINTS.)
 2092 FORMAT(8H   NDP =,I5,5X,5HNCP =,I5/
     1   35H ERROR DETECTED IN ROUTINE   IDCLDP/)
      END
