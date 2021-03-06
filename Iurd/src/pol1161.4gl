#-------------------------------------------------------------------#
# SISTEMA.: GEN�RICO                                                #
# PROGRAMA: POL1161.4GL                                             #
# OBJETIVO: FUN��ES DIVERSAS                                        #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 19/12/2005                                              #
#-------------------------------------------------------------------#
#-------------------------------------------------------------------#
          
DATABASE logix #para colocar dentro do fonte, comente essa linha e
               #defina as vari�veis abaixo dentro do GLOBALS de seu fonte
GLOBALS

    # retornos da fun��o - o objetivo � dividir o texto em at�
    # 15 linhas com no minimo 20 e no m�ximo 200 caracteres
    
   DEFINE r_01 VARCHAR(200),
          r_02 VARCHAR(200),
          r_03 VARCHAR(200),
          r_04 VARCHAR(200),
          r_05 VARCHAR(200),
          r_06 VARCHAR(200),
          r_07 VARCHAR(200),
          r_08 VARCHAR(200),
          r_09 VARCHAR(200),
          r_10 VARCHAR(200),
          r_11 VARCHAR(200),
          r_12 VARCHAR(200),
          r_13 VARCHAR(200),
          r_14 VARCHAR(200),
          r_15 VARCHAR(200)
          
    
    # par�metros recebidos #
          
   DEFINE texto      VARCHAR(3000),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)

   DEFINE num_carac  SMALLINT,
          ret        VARCHAR(200)
          
END GLOBALS

MAIN
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

END MAIN

#----------------------------------------------------------------------#
#CALL pol1161_quebrar_texto(p_texto,p_tamanho,p_qtd_linha,p_justifica) #
#           RETURNING p_retorno_1,p_retorno_2,...,p_retorno_n          #
#                                                                      #
# p_texto: texto a ser quebrado em linhas                              #
# p_tamanho: tamanho de cada linha                                     #
# p_qtd_linha: quantidade de linhas a ser�o retornadas                 #
# p_justifica: se deve ou n�o justificar o resultado                   #
#----------------------------------------------------------------------#

#----------------------------------------#
 FUNCTION pol1161_quebrar_texto(parametro)
#----------------------------------------#

   DEFINE parametro  RECORD 
          texto      VARCHAR(3000),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)
   END RECORD
         
   LET texto      = parametro.texto CLIPPED
   LET tam_linha  = parametro.tam_linha
   LET qtd_linha  = parametro.qtd_linha
   LET justificar = parametro.justificar
   
   CALL pol1161_limpa_retorno()
   
   IF NOT pol1161_checa_parametros() THEN
      LET r_01 = 'ERRO ENVIO PARAMETRO'
   ELSE
      CALL pol1161_separa_texto()
   END IF
   
   CASE qtd_linha

      WHEN  1 RETURN r_01
      WHEN  2 RETURN r_01,r_02
      WHEN  3 RETURN r_01,r_02,r_03
      WHEN  4 RETURN r_01,r_02,r_03,r_04
      WHEN  5 RETURN r_01,r_02,r_03,r_04,r_05
      WHEN  6 RETURN r_01,r_02,r_03,r_04,r_05,r_06
      WHEN  7 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07
      WHEN  8 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08
      WHEN  9 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09
      WHEN 10 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10
      WHEN 11 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11
      WHEN 12 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12
      WHEN 13 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13
      WHEN 14 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13,r_14
      WHEN 15 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13,r_14,r_15

   END CASE
   
   
END FUNCTION 


#--------------------------------#
 FUNCTION pol1161_limpa_retorno()#
#--------------------------------#

   INITIALIZE r_01, r_02, r_03, r_04, r_05, r_06, r_07, r_08, r_09, r_10,
              r_11, r_12, r_13, r_14, r_15 TO NULL 
              
END FUNCTION

#-----------------------------------#
 FUNCTION pol1161_checa_parametros()#
#-----------------------------------#

   IF texto IS NULL THEN
      RETURN FALSE
   END IF
   
   IF tam_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF tam_linha < 20 OR tam_linha > 200 THEN
         RETURN FALSE
      END IF 
   END IF

   IF qtd_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF qtd_linha < 1 OR qtd_linha > 15 THEN
         RETURN FALSE
      END IF 
   END IF

   IF justificar IS NULL THEN
      RETURN FALSE
   ELSE
      IF justificar <> 'S' AND justificar <> 'N' THEN
         RETURN FALSE
      END IF 
   END IF
   
   RETURN TRUE

END FUNCTION


#------------------------------#
 FUNCTION pol1161_separa_texto()
