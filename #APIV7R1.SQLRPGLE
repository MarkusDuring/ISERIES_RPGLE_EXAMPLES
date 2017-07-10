      /if not defined(#API)
      /define #API
      /if defined(#IFS)
      /include #DATATV7R1.SQLRPGLE
      /else
      /include DURING/QPGMSRC,#DATATV7R1
      /endif
      /if defined(#API_OS400)
      /define #API_OS400_CMD
      /define #API_OS400_DTAQ
      /define #API_OS400_USERSPACE
      /define #API_OS400_JOB
      /define #API_OS400_SPOOL
      /endif
      /if defined(#API_OS400_CMD)
      /define #API_QCMDEXC
      /define #API_QCMDCHK
      /endif
      /if defined(#API_OS400_DTAQ)
      /define #API_QCLRDTAQ
      /define #API_QRCVDTAQ
      /endif
      /if defined(#API_OS400_SPOOL)
      /define #API_QUSLSPL
      /endif
      /if defined(#API_OS400_USERSPACE)
      /define #API_QUSCRTUS
      /define #API_QUSDLTUS
      /define #API_QUSRUSAT
      /define #API_QUSRTVUS
      /define #APU_QUSCHGUS
      /define #API_QUSPTRUS
      /endif
      /if defined(#API_OS400_JOB)
      /define #API_QUSLJOB
      /define #API_QUSRJOBI
      /endif
      /if defined(#API_OS400_DB_ACCESS)
      /define #API_QDBLDBR
      /define #API_QWCLOBJL
      /endif
      /if defined(#API_CLE)
      /define #API_QSORT
      /define #API_BSEARCH
      /define #API_ICONV
      /define #API_REGEX
      /define #API_IFSFILE
      /define #API_SLEEP
      /define #API_GETPATHFILEID
      /define #API_SYSTEM
      /define #API_QSH
      /define #API_CEERAN0
      /define #API_PRINTF
      /endif
      /if defined(#API_QMHSNDPM)
       DCL-PR QMHSNDPM EXTPGM( 'QMHSNDPM' ) ;
         MessageIdentifier  CHAR(  8 )          CONST ;
         MessageFileName    LIKE( TP_OBJLIB )   CONST ;
         MessageData        LIKE( LONGCHAR ) OPTIONS( *VARSIZE ) CONST ;
         LengthOfMessage    LIKE( BIN4 )        CONST ;
         MessageType        CHAR( 10 )          CONST ;
         CallStackEntry     LIKE( LONGCHAR ) OPTIONS( *VARSIZE ) CONST ;
         CallStackCounter   LIKE( BIN4 )        CONST ;
         MessageKey         CHAR(  4 ) ;
         ErrorCode          LIKE( LONGCHAR ) OPTIONS( *VARSIZE ) ;
       END-PR ;
      /endif
      //‚*****************OS400 API******************************* €*/
      /if defined(#API_QWCRNETA)
       DCL-PR QWCRNETA EXTPGM( 'QWCRNETA' ) ;
         Receiver              LIKE( LONGCHAR ) OPTIONS( *VARSIZE ) ;
         LenReceiver           LIKE( BIN4 ) CONST ;
         NumberOfNetA          LIKE( BIN4 ) CONST ;
         NetworkAttributNames  CHAR( 10 )   CONST ;
         ErrorCode             LIKE( LONGCHAR ) OPTIONS( *VARSIZE ) ;
       END-PR ;
       DCL-DS RNTA0010 QUALIFIED TEMPLATE ;
         NumberOfNetA          LIKE( BIN4 ) ;
         OffsetNetAInf         LIKE( BIN4 ) ;
       END-DS ;
       DCL-DS RNTA0100 QUALIFIED TEMPLATE ;
         NetworkAttribute   CHAR(  10 )  ;
         TypeOfDate         CHAR(   1 )  ;
         InformationStatus  CHAR(   1 )  ;
         LengthOfData       LIKE( BIN4 ) ;
         dataChar           CHAR( 256 )  ;
         dataInt            INT  ( NORMINT ) OVERLAY( DataChar:1 ) ;
       END-DS ;
      /endif
      /if defined(#API_QDBLDBR)
       DCL-PR QDBLDBR EXTPGM( 'QDBLDBR' ) ;
         UserSpace     LIKEDS( TP_OBJLIB ) CONST ;
         Format        LIKE  ( TP_FORMAT ) CONST ;
         ObjectName    LIKE  ( TP_OBJLIB ) CONST ;
         MemberName    CHAR  ( 10 )        CONST ;
         RecordFormat  CHAR  ( 10 )        CONST ;
         ErrorCode     LIKE  ( LONGCHAR )  OPTIONS( *varsize );
       END-PR ;
       DCL-DS DBRL0100 QUALIFIED TEMPLATE ;
         FileUsed                LIKEDS( TP_OBJLIB ) ;
         DependentFile           LIKEDS( TP_OBJLIB ) ;
         DependencyType          CHAR(  1 ) ;
         Filler                  CHAR(  3 ) ;
         JoinReferenceNumber     LIKE( BIN4 ) ;
         ConstraintLibaryName    CHAR(  10 ) ;
         ConstraintNameLength    LIKE( BIN4 ) ;
         ConstraintName          CHAR( 258 ) ;
       END-DS ;
      /endif
      /if defined(#API_QWCLOBJL)
      //‚--- Prototype for getting OBJECT LOCKS                   €*/
       DCL-PR QWCLOBJL EXTPGM( 'QWCLOBJL' ) ;
         UserSpace    LIKEDS( TP_OBJLIB ) CONST ;
         Format       LIKE  ( TP_FORMAT ) CONST ;
         ObjectName   LIKE  ( TP_OBJLIB ) CONST ;
         ObjectType   CHAR  (  10 )       CONST ;
         MemberName   CHAR  (  10 )       CONST ;
         ErrorCode    LIKE  ( LONGCHAR )  OPTIONS ( *VARSIZE ) ;
       END-PR ;
       DCL-DS OBJL0100 QUALIFIED TEMPLATE ;
         Job               LIKEDS( TP_JOB ) ;
         LockState         CHAR(  10 )  ;
         LockStatus        LIKE( BIN4 ) ;
         LockType          LIKE( BIN4 ) ;
         MemberName        CHAR(  10 )  ;
         Share             CHAR(   1 )  ;
         LockScope         CHAR(   1 )  ;
         ThreadIdentifier  CHAR(   8 )  ;
       END-DS ;
      /endif
      /if defined(#API_QCMDEXC)
       //‚--- Prototype for executing OS400 CMD                    €*/
       DCL-PR QCMDEXC EXTPGM( 'QCMDEXC' ) ;
         Command      LIKE( LONGCHAR )  OPTIONS( *VARSIZE ) CONST ;
         length       PACKED ( 15 : 5 ) CONST ;
         IGCprocessC  CHAR (   3 ) OPTIONS( *NOPASS ) ;
       END-PR;
      /endif
      /if defined(#API_QCMDCHK)
       //‚--- Prototype for validating OS400 CMD                    €*/
       DCL-PR QCMDCHK EXTPGM( 'QCMDCHK' ) ;
         Command      LIKE( LONGCHAR )  OPTIONS( *VARSIZE ) CONST ;
         length       PACKED ( 15 : 5 ) CONST ;
         IGCprocessC  CHAR (   3 ) OPTIONS( *NOPASS ) ;
       END-PR;
      /endif
      /if defined(#API_QCLRDTAQ)
      //‚--- Prototype for API Clear data que                      €*/
       DCL-PR QCLRDTAQ EXTPGM( 'QCLRDTAQ' ) ;
         DTAQName   LIKE( TP_OBJECT ) CONST ;
         LibName    LIKE( TP_LIBARY ) CONST ;
       END-PR ;
      /endif
      /if defined(#API_QRCVDTAQ)
      //‚--- Prototype for API read  data que                      €*/
       DCL-PR QRCVDTAQ EXTPGM( 'QRCVDTAQ' ) ;
         DTAQName  CHAR(  10 )     CONST ;
         LibName   CHAR(  10 )     CONST ;
         DQLen     PACKED( 5 : 0 ) ;
         DQData    CHAR( 128 ) ;
         DQWait    PACKED( 5 : 0 ) CONST ;
       END-PR ;
      /endif
      /if defined(#API_QUSCRTUS)
      //‚CrtUsrSpc: Create User Space for OS/400 API's               €*/
       DCL-PR QUSCRTUS EXTPGM( 'QUSCRTUS' ) ;
         UserSpace      LIKEDS( TP_OBJLIB ) CONST ;
         ExtAttr        CHAR ( 10 ) CONST ;
         InitialSize    INT  ( NORMINT ) CONST ;
         InitialVal     CHAR (  1 ) CONST ;
         PublicAuth     CHAR ( 10 ) CONST ;
         Text           CHAR ( 50 ) CONST ;
         // ‚BLOCK 1                                                    €*/
         Replace        CHAR ( 10 ) CONST OPTIONS( *NOPASS ) ;
         ErrorCode      LIKE ( LONGCHAR ) OPTIONS( *NOPASS: *VARSIZE ) ;
       END-PR ;
      /endif
      //‚--- Prototype for API Rtv Poiter of Userspace               €*/
      /if defined(#API_QUSPTRUS)
       DCL-PR QUSPTRUS EXTPGM( 'QUSPTRUS' ) ;
         UserSpace     LIKEDS( TP_OBJLIB ) CONST ;
         UserSpacePtr  POINTER ;
       END-PR ;
       DCL-DS USPTRINF QUALIFIED TEMPLATE ;
         Filler1     CHAR ( 103 ) ;
         Status      CHAR (   1 ) ;
         Filler2     CHAR (  12 ) ;
         HdrOffset   INT  (  NORMINT ) ;
         HdrSize     INT  (  NORMINT ) ;
         ListOffset  INT  (  NORMINT ) ;
         ListSize    INT  (  NORMINT ) ;
         NumEntries  INT  (  NORMINT ) ;
         EntrySize   INT  (  NORMINT ) ;
       END-DS ;
      /endif
      /if defined(#API_QUSDLTUS)
       //‚--- Prototype for API Delete User Space                     €*/
       DCL-PR QUSDLTUS EXTPGM( 'QUSDLTUS' ) ;
         UserSpace  LIKEDS( TP_OBJLIB ) CONST ;
         ErrorCode  LIKE  ( LONGCHAR  ) OPTIONS( *VARSIZE ) ;
       END-PR ;
      /endif
      /if defined(#API_QUSRUSAT)
       //‚--- Prototype for API Retrieve User Space Attributes         €*/
       DCL-PR QUSRUSAT EXTPGM( 'QUSRUSAT' ) ;
         Receiver    LIKE(LONGCHAR) OPTIONS( *VARSIZE ) ;
         LenOfData   LIKE(BIN4)          CONST ;
         Format      LIKE(TP_FORMAT)     CONST ;
         UserSpace   LIKEDS(TP_OBJLIB)   CONST ;
         ErrorCode   LIKE(LONGCHAR) OPTIONS( *VARSIZE ) ;
       END-PR ;
       DCL-DS SPCA0100 QUALIFIED TEMPLATE ;
        Offset    LIKE( BIN4 ) ;
        Entries   LIKE( BIN4 ) ;
        EntrSize  LIKE( BIN4 ) ;
       END-DS ;
      /endif
      //‚--- Prototype for API Retrive User Space                    €*/
      /if defined(#API_QUSRTVUS)
       DCL-PR QUSRTVUS EXTPGM( 'QUSRTVUS' ) ;
         UserSpace      LIKEDS( TP_OBJLIB ) CONST ;
         StartPosition  LIKE( BIN4 ) CONST ;
         LenOfData      LIKE( BIN4 ) CONST ;
         Receiver       LIKE( LONGCHAR ) OPTIONS( *VARSIZE ) ;
         ErrorCode      LIKE( LONGCHAR ) OPTIONS( *NOPASS: *VARSIZE ) ;
       END-PR ;
       DCL-DS QUSA0100 TEMPLATE QUALIFIED ;
         Offset      LIKE(BIN4) ;
         filler      CHAR( 4 ) ;
         Entries     LIKE(BIN4) ;
         EntrieSize  LIKE(BIN4) ;
       END-DS ;
      /endif
      /if defined(#APU_QUSCHGUS)
      //‚--- Prototype for API Change User Space                     €*/
       DCL-PR QUSCHGUS EXTPGM( 'QUSCHGUS' ) ;
         UserSpace      LIKEDS( TP_OBJLIB ) CONST ;
         StartPositio   LIKE( BIN4 )        CONST ;
         LenOfData      LIKE( BIN4 )        CONST ;
         InputData      LIKE( LONGCHAR )    OPTIONS( *VARSIZE ) ;
         ErrorCode      LIKE( LONGCHAR )    OPTIONS( *NOPASS: *VARSIZE ) ;
       END-PR ;
      /endif
      /if defined(#API_QUSLJOB)
      //‚--- Prototype for API Retrieve Jobs                         €*/
       DCL-PR QUSLJOB EXTPGM( 'QUSLJOB' ) ;
         UserSpace  LIKEDS( TP_OBJLIB )   CONST            ;
         Format     LIKE  ( TP_FORMAT )   CONST            ;
         Job        LIKEDS( TP_JOB )      CONST            ;
         FldStatus  CHAR( 10  )           CONST            ;
         FldError   CHAR( 256 )           OPTIONS( *NOPASS ) ;
         JobType    CHAR( 1 )             CONST OPTIONS( *NOPASS ) ;
         NbrFldRtn  LIKE( BIN4 )          CONST OPTIONS( *NOPASS ) ;
         KeyFldRtn  LIKE( BIN4 ) DIM(100) CONST OPTIONS( *NOPASS ) ;
       END-PR ;
       DCL-DS LJOBINPUT QUALIFIED TEMPLATE ;
         Job            LIKEDS( TP_JOB ) ;
         Status         CHAR  ( 10 ) ;
         UserSpace      LIKEDS( TP_OBJLIB ) ;
         Format         LIKE  ( TP_FORMAT ) ;
         JobType        CHAR  (  1 ) ;
         Reserved01     CHAR  (  3 ) ;
         NbrOfFieldsRt  LIKE  ( BIN4 ) ;
       END-DS ;
       DCL-DS JOBL0100 QUALIFIED TEMPLATE ;
         Job           LIKEDS(TP_JOB) ;
         JobId         CHAR  ( 16 ) ;
         Status        CHAR  ( 10 ) ;
         JobType       CHAR  (  1 ) ;
         JobSubType    CHAR  (  1 ) ;
         Reserved01    CHAR  (  2 ) ;
       END-DS ;
       DCL-DS JOBL0200 QUALIFIED TEMPLATE ;
         Job           LIKEDS(TP_JOB) ;
         JobId         CHAR  ( 16 ) ;
         Status        CHAR  ( 10 ) ;
         JobType       CHAR  (  1 ) ;
         JobSubType    CHAR  (  1 ) ;
         Reserved01    CHAR  (  2 ) ;
         JobInfoStatus CHAR  (  1 ) ;
         Reserved02    CHAR  (  3 ) ;
         NbrOfFldRt    LIKE  ( BIN4 ) ;
         ReturnedData  LIKE  ( LONGCHAR ) ;
       END-DS ;
      /endif
      /if defined(#API_QUSLSPL)
       //‚--- Prototype for API   List spooled files                  €*/
       DCL-PR QUSLSPL EXTPGM( 'QUSLSPL' ) ;
         UserSpace     LIKEDS( TP_OBJLIB   ) CONST ;
         Format        LIKE  ( TP_FORMAT   ) CONST ;
         UserName      LIKE  ( TP_USERNAME ) CONST ;
         QualOutQ      LIKE  ( TP_OBJLIB   ) CONST ;
         FormType      CHAR  (  10 ) CONST ;
         UserData      CHAR  (  10 ) CONST ;
         ErrorCode     LIKE  ( LONGCHAR )   OPTIONS( *NOPASS: *VARSIZE ) ;
         Job           LIKEDS( TP_JOB )     OPTIONS( *NOPASS ) ;
         FieldKeys     INT   ( NORMINT )    OPTIONS( *NOPASS: *VARSIZE)
                                            DIM( 9999 ) ;
         NumFields     INT   ( NORMINT )    OPTIONS( *NOPASS ) CONST ;
         AuxStgPool    INT   ( NORMINT )    OPTIONS( *NOPASS ) CONST ;
         JobSysName    LIKE  ( TP_JOBNAME ) OPTIONS( *NOPASS ) CONST ;
         StartCrtDate  CHAR  (  7 )         OPTIONS( *NOPASS ) CONST ;
         StartCrtTime  CHAR  (  6 )         OPTIONS( *NOPASS ) CONST ;
         EndCrtDate    CHAR  (  7 )         OPTIONS( *NOPASS ) CONST ;
         EndCrtTime    CHAR  (  6 )         OPTIONS( *NOPASS ) CONST ;
       END-PR ;

       DCL-DS SPLF0300 QUALIFIED TEMPLATE ;
         Job          LIKEDS( TP_JOB ) ;
         SplfName     CHAR  ( 10 ) ;
         SplfNbr      INT   ( NORMINT ) ;
         SplfStatus   INT   ( NORMINT ) ;
         OpenDate     CHAR  (  7 ) ;
         OpenTime     CHAR  (  6 ) ;
         Schedule     CHAR  (  1 ) ;
         SysName      CHAR  ( 10 ) ;
         UserData     CHAR  ( 10 ) ;
         FormType     CHAR  ( 10 ) ;
         OutQueue     CHAR  ( 10 ) ;
         OutQueueLib  CHAR  ( 10 ) ;
         AuxPool      INT   ( NORMINT ) ;
         SplfSize     INT   ( NORMINT ) ;
         SizeMult     INT   ( NORMINT ) ;
         TotalPages   INT   ( NORMINT ) ;
         CopiesLeft   INT   ( NORMINT ) ;
         Priority     CHAR  (  1 ) ;
         Reserved     CHAR  (  3 ) ;
       END-DS ;

       // status
       DCL-C SPOOLREADY     1 ;
       DCL-C SPOOLOPENED    2 ;
       DCL-C SPOOLCLOSED    3 ;
       DCL-C SPOOLSAVED     4 ;
       DCL-C SPOOLWRITING   5 ;
       DCL-C SPOOLHELD      6 ;
       DCL-C SPOOLMSGW      7 ;
       DCL-C SPOOLPENDING   8 ;
       DCL-C SPOOLPRINTING  9 ;
       DCL-C SPOOLFINISHED 10 ;
       DCL-C SPOOLSENDING  11 ;
       DCL-C SPOOLDEFERRED 12 ;
      /endif
      /if defined(#API_QUSRJOBI)
      //‚--- Prototype for API Retrieve Job Information              €*/
       DCL-PR QUSRJOBI EXTPGM( 'QUSRJOBI' ) ;
         Receiver     LIKE   ( LONGCHAR )  OPTIONS( *VARSIZE ) ;
         LenReceiver  INT    ( NORMINT )   CONST ;
         FormatName   LIKE   ( TP_FORMAT ) CONST ;
         Job          LIKEDS ( TP_JOB )    CONST ;
         JobId        CHAR   ( 16 )        CONST ;
         ErrorCode    LIKE   ( LONGCHAR )  OPTIONS( *NOPASS: *VARSIZE ) ;
       END-PR ;
       DCL-DS JOBI0200 QUALIFIED TEMPLATE ;
         Offset                LIKE  ( BIN4 ) ;                           //    Bytes Return
         Entries               LIKE  ( BIN4 ) ;                           //    Bytes Avail
         Job                   LIKEDS( TP_JOB ) ;
         JobId                 CHAR  (  16 ) ;                            //    Int Job ID
         JobStatus             CHAR  (  10 ) ;                            //    Job Status
         JobType               CHAR  (   1 ) ;                            //    Job Type
         JobSubType            CHAR  (   1 ) ;                            //    Job Subtype
         Subsystem             CHAR  (  10 ) ;                            //    Subsys Name
         RunPriority           LIKE  ( BIN4 ) ;                           //    Run Priority
         SystemPool            LIKE  ( BIN4 ) ;                           //    System Pool ID
         CPUUsed               LIKE  ( BIN4 ) ;                           //    CPU Used
         AUXIORequest          LIKE  ( BIN4 ) ;                           //    Aux IO Request
         InteractTrans         LIKE  ( BIN4 ) ;                           //    Interact Trans
         ResponseTime          LIKE  ( BIN4 ) ;                           //    Response Time
         FunctionType          CHAR  (   1  ) ;                           //    Function Type
         FunctionName          CHAR  (  10  ) ;                           //    Function Name
         ActiveJobStat         CHAR  (   4  ) ;                           //    Active Job Stat
         NumDBaseLckWts        LIKE  ( BIN4 ) ;                           //    Num DBase Lock Wts
         NumIntlMchLck         LIKE  ( BIN4 ) ;                           //    Num Internal Mch Lck
         NumNonDBasLckW        LIKE  ( BIN4 ) ;                           //    Num Non DBase Lock W
         WaitTimDBasLck        LIKE  ( BIN4 ) ;                           //    Wait Time DBase Lock
         WaitTimIntM           LIKE  ( BIN4 ) ;                           //    Wait Time Internal M
         WaitTimNonDBas        LIKE  ( BIN4 ) ;                           //    Wait Time Non DBase
         QUSERVED45            CHAR  (   1  ) ;                           //    Reserved
         CurSystemPool         LIKE  ( BIN4 ) ;                           //    Current System Pool
         ThreadCount           LIKE  ( BIN4 ) ;                           //    Thread Count
       END-DS ;
      /endif
       DCL-DS QUSEC TEMPLATE QUALIFIED ;
         BytesProvided  INT ( NORMINT ) ;
         BytesAvailble  INT ( NORMINT ) ;
         MessageId      CHAR(   7 ) ;
         Reserved       CHAR(   1 ) ;
         MessageData    CHAR( 240 ) ;
       END-DS ;
      //‚*****************C API*********************************** €*/
      //‚--- Prototype for API Qsort                               €*/
      /if defined(#API_QSORT)
      /define #CONST
       DCL-PR qsort EXTPROC( 'qsort' ) ;
         PtrOfArray     POINTER        VALUE ;
         NbrOfElements  INT ( NORMINT ) VALUE ;
         ElementSize    INT ( NORMINT ) VALUE ;
         PtrOfCompPrc   POINTER(*PROC) VALUE ;
       END-PR ;
      /endif
      //‚--- Prototype for API Bsearch                             €*/
      /if defined(#API_BSEARCH)
      /define #CONST
       DCL-PR bsearch POINTER EXTPROC( 'bsearch' ) ;
         searchArgumnt  POINTER VALUE ;
         PtrOfArray     POINTER VALUE ;
         NbrOfElements  INT ( NORMINT ) VALUE ;
         ElementSize    INT ( NORMINT ) VALUE ;
         PtrOfCompPrc   POINTER(*PROC) VALUE ;
       END-PR ;
      /endif
      /if defined(#CONST)
      /undefine #CONST
       DCL-C HIGH  1 ;
       DCL-C EQUAL 0 ;
       DCL-C LOW  -1 ;
      /endif
      /if defined(#API_ICONV)
      //‚--- Prototype/templates for API Iconv                        €*/
       DCL-DS tp_iconv QUALIFIED TEMPLATE ;
         return_value INT ( NORMINT ) ;
         cd           INT ( NORMINT ) DIM( 12 ) ;
       END-DS ;
       DCL-DS QtqCode QUALIFIED TEMPLATE ;
         CCSID        INT  ( NORMINT ) ;
         ConvAlt      INT  ( NORMINT ) ;
         SubsAlt      INT  ( NORMINT ) ;
         ShiftAlt     INT  ( NORMINT ) ;
         InpLenOp     INT  ( NORMINT ) ;
         ErrorOpt     INT  ( NORMINT ) ;
         Reserved     CHAR (  8 ) INZ ( *ALLx'00' ) ;
       END-DS ;
       DCL-DS iconv_code QUALIFIED TEMPLATE ;
         owner        CHAR (  8 ) INZ ( 'IBMCCSID' ) ;
         CCSID        CHAR (  5 ) INZ ( '00000' ) ;
         ConvAlt      CHAR (  3 ) INZ ( '000' )   ;
         SubsAlt      CHAR (  1 ) INZ ( '0' )     ;
         ShiftAlt     CHAR (  1 ) INZ ( '0' )     ;
         InpLenOpt    CHAR (  1 ) INZ ( '0' )     ;
         ErrorOpt     CHAR (  1 ) INZ ( '0' )     ;
         ReservedFrom CHAR ( 12 ) INZ ( *ALLx'00' ) ;

       END-DS ;
       DCL-PR QtqIconvOpen LIKE( iconv ) EXTPROC( 'QtqIconvOpen' ) ;
         toCode    LIKEDS( QtqCode ) CONST ;
         fromCode  LIKEDS( QtqCode ) CONST ;
       END-PR ;
       DCL-PR iconv_open LIKE( tp_iconv ) EXTPROC('iconv_open') ;
         toCode    LIKE( iconv_code ) CONST ;
         fromCode  LIKE( iconv_code ) CONST ;
       END-PR ;
       DCL-PR iconv UNS ( NORMINT )  ;
         cd            LIKE ( tp_iconv ) VALUE ;
         inbuf         POINTER             const ;
         inbytesleft   UNS  ( NORMINT )    const ;
         outbuf        POINTER             const ;
         outbytesleft  UNS  ( NORMINT )    const ;
       END-PR ;
       DCL-PR QlgTransformUCSData UNS ( NORMINT )
                                  EXTPROC('QlgTransformUCSData') ;
         xformtype        INT ( NORMINT ) VALUE ;
         inbuf            POINTER ;
         inbytesleft      UNS ( NORMINT ) ;
         outbuf           POINTER ;
         outbytesleft     UNS ( NORMINT ) ;
         outspacereq      UNS ( NORMINT ) ;
       END-PR ;

       DCL-C ICONV_FAIL  4294967295 ;
       DCL-PR iconv_close  INT ( NORMINT ) EXTPROC( 'iconv_close' ) ;
         cd   LIKE( tp_iconv ) VALUE ;
       END-PR ;
      /endif
      /if defined(#API_REGEX)
      //‚--- errors returned                                          €*/
       DCL-C REG_NOMATCH  1  ;
       DCL-C REG_BADPAT   2  ;
       DCL-C REG_ECOLLATE 3  ;
       DCL-C REG_ECTYPE   4  ;
       DCL-C REG_EESCAPE  5  ;
       DCL-C REG_ESUBREG  6  ;
       DCL-C REG_EBRACK   7  ;
       DCL-C REG_EPAREN   8  ;
       DCL-C REG_EBRACE   9  ;
       DCL-C REG_BADBR    10 ;
       DCL-C REG_ERANGE   11 ;
       DCL-C REG_ESPACE   12 ;
       DCL-C REG_BADRPT   13 ;
       DCL-C REG_ECHAR    14 ;
       DCL-C REG_EBOL     15 ;
       DCL-C REG_EEOL     16 ;
       DCL-C REG_ECOMP    17 ;
       DCL-C REG_EEXEC    18 ;

       DCL-C REG_SUBEXP_MAX 10 ;

       //‚--- template datastruct for regex                          €*/
       DCL-DS regex QUALIFIED ALIGN TEMPLATE ;
         re_nsub     INT ( NORMINT ) ;
         re_comp     POINTER   ;
         re_cflags   INT ( NORMINT ) ;
         re_erroff   INT ( NORMINT ) ;
         re_len      INT ( NORMINT ) ;
         re_ucoll    INT ( NORMINT ) DIM(2) ;
         re_lsub     POINTER DIM(REG_SUBEXP_MAX) ;
         re_esub     POINTER DIM(REG_SUBEXP_MAX) ;
         re_map      CHAR ( 256 ) ;
         re_shift    INT( SMALLINT ) ;
         re_dbcs     INT( SMALLINT ) ;
       END-DS ;

       //‚--- template datastruct for regmatch                       €*/
       DCL-DS regmatch QUALIFIED ALIGN TEMPLATE ;
         rm_so   INT ( NORMINT ) ;
         rm_ss   INT ( SMALLINT ) ;
         rm_eo   INT ( NORMINT ) ;
         rm_es   INT ( SMALLINT ) ;
       END-DS ;

       DCL-PR regcomp INT( 10 ) EXTPROC( 'regcomp' ) ;
         preg     LIKE(regex) ;
         pattern  POINTER OPTIONS(*STRING) VALUE ;
         cflags   INT ( NORMINT ) VALUE ;
       END-PR ;
       //‚--- cflags for regcomp()                                     €*/
       DCL-C REG_BASIC     0  ;
       DCL-C REG_EXTENDED  1  ;
       DCL-C REG_ICASE     2  ;
       DCL-C REG_NEWLINE   4  ;
       DCL-C REG_NOSUB     8  ;

       DCL-PR regexec INT ( NORMINT ) EXTPROC( 'regexec' ) ;
         preg    LIKE ( regex ) CONST ;
         string  POINTER OPTIONS(*string) VALUE ;
         nmatch  UNS ( NORMINT )  VALUE ;
         pmatch  LIKE ( regmatch ) DIM( 100 ) OPTIONS( *VARSIZE: *OMIT ) ;
         eflags  INT (  NORMINT  ) VALUE ;
       END-PR ;
       //‚--- eflags for regexec()                                     €*/
       DCL-C REG_NOTBOL 256 ;
       DCL-C REG_NOTEOL 512 ;

       DCL-PR regerror UNS ( NORMINT ) EXTPROC( 'regerror' ) ;
         errcode      INT ( NORMINT ) VALUE ;
         preg         LIKE( regex ) CONST ;
         errbuf       POINTER VALUE ;
         errbuf_size  INT ( NORMINT )  VALUE ;
       END-PR ;
       DCL-PR regfree EXTPROC( 'regfree' ) ;
         preg  LIKE( regex ) ;
       END-PR ;

      /endif
      /if defined(#API_IFSFILE)

      //‚--- Prototype for API to open                             €*/
       DCL-PR opend INT ( NORMINT )   EXTPROC( 'open' ) ;
         path      POINTER OPTIONS(*STRING) VALUE ;
         oflag     INT ( NORMINT )  VALUE ;
         mode      UNS ( NORMINT ) VALUE OPTIONS( *NOPASS ) ;
         codepage  UNS ( NORMINT ) VALUE OPTIONS( *NOPASS ) ;
       END-PR ;
      //‚--- oflag constants                                       €*/
       DCL-C O_RDONLY    1        ;
       DCL-C O_TEXTDATA  16777216 ;
       DCL-C O_WRONLY    2        ;
       DCL-C O_CREAT     8        ;
       DCL-C O_TRUNC     64       ;

      //‚--- mode  constants                                       €*/
       DCL-C RW      6  ;
       DCL-C R       4  ;
       DCL-C OWNER   64 ;
       DCL-C GROUP   8  ;

      //‚--- Prototype for API read  File  in IFS                  €*/
       DCL-PR readd INT ( NORMINT )  EXTPROC( 'read' ) ;
         fildes  INT ( NORMINT ) VALUE ;
         buf     POINTER    VALUE ;
         nbyte   UNS ( NORMINT ) VALUE ;
       END-PR ;
      //‚--- Prototype for API write File  in IFS                  €*/
       DCL-PR writed INT ( NORMINT )  EXTPROC( 'write' ) ;
         fildes  INT ( NORMINT )  VALUE ;
         buf     POINTER    VALUE ;
         nbyte   UNS ( NORMINT ) VALUE ;
       END-PR ;

       //‚--- Prototype for API close File  in IFS                  €*/
       DCL-PR closed INT ( NORMINT )  EXTPROC( 'close' ) ;
         fildes  INT ( NORMINT ) VALUE ;
       END-PR ;

       DCL-PR unlink INT ( NORMINT )  EXTPROC( 'unlink' ) ;
         path  POINTER VALUE OPTIONS( *STRING ) ;
       END-PR ;
      /endif
      /if defined(#API_SLEEP)
       //‚--- Prototype for API to sleep                            €*/
       DCL-PR sleep INT ( NORMINT )  EXTPROC( 'sleep' ) ;
         seconds UNS ( NORMINT ) VALUE ;
       END-PR ;
      /endif
      /if defined(#API_PRINTF)
       DCL-PR printf INT ( NORMINT ) EXTPROC( 'printf' ) ;
         format  POINTER VALUE OPTIONS( *STRING ) ;
         arg1    INT ( NORMINT ) VALUE OPTIONS ( *NOPASS );
         arg2    INT ( NORMINT ) VALUE OPTIONS ( *NOPASS );
       END-PR ;
      /endif

      /if defined(#API_GETPATHFILEID)
       DCL-PR GetPathFileID CHAR ( 1 ) extproc('Qp0lGetPathFromFileID') ;
         outPathName  CHAR ( 256 ) ;
         inPathSize   UNS  ( NORMINT ) VALUE ;
         inFileId     CHAR ( 16 ) CONST ;
       END-PR ;
      /endif

      /if defined(#API_SYSTEM)
       //‚--- Prototype for API System                              €*/
       DCL-PR system INT ( NORMINT ) EXTPROC( 'system' ) ;
           string POINTER VALUE OPTIONS( *STRING ) ;
       END-PR ;
       DCL-S cpfmsg  CHAR ( 7 )  IMPORT('_EXCP_MSGID') ;
      /endif
      /if defined(#API_QSH)
       //‚--- Prototype for API System                              €*/
       DCL-PR qsh  INT ( NORMINT ) EXTPROC( 'QzshSystem' ) ;
           string POINTER VALUE OPTIONS( *STRING ) ;
       END-PR ;
      /endif
      /if defined(#API_CEERAN0)
       //‚--- Prototype for API Randomnumber                        €*/
       DCL-PR CEERAN0 EXTPROC( 'CEERAN0' ) ;
         Seed       INT ( NORMINT )  ;
         RandomNum  FLOAT ( 4 ) ;
         fc         CHAR ( 12 ) OPTIONS ( *OMIT ) ;
       END-PR ;
      /endif
      /endif
