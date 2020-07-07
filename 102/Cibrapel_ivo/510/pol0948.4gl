#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0948                                                 #
# OBJETIVO: ESTORNOS DE INSUMOS APÓS COPIADOS                       #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 25/06/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_info           SMALLINT,
          p_ies_cons           SMALLINT,
          p_ies_null           CHAR(01),
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_chave              CHAR(500),
          sql_stmt             CHAR(600)
                       
   
   DEFINE p_tela               RECORD 
          dat_ini              DATE,
          dat_fim              DATE
   END RECORD 
   
   DEFINE p_num_aviso_rec      LIKE aviso_rec.num_aviso_rec,
          p_num_docum          LIKE estoque_trans.num_docum, 
          p_num_seq            LIKE estoque_trans.num_seq,
          p_cod_item           LIKE estoque_trans.cod_item,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_dat_proces         LIKE estoque_trans.dat_proces,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_cod_local_est_dest LIKE estoque_trans.cod_local_est_dest,
          p_ies_sit_est_dest   LIKE estoque_trans.ies_sit_est_dest,
          p_cod_fornecedor     LIKE ar_proces_885.cod_fornecedor,
          p_num_nf             LIKE ar_proces_885.num_nf,
          p_val_adiant         LIKE adiant.val_adiant,
          p_num_ad             LIKE ad_mestre.num_ad, 
          p_den_item_reduz     LIKE item.den_item_reduz
   
   DEFINE pr_movto             ARRAY[1000] OF RECORD
          num_aviso_rec        LIKE aviso_rec.num_aviso_rec,
          num_seq              LIKE estoque_trans.num_seq,
          cod_item             LIKE estoque_trans.cod_item,
          val_adiant           LIKE adiant.val_adiant,
          num_ad               LIKE ad_mestre.num_ad
   END RECORD
   
   DEFINE p_movto              RECORD 
          num_aviso_rec        LIKE aviso_rec.num_aviso_rec, 
          num_seq              LIKE estoque_trans.num_seq,
          cod_item             LIKE estoque_trans.cod_item,
          val_adiant           LIKE adiant.val_adiant,
          num_ad               LIKE ad_mestre.num_ad
   END RECORD 
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0948-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0948_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0948_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0948") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0948 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0948_le_empresa() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO cod_empresa
   LET p_cod_empresa = p_cod_emp_ofic

   IF NOT pol0948_cria_temp() THEN
      RETURN
   END IF
      
   LET p_ies_info = FALSE 
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ o processamento"
         CALL pol0948_limpa_tela()
         CALL pol0948_informar() RETURNING p_status
         IF p_status THEN
            ERROR "Parâmetros informados com sucesso !!!"
            
            LET p_ies_info = TRUE
            NEXT OPTION 'Consultar'
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_info = FALSE
         END IF 
      COMMAND "Consultar" "Processa os dados já informados com sucesso"
         IF p_ies_info THEN
            CALL pol0948_Consultar() RETURNING p_status
            MESSAGE ""
            IF p_status THEN
               ERROR "Consulta efetuada com sucesso !!!"   
               LET p_ies_info = FALSE
               LET p_ies_cons = TRUE 
               IF p_ies_null = 'N' THEN  
                  NEXT OPTION "Listar" 
               ELSE 
                  NEXT OPTION "Fim"
               END IF 
            ELSE
               ERROR 'Operação canceada!!!'
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!!!'
            NEXT OPTION "Informar"
         END IF 
      COMMAND "Listar" "Listagem dos dados já consultados com sucesso"
         IF p_ies_cons THEN
            IF p_ies_null = 'S' THEN  
               ERROR "Não há dados á serem listados !!!"
               LET p_ies_cons = FALSE 
               NEXT OPTION "Fim"
            ELSE
               CALL pol0948_listagem() RETURNING p_status
            END IF
         ELSE
            ERROR 'Consulte previamente!!!'
            NEXT OPTION "Consultar"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0948_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0948

END FUNCTION

#----------------------------#
FUNCTION pol0948_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa  = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#----------------------------#
 FUNCTION pol0948_cria_temp()
