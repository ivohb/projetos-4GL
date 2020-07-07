
DEFINE l_resto  DECIMAL(10,2)

MAIN
   
   LET l_resto = 2016 MOD 4
   CALL log0030_mensagem(l_resto,'info')

END MAIN
