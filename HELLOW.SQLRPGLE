     **FREE
       // ansicon.exe plink.exe -ssh DURING@LS01PROD
       // compile.sh HELLOW.SQLRPGLE DURING/HELLOW

       // declares main procedure of PGM
       CTL-OPT MAIN(HELLOW) ;
       // external definition sources

       // definition of variable/datastruct as Template


       // Mainprocedure :
       DCL-PROC HELLOW ;
          DCL-PI *N EXTPGM ;
          END-PI ;
          DSPLY 'Hello World' ;
          return ;
       END-PROC ;