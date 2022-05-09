C FILE: DRAW_LINES.F
        SUBROUTINE DRAW_LINES(X, H, W, D, POINTS, N_POINTS, WEIGHT)
C       Draw line segments in the 3D image X between the points provided
C       in points.

C       Defines all of the inputs and outputs to function
        INTEGER H, W, D, N_POINTS
        REAL*4 X(H, W, D, 3)
        REAL*8 POINTS(N_POINTS, 3)
        REAL*8 WEIGHT

C       The block below is parsed by f2py. Defines which variables are
C       inputs, outputs, etc. Some inputs, such as h, w, etc are hidden (
C       they can be inferred from the input shape).
Cf2py intent(in) weight
Cf2py intent(in) points
Cf2py integer intent(hide),depend(points) :: n_points=shape(points,0)
Cf2py intent(in,out) x
Cf2py integer intent(hide),depend(x) :: h=shape(x,0), w=shape(x,1), d=shape(x,2)

C       Define all temporary variables used during computation
        INTEGER INDS_MIN(3), INDS_MAX(3), DIMS(3), P_IND
        REAL*8 DELTA_P(3), P(3), P_MID(3), P1(3), P2(3), T, L2, D2
        REAL*8 COLOR(3)

C       There are N_POINTS in array, so go through all N_POINTS-1 pairs
        DO P_IND=1,(N_POINTS-1) 
C           Fortran is 1-based indexing, numpy/python is 0-based
            P1 = POINTS(P_IND,:) + 1
            P2 = POINTS(P_IND+1,:) + 1        

C           Compute vector joining P1 and P2. Then determine color for
C           line segment.
            DELTA_P = P2 - P1
            COLOR = ABS(DELTA_P / SQRT(SUM(DELTA_P**2)))

C           Length squared of vector from P1 to P2. Used later.
            L2 = SUM((P2 - P1)**2)

            DIMS = (/ H, W, D /)

C           Want to assign color to points within WEIGHT of the line
C           segment. Save time by not looping over whole array. Instead,
C           only loop over a small cube containing P1 and P2.
            DO I=1,3
                INDS_MIN(I) = MAX(1, INT(MIN(P1(I), P2(I))-WEIGHT))
                INDS_MAX(I) =MIN(DIMS(I),INT(MAX(P1(I),P2(I))+WEIGHT))
            ENDDO

C           For each point in the cube containing P1 and P2...
            DO I=INDS_MIN(1),INDS_MAX(1)
                DO J=INDS_MIN(2),INDS_MAX(2)
                    DO K=INDS_MIN(3),INDS_MAX(3)
                        P = (/ I, J, K /)            
C                       Project P onto DELTA_P vector. The closest
C                       point on the line connecting P1 and P2 to P
C                       will be at P_MID. But, since it is a line
C                       segment, the T must first be bounded between
C                       0 and 1. Ex: if T = -1. the closest point to P
C                       on the line segment is P1.
                        T = DOT_PRODUCT((P-P1), DELTA_P)/L2
                        T = MAX(0.0, MIN(1.0, T))
                        P_MID = P1 + T*DELTA_P
C                       Compute distance squared between P and the line
C                       segment. If this is less than weight**2, then
C                       color that pixel.
                        D2 = SUM((P_MID - P)**2)
                        IF (D2 <= WEIGHT**2) THEN
                            X(I,J,K,:) = REAL(COLOR, 4)
                        END IF
                    ENDDO
                ENDDO
            ENDDO
        ENDDO
        END
C END FILE DRAW_LINE.F


