#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# MÓDULO..: INTEGRAÇÃO LOGIX X OMC                                  #
# PROGRAMA: pol1169                                                 #
# OBJETIVO: BAIXA DE TÍTULOS A PARTIR DE ARQ. TXT                   #
# AUTOR...: IVO                                                     #
# DATA....: 22/03/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_critica_demis      INTEGER,
          p_men                CHAR(500),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_comando            CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_caminho            CHAR(080),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500)

END GLOBALS

DEFINE p_tela          RECORD
  data                 DATE,
  hora                 CHAR(05)
END RECORD

DEFINE p_titulo    RECORD
  cod_empresa      char(02),
  num_nf           decimal(6,0),
  tip_nf           char(03),
  ser_nf           char(02),
  cod_cliente      char(15),
  dat_vencto       char(10),
  dat_pagto        char(10),
  cod_portador     decimal(4,0),
  tip_portador     char(01),
  val_titulo       decimal(12,2),
  val_multa        decimal(12,2),
  val_juros        decimal(12,2),
  val_pago         decimal(12,2),
  tip_pagto        char(01),
  num_docum        char(14),
  tip_docum        char(02),
  id_titulo        integer,
  cod_estatus      char(01), 
  nom_arquivo      char(30)
END RECORD

DEFINE p_arq_texto          CHAR(35),
       p_dat_char           CHAR(10),
       p_id_registro        INTEGER,
       p_id_registroa       INTEGER,
       p_rejeitou           SMALLINT,
       p_qtd_rejeicao       INTEGER,
       p_qtd_lidos          INTEGER,
       p_data               DATE,
       p_cod_status         CHAR(01),
       p_dat_hor            DATETIME YEAR TO SECOND,
       p_dat_atu            DATETIME YEAR to DAY,
       p_hor_atu            CHAR(08),
       p_trans_nf           INTEGER,
       p_qtd_txt            CHAR(12),
       p_excluiu            SMALLINT,
       p_cod_cliente        CHAR(15),
       p_nom_cliente        CHAR(35),
       p_num_nf             INTEGER,
       p_ser_nf             CHAR(02),
       p_tip_nf             CHAR(03)

DEFINE pr_motivo            ARRAY[15] OF RECORD      
       motivo               CHAR(70)
END RECORD

DEFINE p_docum RECORD LIKE docum.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1169-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1169_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1169_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1169") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1169 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol1169_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso !'
            LET p_ies_cons = TRUE
            NEXT OPTION 'Carregar'
         ELSE
            ERROR 'Operação cancelada !!!'
            LET p_ies_cons = FALSE
         END IF 
      COMMAND "Carregar" "Carrega os dados dos arquivos textos"
         IF p_ies_cons THEN
            CALL pol1169_carregar() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso!'
               NEXT OPTION 'Processar'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF 
         ELSE
            ERROR 'Informe os parâmentors previamente!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Processar" "Processa a baixa dos títulos"
         CALL pol1169_processar() RETURNING p_status
         IF p_status THEN
            CALL log0030_mensagem(p_msg,'excla')
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Rejeições" "Acesso aos títulos rejeitados "
         CALL pol1169_rejeicao()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1169_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1169

END FUNCTION


#-----------------------#
 FUNCTION pol1169_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1169_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION

#-------------------------#
FUNCTION pol1169_informar()
#-------------------------#

   CALL pol1169_limpa_tela()
   
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   LET p_tela.data = TODAY
   
   INPUT BY NAME p_tela.*  WITHOUT DEFAULTS
      
      AFTER FIELD data
			   IF p_tela.data IS NULL THEN
				    ERROR"Campo de preenchimento obrigatório"
				    NEXT FIELD data 
			   END IF 
      
      AFTER FIELD hora
			   IF p_tela.hora IS NULL THEN
				    ERROR"Campo de preenchimento obrigatório"
				    NEXT FIELD hora
			    END IF 
			    
			    IF LENGTH(p_tela.hora) < 5 THEN
			       ERROR 'Informe a hora no formato hh:mm - ex: 10:55 !'
			       NEXT FIELD hora
			    END IF
			
			AFTER INPUT
			   IF NOT INT_FLAG THEN
			      LET p_dat_char = p_tela.data
			      LET p_arq_texto = p_cod_empresa,'TITULOS_',
			             p_dat_char[1,2],p_dat_char[4,5],p_dat_char[7,10],
			             p_tela.hora[1,2],p_tela.hora[4,5],'.TXT'
			      
			      DISPLAY p_arq_texto to arq_texto
			   END IF
			     
   END INPUT
   
	 IF int_flag THEN
		  CALL pol1169_limpa_tela()
      RETURN FALSE
	 END IF
	 
	 RETURN TRUE
	 