#------------------------------#
          
   LET r_01 = pol1161_quebra_texto()
   LET r_02 = pol1161_quebra_texto()
   LET r_03 = pol1161_quebra_texto()
   LET r_04 = pol1161_quebra_texto()
   LET r_05 = pol1161_quebra_texto()
   LET r_06 = pol1161_quebra_texto()
   LET r_07 = pol1161_quebra_texto()
   LET r_08 = pol1161_quebra_texto()
   LET r_09 = pol1161_quebra_texto()
   LET r_10 = pol1161_quebra_texto()
   LET r_11 = pol1161_quebra_texto()
   LET r_12 = pol1161_quebra_texto()
   LET r_13 = pol1161_quebra_texto()
   LET r_14 = pol1161_quebra_texto()
   LET r_15 = pol1161_quebra_texto()
      
              
END FUNCTION

#-----------------------------#
FUNCTION pol1161_quebra_texto()
#-----------------------------#

   DEFINE ind SMALLINT

   LET ret = ''

   LET texto = texto CLIPPED
   LET num_carac = LENGTH(texto)
   IF num_carac = 0 THEN
      RETURN ''
   END IF
   
   IF num_carac <= tam_linha THEN
      LET ret = texto CLIPPED
      INITIALIZE texto TO NULL
      RETURN(ret)
   END IF
   
   FOR ind = tam_linha+1 TO 1 step -1
      IF texto[ind] = ' ' THEN
         LET ret = texto[1,ind-1]
         LET texto = texto[ind+1,num_carac]
         EXIT FOR
      END IF
   END FOR 

   LET ret = ret CLIPPED

   IF LENGTH(ret) > 1 THEN
      IF justificar = 'S' THEN
         IF LENGTH(ret) < tam_linha THEN
            CALL pol1161_justifica()
         END IF
      END IF 
   END IF

  RETURN(ret)
   
END FUNCTION

#--------------------------#
FUNCTION pol1161_justifica()
#--------------------------#

   DEFINE ind, y, p_branco, p_tam, p_tem_branco SMALLINT
   DEFINE p_tex VARCHAR(200)
   
   LET y = 1
   LET p_branco = tam_linha - LENGTH(ret)

   WHILE p_branco > 0   
      LET p_tam = LENGTH(ret)
      LET p_tem_branco = FALSE
      FOR ind = y TO p_tam
         IF ret[ind] = ' ' THEN
            LET p_tem_branco = TRUE
            LET p_tex = ret[1,ind],' ',ret[ind+1,p_tam]
            LET p_branco = p_branco - 1
            LET ret = p_tex
            LET y = ind + 2
            WHILE ret[y] = ' '
               LET y = y + 1
            END WHILE
            IF y >= LENGTH(ret) THEN
               LET y = 1
            END IF
            EXIT FOR
         END IF
      END FOR
      IF NOT p_tem_branco THEN
         LET y = 1
      END IF
   END WHILE 
      
END FUNCTION

#----------------------------------------#
 FUNCTION pol1161_grava_auadit(parametro)#
#----------------------------------------#

   DEFINE parametro     RECORD
          cod_empresa   LIKE audit_logix.cod_empresa,
          texto         LIKE audit_logix.texto,
          num_programa  LIKE audit_logix.num_programa,
          usuario       LIKE audit_logix.usuario
   END RECORD
   
   DEFINE p_dat_proces  DATE,
          p_hor_proces  CHAR(08)

   LET p_dat_proces = TODAY
   LET p_hor_proces = TIME
   
   INSERT INTO audit_logix
    VALUES(parametro.cod_empresa,
           parametro.texto,
           parametro.num_programa,
           p_dat_proces,
           p_hor_proces,
           parametro.usuario)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_logix')
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION
              
    
#--------------------------------------#
FUNCTION pol1161_versao_prg(p_ver_prog)#
#--------------------------------------#
   
   DEFINE p_ver_prog      CHAR(18),
          p_dat_alteracao DATE
          
   DEFINE p_programa RECORD
      nom_programa   CHAR(08),
      ver_programa   CHAR(09)
   END RECORD
   
   LET p_programa.nom_programa = UPSHIFT(p_ver_prog[1,7])     
   LET p_programa.ver_programa = p_ver_prog[9,18]     
   
   SELECT num_versao
     FROM log_versao_prg
    WHERE num_programa = p_programa.nom_programa

   IF STATUS = 100 THEN
      LET p_dat_alteracao = TODAY
      INSERT INTO log_versao_prg(
         num_programa,
         num_versao,
         dat_alteracao)
      VALUES(p_programa.nom_programa,
             p_programa.ver_programa,
             p_dat_alteracao)
   ELSE
      UPDATE log_versao_prg
         SET num_versao = p_programa.ver_programa
       WHERE num_programa = p_programa.nom_programa
   END IF

   RETURN TRUE

END FUNCTION
             
 