      /if not defined(#DATATYPES)
      /define #DATATYPES
       DCL-S BOOL          IND TEMPLATE ;
       DCL-C TRUE          *on  ;
       DCL-C FALSE         *off ;
       DCL-C FLOAT         4  ;
       DCL-C DOUBLE        8  ;
       DCL-C TINYINT       3  ;
       DCL-C SMALLINT      5  ;
       DCL-C NORMINT      10  ;
       DCL-C BIGINT       20  ;
       // Hier wird mit absicht nicht der Datentyp "b" benutzt da dieser nicht performant ist
       //  und auch kein echter Binärer datentyp
       DCL-S BIN1      INT( TINYINT  )   TEMPLATE ;
       DCL-S BIN2      INT( SMALLINT )   TEMPLATE ;
       DCL-S BIN4      INT( NORMINT  )   TEMPLATE ;
       DCL-S BIN8      INT( BIGINT   )   TEMPLATE ;
       DCL-S UBIN1     UNS( TINYINT  )   TEMPLATE ;
       DCL-S UBIN2     UNS( SMALLINT )   TEMPLATE ;
       DCL-S UBIN4     UNS( NORMINT  )   TEMPLATE ;
       DCL-S UBIN8     UNS( BIGINT   )   TEMPLATE ;
       DCL-S LONGCHAR  CHAR( 32766 )     TEMPLATE ;
       DCL-S TP_OBJECT CHAR( 10 )        TEMPLATE ;
       DCL-S TP_LIBARY CHAR( 10 )        TEMPLATE ;
       DCL-DS TP_OBJLIB TEMPLATE QUALIFIED ;
          OBJECT  LIKE(TP_OBJECT) ;
          LIBARY  LIKE(TP_LIBARY) ;
       END-DS ;
       DCL-S TP_USERNAME  CHAR( 10 ) TEMPLATE ;
       DCL-S TP_JOBNAME   CHAR( 10 ) TEMPLATE ;
       DCL-S TP_JOBNUMBER CHAR(  6 ) TEMPLATE ;
       DCL-S TP_FORMAT    CHAR(  8 ) TEMPLATE ;
       DCL-DS TP_JOB      TEMPLATE QUALIFIED ;
          JOBNAME      LIKE(TP_JOBNAME)  ;
          USERNAME     LIKE(TP_USERNAME) ;
          JOBNUMBER    LIKE(TP_JOBNUMBER);
       END-DS ;
      /endif