END FUNCTION

#--------------------------#
FUNCTION pol1169_carregar()#
#--------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   SELECT nom_caminho,
          ies_ambiente
      INTO p_caminho, 
           g_ies_ambiente
      FROM path_logix_v2
     WHERE cod_sistema = "UNL"
       AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','path_logix_v2')
      RETURN FALSE
   END IF
      
   IF NOT pol1169_cria_tab_tmp() THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
      
   IF NOT pol1169_load_texto() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   CALL log0030_mensagem(p_men,'info')
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1169_cria_tab_tmp()
#-----------------------------#

   DROP TABLE titulos_tmp_509
   
   CREATE TEMP TABLE titulos_tmp_509(
      cod_empresa      char(02),
      num_nf           char(06),
      tip_nf           char(03),                    
      ser_nf           char(02),
      cod_cliente      char(15),
      dat_vencto       char(10),
      dat_pagto        char(10),
      cod_portador     char(04),
      tip_portador     char(01),                    
      val_titulo       char(12),
      val_multa        char(12),
      val_juros        char(12),
      val_pago         char(12),
      tip_pagto        char(01));                    
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","TITULOS_TMP_509")
			RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1169_load_texto()#
#----------------------------#

   IF NOT pol1169_del_tabs() THEN                                  
      RETURN FALSE                                                 
   END IF                                                          

   LET p_men = 'RESUMO DA CARGA:\n'                                      
                                                                   
   LET p_nom_arquivo = p_caminho CLIPPED, p_arq_texto                
   LOAD from p_nom_arquivo INSERT INTO titulos_tmp_509                  
                                                                   
   IF STATUS = 0 THEN                                                 
      IF NOT pol1169_insere_titulos() THEN                            
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_texto CLIPPED,                
                  ': carregado com sucesso;\n'                        
   ELSE                                                               
      IF STATUS <> -805 THEN                                          
         CALL log003_err_sql("LOAD",p_nom_arquivo)                    
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_texto CLIPPED,                
                  ': não encontrado\n'                               
   END IF                                                             
                                                                   
   RETURN TRUE                                                        

END FUNCTION

