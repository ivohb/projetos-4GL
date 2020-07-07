#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# MÓDULO..: INTEGRAÇÃO LOGIX X OMC                                  #
# PROGRAMA: pol1142                                                 #
# OBJETIVO: CÓPIA DE PRODUTO                                        #
# AUTOR...: IVO                                                     #
# DATA....: 30/03/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_versao          CHAR(18),
          p_empresa_orig    CHAR(02),
          p_item_orig       CHAR(15),
          p_item_dest       CHAR(15),
          p_men             CHAR(500),
          p_cod_status      CHAR(10)
   
END GLOBALS
MAIN
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1142-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

END MAIN

#--------------------------------------------------#
FUNCTION pol1142_copia_item(p_emp,p_itorig,p_itdest)
#--------------------------------------------------#
   
   DEFINE p_emp      CHAR(02),
          p_itorig   CHAR(15),
          p_itdest   CHAR(15)

   LET p_empresa_orig = p_emp
   LET p_item_orig    = p_itorig
   LET p_item_dest    = p_itdest    
   LET p_men = NULL
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1142_processa_copia() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   RETURN p_men
   
END FUNCTION

#-------------------------------#
FUNCTION pol1142_processa_copia()
#-------------------------------#

   IF NOT pol1142_copia_item_geral() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_vdp() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_man() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_barra() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_grade() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_ctr_grade() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_embalagem() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_custo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1142_copia_item_esp() THEN
      RETURN FALSE
   END IF

   RETURN TRUE 

END FUNCTION

#----------------------------------#
FUNCTION pol1142_copia_item_geral()
#----------------------------------#   

   DEFINE p_item RECORD LIKE item.*
   
   SELECT *
     INTO p_item.*
     FROM item
    WHERE cod_empresa = p_empresa_orig
      AND cod_item    = p_item_orig
   
   IF STATUS = 100 THEN
      LET p_men = 'ITEM ESPELHO ', p_item_orig CLIPPED, ' NAO CADASTRADO'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM'
         RETURN FALSE
      END IF
   END IF
   
   LET p_item.cod_item = p_item_dest
   
   INSERT INTO item VALUES(p_item.*)
   
   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_men = 'ERRO ', p_cod_status CLIPPED,
                  ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM'
      RETURN FALSE
   END IF

   SELECT cod_empresa
     FROM estoque
    WHERE cod_empresa = p_empresa_orig
      AND cod_item    = p_item_dest

   IF STATUS = 100 THEN
      INSERT INTO estoque
       VALUES(p_empresa_orig,p_item_dest,0,0,0,0,0,0,' ',' ',' ')
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1142_copia_item_vdp()
#--------------------------------#   

   DEFINE p_item RECORD LIKE item_vdp.*
   
   SELECT *
     INTO p_item.*
     FROM item_vdp
    WHERE cod_empresa = p_empresa_orig
      AND cod_item    = p_item_orig
   
   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_VDP'
         RETURN FALSE
      END IF
   END IF
   
   LET p_item.cod_item = p_item_dest
   
   INSERT INTO item_vdp VALUES(p_item.*)
   
   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_men = 'ERRO ', p_cod_status CLIPPED,
                  ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_VDP'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1142_copia_item_man()
#--------------------------------#

   DEFINE p_item RECORD LIKE item_man.*
   
   SELECT *
     INTO p_item.*
     FROM item_man
    WHERE cod_empresa = p_empresa_orig
      AND cod_item    = p_item_orig
   
   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_MAN'
         RETURN FALSE
      END IF
   END IF
   
   LET p_item.cod_item = p_item_dest
   
   INSERT INTO item_man VALUES(p_item.*)
   
   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_men = 'ERRO ', p_cod_status CLIPPED,
                  ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_MAN'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1142_copia_item_sup()
#-------------------------------#

   DEFINE p_item RECORD LIKE item_sup.*
   
   SELECT *
     INTO p_item.*
     FROM item_sup
    WHERE cod_empresa = p_empresa_orig
      AND cod_item    = p_item_orig
   
   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_SUP'
         RETURN FALSE
      END IF
   END IF
   
   LET p_item.cod_item = p_item_dest
   
   INSERT INTO item_sup VALUES(p_item.*)
   
   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_men = 'ERRO ', p_cod_status CLIPPED,
                  ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_SUP'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1142_copia_item_barra()
