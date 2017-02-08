     **FREE
       // ansicon.exe plink.exe -ssh LOGIN@SERVER
       // compile.sh WRKDBRLCK.SQLRPGLE DURING/WRKDBRLCK
       //test

       // declares main procedure of PGM
       CTL-OPT MAIN(WRKDBRLCK) ;
       // external definition sources
      /define #IFS
      /define #API_OS400_USERSPACE
      /define #API_QDBLDBR
      /define #API_QCMDEXC
      /define #API_QWCLOBJL
      /if defined(#IFS)
      /include #HSPECV7R1.SQLRPGLE
      /include #DATATV7R1.SQLRPGLE
      /include #CONSTV7R1.SQLRPGLE
      /include #APIV7R1.SQLRPGLE
      /else
      /include DURING/QPGMSRC,#DATATV7R1
      /include DURING/QPGMSRC,#HSPECV7R1
      /include DURING/QPGMSRC,#CONSTV7R1
      /include DURING/QPGMSRC,#APIV7R1
      /endif

       DCL-S outf CHAR(21) INZ('DURING/WRKDBRLCKF') ;
       // external file definitions as template for other definitions
       DCL-F TP_PRTF printer qualified template
                     extfile(*EXTDESC) extdesc('DURING/WRKDBRLCKP') ;

       DCL-F TP_DSPF workstn qualified template
                     extfile(*EXTDESC) extdesc('DURING/WRKDBRLCKD') ;

       DCL-F TP_OUTF DISK(*EXT) qualified template
                     extfile(*EXTDESC) extdesc('DURING/WRKDBRLCKF')
                     rename(WRKDBRLCKF:dataline) ;

       // definition of variable/datastruct as Template
       DCL-DS UsrspceWorking  QUALIFIED TEMPLATE ;
          Element      LIKE(QUSA0100.Entries) ;
          start        LIKE(BIN4)             ;
          first        LIKE(BOOL)             ;
          Usrspcat     LIKEDS(QUSA0100)       ;
       END-DS ;
       
       // global variable/datastruct definition
       DCL-DS settings QUALIFIED ;
          print              LIKE( bool ) ;
          display            LIKE( bool ) ;
          outfile            LIKE( bool ) ;
          user               CHAR( 10) inz(*USER) ;
          baseObject         LIKEDS(TP_OBJLIB) ;
          system             CHAR(  8) ;
          repeat             LIKE( bool ) ;
       END-DS;


       // Mainprocedure :

       // displays/prints/writes filelocks with the locks of its dependencies
       // @param DS       baseObject IN    -  contains Object and Lib
       // @param CHAR(10) outputType IN    -  allowed value "*FILE" "*PRINT" "*OUTFILE"
       DCL-PROC WRKDBRLCK ;
          DCL-PI *N EXTPGM ;
             baseObject  LIKEDS(TP_OBJLIB) CONST ;
             outputType  CHAR( 10 )        CONST ;
          END-PI ;
          DCL-DS dbldbrUsrspc        LIKEDS(TP_OBJLIB) ;
          DCL-DS dbldbrUWorking      LIKEDS(UsrspceWorking) ;
          DCL-S  dbldbrFormat        VARCHAR ( 10 ) INZ('DBRL0100') ;
          DCL-DS dbldbrResult        LIKEDS(DBRL0100) ;
          DCL-DS wclobjlUsrspc       LIKEDS(TP_OBJLIB) ;
          DCL-DS wclobjlWorking      LIKEDS(UsrspceWorking) ;
          DCL-S  wclobjlFormat       VARCHAR ( 10 ) INZ('OBJL0100') ;
          DCL-DS wclobjlResult       LIKEDS(OBJL0100) ;
          DCL-DS myerror             LIKEDS(QUSEC)    ;
          DCL-C  USRSPCSIZE          10000  ;

         settings.print   = (outputType = #PRINT);
         settings.display = (outputType = #DISPLAY);
         settings.outfile = (outputType = #OUTFILE);
         settings.baseObject = baseObject;
         settings.repeat = FALSE;

         // CREATE USERSPACE "QTEMP/#DBLDBR" FOR QDBLDBR API
         dbldbrUsrspc.OBJECT = '#DBLDBR';
         dbldbrUsrspc.LIBARY = 'QTEMP';
         QUSCRTUS(dbldbrUsrspc: 'QDBLDBR': USRSPCSIZE: #HEXNULL: #ALL   :
                  'Temp User Space for  QDBLDBR API');

         // CREATE USERSPACE "QTEMP/#WCLOBJL" FOR QWCLOBJL API
         wclobjlUsrspc.OBJECT = '#WCLOBJL';
         wclobjlUsrspc.LIBARY = 'QTEMP';
         QUSCRTUS(wclobjlUsrspc: 'QWCLOBJL': USRSPCSIZE: #HEXNULL: #ALL   :
                  'Temp User Space for  Qwclobjl API');

         dou (NOT settings.repeat);
            // OPEN PRINTERFILE FOR A DUMMY PRINT OUT
            ocOutput(#OPEN);

            // EXEUTE QDBLDBR FILLS ALL RELATIONS OF "baseObject" IN USERSPACE
            // MY OBJ SHOULD BE A TABLE OR PHYSICAL FILE WITH SINGLE MEMBERS

            // PRINT ALL OBJECT LOCKS FOR FILE
            QWCLOBJL(wclobjlUsrspc :wclobjlFormat
                    :baseObject :#FILE :#ALL :myerror);
            wclobjlWorking.first = TRUE;

            dow (getNextUsrspcE(wclobjlUsrspc:wclobjlWorking:wclobjlResult));

               if (wclobjlResult.lockState <> #NONE);
                  appendOnOutput(baseObject: wclobjlResult.Job
                             : wclobjlResult.LockState);
               endif;
            enddo;

            // LOOP THROUGH ALL DATABASE RELATION PRINT THEM
            // AND PRINT ALL LOCKS FOR THEM
            QDBLDBR(dbldbrUsrspc:dbldbrFormat:baseObject:#FIRST:#ALL:myerror);
            dbldbrUWorking.first = TRUE;

            dow  (getNextUsrspcE(dbldbrUsrspc:dbldbrUWorking:dbldbrResult));

               // PRINT ALL OBJECT LOCKS FOR FILE
               QWCLOBJL(wclobjlUsrspc:wclobjlFormat
                       :dbldbrResult.DependentFile:#FILE:#ALL:myerror);
               wclobjlWorking.first = TRUE;

               dow (getNextUsrspcE(wclobjlUsrspc:wclobjlWorking
                                  :wclobjlResult));

                  if (wclobjlResult.lockState <> #NONE);
                    appendOnOutput(dbldbrResult.DependentFile
                                  : wclobjlResult.Job
                                  : wclobjlResult.LockState);
                  endif;
               enddo;

            enddo;

            // DELETE USERSPACES
            ocOutput(#CLOSE);
         enddo;
         QUSDLTUS(dbldbrUsrspc:myerror);
         QUSDLTUS(wclobjlUsrspc:myerror);
         return;
       END-PROC ;

       // reads next Userspace Entry
       // @param DS       Usrspc     IN    -  contains Object and Lib of processing Userspace
       // @param DS       Working    I/O   -  each Userspace needs its own working DS
       //                                     for internal use only
       // @param CHAR     result     OUT   -  A Long Long String which is the Userpace Entry
       DCL-PROC getNextUsrspcE ;
          DCL-PI *N like(BOOL) ;
             Usrspc     LIKEDS(TP_OBJLIB) VALUE ;
             Working    LIKEDS(UsrspceWorking) ;
             result     LIKE(LONGCHAR) OPTIONS(*VARSIZE) ;
          END-PI ;
          DCL-DS myerror LIKEDS(QUSEC) ;

          if (Working.first = true);

            QUSRTVUS(Usrspc:125:16:Working.Usrspcat);
            Working.Start = Working.Usrspcat.Offset + 1;
            Working.Element = 0;
            Working.first = false;
          endif;

          if (Working.Usrspcat.Entries = Working.Element);

             return FALSE;
          endif;
          QUSRTVUS(Usrspc:Working.Start:Working.Usrspcat.EntrieSize
                   :result:myerror);
          Working.Start += Working.Usrspcat.EntrieSize;
          Working.Element += 1;
          return TRUE;
       END-PROC;

       // Decides based on settings which output type will written to
       // @param DS       Object     IN    -  contains Object and Lib with lock
       // @param DS       JOB        IN    -  Job which blocks Object
       // @param CHAR(10) LockState  IN    -  the lock state of the current lock
       DCL-PROC appendOnOutput ;
          DCL-PI *N ;
             Object      LIKEDS(TP_OBJLIB) VALUE ;
             Job         LIKEDS(TP_JOB)    VALUE ;
             LockState   CHAR( 10   )      VALUE ;
          END-PI ;
          DCL-DS dataline      LIKEREC(TP_PRTF.dataline:*output) INZ ;
          DCL-DS datalineDspf  LIKEREC(TP_DSPF.dataline:*output) INZ ;
          DCL-DS datalineOutf  LIKEREC(TP_OUTF.dataline:*output) INZ ;

          eval-corr dataline = Object;
          eval-corr dataline = Job;
                    dataline.LockState = Lockstate;

          if (settings.print);

             prtfhandling(#WRITE:dataline);
          endif;

          if (settings.outfile);

             eval-corr datalineOutf = dataline;
             outfhandling(#WRITE:datalineOutf);
          endif;

          if (settings.display);

             eval-corr datalineDspf = dataline;
             dspfhandling(#WRITE:datalineDspf);
          endif;
          return;
       END-PROC ;

       // Decides based on settings which output type will be opened/close
       // @param VARCHAR(10) action     IN  - allowed values *CLOSE, *OPEN
       DCL-PROC ocOutput ;
          DCL-PI *N ;
             action VARCHAR( 10 ) VALUE ;
          END-PI ;

          if (settings.print);

             prtfhandling(action);
          endif;

          if (settings.display);

             dspfhandling(action);
          endif;

          if (settings.outfile);

             outfhandling(action);
          endif;
          return;

       END-PROC ;

       // Handles Print Output
       // @param VARCHAR(10) action     IN      -  allowed values *WRITE *CLOSE *OPEN
       // @param DS          datalineP  IN(OPT) -  Has to be filled in case of *WRITE
       //                                          line which will be printed
       DCL-PROC prtfhandling ;
          DCL-PI *N ;
             action     VARCHAR( 10 ) VALUE ;
             datalineP  LIKEREC(TP_PRTF.dataline:*OUTPUT)
                        OPTIONS(*NOPASS) ;
          END-PI ;
          DCL-F handle  PRINTER STATIC USROPN QUALIFIED
                        EXTFILE(*EXTDESC)
                        EXTDESC('DURING/WRKDBRLCKP') ;

          DCL-DS info        LIKEREC( handle.info : *OUTPUT )   INZ ;
          DCL-DS headline    LIKEREC( handle.headline:*OUTPUT ) INZ ;
          DCL-DS dataline    LIKEREC( handle.dataline:*OUTPUT ) INZ ;
          DCL-S  rrn         ZONED( 6 ) STATIC ;
          DCL-S  handleOpen  LIKE(BOOL) STATIC ; 

          if (action = #OPEN AND NOT handleOpen);

             handleOpen = TRUE;
             open handle;
             write handle.info info;
             write handle.headline headline;
             rrn = 0;
          endif;

          if (action = #WRITE AND handleOpen);

             eval-corr dataline = datalineP;
             rrn += 1;
             dataline.rrn = rrn;
             write handle.dataline dataline;
          endif;

          if (action = #CLOSE AND handleOpen);

             rrn = 0;
             close handle;
             handleOpen = FALSE;
          endif;
          return;

       END-PROC ;

       // Handles Display Output
       // in case of *CLOSE recursion WITH *EXFMT
       // in case of *EXFMT recursion WITH *READC
       // changes settings to tell mnain routine to repeat

       // @param VARCHAR(10) action     IN      -  allowed values *WRITE *CLOSE *OPEN
       //                                          *READC *EXFMT
       // @param DS          datalineP  IN(OPT) -  Has to be filled in case of *WRITE
       //                                          line which will be printed
       DCL-PROC dspfhandling ;
          DCL-PI *N ;
             action        VARCHAR(10) VALUE ;
             datalineP     LIKEREC(TP_DSPF.dataline:*OUTPUT)
                           OPTIONS(*NOPASS) ;
          END-PI ;
          DCL-F handle  WORKSTN STATIC USROPN QUALIFIED
                        EXTFILE(*EXTDESC)
                        EXTDESC('DURING/WRKDBRLCKD')
                        SFILE(dataline:rrn)
                        INFDS(handleInfo) ;
          DCL-DS datalineI   LIKEREC(handle.dataline:*INPUT)      ;
          DCL-DS datalineA   LIKEREC(handle.dataline:*ALL)        ;
          DCL-DS dataline    LIKEREC(handle.dataline:*OUTPUT) INZ ;
          DCL-DS nodata      LIKEREC(handle.nodata  :*OUTPUT) INZ ;
          DCL-DS headline    LIKEREC(handle.headline:*ALL   ) INZ ;
          DCL-DS footer      LIKEREC(handle.footer  :*OUTPUT) INZ ;
          DCL-DS ctl         LIKEREC(handle.ctl     :*OUTPUT) INZ ;
          DCL-S  rrn         ZONED ( 6 ) STATIC ;
          DCL-S  handleOpen  LIKE(BOOL)  STATIC ;
          DCL-DS  handleInfo  qualified  STATIC ;
             Fkey CHAR(1) POS(369) ;
          END-DS ;
          DCL-S job             VARCHAR( 30 ) ;
          DCL-S cmd             VARCHAR( 128 ) ;
          DCL-S option          CHAR ( 1 ) ;
          DCL-S blankval        CHAR ( 1 ) ;

          if (action = #OPEN AND NOT handleOpen);

             open handle;
             rrn = 0;
             handleOpen = TRUE;
          endif;

          if (action = #WRITE AND handleOpen);

             eval-corr dataline = datalineP;
             rrn += 1;
             dataline.rrn = rrn;
             write handle.dataline dataline;
          endif;

          if (action = #READC AND handleOpen AND rrn > 0);
             dou %eof(handle);

                clear cmd;
                job = %trim(datalineI.Jobnumber) + '/'
                    + %trim(datalineI.Username) +  '/'
                    + %trim(datalineI.Jobname);

                if (handleInfo.fkey = #key.F04);
                   cmd = '?';
                endif;
                if (datalineI.option =  '4');
                   cmd = cmd + 'ENDJOB JOB('+ job +')';
                endif;
                if (datalineI.option  = '5');
                   cmd = cmd + 'WRKJOB JOB('+ job +')';
                endif;
                if (datalineI.option  <> ' ');
                   eval-corr datalineA = datalineI;
                   datalineA.option = ' ';
                   datalineA.in86 = TRUE;
                   update handle.dataline datalineA;
                   monitor;
                     QCMDEXC (cmd:%len(cmd));
                   on-error;
                   endmon;
                endif;

                readc handle.dataline datalineI;
             enddo;
             write handle.ctl ctl;
          endif;
          if (action = #EXFMT AND handleOpen);

             if (rrn = 0) ;

                write handle.nodata nodata;
             else;

                ctl.rrn = rrn;
                ctl.in45 = TRUE;
                write handle.ctl ctl;

             endif;
             write handle.footer footer;
             eval-corr headline = settings.baseObject;
             dou (handleInfo.fkey = #key.F03)
              or   (handleInfo.fkey = #key.F12)
              or   (handleInfo.fkey = #key.F05);
                dspfhandling(#READC);
                exfmt  handle.headline headline;
             enddo;
             settings.repeat = (handleInfo.fkey = #key.F05);
          endif;

          if (action = #CLOSE AND handleOpen);

             rrn = 0;
             close handle;
             handleOpen = FALSE;
          endif;
          return;

       END-PROC ;

       // Handles File  Output
       // @param VARCHAR(10) action     IN      -  allowed values *WRITE *CLOSE *OPEN
       // @param DS          datalineP  IN(OPT) -  Has to be filled in case of *WRITE
       //                                          line which will be printed
       DCL-PROC outfhandling ;
          DCL-PI *N ;
             action      VARCHAR( 10 ) VALUE ;
             datalineP   LIKEREC(TP_OUTF.dataline:*OUTPUT)
                         OPTIONS(*NOPASS) ;
          END-PI ;
          DCL-F handle  DISK USAGE(*INPUT : *OUTPUT)
                             STATIC USROPN QUALIFIED
                             EXTFILE(outf)
                             EXTDESC('DURING/WRKDBRLCKF')
                             RENAME(WRKDBRLCKF:dataline) ;
          DCL-S handleOpen  LIKE(BOOL) STATIC ;
          DCL-DS dataline   LIKEREC(handle.dataline:*OUTPUT) ;

          if (action = #OPEN AND NOT handleOpen);

             open handle;
             handleOpen = TRUE;
          endif;
          if (action = #WRITE AND handleOpen);

             eval-corr dataline = datalineP;
             write handle.dataline dataline;
          endif;
          if (action = #CLOSE AND handleOpen);

             close handle;
             handleOpen = FALSE;
          endif;
          return;
       END-PROC ;