#---------------------------#
FUNCTION pol1169_del_tabs()
#---------------------------#

   DELETE FROM titulos_509
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','titulos_509')
      RETURN FALSE
   END IF

   DELETE FROM rejeicao_tit_509
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','rejeicao_tit_509')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#   
FUNCTION pol1169_insere_titulos()#
#--------------------------------#

   SELECT MAX(id_titulo)
     INTO p_id_registro
     FROM titulos_509
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','titulos_509:MAX')
      RETURN FALSE
   END IF
   
   IF p_id_registro IS NULL THEN
      LET p_id_registro = 0
   END IF
   
   INITIALIZE p_titulo TO NULL
   
   DECLARE cq_tit_tmp CURSOR FOR
    SELECT *
      FROM titulos_tmp_509
   
   FOREACH cq_tit_tmp INTO p_titulo.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','titulos_tmp_509:cq_tit_tmp')
         RETURN FALSE
      END IF
      
      LET p_id_registro = p_id_registro + 1
      LET p_titulo.id_titulo = p_id_registro
      LET p_titulo.nom_arquivo = p_arq_texto
      LET p_titulo.cod_estatus = 'R'
      
      INSERT INTO titulos_509 VALUES(p_titulo.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','titulos_509')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   DROP TABLE titulos_tmp_509
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1169_processar()#
#---------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")

   LET p_qtd_rejeicao = 0
   LET p_qtd_lidos = 0
   
   IF NOT pol1169_consiste() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   IF p_qtd_rejeicao > 0 THEN
      LET p_qtd_txt = p_qtd_rejeicao
      LET p_msg = 'A rotina de consistência criticou\n',
          p_qtd_txt CLIPPED, ' titulos. Consulte as rejeições.'
      RETURN TRUE
   END IF

   IF p_qtd_lidos = 0 THEN
      LET p_msg = 'Não há titulos a\n serem processados.'
      RETURN TRUE
   END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol1169_baixa_titulo() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   LET p_msg = 'Processamento efetuado com sucesso.'

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
FUNCTION pol1169_consiste()#
#--------------------------#

   DECLARE cq_consist CURSOR WITH HOLD FOR
    SELECT *
      FROM titulos_509
     WHERE cod_empresa = p_cod_empresa 
       AND cod_estatus = 'R'
   
   FOREACH cq_consist INTO p_titulo.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_consist')
         RETURN FALSE
      END IF

      LET p_rejeitou = FALSE
      LET p_qtd_lidos = p_qtd_lidos + 1

      IF NOT pol1169_consist_titulo() THEN
         RETURN FALSE
      END IF
      
      IF p_rejeitou THEN
         LET p_qtd_rejeicao = p_qtd_rejeicao + 1
      END IF
       
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1169_consist_titulo()
#--------------------------------#

   SELECT COUNT(num_docum)                                                                            
     INTO p_count                                                                                        
     FROM docum                                                                                          
    WHERE cod_empresa = p_cod_empresa                                                                    
      AND num_docum_origem = p_titulo.num_nf                                                             
      AND ies_tip_docum_orig = p_titulo.tip_nf                                                           
      AND ies_serie_fat = p_titulo.ser_nf                                                                
      AND cod_cliente = p_titulo.cod_cliente                                                             
                                                                                                      
   IF STATUS <> 0 THEN                                                                                   
      CALL log003_err_sql('Lendo','docum:cq_consist')                                                    
      RETURN FALSE                                                                                       
   END IF                                                                                                
                                                                                                      
   IF p_count = 0 THEN                                                                                   
      LET p_msg = 'TITULO ENESISTENTE - VERIFIQUE NUMERO, ESPECIE E SERIE DA NF ENVIADA'                 
      CALL pol1169_grava_rejeicao()                                                                      
   END IF                                                                                                
                                                                                                      
   SELECT COUNT(cod_cliente)                                                                             
     INTO p_count                                                                                        
     FROM clientes                                                                                       
    WHERE cod_cliente = p_titulo.cod_cliente                                                             
                                                                                                         
   IF STATUS <> 0 THEN                                                                                   
      CALL log003_err_sql('Lendo','clientes:cq_consist')                                                 
      RETURN FALSE                                                                                       
   END IF                                                                                                
                                                                                                      
   IF p_count = 0 THEN                                                                                   
      LET p_msg = 'O CLIENTE ENVIADO NAO EXISTE NO LOGIX'                                                
      CALL pol1169_grava_rejeicao()                                                                      
   END IF                                                                                                
                                                                                                         
   IF p_titulo.dat_vencto IS NULL THEN                                                                   
      LET p_msg = 'A DATA DE VENCIMENTO ENVIADA NAO E VALIDA'                                            
      CALL pol1169_grava_rejeicao()                                                                      
   END IF                                                                                                
                                                                                                         
   IF p_titulo.dat_pagto IS NULL THEN                                                                    
      LET p_msg = 'A DATA DE PAGAMENTO ENVIADA NAO E VALIDA'                                             
      CALL pol1169_grava_rejeicao()                                                                      
   END IF                                                                                                
                                                                                                      
   IF p_titulo.tip_portador IS NULL THEN                                                                 
      LET p_msg = 'O TIPO DE PORTADOR ENVIADO NAO E VALIDO - ESPERADO: B/C'                              
      CALL pol1169_grava_rejeicao()                                                                      
   END IF                                                                                                
                                                                                                      
   IF p_titulo.tip_portador = 'B' THEN                                                                   
      SELECT COUNT(nom_banco)                                                                            
        INTO p_count                                                                                     
        FROM bancos                                                                                      
       WHERE cod_banco = p_titulo.cod_portador                                                           
                                                                                                         
      IF STATUS <> 0 THEN                                                                                
         CALL log003_err_sql('Lendo','clientes:cq_consist')                                              
         RETURN FALSE                                                                                    
      END IF                                                                                             
                                                                                                      
      IF p_count = 0 THEN                                                                                
         LET p_msg = 'O PORTADOR ENVIADO NAO EXISTE NO LOGIX'                                            
         CALL pol1169_grava_rejeicao()                                                                   
      END IF                                                                                             
   END IF                                                                                                
                                                                                                         
   IF p_titulo.val_titulo IS NULL OR p_titulo.val_titulo = 0 THEN                                        
      LET p_msg = 'O VALOR DO TITULO ENVIADO NAO E VALIDO - ESPERADO: > 0'                               
      CALL pol1169_grava_rejeicao()                                                                      
   END IF                                                                                                
                                                                                                         
   IF p_titulo.val_pago IS NULL OR p_titulo.val_pago = 0 THEN                                            
      LET p_msg = 'O VALOR PAGO ENVIADO NAO E VALIDO - ESPERADO: > 0'                                    
      CALL pol1169_grava_rejeicao()                                                                      
   END IF                                                                                                
                                                                                                         
   RETURN TRUE                                                                                           

END FUNCTION
      
#-------------------------------#
FUNCTION pol1169_grava_rejeicao()
#-------------------------------#

   LET p_rejeitou = TRUE   
   
   INSERT INTO rejeicao_tit_509
    VALUES(p_titulo.cod_empresa,
           p_titulo.nom_arquivo,
           p_titulo.id_titulo,
           p_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','rejeicao_tit_509')
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol1169_baixa_titulo()#
#------------------------------#

   LET p_dat_atu = TODAY
   
   DECLARE cq_baixa CURSOR WITH HOLD FOR
    SELECT *
      FROM titulos_509
     WHERE cod_empresa = p_cod_empresa 
       AND cod_estatus = 'R'
   
   FOREACH cq_baixa INTO p_titulo.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_consist')
         RETURN FALSE
      END IF

      SELECT *
        INTO p_docum.*                                                                                        
        FROM docum                                                                                          
       WHERE cod_empresa = p_cod_empresa                                                                    
         AND num_docum_origem = p_titulo.num_nf                                                             
         AND ies_tip_docum_orig = p_titulo.tip_nf                                                           
         AND ies_serie_fat = p_titulo.ser_nf         
         AND cod_cliente = p_titulo.cod_cliente                                                             
                                                                                                      
      IF STATUS <> 0 THEN                                                                                   
         CALL log003_err_sql('Lendo','docum:cq_consist')                                                    
         RETURN FALSE                                                                                       
      END IF                                                                                                

      IF NOT pol1169_insere_docum_pgto() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1169_atualiza_docum() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
 
END FUNCTION

#-----------------------------------#
FUNCTION pol1169_insere_docum_pgto()#
#-----------------------------------#  

   DEFINE p_doc_pgto RECORD LIKE docum_pgto.*
   
   LET p_doc_pgto.cod_empresa       = p_docum.cod_empresa
   LET p_doc_pgto.num_docum         = p_docum.num_docum
   LET p_doc_pgto.ies_tip_docum     = p_docum.ies_tip_docum
   LET p_doc_pgto.num_seq_docum     = 1
   LET p_doc_pgto.dat_pgto          = p_titulo.dat_pagto
   LET p_doc_pgto.dat_credito       = p_titulo.dat_pagto
   LET p_doc_pgto.dat_lanc          = p_titulo.dat_pagto
   LET p_doc_pgto.val_pago          = p_titulo.val_pago
   LET p_doc_pgto.val_a_pagar       = 0
   LET p_doc_pgto.val_juro_pago     = p_titulo.val_juros
   LET p_doc_pgto.val_juro_a_pagar  = 0
   LET p_doc_pgto.val_desc_conc     = 0
   LET p_doc_pgto.val_desc_a_conc   = 0
   LET p_doc_pgto.val_abat          = 0
   LET p_doc_pgto.val_desp_cartorio = 0
   LET p_doc_pgto.val_despesas      = 0
   LET p_doc_pgto.val_var_moeda     = 0
   LET p_doc_pgto.val_var_moeda_cont= 0
   LET p_doc_pgto.val_multa_paga    = p_titulo.val_multa
   LET p_doc_pgto.val_multa_a_pagar = 0
   LET p_doc_pgto.val_ir_pago       = 0
   LET p_doc_pgto.ies_tip_pgto      = p_titulo.tip_pagto

   IF p_titulo.tip_portador = 'B' THEN
      LET p_doc_pgto.ies_forma_pgto = 'BC'
   ELSE
      LET p_doc_pgto.ies_forma_pgto = 'NC'
   END IF
   
   LET p_doc_pgto.cod_portador      = p_titulo.cod_portador
   LET p_doc_pgto.ies_tip_portador  = p_titulo.tip_portador
   LET p_doc_pgto.num_lote_lanc_cont= 0
   LET p_doc_pgto.num_lote_pgto     = 0
   LET p_doc_pgto.dat_atualiz       = p_dat_atu
   
   INSERT INTO docum_pgto
      VALUES(p_doc_pgto.*)
      
   IF STATUS <> 0 THEN                                                                                   
      CALL log003_err_sql('Inserindo','docum_pgto')                                                    
      RETURN FALSE                                                                                       
   END IF                                                                                                
   
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1169_atualiza_docum()#
#--------------------------------#

   UPDATE docum
      SET val_saldo = val_saldo - p_titulo.val_pago,
          cod_portador = p_titulo.cod_portador,
          ies_tip_portador = p_titulo.tip_portador,
          ies_pgto_docum = p_titulo.tip_pagto,
          dat_atualiz = p_dat_atu
    WHERE cod_empresa = p_cod_empresa                                                                    
      AND num_docum_origem = p_titulo.num_nf                                                             
      AND ies_tip_docum_orig = p_titulo.tip_nf                                                           
      AND ies_serie_fat = p_titulo.ser_nf   
      AND cod_cliente = p_titulo.cod_cliente                                                             
                                                                                                      
   IF STATUS <> 0 THEN                                                                                   
      CALL log003_err_sql('Atualizando','docum')                                                    
      RETURN FALSE                                                                                       
   END IF      
   
   RETURN TRUE

END FUNCTION
                                                                                             

#--------------------------#
FUNCTION pol1169_rejeicao()#
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1169a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1169a AT 2,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
     
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1169_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1169_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1169_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados dos titulos rejeitados."
         IF p_ies_cons THEN
            CALL pol1169_modificar() RETURNING p_status  
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
     COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1169_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1169_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1169_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1169

END FUNCTION

#--------------------------#
FUNCTION pol1169_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1169_limpa_tela()
   LET p_id_registroa = p_id_registro
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      titulos_509.cod_cliente,
      titulos_509.num_nf,
      titulos_509.ser_nf,
      titulos_509.tip_nf
      
      ON KEY (control-z)
         CALL pol1169_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1169_limpa_tela()
         ELSE
            LET p_id_registro = p_id_registroa
            CALL pol1169_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT id_titulo, cod_cliente",
                  "  FROM titulos_509 ",
                  " WHERE ", where_clause CLIPPED, 
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "   AND cod_estatus = 'R' ",
				  "   AND id_titulo IN (SELECT id_titulo FROM rejeicao_tit_509) ",
                  " ORDER BY cod_cliente"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1169_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1169_exibe_dados()
#------------------------------#
   
   SELECT t.cod_cliente,
          c.nom_cliente,
          t.num_nf,
          t.ser_nf,
          t.tip_nf
     INTO p_cod_cliente,
          p_nom_cliente,
          p_num_nf,
          p_ser_nf,
          p_tip_nf
     FROM titulos_509 AS t
          LEFT OUTER JOIN clientes c
             ON c.cod_cliente = t.cod_cliente
    WHERE t.cod_empresa = p_cod_empresa
      AND t.id_titulo = p_id_registro
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "titulos_509/clientes")
      RETURN FALSE
   END IF
      
   DISPLAY p_cod_cliente  TO cod_cliente
   DISPLAY p_nom_cliente  TO nom_cliente
   DISPLAY p_num_nf TO num_nf
   DISPLAY p_ser_nf  TO ser_nf
   DISPLAY p_tip_nf  TO tip_nf
                                       
   CALL pol1169_le_motivo()
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol1169_le_motivo()
#--------------------------#

   INITIALIZE pr_motivo to null
   LET p_ind = 1
   
   DECLARE cq_mot CURSOR FOR
    SELECT motivo
      FROM rejeicao_tit_509
     WHERE cod_empresa = p_cod_empresa
       AND id_titulo = p_id_registro
  ORDER BY motivo

   FOREACH cq_mot 
      INTO pr_motivo[p_ind].motivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','CQ_MOT')       
         RETURN
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 15 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   CALL SET_COUNT(p_ind - 1)

   IF p_ind > 10 THEN
      DISPLAY ARRAY pr_motivo TO sr_motivo.*
   ELSE
      INPUT ARRAY pr_motivo WITHOUT DEFAULTS FROM sr_motivo.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
   
END FUNCTION
   
#-----------------------------------#
 FUNCTION pol1169_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_id_registroa = p_id_registro
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_id_registro
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_id_registro
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_cliente
           FROM titulos_509
          WHERE cod_empresa = p_cod_empresa
            AND id_titulo = p_id_registro
            
         IF STATUS = 0 THEN
            CALL pol1169_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_id_registro = p_id_registroa
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#-----------------------#
FUNCTION pol1169_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol11691
         IF p_codigo IS NOT NULL THEN
            LET p_titulo.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF

   END CASE   

END FUNCTION

#----------------------------------#
 FUNCTION pol1169_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT id_titulo 
      FROM titulos_509  
     WHERE cod_empresa = p_cod_empresa
       AND id_titulo = p_id_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH","CQ_PRENDE")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1169_modificar()
#--------------------------#

   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF pol1169_prende_registro() THEN
      IF pol1169_edita_titulo() THEN
         IF pol1169_grava_titulo() THEN       
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      CALL pol1169_consist_titulo() RETURNING p_status
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   CALL pol1169_exibe_dados()
   
   RETURN p_retorno

END FUNCTION

#------------------------------#
FUNCTION pol1169_grava_titulo()#
#------------------------------#

   UPDATE titulos_509
      SET num_nf       = p_titulo.num_nf,
          tip_nf       = p_titulo.tip_nf,      
          ser_nf       = p_titulo.ser_nf,      
          cod_cliente  = p_titulo.cod_cliente, 
          dat_vencto   = p_titulo.dat_vencto,  
          dat_pagto    = p_titulo.dat_pagto,   
          cod_portador = p_titulo.cod_portador,
          tip_portador = p_titulo.tip_portador,
          val_titulo   = p_titulo.val_titulo,  
          val_multa    = p_titulo.val_multa,   
          val_juros    = p_titulo.val_juros,   
          val_pago     = p_titulo.val_pago,    
          tip_pagto    = p_titulo.tip_pagto   
    WHERE cod_empresa = p_cod_empresa
      AND id_titulo = p_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "titulos_509")
      RETURN FALSE
   END IF
   
   DELETE FROM rejeicao_tit_509
    WHERE cod_empresa = p_cod_empresa
      AND id_titulo = p_id_registro
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE", "rejeicao_tit_509")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
               