#---------------------------------#

   DEFINE p_item RECORD LIKE item_barra.*
   
   SELECT *
     INTO p_item.*
     FROM item_barra
    WHERE cod_empresa = p_empresa_orig
      AND cod_item    = p_item_orig
   
   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_BARRA'
         RETURN FALSE
      END IF
   END IF
   
   LET p_item.cod_item = p_item_dest
   LET p_item.cod_item_barra_ser = 0
   LET p_item.cod_item_barra_dig = ''
   
   INSERT INTO item_barra(
      cod_empresa,
      cod_item,
      cod_item_barra_dig,
      reservado_01,
      reservado_02,
      reservado_03,
      reservado_04)
    VALUES(p_item.cod_empresa,
           p_item.cod_item,
           p_item.cod_item_barra_dig,
           p_item.reservado_01,   
           p_item.reservado_02,   
           p_item.reservado_03,   
           p_item.reservado_04)   
   
   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_men = 'ERRO ', p_cod_status CLIPPED,
                  ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_BARRA'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1142_copia_item_grade()
#---------------------------------#

   DEFINE p_item RECORD LIKE item_grade.*
   
   DECLARE cq_grade CURSOR FOR
    SELECT *
      FROM item_grade
     WHERE cod_empresa = p_empresa_orig
       AND cod_item    = p_item_orig
   
   FOREACH cq_grade INTO p_item.* 
  
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_GRADE'
         RETURN FALSE
      END IF
   
      LET p_item.cod_item = p_item_dest
   
      INSERT INTO item_grade VALUES(p_item.*)
   
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_GRADE'
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1142_copia_item_ctr_grade()
#-------------------------------------#

   DEFINE p_item RECORD LIKE item_ctr_grade.*
   
   DECLARE cq_grade CURSOR FOR
    SELECT *
      FROM item_ctr_grade
     WHERE cod_empresa = p_empresa_orig
       AND cod_item    = p_item_orig
   
   FOREACH cq_grade INTO p_item.* 
  
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_CTR_GRADE'
         RETURN FALSE
      END IF
   
      LET p_item.cod_item = p_item_dest
   
      INSERT INTO item_ctr_grade VALUES(p_item.*)
   
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_CTR_GRADE'
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1142_copia_item_embalagem()
#-------------------------------------#

   DEFINE p_item RECORD LIKE item_embalagem.*
   
   DECLARE cq_grade CURSOR FOR
    SELECT *
      FROM item_embalagem
     WHERE cod_empresa = p_empresa_orig
       AND cod_item    = p_item_orig
   
   FOREACH cq_grade INTO p_item.* 
  
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_EMBALAGEM'
         RETURN FALSE
      END IF
   
      LET p_item.cod_item = p_item_dest
      LET p_item.num_transac = 0
      
      INSERT INTO item_embalagem(
        cod_empresa,
        cod_item,
        cod_embal,
        ies_tip_embal,
        qtd_padr_embal,
        vol_padr_embal) 
        VALUES(p_item.cod_empresa,    
               p_item.cod_item,       
               p_item.cod_embal,      
               p_item.ies_tip_embal,  
               p_item.qtd_padr_embal, 
               p_item.vol_padr_embal) 
        
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_EMBALAGEM'
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1142_copia_item_custo()
#---------------------------------#

   DEFINE p_item RECORD LIKE item_custo.*
   
   SELECT *
     INTO p_item.*
     FROM item_custo
    WHERE cod_empresa = p_empresa_orig
      AND cod_item    = p_item_orig
   
   IF STATUS = 100 THEN
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_CUSTO'
         RETURN FALSE
      END IF
   END IF
   
   LET p_item.cod_item = p_item_dest
   
   INSERT INTO item_custo VALUES(p_item.*)
   
   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_men = 'ERRO ', p_cod_status CLIPPED,
                  ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_CUSTO'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1142_copia_item_esp()
#--------------------------------#

   DEFINE p_item RECORD LIKE item_esp.*
   
   DECLARE cq_grade CURSOR FOR
    SELECT *
      FROM item_esp
     WHERE cod_empresa = p_empresa_orig
       AND cod_item    = p_item_orig
   
   FOREACH cq_grade INTO p_item.* 
  
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' LENDO ITEM ESPELHO ',p_item_orig CLIPPED,' DA TABELA ITEM_ESP'
         RETURN FALSE
      END IF
   
      LET p_item.cod_item = p_item_dest
   
      INSERT INTO item_esp VALUES(p_item.*)
   
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_men = 'ERRO ', p_cod_status CLIPPED,
                     ' INSERINDO ITEM DESTINO ',p_item_dest CLIPPED,' NA TABELA ITEM_ESP'
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
