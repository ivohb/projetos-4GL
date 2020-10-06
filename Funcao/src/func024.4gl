
#----------------------------------------------------------------------#
#-----------Objetivo: separar um texto em n pedaços--------------------#
#------------------------formato da chamada----------------------------#
# CALL func024_quebrar_texto(p_texto,p_tamanho,p_qtd_linha,p_justifica)#
#           RETURNING p_retorno_1,p_retorno_2,...,p_retorno_n          #
#                                                                      #
# p_texto: texto a ser quebrado em linhas (tamanho máximo 3000 digitos)#
# p_tamanho: tamanho de cada linha (tamanho máximo 200 digitos)        #
# p_qtd_linha: quantidade de linhas a ser retornada (15 no máximo)     #
# p_justifica: se deve ou não justificar o resultado                   #
#---------------------------Retorno------------------------------------#
# o texto separado em até 15 pedaços com até 200 caracteres cada       #
#----------------------------------------------------------------------#
    
#--parâmetros recebidos--#
          
DEFINE texto        VARCHAR(4000),
       tam_linha    SMALLINT,
       qtd_linha    SMALLINT,
       justificar   CHAR(01),
       resto        INTEGER

#--variáveis auxiliares--#

DEFINE num_carac    SMALLINT,
       ret          VARCHAR(200),
       p_ind        INTEGER,
       m_ind        integer


#----------------------------------------#
 FUNCTION func024_quebrar_texto(parametro)
#----------------------------------------#

   DEFINE parametro  RECORD 
          texto      VARCHAR(4000),
          tam_linha  SMALLINT,
          justificar CHAR(01)
   END RECORD
         
   LET texto      = parametro.texto CLIPPED
   LET tam_linha  = parametro.tam_linha
   LET justificar = parametro.justificar

   IF texto IS NULL THEN
      RETURN FALSE
   END IF
   
   IF tam_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF tam_linha > 400 OR tam_linha > LENGTH(texto) THEN
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

   IF NOT func024_cria_tab_txt() THEN
      RETURN FALSE
   END IF
      
   IF NOT func024_separa_texto() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION 

#------------------------------#
FUNCTION func024_cria_tab_txt()#
#------------------------------#

   WHENEVER ANY ERROR CONTINUE

   DROP TABLE w_txt_observ;
   
   CREATE TEMP TABLE w_txt_observ (
    num_seq        INTEGER,
    texto          CHAR(400)
   );
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX w_txt_observ
    ON w_txt_observ(num_seq);

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION        
         
#------------------------------#
 FUNCTION func024_separa_texto()
#------------------------------#
   
   DEFINE den_txt       VARCHAR(400),
          lenf          integer,
          l_ind         integer
          
   LET lenf = LENGTH(texto)
   LET qtd_linha = lenf / tam_linha
   LET resto = (lenf MOD tam_linha)
   
   IF resto > 0 THEN 
      LET qtd_linha = qtd_linha + 1
   END IF
   
   LET qtd_linha = 1000
   
   DELETE FROM w_txt_observ
   
   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
   
   LET l_ind = 0
   
   FOR m_ind = 1 TO qtd_linha
       
       IF texto IS NOT NULL THEN
          LET den_txt = func024_quebra_texto()
          LET l_ind = l_ind + 1
          INSERT INTO w_txt_observ
           VALUES(l_ind, den_txt)
          IF STATUS <> 0 THEN
             RETURN FALSE
          END IF           
       END IF
       
   END FOR
              
END FUNCTION

#-----------------------------#
FUNCTION func024_quebra_texto()
#-----------------------------#

   DEFINE ind SMALLINT

   LET ret = ''

   LET texto = texto CLIPPED
   LET num_carac = LENGTH(texto)
   IF num_carac = 0 THEN
      LET m_ind = qtd_linha
      RETURN ''
   END IF
   
   IF num_carac <= tam_linha THEN
      LET ret = texto CLIPPED
      INITIALIZE texto TO NULL
      LET m_ind = qtd_linha
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
            CALL func024_justifica()
         END IF
      END IF 
   END IF

  RETURN(ret)
   
END FUNCTION

#--------------------------#
FUNCTION func024_justifica()
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