#----------------------------#
   
   CREATE TEMP TABLE ar_tmp_885
     (
      num_aviso_rec  DECIMAL(6,0),
      num_seq        DECIMAL(12,0),
      cod_item       CHAR(15)       
     );
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("criando","ar_tmp_885")
      RETURN FALSE
   END IF

   CREATE TEMP TABLE movto_tmp_885
     (
      num_aviso_rec  DECIMAL(6,0),
      num_seq        DECIMAL(12,0),
      cod_item       CHAR(15),
      val_adiant     DECIMAL(17,2),
      num_ad         DECIMAL(6,0)
     );
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("criando","movto_tmp_885")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#---------------------------#
FUNCTION pol0948_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol0948_Informar()
#--------------------------#
   
   CALL pol0948_limpa_tela()
   
   INITIALIZE p_tela TO NULL
   
   DELETE FROM ar_tmp_885
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletanto','ar_tmp_885')
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME P_tela.* WITHOUT DEFAULTS
   
   AFTER FIELD dat_ini
   IF p_tela.dat_ini IS NULL THEN 
      ERROR "Campo com Prenchimento obrigatório!!!"
      NEXT FIELD dat_ini
   END IF 
   
   AFTER FIELD dat_fim
   IF p_tela.dat_fim IS NULL THEN 
      ERROR "Campo com Prenchimento obrigatório!!!"
      NEXT FIELD dat_fim
   END IF
   
   AFTER INPUT 
   IF NOT INT_FLAG THEN
      IF p_tela.dat_ini > p_tela.dat_fim THEN 
         ERROR "A data inicial é maior que a data final!!!"
         NEXT FIELD dat_ini
      END IF
   END IF
   
       
   END INPUT 
            
  IF INT_FLAG THEN
     CALL pol0948_limpa_tela()
     RETURN FALSE
  END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
 FUNCTION pol0948_Consultar()
#---------------------------#
   
   LET p_ies_null = 'N'
   
   DELETE FROM ar_tmp_885
   
   MESSAGE 'Processando...'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando', 'ar_tmp_885')
      RETURN FALSE
   END IF 

   DELETE FROM movto_tmp_885

   IF STATUS <> 0 THEN
      CALL log003_err_sql('deletando', 'movto_tmp_885')
      RETURN FALSE
   END IF 
   
   DECLARE cq_mov CURSOR WITH HOLD FOR 
    SELECT num_docum,
           num_seq,
           cod_item,
           dat_movto,
           qtd_movto,
           cod_local_est_dest,
           ies_sit_est_dest,
           dat_proces
      FROM estoque_trans 
     WHERE cod_empresa = p_cod_empresa
       AND dat_movto BETWEEN p_tela.dat_ini AND p_tela.dat_fim
       AND ies_tip_movto = 'R'
       AND cod_operacao = 'INSP'

   FOREACH cq_mov 
      INTO p_num_docum,
           p_num_seq,
           p_cod_item,
           p_dat_movto,
           p_qtd_movto,
           p_cod_local_est_dest,
           p_ies_sit_est_dest,
           p_dat_proces
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'cq_mov')
         RETURN FALSE
      END IF 
      
      LET p_num_aviso_rec = p_num_docum
      
      DISPLAY p_num_docum AT 21,20 
      
      SELECT dat_movto
        INTO p_dat_movto
        FROM ar_proces_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
         AND dat_movto    <= p_dat_proces
         
      IF STATUS = 0 THEN 
      ELSE
         IF STATUS = 100 THEN
            CONTINUE FOREACH
         ELSE   
            CALL log003_err_sql('lendo', 'ar_proces_885')
            RETURN FALSE
         END IF
      END IF 
         
      SELECT num_docum
        FROM estoque_trans 
       WHERE cod_empresa = p_cod_emp_ger
         AND ies_tip_movto      = 'R'
         #AND cod_operacao       = 'INSP'
         AND num_docum          = p_num_docum
         AND num_seq            = p_num_seq
         AND cod_item           = p_cod_item
         AND dat_movto          = p_dat_movto
         AND qtd_movto          = p_qtd_movto
         AND cod_local_est_dest = p_cod_local_est_dest
         AND ies_sit_est_dest   = p_ies_sit_est_dest
       
      IF STATUS = 100 THEN 
      ELSE
         IF STATUS = 0 THEN
            CONTINUE FOREACH
         ELSE   
            CALL log003_err_sql('lendo', 'estoque_trans')
            RETURN FALSE
         END IF
      END IF 
        
      IF pol0948_grava_tabela_ar_tmp_885() THEN 
      ELSE 
         RETURN FALSE 
      END IF 
              
   END FOREACH

   IF pol0948_insere_movto_tmp_885() THEN 
   ELSE 
      RETURN FALSE 
   END IF 
   
   SELECT COUNT (num_aviso_rec)
     INTO p_count
     FROM movto_tmp_885
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','movto_tmp_885')
      RETURN FALSE 
   END IF 
   
   IF p_count = 0 THEN 
      CALL log0030_mensagem("Não há estornos para o período informado !!!","exclamation")
      LET p_ies_null = 'S'
      RETURN TRUE 
   END IF 
   
   IF pol0948_exibe_dados() THEN 
   ELSE 
      RETURN FALSE 
   END IF 
   
   RETURN TRUE
   
END FUNCTION
   

#-----------------------------------------#
 FUNCTION pol0948_grava_tabela_ar_tmp_885()
#-----------------------------------------#

   INSERT INTO ar_tmp_885
        VALUES(p_num_aviso_rec,p_num_seq,p_cod_item)
        
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("inserindo","ar_tmp_885")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#--------------------------------------#
 FUNCTION pol0948_insere_movto_tmp_885()
