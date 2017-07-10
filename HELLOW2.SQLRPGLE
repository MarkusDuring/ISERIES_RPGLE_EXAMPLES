     **FREE
       // ansicon.exe plink.exe -ssh DURING@LS01PROD
       // compile.sh HELLOW2.SQLRPGLE DURING/HELLOW2

       // declares main procedure of PGM

       CTL-OPT MAIN(HELLOW2) ;
       // external definition sources
      /define #IFS
      /define #API_PRINTF
      /include #HSPECV7R1.SQLRPGLE
      /include #DATATV7R1.SQLRPGLE
      /include #CONSTV7R1.SQLRPGLE
      /include #APIV7R1.SQLRPGLE  
       // definition of variable/datastruct as Template


       // Mainprocedure :
       DCL-PROC HELLOW2 ;
          DCL-PI *N EXTPGM ;
          END-PI ;
          PRINTF('Hello World') ;
          return ;
       END-PROC ;