#------------------------------#
FUNCTION pol1169_edita_titulo()#
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1169b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1169b AT 2,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   SELECT *
     INTO p_titulo.*
     FROM titulos_509
    WHERE cod_empresa = p_cod_empresa
      AND id_titulo = p_id_registro   
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "titulos_509")
      CLOSE WINDOW w_pol1169b
      RETURN FALSE
   END IF 
          
   INPUT p_titulo.num_nf,      
         p_titulo.tip_nf,      
         p_titulo.ser_nf,      
         p_titulo.cod_cliente, 
         p_titulo.dat_vencto,  
         p_titulo.dat_pagto,   
         p_titulo.cod_portador,
         p_titulo.tip_portador,
         p_titulo.val_titulo,  
         p_titulo.val_multa,   
         p_titulo.val_juros,   
         p_titulo.val_pago,    
         p_titulo.tip_pagto   
      WITHOUT DEFAULTS
      FROM num_nf,      
           tip_nf,      
           ser_nf,      
           cod_cliente, 
           dat_vencto,  
           dat_pagto,   
           cod_portador,
           tip_portador,
           val_titulo,  
           val_multa,   
           val_juros,   
           val_pago,   
           tip_pagto   
   
      ON KEY (control-z)
         CALL pol1169_popup()

      AFTER FIELD cod_cliente
      
         SELECT COUNT(nom_cliente)                                                                             
           INTO p_nom_cliente                                                                                      
           FROM clientes                                                                                       
          WHERE cod_cliente = p_titulo.cod_cliente                                                             
                                                                                                         
         IF STATUS <> 0 THEN                                                                                   
            ERROR 'Cliente inválido!'
            NEXT FIELD cod_cliente
         END IF    
         
         DISPLAY p_nom_cliente TO nom_cliente                                                                                           

   END INPUT
   
   CLOSE WINDOW w_pol1169b
   
	 IF INT_FLAG THEN
      RETURN FALSE
	 END IF
	 
	 RETURN TRUE
	 
END FUNCTION

#--------------------------#
 FUNCTION pol1169_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1169_prende_registro() THEN
      DELETE FROM titulos_509
			 WHERE cod_empresa = p_cod_empresa
			   AND id_titulo = p_id_registro

      IF STATUS = 0 THEN               
         
         DELETE FROM rejeicao_tit_509
   			  WHERE cod_empresa = p_cod_empresa
			      AND id_titulo = p_id_registro
         
         IF STATUS = 0 THEN
            CALL pol1169_limpa_tela()         
            LET p_retorno = TRUE
            LET p_excluiu = TRUE                     
         ELSE
            CALL log003_err_sql("Excluindo","rejeicao_tit_509")
         END IF
      ELSE
         CALL log003_err_sql("Excluindo","titulos_509")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