#--------------------------------------#
  
   DEFINE p_cod_empresa_destin LIKE empresa.cod_empresa
   
   DECLARE cq_mov_2 CURSOR WITH HOLD FOR 
    SELECT num_aviso_rec,
           num_seq,
           cod_item
      FROM ar_tmp_885
   
   FOREACH cq_mov_2 
      INTO p_num_aviso_rec,
           p_num_seq,
           p_cod_item
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'cq_mov_2')
         RETURN FALSE
      END IF 
      
      DISPLAY p_num_aviso_rec AT 21,20
      
      SELECT cod_fornecedor,
             num_nf
        INTO p_cod_fornecedor,
             p_num_nf
        FROM ar_proces_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso_rec
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'ar_proces_885')
         RETURN FALSE
      END IF 
      
      SELECT val_adiant
        INTO p_val_adiant
        FROM adiant
       WHERE cod_empresa    = p_cod_empresa
         AND num_ad_nf_orig = p_num_nf
         AND cod_fornecedor = p_cod_fornecedor
         
      IF STATUS = 100 THEN 
         LET p_val_adiant = NULL
      ELSE 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo', 'adiant')
            RETURN FALSE
         END IF 
      END IF 
      
      SELECT cod_empresa_destin
        INTO p_cod_empresa_destin
        FROM emp_orig_destino
       WHERE cod_empresa_orig = p_cod_emp_ger

      IF STATUS = 100 THEN 
         LET p_cod_empresa_destin = p_cod_emp_ger
      ELSE 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo', 'emp_orig_destino')
            RETURN FALSE
         END IF 
      END IF 
     
      SELECT num_ad
        INTO p_num_ad 
        FROM ad_mestre
       WHERE cod_empresa    = p_cod_empresa_destin
         AND num_nf         = p_num_nf
         AND cod_fornecedor = p_cod_fornecedor
         
      IF STATUS = 100 THEN 
         LET p_num_ad = NULL
      ELSE 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo', 'ad_mestre')
            RETURN FALSE
         END IF 
      END IF

      INSERT INTO movto_tmp_885
           VALUES(p_num_aviso_rec,p_num_seq,p_cod_item,p_val_adiant,p_num_ad)
        
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("inserindo","movto_tmp_885")
         RETURN FALSE
      END IF
      
   END FOREACH
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0948_exibe_dados()
#-----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09481") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09481 AT 6,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET p_index = 1
   
   DECLARE cq_exibe CURSOR FOR
   
   SELECT num_aviso_rec,
          num_seq,
          cod_item,
          val_adiant,
          num_ad
     FROM movto_tmp_885
                               
   FOREACH cq_exibe INTO 
           pr_movto[p_index].num_aviso_rec,
           pr_movto[p_index].num_seq,
           pr_movto[p_index].cod_item,
           pr_movto[p_index].val_adiant,
           pr_movto[p_index].num_ad
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'cq_exibe')
         RETURN FALSE
      END IF 
   
      LET p_index = p_index + 1
      
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_movto TO sr_movto.*
   
   CLOSE WINDOW w_pol09481
   
   RETURN TRUE 

END FUNCTION 
   
#--------------------------#
 FUNCTION pol0948_listagem()
#--------------------------#     

   IF NOT pol0948_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0948_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT num_aviso_rec,
          num_seq,
          cod_item,
          val_adiant,
          num_ad
     FROM movto_tmp_885
 ORDER BY num_seq                          
  
   FOREACH cq_exibe INTO 
           p_movto.num_aviso_rec,
           p_movto.num_seq,
           p_movto.cod_item,
           p_movto.val_adiant,
           p_movto.num_ad
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'cq_impressao')
         RETURN FALSE
      END IF 
   
      SELECT den_item_reduz
        INTO p_den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_movto.cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'item')
         RETURN FALSE
      END IF 
   
   OUTPUT TO REPORT pol0948_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0948_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso!!!'
   END IF

   RETURN TRUE 
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol0948_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0948.tmp"
         START REPORT pol0948_relat TO p_caminho
      ELSE
         START REPORT pol0948_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol0948_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------#
 REPORT pol0948_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol0948",
               COLUMN 015, "ESTORNOS DE INSUMOS APÓS COPIADOS",
               COLUMN 052, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '  AR     Sequencia     Cod. Item        Den. Item         Adiantamento      AD'
         PRINT COLUMN 002, '------ ------------ --------------- ------------------ ------------------ ------'
                            
      ON EVERY ROW

         PRINT COLUMN 002, p_movto.num_aviso_rec USING "######",
               COLUMN 009, p_movto.num_seq       USING "############",
               COLUMN 022, p_movto.cod_item,
               COLUMN 038, p_den_item_reduz,          
               COLUMN 057, p_movto.val_adiant    USING "##############&.&&",
               COLUMN 076, p_movto.num_ad        USING "######"
               
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol0948_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#   
  
