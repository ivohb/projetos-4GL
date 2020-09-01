
#----------------------------------------------------------------------#
#-----------Objetivo: separar um texto em n pedaços--------------------#
#------------------------formato da chamada----------------------------#
# CALL func001_quebrar_texto(p_texto,p_tamanho,p_qtd_linha,p_justifica)#
#           RETURNING p_retorno_1,p_retorno_2,...,p_retorno_n          #
#                                                                      #
# p_texto: texto a ser quebrado em linhas (tamanho máximo 3000 digitos)#
# p_tamanho: tamanho de cada linha (tamanho máximo 200 digitos)        #
# p_qtd_linha: quantidade de linhas a ser retornada (15 no máximo)     #
# p_justifica: se deve ou não justificar o resultado                   #
#---------------------------Retorno------------------------------------#
# o texto separado em até 15 pedaços com até 200 caracteres cada       #
#----------------------------------------------------------------------#

#--retornos do programa--#
  
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
          
    
#--parâmetros recebidos--#
          
DEFINE texto        VARCHAR(4000),
       tam_linha    SMALLINT,
       qtd_linha    SMALLINT,
       justificar   CHAR(01)

#--variáveis auxiliares--#

DEFINE num_carac    SMALLINT,
       ret          VARCHAR(200),
       p_ind        INTEGER

#----------------------------------------#
 FUNCTION func001_quebrar_texto(parametro)
#----------------------------------------#

   DEFINE parametro  RECORD 
          texto      VARCHAR(4000),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)
   END RECORD
         
   LET texto      = parametro.texto CLIPPED
   LET tam_linha  = parametro.tam_linha
   LET qtd_linha  = parametro.qtd_linha
   LET justificar = parametro.justificar
   
   CALL func001_limpa_retorno()
   
   IF NOT func001_checa_parametros() THEN
      LET r_01 = 'ERRO ENVIO PARAMETRO'
   ELSE
      CALL func001_separa_texto()
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
 FUNCTION func001_limpa_retorno()#
#--------------------------------#

   INITIALIZE r_01, r_02, r_03, r_04, r_05, r_06, r_07, r_08, r_09, r_10,
              r_11, r_12, r_13, r_14, r_15 TO NULL 
              
END FUNCTION

#-----------------------------------#
 FUNCTION func001_checa_parametros()#
#-----------------------------------#

   IF texto IS NULL THEN
      RETURN FALSE
   END IF
   
   IF tam_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF tam_linha < 20 OR tam_linha > 200 OR tam_linha < LENGTH(texto) THEN
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
 FUNCTION func001_separa_texto()
#------------------------------#
      
   LET r_01 = func001_quebra_texto()
   LET r_02 = func001_quebra_texto()
   LET r_03 = func001_quebra_texto()
   LET r_04 = func001_quebra_texto()
   LET r_05 = func001_quebra_texto()
   LET r_06 = func001_quebra_texto()
   LET r_07 = func001_quebra_texto()
   LET r_08 = func001_quebra_texto()
   LET r_09 = func001_quebra_texto()
   LET r_10 = func001_quebra_texto()
   LET r_11 = func001_quebra_texto()
   LET r_12 = func001_quebra_texto()
   LET r_13 = func001_quebra_texto()
   LET r_14 = func001_quebra_texto()
   LET r_15 = func001_quebra_texto()
              
END FUNCTION

#-----------------------------#
FUNCTION func001_quebra_texto()
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
            CALL func001_justifica()
         END IF
      END IF 
   END IF

  RETURN(ret)
   
END FUNCTION

#--------------------------#
FUNCTION func001_justifica()
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


#-------------fim do programa---------#