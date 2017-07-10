     **FREE
       //*******************************************************************************************
       //*‚COMPILER SETTINGS
       //*******************************************************************************************
       CTL-OPT DFTACTGRP ( *NO )                  ;
       CTL-OPT ACTGRP    ( *CALLER )              ;
       CTL-OPT OPTION    ( *SRCSTMT :*NODEBUGIO ) ;
       CTL-OPT CCSID     ( *CHAR:*JOBRUN )        ;
       CTL-OPT MAIN      ( TWOPAGE )              ;
       CTL-OPT TIMFMT    ( *ISO )                 ;
       //*******************************************************************************************
       //*‚TEMPLATES
       //*******************************************************************************************
       DCL-F display WORKSTN QUALIFIED ALIAS TEMPLATE
                     EXTFILE ( *EXTDESC ) EXTDESC ( 'DURING/TWOPAGED' ) ;
       DCL-F file2   DISK QUALIFIED ALIAS TEMPLATE
                     USAGE( *INPUT )
                     EXTFILE ( *EXTDESC ) EXTDESC ( 'DURING/LMCUPF03' ) ;
       DCL-DS tms_cutoff_schema_time LIKEREC (file2.curec03 ) TEMPLATE ;
       DCL-DS TpDisplayControl QUALIFIED TEMPLATE ;
           F03        IND POS(  3 ) ;
           F12        IND POS( 12 ) ;
           PAGEDOWN   IND POS( 25 ) ;
           PAGEUP     IND POS( 26 ) ;
           CLEARLEFT  IND POS( 40 ) ;
           CLEARRIGHT IND POS( 60 ) ;
           PAGEDOWNLEFT   IND POS( 41 );
           PAGEUPLEFT     IND POS( 42 );
           PAGEDOWNRIGHT  IND POS( 61 );
           PAGEUPRIGHT    IND POS( 62 );
       END-DS ;
       DCL-DS TpFillWindowWorkspace QUALIFIED TEMPLATE ;
          firstJ          INT( 5 ) INZ ( 9999  ) ;
          lastJ           INT( 5 ) INZ ( 0  ) ;
       END-DS ;
       DCL-DS TpHandleFileRightFilter QUALIFIED TEMPLATE ;
          schema_id   LIKE ( tms_cutoff_schema_time.schema_id   ) ;
       END-DS ;

       DCL-PR handleFile POINTER EXTPROC( handleFilePointer ) ;
          method VARCHAR ( 30 ) VALUE ;
          data POINTER VALUE ;
       END-PR ;
       //*******************************************************************************************
       //*‚GLOBALS
       //*******************************************************************************************
       DCL-S handleFilePointer POINTER( *PROC ) ;

       //*******************************************************************************************
       //*‚TWOPAGE
       //*******************************************************************************************
       DCL-PROC TWOPAGE ;
          DCL-PI *N EXTPGM ;
          END-PI ;

          DCL-S  ReturnControlPointer POINTER ;
          DCL-DS ReturnControl LIKEDS(TpDisplayControl)
                               BASED ( ReturnControlPointer ) ;
          DCL-DS leftPageOut     LIKEREC ( display.l_sfl: *OUTPUT )
                                 BASED( leftPageOutPtr ) ;
          DCL-S  leftPageOutPtr  POINTER ;
          DCL-DS RightFWWorkspace LIKEDS( TPFillWindowWorkspace ) INZ ;
          DCL-DS LeftFWWorkspace LIKEDS( TPFillWindowWorkspace ) INZ ;
          DCL-DS Filter  LIKEDS( TpHandleFileRightFilter ) ;
          DCL-S  i INT( 5 ) INZ ( 1 ) ;

          EXEC SQL SET OPTION DATFMT = *ISO
                            , TIMFMT = *ISO
                            , TIMSEP = *COLON  ;
          handleFileLeft( 'INIT' : *NULL ) ;
          handleFileRight( 'INIT' : *NULL ) ;
          handleFileLeft( 'FETCH_DATA' : *NULL) ;
          reset i ;
          leftPageOutPtr = handleFileLeft( 'GET_RECORD' : %addr( i ) ) ;
          eval-corr Filter = leftPageOut ;
          handleFileRight( 'FETCH_DATA' : %addr( Filter ) ) ;
          handleDislpay( 'OPEN' ) ;
          fillWindow( RightFWWorkspace : 'RIGHT'
                    : %paddr(handleFileRight) );
          fillWindow( LeftFWWorkspace : 'LEFT'
                    : %paddr(handleFileLeft) );

          ReturnControlPointer =
                          handleDislpay( 'GET_CONTROL'  ) ;
          DOW ( NOT ReturnControl.F03  )
           AND ( NOT ReturnControl.F12  ) ;
             handleDislpay( 'EXFMT' ) ;
             ReturnControlPointer =
                          handleDislpay( 'GET_CONTROL'  ) ;

             IF  ( ReturnControl.pagedown )
              OR ( ReturnControl.pageup   ) ;
                 fillWindow( RightFWWorkspace : 'RIGHT'
                           : %paddr(handleFileRight) );
                 fillWindow( LeftFWWorkspace : 'LEFT'
                          : %paddr(handleFileLeft) );
             ENDIF ;
          ENDDO ;
          handleDislpay( 'CLOSE' ) ;
          RETURN ;

       END-PROC ;

       //*******************************************************************************************
       //*‚fillWindow
       //*******************************************************************************************
       DCL-PROC fillWindow ;
          DCL-PI *N POINTER ;
             Workspace LIKEDS( TpFillWindowWorkspace ) ;
             method VARCHAR ( 30 ) VALUE ;
             data POINTER( *PROC ) OPTIONS ( *NOPASS ) VALUE ;
          END-PI ;
          DCL-S  i               INT( 5 ) INZ ;
          DCL-S  j               INT( 5 ) INZ ;
          DCL-S  lastRow         INT( 5 ) INZ ;
          DCL-S  ReturnControlPointer POINTER ;
          DCL-DS ReturnControl LIKEDS(TpDisplayControl)
                               BASED ( ReturnControlPointer ) ;
          DCL-S  AmountRows      INT( 5 ) BASED ( AmountRowsPointer ) ;
          DCL-S  AmountRowsPointer POINTER ;


          handleFilePointer = data ;
          AmountRowsPointer = handleFile( 'GET_AMOUNT' : *NULL ) ;
          ReturnControlPointer =
                       handleDislpay( 'GET_CONTROL'  ) ;

          IF  ( ReturnControl.pagedown ) ;
             j = Workspace.lastJ ;
             IF ( j = AmountRows ) ;
                Return *NULL;
             ENDIF ;
          ELSE ;
             j = Workspace.firstJ - 17;
             IF ( Workspace.firstJ = 0 ) ;
                Return *NULL;
             ENDIF ;
          ENDIF ;

          handleDislpay( 'CLEAR_' + method + '_SFL'  ) ;

          Workspace.firstJ = j ;
          IF ( j + 17  > AmountRows );
             lastRow = AmountRows - j ;
          ELSE ;
             lastRow = 17 ;
          ENDIF ;
          FOR i = 1 BY 1 TO lastRow ;
             j += 1;
             handleDislpay( 'WRITE_' + method
                          : handleFile ( 'GET_RECORD' : %addr( j ) )
                          ) ;
          ENDFOR ;
          Workspace.lastJ = j;

          RETURN *NULL ;
       END-PROC ;

       //*******************************************************************************************
       //*‚handleFileLeft
       //*******************************************************************************************
       DCL-PROC handleFileLeft ;
          DCL-PI *N POINTER ;
             method VARCHAR ( 30 ) VALUE ;
             data POINTER VALUE ;
          END-PI ;
          DCL-S i INT ( 5 ) BASED ( data ) ;
          DCL-S AmountRows  INT ( 5 ) STATIC ;
          DCL-DS leftPageOut     LIKEREC ( display.l_sfl: *OUTPUT )
                                 STATIC INZ  ;
          DCL-S query VARCHAR ( 125 ) ;
          DCL-DS Result QUALIFIED STATIC DIM( 9999 );
             schema_id   INT     ( 10 ) ;
             schema_text VARCHAR ( 30 ) ;
          END-DS ;

          //*************************************
          //*‚INIT
          //*************************************
          IF ( method = 'INIT' ) ;
             query = 'SELECT schema_id, schema_text '
                   + ' FROM tms_cutoff_schema '
                   ;
             EXEC SQL PREPARE LeftFileQuery  FROM :query ;
             EXEC SQL DECLARE LeftFileCursor CURSOR FOR LeftFileQuery ;
          ENDIF ;
          //*************************************
          //*‚FETCH_DATA
          //*************************************
          IF ( method = 'FETCH_DATA' ) ;
             EXEC SQL OPEN  LeftFileCursor ;
             EXEC SQL FETCH LeftFileCursor FOR 9999 ROWS INTO :Result ;
             EXEC SQL GET DIAGNOSTICS :AmountRows  = ROW_COUNT ;
             EXEC SQL CLOSE LeftFileCursor ;
          ENDIF ;

          //*************************************
          //*‚GET_RECORD
          //*************************************
          IF ( method = 'GET_RECORD' ) ;
             RESET leftPageOut ;
             IF ( AmountRows  >= i ) ;
                eval-corr leftPageOut = result( i );
             ENDIF ;
             RETURN %addr(leftPageOut) ;
          ENDIF ;

          //*************************************
          //*‚GET_AMOUNT
          //*************************************
          IF ( method = 'GET_AMOUNT' ) ;
             RETURN %addr(AmountRows) ;
          ENDIF ;

          RETURN *NULL ;
       END-PROC ;

       //*******************************************************************************************
       //*‚handleFileRight
       //*******************************************************************************************
       DCL-PROC handleFileRight ;
          DCL-PI *N POINTER ;
             method VARCHAR ( 30 ) VALUE ;
             data POINTER VALUE ;
          END-PI ;
          DCL-S  i                INT ( 5 ) BASED ( data ) ;
          DCL-DS Filter           LIKEDS(TpHandleFileRightFilter)
                                  BASED ( data ) ;
          DCL-S  AmountRows       INT ( 5 ) STATIC ;
          DCL-DS rightPageOutRet  LIKEREC ( display.r_sfl: *OUTPUT )
                                  STATIC INZ ;
          DCL-DS map              QUALIFIED;
                 rightPageOut     LIKEREC ( display.r_sfl: *OUTPUT ) ;
                 Element          LIKEDS ( SingleElement ) DIM ( 7 )
                                  OVERLAY ( rightPageOut ) ;
          END-DS ;
          DCL-DS SingleElement    QUALIFIED TEMPLATE ;
                 time_id     LIKE ( rightPageOutRet.time_id_0     ) ;
                 schema_id   LIKE ( rightPageOutRet.schema_id_0   ) ;
                 option      LIKE ( rightPageOutRet.option_0      ) ;
                 cutoff_time LIKE ( rightPageOutRet.cutoff_time_0 ) ;
          END-DS ;
          DCL-S  query            VARCHAR ( 125 ) ;
          DCL-DS Result           QUALIFIED DIM( 9999 );
             time_id     LIKE ( tms_cutoff_schema_time.time_id     ) ;
             cutoff_day  LIKE ( tms_cutoff_schema_time.cutoff_day  ) ;
             cutoff_time LIKE ( tms_cutoff_schema_time.cutoff_time ) ;
             schema_id   LIKE ( tms_cutoff_schema_time.schema_id   ) ;
          END-DS ;
          DCL-DS timeTable        QUALIFIED STATIC DIM( 9999 ) INZ ;
             timeTableUnit LIKEDS ( TpTimeTableUnit ) DIM ( 7 ) ;
          END-DS ;
          DCL-DS TpTimeTableUnit  QUALIFIED TEMPLATE;
             time_id     LIKE ( tms_cutoff_schema_time.time_id     ) ;
             cutoff_time LIKE ( tms_cutoff_schema_time.cutoff_time ) ;
          END-DS ;
          DCL-S k                  INT ( 5  ) ;
          DCL-S j                  INT ( 5  ) ;
          DCL-S maxJ               INT ( 5  ) STATIC INZ ;

          //*************************************
          //*‚INIT
          //*************************************
          IF ( method = 'INIT' ) ;
             query = 'SELECT time_id, cutoff_day, cutoff_time, schema_id '
                   + ' FROM tms_cutoff_schema_time '
                   + ' WHERE schema_id = ? '
                   ;
             EXEC SQL PREPARE RightFileQuery  FROM :query ;
             EXEC SQL DECLARE RightFileCursor CURSOR FOR RightFileQuery ;
          ENDIF ;

          //*************************************
          //*‚FETCH_DATA
          //*************************************
          IF ( method = 'FETCH_DATA' ) ;
             EXEC SQL OPEN  RightFileCursor USING :Filter.schema_id ;
             EXEC SQL FETCH RightFileCursor FOR 9999 ROWS INTO :Result ;
             EXEC SQL GET DIAGNOSTICS :AmountRows  = ROW_COUNT ;
             EXEC SQL CLOSE RightFileCursor ;
             RESET timeTable ;
             RESET maxJ      ;
             FOR  k = 1 BY 1 TO AmountRows  ;
                FOR j = 1 BY 1 TO 9999 ;
                    IF ( timeTable ( j ).
                         timeTableUnit ( Result ( k ).cutoff_day + 1 ).
                         time_id = *ZEROS ) ;
                       EVAL-CORR  timeTable ( j ).
                                  timeTableUnit( Result ( k ).cutoff_day + 1 )
                               =  Result ( k ) ;
                       LEAVE ;
                    ENDIF ;
                ENDFOR ;
                IF ( j > maxJ ) ;
                   maxJ = j ;
                ENDIF;
             ENDFOR ;
          ENDIF ;

          //*************************************
          //*‚GET_RECORD
          //*************************************
          IF ( method = 'GET_RECORD' ) ;
             FOR j = 1 BY 1 TO 7 ;
                EVAL-CORR map.element( j ) = timeTable ( i )
                                   .timeTableUnit ( j ) ;
             ENDFOR ;
             rightPageOutRet = map.rightPageOut;
             RETURN %ADDR(rightPageOutRet) ;
          ENDIF ;

          //*************************************
          //*‚GET_AMOUNT
          //*************************************
          IF ( method = 'GET_AMOUNT' ) ;
             RETURN %addr(maxJ) ;
          ENDIF ;
          RETURN *NULL ;
       END-PROC ;

       //*******************************************************************************************
       //*‚handleDislpay
       //*******************************************************************************************
       DCL-PROC handleDislpay ;
          DCL-PI *N POINTER ;
             method VARCHAR ( 30 ) VALUE ;
             data POINTER OPTIONS ( *NOPASS ) VALUE ;
          END-PI ;
          DCL-F display WORKSTN QUALIFIED USROPN ALIAS STATIC
                        EXTFILE ( *EXTDESC ) EXTDESC ( 'DURING/TWOPAGED' )
                        SFILE ( l_sfl : leftRrn )
                        SFILE ( r_sfl : rightRrn )
                        INDDS ( displayControl ) ;

          DCL-DS leftPageCtlIn   LIKEREC ( display.l_sfl_c: *INPUT )  INZ ;
          DCL-DS leftPageCtlOut  LIKEREC ( display.l_sfl_c: *OUTPUT ) INZ ;
          DCL-DS leftPageOut     LIKEREC ( display.l_sfl: *OUTPUT )
                                 BASED(data) ;
          DCL-DS rightPageCtlIn  LIKEREC ( display.r_sfl_c: *INPUT )  INZ ;
          DCL-DS rightPageCtlOut LIKEREC ( display.r_sfl_c: *OUTPUT ) INZ ;
          DCL-DS headerOut       LIKEREC ( display.header : *OUTPUT ) INZ ;
          DCL-DS rightPageOut    LIKEREC ( display.r_sfl: *OUTPUT )
                                 BASED(data) ;
          DCL-S  leftRrn         ZONED( 4 : 0 ) INZ STATIC ;
          DCL-S  rightRrn        ZONED( 4 : 0 ) INZ STATIC ;
          DCL-S  LeftPage        IND INZ ;

          DCL-DS DisplayControl STATIC LIKEDS(TpDisplayControl) INZ ;
          DCL-DS ReturnControl  STATIC LIKEDS(TpDisplayControl) INZ ;

          //*************************************
          //*‚OPEN
          //*************************************
          IF ( method = 'OPEN' ) ;
             OPEN  display ;
             RESET ReturnControl ;
             RESET DisplayControl ;
             DisplayControl.pagedown   = *ON ;
          ENDIF ;

          //*************************************
          //*‚EXFMT
          //*************************************
          IF ( method = 'EXFMT' ) ;
             WRITE display.header  headerOut ;
             WRITE display.r_sfl_c rightPageCtlOut ;
             WRITE display.l_sfl_c leftPageCtlOut  ;
             READ  display.l_sfl_c leftPageCtlIn   ;
             READ  display.r_sfl_c rightPageCtlIn  ;
             LeftPage  = ( LeftPageCtlIn.Cursor_Column < 32 ) ;
             DisplayControl.PageDownLeft = (DisplayControl.PageDown AND
                                            LeftPage ) ;
             DisplayControl.PageUpLeft   = (DisplayControl.PageUp   AND
                                            LeftPage ) ;
             DisplayControl.PageDownRight= (DisplayControl.PageDown AND
                                            NOT ( LeftPage ) ) ;
             DisplayControl.PageUpRight  = (DisplayControl.PageUp   AND
                                            NOT ( LeftPage ) ) ;
          ENDIF ;

          //*************************************
          //*‚GET_CONTROL
          //*************************************
          IF ( method = 'GET_CONTROL' ) ;
             ReturnControl = DisplayControl ;
             RETURN %ADDR( ReturnControl ) ;
          ENDIF ;

          //*************************************
          //*‚CLEAR_LEFT_SFL
          //*************************************
          IF ( method = 'CLEAR_LEFT_SFL' ) ;
             DisplayControl.clearleft  = *ON ;
             WRITE display.l_sfl_c leftPageCtlOut ;
             DisplayControl.clearleft  = *OFF ;
             rightRrn = 0;
          ENDIF ;

          //*************************************
          //*‚CLEAR_RIGHT_SFL
          //*************************************
          IF ( method = 'CLEAR_RIGHT_SFL' ) ;
             DisplayControl.clearright = *ON ;
             WRITE display.r_sfl_c rightPageCtlOut ;
             DisplayControl.clearright = *OFF ;
             leftRrn = 0;
          ENDIF ;

          //*************************************
          //*‚WRITE_LEFT
          //*************************************
          IF ( method = 'WRITE_LEFT' ) ;
             leftRrn += 1 ;
             WRITE  display.l_sfl leftPageOut ;
          ENDIF ;

          //*************************************
          //*‚WRITE_RIGHT
          //*************************************
          IF ( method = 'WRITE_RIGHT' ) ;
             rightRrn += 1 ;
             WRITE  display.r_sfl rightPageOut ;
          ENDIF ;

          //*************************************
          //*‚CLOSE
          //*************************************
          IF ( method = 'CLOSE' ) ;
             CLOSE display ;
          ENDIF ;

          RETURN *NULL ;
       END-PROC ;
