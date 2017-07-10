      /if not defined(#DFTHSPEC)
      /define #DFTHSPEC
      /if defined(*CRTBNDRPG)
       CTL-OPT dftactgrp( *no ) ;
       CTL-OPT actgrp( *caller ) ;
      /endif
       CTL-OPT option(*SRCSTMT :*NODEBUGIO) ;
       CTL-OPT CCSID(*CHAR:*JOBRUN)         ;
      /endif
