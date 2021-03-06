#---------------------------------------------------------------#
#-------Objetivo: func�es diversas                --------------#
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE g_msg               CHAR(150),
          g_tipo_sgbd         CHAR(003)
END GLOBALS

DEFINE m_cod_empresa          CHAR(02),
       m_qtd_dias             INTEGER,
       m_dat_ini              DATE,
       m_dat_fim              DATE,
       m_erro                 CHAR(10),
       m_dia_util             SMALLINT,
       m_msg                  CHAR(150)

#--------------------par�metros--------------------#
#Campos dos records abaixo                         #
#--------------------retorno-----------------------#
# dias uteis do periodo                            #
# se ocorrer erro, a mensaem correspontente ficar� #
# armazenada na vari�vel m_msg a qual ser� retor-  #
# juntamente com a quantidade de dias uteis        #
#--------------------------------------------------# 
FUNCTION func023_calc_dias(lr_param)               #
#--------------------------------------------------# 

   DEFINE lr_param               RECORD
          cod_empresa            CHAR(02),
          dat_proces             DATE,
          dat_abertura           DATE,
          dat_ship               DATE
   END RECORD
   
   LET m_cod_empresa = lr_param.cod_empresa
   LET m_dat_ini = lr_param.dat_proces
            
   IF lr_param.dat_ship IS NULL THEN
      LET m_dat_fim = lr_param.dat_abertura
   ELSE
      IF lr_param.dat_ship < lr_param.dat_abertura THEN
         LET m_dat_fim = lr_param.dat_abertura
      ELSE
         LET m_dat_fim = lr_param.dat_ship
      END IF
   END IF
   
   LET m_msg = NULL
   
   CALL func023_calc_dia_util() 
   
   IF m_msg IS NOT NULL THEN
      LET m_qtd_dias = -1
   END IF
   
   RETURN m_qtd_dias, m_msg

END FUNCTION   
   
#-------------------------------#      
FUNCTION func023_calc_dia_util()#
#-------------------------------#
   
   LET m_qtd_dias = 0
   
   WHILE m_dat_ini <= m_dat_fim
      
      IF NOT func023_checa_dia(m_dat_ini) THEN
         RETURN 
      END IF
      
      IF m_dia_util THEN
         LET m_qtd_dias = m_qtd_dias + 1
      END IF
      
      LET m_dat_ini = m_dat_ini + 1              
   
   END WHILE
   
END FUNCTION

#---------------------------------#
FUNCTION func023_checa_dia(l_data)#
#---------------------------------#

   DEFINE l_data        DATE,
          l_dia         INTEGER,
          l_ies_situa   CHAR(01)
   
   LET m_dia_util = FALSE
   LET l_dia = WEEKDAY(l_data) 

   SELECT ies_situa 
     INTO l_ies_situa
     FROM semana
    WHERE cod_empresa = m_cod_empresa
      AND ies_dia_semana = l_dia

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ', m_erro CLIPPED, ' lendo a tabela semana '      
      RETURN FALSE
   END IF
   
   IF l_ies_situa = '3' THEN
      RETURN TRUE
   END IF

   SELECT ies_situa 
     INTO l_ies_situa
     FROM feriado
    WHERE cod_empresa = m_cod_empresa
      AND dat_ref = l_data

   IF STATUS = 100 THEN
      LET m_dia_util = TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ', m_erro CLIPPED,' lendo a tabela feriado '    
         RETURN FALSE
      ELSE
         IF l_ies_situa = '3' THEN
         ELSE
            LET m_dia_util = TRUE
         END IF
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
