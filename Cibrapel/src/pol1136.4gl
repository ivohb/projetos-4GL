#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# M�DULO..: INTEGRA��O LOGIX X OMC                                  #
# PROGRAMA: pol1136                                                 #
# OBJETIVO: IMPORTA�O DE NOTAS DE SAIDA/SERVI�O A PARTIR DE ARQ. TXT#
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
          p_cid_ibeg           INTEGER,
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_cpf                CHAR(14),
          p_cod_bco            DECIMAL(3,0),
          p_ano_mes_demis      CHAR(07),
          p_ies_emite_dupl    CHAR (01)		  
   
   DEFINE p_arq_mestre         CHAR(35),
          p_arq_itens          CHAR(35),
          p_arq_cli            CHAR(35),         
          p_dat_char           CHAR(10),
          p_id_registro        INTEGER,
          p_rejeitou           SMALLINT,
          p_data               DATE,
          p_tip_docum          CHAR(10),
          p_item_espelho       CHAR(15),
          p_cod_status         CHAR(10),
          p_dat_hor            DATETIME YEAR TO SECOND,
          p_dat_atu            DATETIME YEAR to DAY,
          p_hor_atu            CHAR(08),
          p_trans_nf           INTEGER,
          p_tem_param          SMALLINT,
          p_tip_item           CHAR(01),
          p_cod_nat_oper       INTEGER,
          p_cod_item           CHAR(15),
          p_ssr_nf             INTEGER,
          p_nf_despre          INTEGER,
          p_nf_rejei           INTEGER,
          p_nf_grav            INTEGER,
          p_cli_rejei          INTEGER,
          p_cli_grav           INTEGER,
          p_cod_clas           CHAR(02),
          p_cod_tip_cli        CHAR(03),
          p_cod_cic_cli        CHAR(05),
          p_cod_cic_cob        CHAR(05),
          l_estado             CHAR(02),
          l_cod_reg            INTEGER,
          p_opcao              CHAR(01),
				  l_parametro_booleano CHAR(01),
				  l_parametro_texto		 CHAR(200),
				  p_num_seq_erro       INTEGER,
				  p_num_prx_ar         INTEGER,
          p_cod_desc           CHAR(05),
          p_pct_desc           DECIMAL(5,2),
          p_peso_bruto         DECIMAL(15,3),
          p_cod_unid_med       CHAR(02),
          l_val_pis_rec        DECIMAL(17,2),
				  l_val_cofins_rec     DECIMAL(17,2),
				  l_cod_fiscal   			 INTEGER,
	        p_num_trans_cfg      INTEGER,
          p_raz_reduz          CHAR(10),
          l_cpf_cgc            CHAR(19)
          

   DEFINE p_tela               RECORD
          data                 DATE,
          hora                 CHAR(05)
   END RECORD

	DEFINE p_aen              RECORD 
	       cod_lin_prod       LIKE item.cod_lin_prod,
	       cod_lin_recei      LIKE item.cod_lin_recei,
	       cod_seg_merc       LIKE item.cod_seg_merc,
	       cod_cla_uso        LIKE item.cod_cla_uso
	END RECORD

   DEFINE p_nf_mestre RECORD
      cod_empresa	    char(02),          
      tip_nf 	        Char(03),          
      num_nf	        decimal(6,0),    
      ser_nf	        Char(02),        
      cod_cliente	    Char(15),            
      dat_emissao	    datetime YEAR TO DAY,                
      dat_vencto 	    datetime YEAR TO DAY,                
      val_bruto_nf 	  decimal(17,2),     
      val_desc_incond	decimal(17,2),     
      val_liq_nf 	    decimal(17,2),     
      val_desc_cenp   decimal(17,2),    
      val_tot_nf 	    decimal(17,2),       
      val_duplicata	  decimal(17,2),     
      num_boleto	    Char(15),            
      ies_situa_nf	  char(1),           
      dat_cancel	    datetime YEAR TO DAY,                
      txt_nf     	    Char(300),         
      tip_nf_dev	    Char(03),          
      num_nf_dev	    decimal(6,0),        
      ser_nf_dev      Char(02),         
      chave_acesso    char(44),
      protocolo       char(15),
      dat_protocolo   datetime YEAR TO DAY,
      hor_protocolo   char(08),
      cod_estatus     char(01),         
      nom_arquivo     char(30),         
      id_registro     integer           
   END RECORD

   DEFINE p_nf_item            RECORD LIKE nf_itens_509.*,
          p_clientes           RECORD LIKE clientes_509.*,
          p_nf_sup             RECORD LIKE nf_sup.*,
          p_aviso_rec          RECORD LIKE aviso_rec.*,
          p_config             RECORD LIKE obf_config_fiscal.*

   DEFINE l_parametro          LIKE vdp_cli_parametro.parametro,
          l_des_parametro      LIKE vdp_cli_parametro.des_parametro,
          l_tip_parametro      LIKE vdp_cli_parametro.tip_parametro,
          l_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_num_conta          LIKE item_sup.num_conta,
          p_finalidade         LIKE fat_nf_mestre.finalidade
      
      
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1136-10.02.49"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1136_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1136_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1136") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1136 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar par�metros para o processamento"
         CALL pol1136_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Par�metros informados com sucesso !'
            LET p_ies_cons = TRUE
            NEXT OPTION 'Carregar'
         ELSE
            ERROR 'Opera��o cancelada !!!'
            LET p_ies_cons = FALSE
         END IF 
      COMMAND "Carregar" "Carrega os dados dos arquivos textos"
         IF p_ies_cons THEN
            CALL pol1136_carga_txt() RETURNING p_status
            IF p_status THEN
               ERROR 'Opera��o efetuada com sucesso!'
               NEXT OPTION 'Processar'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF 
         ELSE
            ERROR 'Informe os par�mentors previamente!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Processar" "Processa a grava��o das notas no Logix"
         CALL pol1136_gera_notas() RETURNING p_status
         IF p_status THEN
            ERROR 'Opera��o efetuada com sucesso!'
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Notas c/ erro" "Acesso �s notas rejeitadas"
         CALL log120_procura_caminho("pol1139") RETURNING p_comando
         LET p_comando = p_comando CLIPPED
         RUN p_comando RETURNING p_status   
      COMMAND KEY ("L") "cLientes c/ erro" "Acesso aos clientes rejeitados"
         CALL log120_procura_caminho("pol1138") RETURNING p_comando
         LET p_comando = p_comando CLIPPED
         RUN p_comando RETURNING p_status   
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1136_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1136

END FUNCTION


#-----------------------#
 FUNCTION pol1136_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1136_limpa_tela()
#----------------------------#

   DISPLAY p_cod_empresa to cod_empresa
   CLEAR FORM
   
END FUNCTION

#-------------------------#
FUNCTION pol1136_informar()
#-------------------------#

   CALL pol1136_limpa_tela()
   
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   LET p_tela.data = TODAY
   
   INPUT BY NAME p_tela.*  WITHOUT DEFAULTS
      
      AFTER FIELD data
			   IF p_tela.data IS NULL THEN
				    ERROR"Campo de preenchimento obrigat�rio"
				    NEXT FIELD data 
			   END IF 
      
      AFTER FIELD hora
			   IF p_tela.hora IS NULL THEN
				    ERROR"Campo de preenchimento obrigat�rio"
				    NEXT FIELD hora
			    END IF 
			    
			    IF LENGTH(p_tela.hora) < 5 THEN
			       ERROR 'Informe a hora no formato hh:mm - ex: 10:55 !'
			       NEXT FIELD hora
			    END IF
			
			AFTER INPUT
			   IF NOT INT_FLAG THEN
			      LET p_dat_char = p_tela.data
			      LET p_arq_mestre = p_cod_empresa,'NF_MESTRE_',
			             p_dat_char[1,2],p_dat_char[4,5],p_dat_char[7,10],
			             p_tela.hora[1,2],p_tela.hora[4,5],'.TXT'
			      LET p_arq_itens = p_cod_empresa,'NF_ITENS_',
			             p_dat_char[1,2],p_dat_char[4,5],p_dat_char[7,10],
			             p_tela.hora[1,2],p_tela.hora[4,5],'.TXT'

			      LET p_arq_cli = p_cod_empresa,'CLIENTES_NFS_',
			             p_dat_char[1,2],p_dat_char[4,5],p_dat_char[7,10],
			             p_tela.hora[1,2],p_tela.hora[4,5],'.TXT'
			      
			      DISPLAY p_arq_mestre to arq_meste
			      DISPLAY p_arq_itens to arq_itens
			      DISPLAY p_arq_cli to arq_cli
			   END IF
			     
   END INPUT
   
	 IF int_flag THEN
		  CALL pol1136_limpa_tela()
      RETURN FALSE
	 END IF
	 
	 RETURN TRUE
	 
END FUNCTION

#---------------------------#
FUNCTION pol1136_carga_txt()
#---------------------------#

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
      
   IF NOT pol1136_cria_nf_tmp() THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
      
   IF NOT pol1136_carga_arquivos() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   CALL log0030_mensagem(p_men,'info')
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1136_cria_nf_tmp()
#-----------------------------#

   DROP TABLE nf_mestre_tmp
   
   CREATE TEMP TABLE nf_mestre_tmp(
   cod_empresa	    char(02),
   tip_nf 	        Char(03),  
   num_nf	          decimal(6,0),
   ser_nf	          Char(02),
   cod_cliente	    Char(14),             
   dat_emissao	    date,                 
   dat_vencto 	    date,                 
   val_bruto_nf 	  decimal(17,2),      
   val_desc_incond	decimal(17,2),    
   val_liq_nf 	    decimal(17,2),    
   val_desc_cenp    decimal(17,2),  
   val_tot_nf 	    decimal(17,2),        
   val_duplicata	  decimal(17,2),      
   vum_boleto	      Char(15),               
   ies_situa_nf	    char(1),              
   dat_cancel	      date,                   
   txt_nf     	    Char(300),  
   tip_nf_dev	      Char(03),             
   num_nf_dev	      decimal(6,0),           
   ser_nf_dev       Char(02),
   chave_acesso    char(44),
   protocolo       char(15),
   dat_protocolo   date,
   hor_protocolo   char(08));

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","NF_MESTRE_TMP")
			RETURN FALSE
	 END IF

   DROP TABLE nf_itens_tmp

   CREATE TEMP TABLE nf_itens_tmp (
   cod_empresa     char(02),
   num_nf          decimal(6,0),                       
   ser_nf          Char(02),                   
   cod_cliente     Char(15),                     
   num_seq_nf      Decimal(5,0),                   
   cod_item        Char(15),                         
   den_item	       Char(76),                         
   ncm             Char(15),  
   grupo_item      Char(20),       
   qtd_item        decimal(12,3),                    
   cod_unidade     Char(03),                   
   pre_unit_bruto  decimal(17,6),                    
   pre_unit_liq    decimal(17,6), 
   Val_bruto_item  decimal(17,2),                    
   val_liq_item    decimal(17,2), 
   val_desc_incond decimal(17,2), 
   val_desc_cenp   decimal(17,2),  
   val_item_dupl   decimal(17,2),  
   pct_iss         decimal(5,2),                    
   val_base_iss	   decimal(17,2),            
   val_iss         decimal(17,2),                    
   pct_icms	       decimal(5,2),                     
   val_base_icms   decimal(17,2),          
   val_icms	       decimal(17,2),                
   pct_irpj	       decimal(5,2),                     
   val_base_irpj	 decimal(15,2),              
   val_irpj	       decimal(15,2),                    
   pct_csll	       decimal(5,2),                     
   val_base_csll	 decimal(15,2),              
   val_csll	       decimal(15,2),                    
   pct_cofins	     decimal(5,2),                   
   val_base_cofins decimal(15,2),            
   val_cofins	     decimal(15,2),                  
   pct_pis         decimal(5,2),                     
   val_base_pis    decimal(15,2),                
   val_pis	       decimal(15,2),                    
   ctr_estoque	   Char(1),                  
   txt_item	       Char(300),
   cod_fiscal      decimal(9,0)
   );

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","NF_ITENS_TMP")
			RETURN FALSE
	 END IF

   DROP TABLE clientes_tmp
   
   CREATE TEMP TABLE clientes_tmp(
   cod_cliente	  char(15), 
   num_cnpj_cpf   char(15),  
   tip_cliente	  Char(01), 
   nom_cliente	  Char(35), 
   nom_reduzido   Char(15),  
   end_cliente	  Char(36), 
   den_bairro	    Char(19),   
   cidade         Char(50),  
   cod_cidade     char(10),  
   cod_cep        Char(09),  
   estado         Char(02),  
   num_telefone   char(15),  
   num_fax	      Char(15), 
   insc_municipal Char(15),  
   insc_estadual  Char(15),  
   end_cob        char(36),  
   bairro_cob     Char(19),  
   cidade_cob     Char(50),  
   cod_cid_cob	  char(10), 
   estado_cob     Char(02),  
   cod_cep_cob	  Char(09), 
   contato        Char(15),  
   email1	        Char(50), 
   email2	        Char(50), 
   email3	        Char(50),
   cli_fornec     char(01));
   
	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CRIANDO","CLIENTES_TMP")
			RETURN FALSE
	 END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1136_carga_arquivos()
#--------------------------------#

   IF NOT pol1136_del_tabs() THEN                                  
      RETURN FALSE                                                 
   END IF                                                          

   LET p_men = 'RESUMO DA CARGA:\n'                                      
                                                                   
   LET p_nom_arquivo = p_caminho CLIPPED, p_arq_mestre                
   LOAD from p_nom_arquivo INSERT INTO nf_mestre_tmp                  
                                                                   
   IF STATUS = 0 THEN                                                 
      IF NOT pol1136_carrega_mestre() THEN                            
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_mestre CLIPPED,                
                  ': carregado com sucesso;\n'                        
   ELSE                                                               
      IF STATUS <> -805 THEN                                          
         CALL log003_err_sql("LOAD",p_nom_arquivo)                    
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_mestre CLIPPED,                
                  ': n�o encontrado;\n'   
   END IF                                                             
                                                                   
                                                                   
   LET p_nom_arquivo = p_caminho CLIPPED, p_arq_itens                 
   LOAD from p_nom_arquivo INSERT INTO nf_itens_tmp                   
                                                                   
   IF STATUS = 0 THEN                                                 
      IF NOT pol1136_carrega_itens() THEN                             
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_itens CLIPPED,                 
                  ': carregado com sucesso;\n'                        
   ELSE                                                               
      IF STATUS <> -805 THEN                                          
         CALL log003_err_sql("LOAD",p_nom_arquivo)                    
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_itens CLIPPED,                 
                  ': n�o encontrado;\n'                               
   END IF                                                             
                                                                   
   LET p_nom_arquivo = p_caminho CLIPPED, p_arq_cli                   
   LOAD from p_nom_arquivo INSERT INTO clientes_tmp                   
                                                                   
   IF STATUS = 0 THEN                                                 
      IF NOT pol1136_carrega_cliente() THEN                           
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_cli CLIPPED,                   
                  ': carregado com sucesso;\n'                        
   ELSE                                                               
      IF STATUS <> -805 THEN                                          
         CALL log003_err_sql("LOAD",p_nom_arquivo)                    
         RETURN FALSE                                                 
      END IF                                                          
      LET p_men = p_men CLIPPED, p_arq_cli CLIPPED,                   
                  ': n�o encontrado;\n'                               
   END IF                                                             
                                                                   
   RETURN TRUE                                                        

END FUNCTION

#---------------------------#
FUNCTION pol1136_del_tabs()
#---------------------------#

   DELETE FROM nf_mestre_509
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','nf_mestre_509')
      RETURN FALSE
   END IF

   DELETE FROM nf_itens_509
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','nf_mestre_509')
      RETURN FALSE
   END IF

   DELETE FROM clientes_509
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','clientes_509')
      RETURN FALSE
   END IF

   DELETE FROM rejeicao_nf_509
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','rejeicao_nf_509')
      RETURN FALSE
   END IF

   DELETE FROM rejeicao_cli_509
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','rejeicao_cli_509')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#-------------------------------#   
FUNCTION pol1136_carrega_mestre()
#-------------------------------#

   SELECT MAX(id_registro)
     INTO p_id_registro
     FROM nf_mestre_509

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nf_mestre_509:MAX')
      RETURN FALSE
   END IF
   
   IF p_id_registro IS NULL THEN
      LET p_id_registro = 0
   END IF

   DECLARE cq_mest CURSOR FOR
    SELECT *
      FROM nf_mestre_tmp
   
   FOREACH cq_mest INTO p_nf_mestre.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_mest')
         RETURN FALSE
      END IF
      
      LET p_id_registro = p_id_registro + 1
      LET p_nf_mestre.nom_arquivo = p_arq_mestre
      LET p_nf_mestre.cod_estatus = 'R'
      LET p_nf_mestre.id_registro = p_id_registro
      
      INSERT INTO nf_mestre_509 VALUES(p_nf_mestre.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','nf_mestre_509:cq_mest')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   DROP TABLE nf_mestre_tmp
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#   
FUNCTION pol1136_carrega_itens()
#-------------------------------#

   DECLARE cq_it_tmp CURSOR FOR
    SELECT *
      FROM nf_itens_tmp
   
   FOREACH cq_it_tmp INTO p_nf_item.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_it_tmp')
         RETURN FALSE
      END IF
      
      LET p_nf_item.nom_arquivo   = p_arq_itens
      LET p_nf_item.pct_ipi       = 0
      LET p_nf_item.val_base_ipi  = 0
      LET p_nf_item.val_ipi       = 0
      LET p_nf_item.seq_nf_dev    = 0
      LET p_nf_item.motivo_dev    = 0

      IF p_nf_item.ctr_estoque IS NULL OR
            p_nf_item.ctr_estoque = ' ' THEN
         LET p_nf_item.ctr_estoque = 'N'
      END IF
      
      INSERT INTO nf_itens_509 VALUES(p_nf_item.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','nf_itens_509')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   DROP TABLE nf_itens_tmp
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#   
FUNCTION pol1136_carrega_cliente()
#--------------------------------#

   SELECT MAX(id_registro)
     INTO p_id_registro
     FROM clientes_509

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','clientes_509:MAX')
      RETURN FALSE
   END IF
   
   IF p_id_registro IS NULL THEN
      LET p_id_registro = 0
   END IF

   DECLARE cq_cli_tmp CURSOR FOR
    SELECT *
      FROM clientes_tmp
   
   FOREACH cq_cli_tmp INTO p_clientes.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_cli_tmp')
         RETURN FALSE
      END IF
      
      LET p_id_registro = p_id_registro + 1
      LET p_clientes.nom_arquivo = p_arq_cli
      LET p_clientes.cod_estatus = 'R'
      LET p_clientes.id_registro = p_id_registro
      LET p_clientes.cod_empresa = p_cod_empresa
      
      IF p_clientes.insc_estadual[1] MATCHES '[0123456789]' THEN
      ELSE
         LET p_clientes.insc_estadual = ''
      END IF
      
      IF NOT pol1136_end_com_virgula() THEN
         LET p_clientes.end_cliente[36] = ','
      END IF

      IF p_clientes.cli_fornec = 'F' THEN
         IF p_clientes.num_telefone IS NULL OR p_clientes.num_telefone = ' ' THEN
            LET p_clientes.num_telefone = '1111111'
         END IF
      END IF
      
      INSERT INTO clientes_509 VALUES(p_clientes.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','clientes_509:cq_cli_tmp')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   DROP TABLE clientes_tmp
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1136_end_com_virgula()
#---------------------------------#

   DEFINE p_ind   INTEGER,
          p_carac CHAR(01)
   
   FOR p_ind = 1 TO LENGTH(p_clientes.end_cliente)
       LET p_carac = p_clientes.end_cliente[p_ind]
       IF p_carac = ',' THEN
          RETURN TRUE
       END IF
   END FOR
   
   RETURN FALSE

END FUNCTION

#---------------------------#
FUNCTION pol1136_gera_notas()
#---------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   LET p_cli_rejei = 0
   LET p_cli_grav = 0
   
   IF NOT pol1136_le_clientes_509() THEN
      RETURN FALSE
   END IF

   IF p_cli_rejei = 0 THEN
      
      CALL log085_transacao("BEGIN")

      IF NOT pol1136_grava_clientes() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
   END IF    

   LET p_nf_despre = 0
   LET p_nf_rejei = 0
   LET p_nf_grav = 0
   
   DECLARE cq_notas CURSOR WITH HOLD FOR
    SELECT *
      FROM nf_mestre_509
     WHERE cod_empresa = p_cod_empresa 
       AND cod_estatus = 'R'
     ORDER BY ies_situa_nf DESC
   
   FOREACH cq_notas INTO p_nf_mestre.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_notas')
         RETURN FALSE
      END IF

      DELETE FROM rejeicao_nf_509
       WHERE cod_empresa = p_nf_mestre.cod_empresa
         AND id_nf_mestre = p_nf_mestre.id_registro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','REJEICAO_NF_509:CQ_NOTAS')
         RETURN FALSE
      END IF
      
      LET p_rejeitou = FALSE

      IF p_nf_mestre.tip_nf = 'NF' OR p_nf_mestre.tip_nf = 'NFD' THEN
         LET p_ssr_nf = pol1136_le_par_omc('SUB_SER_NF_PRODUT')
         LET p_tip_docum = 'FATPRDSV'
      ELSE
         IF p_nf_mestre.tip_nf = 'NFS' THEN
            LET p_ssr_nf = pol1136_le_par_omc('SUB_SER_NF_SERVICO')
            LET p_tip_docum = 'FATSERV'
         ELSE
            LET p_ssr_nf = pol1136_le_par_omc('SUB_SER_NF_ENTRADA')
            LET p_tip_docum = ''
         END IF
      END IF
      
      IF NOT pol1136_checa_existencia() THEN
         RETURN FALSE
      END IF
      
      IF p_rejeitou THEN

         IF NOT pol1136_atu_nf_mestre('D') THEN
            RETURN FALSE
         END IF

         LET p_nf_despre = p_nf_despre + 1
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1136_consiste_nota() THEN
         RETURN FALSE
      END IF

      IF NOT pol1136_consiste_itens() THEN
         RETURN FALSE
      END IF
         
      IF p_rejeitou THEN
         LET p_nf_rejei = p_nf_rejei + 1
      END IF

   END FOREACH

   IF p_nf_rejei = 0 THEN
      CALL log085_transacao("BEGIN")

      IF NOT pol1136_grava_notas() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      CALL log085_transacao("COMMIT")
   END IF
  
#  Os comandos abaixo acertam a inscricao estadual gravando nulo caso encontre registo como I ou S.
    UPDATE clientes
	SET ins_estadual = null
	WHERE (lower(ins_estadual) LIKE '%i%'
	AND    lower(ins_estadual) LIKE '%s%')

	UPDATE  fornecedor
	SET ins_estadual = null
	WHERE (lower(ins_estadual) LIKE '%i%'
	AND    lower(ins_estadual) LIKE '%s%')
   
   
   LET p_msg = 'Notas rejeitadas....: ', p_nf_rejei, '\n',
               'Notas gravadas......: ', p_nf_grav, '\n\n',
               'Clientes rejeitados.: ', p_cli_rejei, '\n',
               'Clientes gravadas...: ', p_cli_grav, '\n'
               
   CALL log0030_mensagem(p_msg,'information')
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1136_checa_existencia()
#---------------------------------#

   IF p_nf_mestre.tip_nf = 'NF' OR p_nf_mestre.tip_nf = 'NFS' THEN
      {SELECT COUNT(empresa)
        INTO p_count
        FROM fat_nf_mestre
       WHERE empresa = p_nf_mestre.cod_empresa
         AND tip_nota_fiscal = p_tip_docum
         AND nota_fiscal     = p_nf_mestre.num_nf
         AND serie_nota_fiscal = p_nf_mestre.ser_nf
         AND subserie_nf = p_ssr_nf
         #AND cliente = p_nf_mestre.cod_cliente

      IF STATUS <> 0 THEN
         CALL log003_err_sql('','CONSISTINDO EXISTENCIA DA NF')
         RETURN FALSE
      END IF

      IF p_count > 0 THEN
         LET p_msg = 'NOTA FISCAL DE SAIDA JA INEXISTENTE NO LOGIX'
         CALL pol1136_grava_rejeicao()
      END IF}
   ELSE
      SELECT COUNT(cod_empresa)
        INTO p_count
        FROM nf_sup
       WHERE cod_empresa = p_nf_mestre.cod_empresa
         AND num_nf      = p_nf_mestre.num_nf
         AND ser_nf      = p_nf_mestre.ser_nf
         #AND ssr_nf      = p_ssr_nf
         AND ies_especie_nf = p_nf_mestre.tip_nf
         AND cod_fornecedor = p_nf_mestre.cod_cliente

      IF STATUS <> 0 THEN
         CALL log003_err_sql('','CONSISTINDO EXISTENCIA DA NF')
         RETURN FALSE
      END IF

      IF p_count > 0 THEN
         LET p_msg = 'NOTA FISCAL DE ENTRADA JA INEXISTENTE NO LOGIX'
         CALL pol1136_grava_rejeicao()
      END IF
   END IF

   RETURN TRUE

END FUNCTION

  
#-------------------------------#
FUNCTION pol1136_consiste_nota()
#-------------------------------#
   
   LET p_nf_item.num_seq_nf = 0
   
   IF p_nf_mestre.cod_empresa IS NULL THEN
      LET p_msg = 'CODIGO DA EMPRESA ESTA NULO'
      CALL pol1136_grava_rejeicao()
   ELSE
      SELECT cod_empresa
        FROM empresa
       WHERE cod_empresa = p_nf_mestre.cod_empresa
      
      IF STATUS = 100 THEN
         LET p_msg = 'EMPRESA NAO CADASTRADA'
         CALL pol1136_grava_rejeicao()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CONSISTINDO EMPRESA')
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_nf_mestre.tip_nf IS NULL THEN
      LET p_msg = 'TIPO DE NOTA ESTA NULO'
      CALL pol1136_grava_rejeicao()
   ELSE
      IF p_nf_mestre.tip_nf = 'NF'  OR
         p_nf_mestre.tip_nf = 'NFS' OR
         p_nf_mestre.tip_nf = 'NFE' OR
         p_nf_mestre.tip_nf = 'NFD' THEN
      ELSE
         LET p_msg = 'TIPO DE NOTA INVALIDO'
         CALL pol1136_grava_rejeicao()
      END IF
   END IF

   IF p_nf_mestre.num_nf IS NULL THEN
      LET p_msg = 'NUMERO DA NOTA ESTA NULO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.ser_nf IS NULL THEN
      LET p_msg = 'SERIE DA NOTA ESTA NULA'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.dat_emissao IS NULL THEN
      LET p_msg = 'DATA DA EMISSAO ESTA NULA'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.tip_nf = 'NF'  OR
      p_nf_mestre.tip_nf = 'NFS' THEN
      IF p_nf_mestre.dat_vencto IS NULL THEN
         LET p_msg = 'DATA DE VENCIMENTO ESTA NULA'
         CALL pol1136_grava_rejeicao()
      END IF
   END IF

   IF p_nf_mestre.val_bruto_nf IS NULL THEN
      LET p_msg = 'VALOR BRUTO DA NF ESTA NULO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_desc_incond IS NULL THEN
      LET p_msg = 'VALOR DESCONTO INCONDICIONAL ESTA NULO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_liq_nf IS NULL THEN
      LET p_msg = 'VALOR LIQUIDO DA NF ESTA NULO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_desc_cenp IS NULL THEN
      LET p_msg = 'VALOR DESCONTO CENP ESTA NULO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_tot_nf IS NULL THEN
      LET p_msg = 'VALOR TOTAL DA NF ESTA NULO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_duplicata IS NULL THEN
      LET p_msg = 'VALOR REFERENCIA P/ DUPLICATA ESTA NULO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.ies_situa_nf MATCHES '[NC]' THEN
      IF p_nf_mestre.ies_situa_nf = 'C' THEN
         IF p_nf_mestre.dat_cancel IS NULL THEN
            LET p_msg = 'DATA DO CANCELAMENTO ESTA NULA'
            CALL pol1136_grava_rejeicao()
         END IF
      END IF
   ELSE
      LET p_msg = 'COUNTEUDO DA SITUACAO DA NF INVALIDO'
      CALL pol1136_grava_rejeicao()
   END IF

   IF p_nf_mestre.cod_cliente IS NULL THEN
      LET p_msg = 'CODIGO DO CLIENTE/FORNECEDOR ESTA NULO'
      CALL pol1136_grava_rejeicao()
   ELSE
      IF p_tip_docum IS NOT NULL THEN # NF ou NFS
         SELECT cod_cliente
           FROM clientes
          WHERE cod_cliente = p_nf_mestre.cod_cliente
      ELSE
         SELECT cod_fornecedor
           FROM fornecedor
          WHERE cod_fornecedor = p_nf_mestre.cod_cliente
      END IF
      
      IF STATUS = 100 THEN
         LET p_msg = 'CLIENTE/FORNECEDOR NAO CADASTRADO NO LOGIX'
         CALL pol1136_grava_rejeicao()
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('CONSISTINDO','CLIENTE/FORNECEDOR')
            RETURN FALSE
         END IF
      END IF   
   
   END IF

   IF p_nf_mestre.tip_nf = 'NFS' THEN
   ELSE
      IF p_nf_mestre.chave_acesso IS NULL THEN
         LET p_msg = 'CHAVE DE ACESSO ESTA NULA'
         CALL pol1136_grava_rejeicao()
      END IF
      IF p_nf_mestre.protocolo IS NULL THEN
         LET p_msg = 'PROTOCULO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF
      IF p_nf_mestre.dat_protocolo IS NULL THEN
         LET p_msg = 'DATA DO PROTOCOLO ESTA NULA'
         CALL pol1136_grava_rejeicao()
      END IF
      IF p_nf_mestre.hor_protocolo IS NULL THEN
         LET p_msg = 'HORA DO PROTOCOLO ESTA NULA'
         CALL pol1136_grava_rejeicao()
      END IF
   END IF
   
   IF p_nf_mestre.tip_nf = 'NFD' THEN
      LET p_msg = NULL
      IF p_nf_mestre.tip_nf_dev = 'NF'  OR 
         p_nf_mestre.tip_nf_dev = 'NFS' THEN
         IF p_nf_mestre.tip_nf_dev = 'NF' THEN
            LET p_tip_docum = 'FATPRDSV'
         ELSE
            LET p_tip_docum = 'FATSERV'
         END IF
      ELSE
         LET p_msg = 'TIPO DA NF ORIGEM DA DEVOLUCAO INVALIDO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_mestre.num_nf_dev IS NULL THEN
         LET p_msg = 'NUMERO DA NF ORIGEM DA DEVOLUCAO INVALIDO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_mestre.ser_nf_dev IS NULL THEN
         LET p_msg = 'SERIE DA NF ORIGEM DA DEVOLUCAO INVALIDO'
         CALL pol1136_grava_rejeicao()
      END IF
      
      IF p_msg IS NULL THEN
         SELECT COUNT(empresa)
           INTO p_count
           FROM fat_nf_mestre
          WHERE empresa = p_nf_mestre.cod_empresa
            AND tip_nota_fiscal = p_tip_docum
            AND nota_fiscal     = p_nf_mestre.num_nf_dev
            AND serie_nota_fiscal = p_nf_mestre.ser_nf_dev
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CONSISTINDO NUM. NF DEV NA TAB FAT_NF_MESTRE')
            RETURN FALSE
         END IF
         IF p_count = 0 THEN
            SELECT COUNT(num_nf)
              INTO p_count
              FROM nf_mestre_509
             WHERE cod_empresa = p_nf_mestre.cod_empresa
               AND num_nf = p_nf_mestre.num_nf_dev
               AND ser_nf = p_nf_mestre.ser_nf_dev
               AND tip_nf = p_nf_mestre.tip_nf_dev
            IF STATUS <> 0 THEN
               CALL log003_err_sql('','CONSISTINDO NUM. NF DEV NA TAB NF_MESTRE_509')
               RETURN FALSE
            END IF
            IF p_count = 0 THEN 
               LET p_msg = 'NUMERO DA NF ORIGEM DE DEVOLUCAO INEXISTENTE'
               CALL pol1136_grava_rejeicao()
            END IF
         END IF
      END IF
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1136_consiste_itens()
#-------------------------------#

   DEFINE p_tem_itens SMALLINT
   
   LET p_tem_itens = FALSE
   
   DECLARE cq_ci CURSOR WITH HOLD FOR
    SELECT *
      FROM nf_itens_509
     WHERE cod_empresa = p_nf_mestre.cod_empresa
       AND cod_cliente = p_nf_mestre.cod_cliente
       AND num_nf      = p_nf_mestre.num_nf
       AND ser_nf      = p_nf_mestre.ser_nf
       
   FOREACH cq_ci INTO p_nf_item.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_CI')
         RETURN FALSE
      END IF
      
      LET p_tem_itens = TRUE

      IF p_nf_item.num_seq_nf IS NULL THEN
         LET p_msg = 'A SEQUENCIA DA NF ESTA NULA'
         CALL pol1136_grava_rejeicao()
      END IF
      
      IF p_nf_item.cod_item IS NULL THEN
         LET p_msg = 'CODIGO DO ITEM ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.qtd_item IS NULL THEN
         LET p_msg = 'QUANTIDADE DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.pre_unit_bruto IS NULL THEN
         LET p_msg = 'PRECO BRUTO DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.pre_unit_liq IS NULL THEN
         LET p_msg = 'PRECO LIQUIDO DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.Val_bruto_item IS NULL THEN
         LET p_msg = 'VALOR BRUTO DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_liq_item IS NULL THEN
         LET p_msg = 'VALOR LIQUIDO DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_desc_incond IS NULL THEN
         LET p_msg = 'VALOR DESC INCOND DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_desc_cenp IS NULL THEN
         LET p_msg = 'VALOR DESC CENP DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.grupo_item IS NULL THEN
         LET p_msg = 'GRUPO DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      ELSE
         SELECT cod_item
           INTO p_item_espelho
           FROM grupo_item_509
          WHERE grupo_item = p_nf_item.grupo_item
		    AND cod_empresa = p_cod_empresa
         IF STATUS = 100 THEN
            LET p_item_espelho = NULL
            LET p_msg = 'GRUPO DO PRODUTO NAO CADASRADO'
            CALL pol1136_grava_rejeicao()
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('','CONSISTINDO GRUPO_ITEM')
               RETURN FALSE
            END IF
         END IF
      END IF

      IF p_nf_item.ctr_estoque IS NULL THEN
         LET p_msg = 'CONTROLE DE ESTOQUE ESTA NULO'
         CALL pol1136_grava_rejeicao()
      ELSE
         IF p_nf_item.ctr_estoque MATCHES '[SN]' THEN
         ELSE
            LET p_msg = 'CONTROLE DE ESTOQUE INVALIDO'
            CALL pol1136_grava_rejeicao()
         END IF
      END IF

      IF p_nf_item.pct_iss IS NULL THEN
         LET p_msg = '% DE ISS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_iss IS NULL THEN
         LET p_msg = 'VALOR BASE DE ISS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_iss IS NULL THEN
         LET p_msg = 'VALOR DO ISS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.pct_icms IS NULL THEN
         LET p_msg = '% DE ICMS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_icms IS NULL THEN
         LET p_msg = 'BASE DE ICMS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_icms IS NULL THEN
         LET p_msg = 'VALOR DO ICMS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.pct_irpj IS NULL THEN
         LET p_msg = '% DE IR DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_irpj IS NULL THEN
         LET p_msg = 'BASE DE IR DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_irpj IS NULL THEN
         LET p_msg = 'VALOR DO IR DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.pct_csll IS NULL THEN
         LET p_msg = '% DE CSLL DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_csll IS NULL THEN
         LET p_msg = 'BASE DE CSLL DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_csll IS NULL THEN
         LET p_msg = 'VALOR DO CSLL DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.pct_cofins IS NULL THEN
         LET p_msg = '% DE COFINS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_cofins IS NULL THEN
         LET p_msg = 'BASE DE COFINS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_cofins IS NULL THEN
         LET p_msg = 'VALOR DO COFINS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.pct_pis IS NULL THEN
         LET p_msg = '% DE PIS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_pis IS NULL THEN
         LET p_msg = 'BASE DE PIS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_item.val_pis IS NULL THEN
         LET p_msg = 'VALOR DO PIS DO PRODUTO ESTA NULO'
         CALL pol1136_grava_rejeicao()
      END IF

      IF p_nf_mestre.tip_nf = 'NFS' THEN
      ELSE
         IF p_nf_item.cod_fiscal IS NULL THEN
            LET p_msg = 'CODIGO FISCAL DO PRODUTO ESTA NULO'
            CALL pol1136_grava_rejeicao()
         ELSE
            SELECT den_cod_fiscal
              FROM codigo_fiscal
             WHERE cod_fiscal = p_nf_item.cod_fiscal
            IF STATUS = 100 THEN
               LET p_msg = 'CODIGO FISCAL INEXISTENTE NO LOGIX'
               CALL pol1136_grava_rejeicao()
            ELSE   
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('','CONSISTINDO CODIGO FISCAL')
                  RETURN FALSE
               END IF
            END IF
         END IF       
      END IF

      LET p_cod_unid_med = NULL
      
      IF p_nf_item.cod_item IS NOT NULL THEN
         SELECT cod_unid_med
           INTO p_cod_unid_med
           FROM item
          WHERE cod_empresa = p_nf_item.cod_empresa
            AND cod_item    = p_nf_item.cod_item
      
         IF STATUS = 100 THEN
            IF p_item_espelho IS NOT NULL THEN
               CALL pol1136_ins_item()
            END IF
         ELSE   
            IF STATUS <> 0 THEN
               CALL log003_err_sql('','CONSISTINDO PRODUTO')
               RETURN FALSE
            END IF
         END IF
      END IF

      IF p_nf_item.cod_unidade IS NULL THEN
         IF p_cod_unid_med IS NULL THEN
            LET p_nf_item.cod_unidade = pol1136_le_par_omc('COD_UNID_MEDIDA')
         ELSE
            LET p_nf_item.cod_unidade = p_cod_unid_med
         END IF
         UPDATE nf_itens_509
            SET cod_unidade = p_nf_item.cod_unidade
          WHERE cod_empresa = p_nf_mestre.cod_empresa
            AND cod_cliente = p_nf_mestre.cod_cliente
            AND num_nf      = p_nf_mestre.num_nf
            AND ser_nf      = p_nf_mestre.ser_nf
            AND num_seq_nf  = p_nf_item.num_seq_nf
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','nf_itens_509')
            RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   IF NOT p_tem_itens THEN
      LET p_msg = 'NF SEM OS ITENS CORRESPONDENTES'
      CALL pol1136_grava_rejeicao()
   END IF
   
   RETURN TRUE

END FUNCTION      

#-------------------------------#
FUNCTION pol1136_grava_rejeicao()
#-------------------------------#

   LET p_rejeitou = TRUE
   
   INSERT INTO rejeicao_nf_509
    VALUES(p_nf_mestre.cod_empresa,
           p_nf_mestre.nom_arquivo,
           p_nf_mestre.id_registro,
           p_nf_item.num_seq_nf,
           p_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','rejeicao_nf_509')
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1136_ins_item()
#--------------------------#

   CALL pol1142_copia_item(p_nf_item.cod_empresa, 
          p_item_espelho, p_nf_item.cod_item) RETURNING p_msg
   
   IF p_msg IS NOT NULL THEN
      CALL pol1136_grava_rejeicao()
      CALL log0030_mensagem(p_msg,'excla')
      RETURN
   END IF
   
   UPDATE item
      SET den_item        = p_nf_item.den_item
    WHERE cod_empresa = p_nf_item.cod_empresa
      AND cod_item    = p_nf_item.cod_item

   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status CLIPPED, ' ATUALIZANDO ITEM ',
             p_nf_item.cod_item CLIPPED,' NA TABELA ITEM'
      CALL pol1136_grava_rejeicao()
   END IF
      
END FUNCTION

#----------------------------#      
FUNCTION pol1136_grava_notas()
#----------------------------#

   DECLARE cq_grv_notas CURSOR WITH HOLD FOR
    SELECT *
      FROM nf_mestre_509
     WHERE cod_empresa = p_cod_empresa 
       AND cod_estatus = 'R'
     ORDER BY tip_nf, ies_situa_nf DESC
     
   FOREACH cq_grv_notas INTO p_nf_mestre.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_GRV_NOTAS')
         RETURN FALSE
      END IF

      LET p_nf_grav = p_nf_grav + 1

      IF p_nf_mestre.tip_nf = 'NFD' OR p_nf_mestre.tip_nf = 'NFE' THEN
         IF NOT pol1136_grava_entrda() THEN 
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1136_grava_saida() THEN 
            RETURN FALSE
         END IF
      END IF

      IF NOT pol1136_atu_nf_mestre('A') THEN
         RETURN FALSE
      END IF
    
   END FOREACH

   RETURN TRUE
   
END FUNCTION   

#--------------------------------------------#
FUNCTION pol1136_atu_nf_mestre(p_cod_estatus)
#--------------------------------------------#
  
   DEFINE p_cod_estatus CHAR(01)
   
   UPDATE nf_mestre_509
      SET cod_estatus = p_cod_estatus
    WHERE cod_empresa = p_nf_mestre.cod_empresa
      AND id_registro = p_nf_mestre.id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','NF_MESTRE_509')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#      
FUNCTION pol1136_cancela_nf()
#----------------------------#      

   DEFINE p_dat_cancel DATETIME YEAR TO SECOND
   
   LET p_dat_cancel = p_nf_mestre.dat_cancel
   
   UPDATE fat_nf_mestre
      SET sit_nota_fiscal = 'C',
          dat_hor_cancel  = p_dat_cancel
    WHERE empresa =  p_nf_mestre.cod_empresa
      AND tip_nota_fiscal = p_tip_docum
      AND nota_fiscal = p_nf_mestre.num_nf
      AND serie_nota_fiscal = p_nf_mestre.ser_nf
      AND cliente = p_nf_mestre.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','FAT_NF_MESTRE')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
      
#----------------------------#      
FUNCTION pol1136_grava_saida()
#----------------------------#

   IF p_nf_mestre.tip_nf = 'NF' THEN
      LET p_tip_docum = 'FATPRDSV'
   ELSE
      IF p_nf_mestre.tip_nf = 'NFS' THEN
         LET p_tip_docum = 'FATSERV'
      ELSE
         RETURN TRUE
      END IF
   END IF

   IF p_nf_mestre.ies_situa_nf = 'C' THEN
      IF NOT pol1136_cancela_nf() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   SELECT cod_uni_feder
     INTO l_estado
     FROM cidades a,
          clientes b
    WHERE a.cod_cidade  = b.cod_cidade
      AND b.cod_cliente = p_nf_mestre.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estado do cliente')
      RETURN FALSE
   END IF
     
   IF NOT pol1136_grava_nf_mestre() THEN
      RETURN FALSE
   END IF

   IF p_nf_mestre.txt_nf IS NOT NULL THEN
      IF NOT pol1136_grava_texto_nf(p_nf_mestre.txt_nf) THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1136_grava_item_nf() THEN
      RETURN FALSE
   END IF
   
   UPDATE fat_nf_mestre
      SET peso_liquido = p_peso_bruto,
          peso_bruto  = p_peso_bruto
    WHERE empresa = p_nf_mestre.cod_empresa
      AND trans_nota_fiscal = p_trans_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualzando','fat_nf_mestre')
      RETURN FALSE
   END IF
    
   IF NOT pol1136_grava_mestre_fisc() THEN
      RETURN FALSE
   END IF

   IF NOT pol1136_grava_dupl() THEN
      RETURN FALSE
   END IF

   IF NOT pol1136_grava_nf_integra() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE   
   
END FUNCTION
      
      
#----------------------------------#
FUNCTION pol1136_le_par_omc(p_param)
#----------------------------------#

   DEFINE p_param   LIKE par_omc_509.cod_parametro
   
   DEFINE p_par_omc RECORD
          par_tipo  LIKE par_omc_509.par_tipo,
          par_dec   LIKE par_omc_509.par_dec,
          par_int   LIKE par_omc_509.par_int,
          par_dat   LIKE par_omc_509.par_dat,
          par_txt   LIKE par_omc_509.par_txt
   END RECORD
   
   LET p_tem_param = FALSE
   
   SELECT par_tipo,
          par_dec,
          par_int,
          par_dat,
          par_txt
     INTO p_par_omc.*
     FROM par_omc_509
    WHERE cod_empresa   = p_nf_mestre.cod_empresa
      AND cod_parametro = p_param

   IF STATUS = 100 THEN
      LET p_msg = 'Par�metro ',p_param CLIPPED,
                  ' n�o cadastrado no pol1137!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','PAR_OMC_509')
         RETURN NULL
      END IF
   END IF
   
   LET p_tem_param = TRUE
   
   CASE p_par_omc.par_tipo
        WHEN 'F' RETURN p_par_omc.par_dec      
        WHEN 'I' RETURN p_par_omc.par_int      
        WHEN 'D' RETURN p_par_omc.par_dat      
        WHEN 'C' RETURN p_par_omc.par_txt
   END CASE

END FUNCTION            

#----------------------------------#
FUNCTION pol1136_le_par_cli(p_param)
#----------------------------------#

   DEFINE p_param   LIKE par_omc_509.cod_parametro
   
   DEFINE p_par_omc RECORD
          par_tipo  LIKE par_omc_509.par_tipo,
          par_dec   LIKE par_omc_509.par_dec,
          par_int   LIKE par_omc_509.par_int,
          par_dat   LIKE par_omc_509.par_dat,
          par_txt   LIKE par_omc_509.par_txt
   END RECORD
   
   LET p_tem_param = FALSE

   DECLARE cq_par_cli CURSOR FOR
    SELECT par_tipo,
           par_dec,
           par_int,
           par_dat,
           par_txt
      FROM par_omc_509
     WHERE cod_parametro = p_param
   
   FOREACH cq_par_cli INTO p_par_omc.*
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','PAR_OMC_509')
         RETURN NULL
      END IF

      LET p_tem_param = TRUE
      EXIT FOREACH
      
   END FOREACH

   IF NOT p_tem_param THEN
      LET p_msg = 'Par�metro ',p_param CLIPPED,
                  ' n�o cadastrado no pol1137!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN NULL
   END IF
   
   LET p_tem_param = TRUE
   
   CASE p_par_omc.par_tipo
        WHEN 'F' RETURN p_par_omc.par_dec      
        WHEN 'I' RETURN p_par_omc.par_int      
        WHEN 'D' RETURN p_par_omc.par_dat      
        WHEN 'C' RETURN p_par_omc.par_txt
   END CASE

END FUNCTION            

#--------------------------------#
FUNCTION pol1136_grava_nf_mestre()
#--------------------------------#

   DEFINE p_cod_repres INTEGER

   DEFINE p_fat_mestre         RECORD
          empresa              char(2), 
          #trans_nota_fiscal    serial,  
          tip_nota_fiscal      char(8), 
          serie_nota_fiscal    char(3), 
          subserie_nf          smallint,
          espc_nota_fiscal     char(3), 
          nota_fiscal          integer, 
          status_nota_fiscal   char(1), 
          modelo_nota_fiscal   char(2), 
          origem_nota_fiscal   char(1), 
          tip_processamento    char(1), 
          sit_nota_fiscal      char(1), 
          cliente              char(15),
          remetent             char(15),
          zona_franca          char(1), 
          natureza_operacao    integer,     
          finalidade           char(1),     
          cond_pagto           integer,     
          tip_carteira         char(2),     
          ind_despesa_financ   decimal(7,6),
          moeda                smallint,    
          plano_venda          char(1),     
          transportadora       char(15),    
          tip_frete            char(1),     
          placa_veiculo        char(10),    
          estado_placa_veic    char(2),     
          placa_carreta_1      char(10),    
          estado_plac_carr_1   char(2),     
          placa_carreta_2      char(10),    
          estado_plac_carr_2   char(2),     
          tabela_frete         smallint,               
          seq_tabela_frete     smallint,               
          sequencia_faixa      smallint,               
          via_transporte       smallint,               
          peso_liquido         decimal(17,6),          
          peso_bruto           decimal(17,6),          
          peso_tara            decimal(17,6),          
          num_prim_volume      integer,                
          volume_cubico        decimal(17,6),          
          usu_incl_nf          char(8),                
          dat_hor_emissao      datetime year to second,
          dat_hor_saida        datetime year to second,
          dat_hor_entrega      datetime year to second,
          contato_entrega      char(40),               
          dat_hor_cancel       datetime year to second,
          motivo_cancel        smallint,     
          usu_canc_nf          char(8),      
          sit_impressao        char(1),      
          val_frete_rodov      decimal(17,2),
          val_seguro_rodov     decimal(17,2),
          val_fret_consig      decimal(17,2),
          val_segr_consig      decimal(17,2),
          val_frete_cliente    decimal(17,2),
          val_seguro_cliente   decimal(17,2),
          val_desc_merc        decimal(17,2),
          val_desc_nf          decimal(17,2),
          val_desc_duplicata   decimal(17,2),
          val_acre_merc        decimal(17,2),
          val_acre_nf          decimal(17,2),
          val_acre_duplicata   decimal(17,2),
          val_mercadoria       decimal(17,2),
          val_duplicata        decimal(17,2),
          val_nota_fiscal      decimal(17,2),
          tip_venda            decimal(2,0) 
   END RECORD

   INITIALIZE p_fat_mestre TO NULL

   LET p_fat_mestre.empresa            =  p_nf_mestre.cod_empresa            
   #LET p_fat_mestre.trans_nota_fiscal  =  0                        
   LET p_fat_mestre.tip_nota_fiscal    =  p_tip_docum             
   LET p_fat_mestre.serie_nota_fiscal  =  p_nf_mestre.ser_nf
   
   LET p_fat_mestre.subserie_nf        =  pol1136_le_par_omc('SUB_SER_NF_PRODUT')
   LET p_ssr_nf = p_fat_mestre.subserie_nf 
   
   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF
   
   LET p_fat_mestre.espc_nota_fiscal   =  p_nf_mestre.tip_nf                   
   LET p_fat_mestre.nota_fiscal        =  p_nf_mestre.num_nf             
   LET p_fat_mestre.status_nota_fiscal =  'F'  
                       
   
   IF   p_nf_mestre.tip_nf = 'NF' THEN   
		LET p_fat_mestre.modelo_nota_fiscal =  pol1136_le_par_omc('MODELO_DA_NF')
   ELSE
		LET p_fat_mestre.modelo_nota_fiscal =  ' '
   END IF 
		
   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF

   LET p_fat_mestre.origem_nota_fiscal =  pol1136_le_par_omc('ORIGEM_DA_NF')

   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF
   
   LET p_fat_mestre.tip_processamento  =  'A'                      
   LET p_fat_mestre.sit_nota_fiscal    =  p_nf_mestre.ies_situa_nf  
   LET p_fat_mestre.cliente            =  p_nf_mestre.cod_cliente
   LET p_fat_mestre.remetent           =  ' '                      
   LET p_fat_mestre.zona_franca        =  'N'    
   
   IF p_nf_mestre.tip_nf = 'NF' THEN  
      IF NOT pol1136_le_nutureza() THEN
         RETURN FALSE
      END IF
      LET p_fat_mestre.natureza_operacao = p_cod_nat_oper 
      LET p_tip_item = 'P'
   ELSE
      LET p_fat_mestre.natureza_operacao = pol1136_le_par_omc('NAT_OPER_NF_SERVICO')
      LET p_tip_item = 'S'
   END IF
   
   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF

   LET p_cod_nat_oper = p_fat_mestre.natureza_operacao
      
   LET p_fat_mestre.finalidade =  pol1136_le_par_omc('FINALIDADE_DA_NF')

   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF
   
   LET p_finalidade = p_fat_mestre.finalidade
   
   
    INITIALIZE p_ies_emite_dupl   TO NULL
	
	SELECT  ies_emite_dupl
	INTO p_ies_emite_dupl
	FROM nat_operacao
	WHERE cod_nat_oper = p_fat_mestre.natureza_operacao
	
	IF STATUS <> 0 THEN
		LET p_fat_mestre.cond_pagto =  pol1136_le_par_omc('COD_COND_PGTO')
		IF NOT p_tem_param THEN
			RETURN FALSE
		END IF		
	ELSE
        IF 	p_ies_emite_dupl  = 'N' THEN 
		    LET p_fat_mestre.cond_pagto =  999
		ELSE
            LET p_fat_mestre.cond_pagto =  pol1136_le_par_omc('COD_COND_PGTO')
			IF NOT p_tem_param THEN
				RETURN FALSE
			END IF			
		END IF
    END IF  

   
   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF

   LET p_fat_mestre.tip_carteira  =  pol1136_le_par_omc('COD_DA_CARTEIRA')

   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF
         
   LET p_fat_mestre.ind_despesa_financ =  0                        
   LET p_fat_mestre.moeda              =  1                        
   LET p_fat_mestre.plano_venda        =  'N'     
   LET p_fat_mestre.transportadora     =  ' ' 
   LET p_fat_mestre.tip_frete          =  pol1136_le_par_omc('COD_TIP_FRETE') 
   LET p_fat_mestre.peso_liquido       =  0                        
   LET p_fat_mestre.peso_bruto         =  0                        
   LET p_fat_mestre.peso_tara          =  0                        
   LET p_fat_mestre.num_prim_volume    =  0                        
   LET p_fat_mestre.volume_cubico      =  0                        
   LET p_fat_mestre.usu_incl_nf        =  p_user   
   LET p_dat_hor                       =  p_nf_mestre.dat_emissao                 
   LET p_fat_mestre.dat_hor_emissao    =  p_dat_hor                 
   LET p_fat_mestre.sit_impressao      =  'N'                      
   LET p_fat_mestre.val_frete_rodov    =  0                        
   LET p_fat_mestre.val_seguro_rodov   =  0                        
   LET p_fat_mestre.val_fret_consig    =  0                        
   LET p_fat_mestre.val_segr_consig    =  0                        
   LET p_fat_mestre.val_frete_cliente  =  0                        
   LET p_fat_mestre.val_seguro_cliente =  0 
   LET p_fat_mestre.val_acre_merc      =  0                        
   LET p_fat_mestre.val_acre_nf        =  0                        
   LET p_fat_mestre.val_acre_duplicata =  0                        
   
   LET p_fat_mestre.val_desc_merc      =  p_nf_mestre.val_desc_incond + p_nf_mestre.val_desc_cenp                        
   LET p_fat_mestre.val_desc_nf        =  p_nf_mestre.val_desc_incond + p_nf_mestre.val_desc_cenp                        
   LET p_fat_mestre.val_desc_duplicata =  p_nf_mestre.val_desc_incond + p_nf_mestre.val_desc_cenp                                               
   
   LET p_fat_mestre.val_mercadoria     =  p_nf_mestre.val_bruto_nf #mais impostos?                     
   LET p_fat_mestre.val_duplicata      =  p_nf_mestre.val_duplicata                        
   LET p_fat_mestre.val_nota_fiscal    =  p_nf_mestre.val_duplicata                       

   INSERT INTO fat_nf_mestre(
      empresa, #trans_nota_fiscal,          
      tip_nota_fiscal,   
      serie_nota_fiscal, 
      subserie_nf,       
      espc_nota_fiscal,  
      nota_fiscal,       
      status_nota_fiscal,
      modelo_nota_fiscal,
      origem_nota_fiscal,
      tip_processamento, 
      sit_nota_fiscal,   
      cliente,           
      remetent,          
      zona_franca,       
      natureza_operacao, 
      finalidade,        
      cond_pagto,        
      tip_carteira,      
      ind_despesa_financ,
      moeda,             
      plano_venda,       
      transportadora,    
      tip_frete,         
      placa_veiculo,     
      estado_placa_veic, 
      placa_carreta_1,   
      estado_plac_carr_1,
      placa_carreta_2,   
      estado_plac_carr_2,
      tabela_frete,      
      seq_tabela_frete,  
      sequencia_faixa,   
      via_transporte,    
      peso_liquido,      
      peso_bruto,        
      peso_tara,         
      num_prim_volume,   
      volume_cubico,     
      usu_incl_nf,       
      dat_hor_emissao,   
      dat_hor_saida,     
      dat_hor_entrega,   
      contato_entrega,   
      dat_hor_cancel,    
      motivo_cancel,     
      usu_canc_nf,       
      sit_impressao,     
      val_frete_rodov,   
      val_seguro_rodov,  
      val_fret_consig,   
      val_segr_consig,   
      val_frete_cliente, 
      val_seguro_cliente,
      val_desc_merc,     
      val_desc_nf,       
      val_desc_duplicata,
      val_acre_merc,     
      val_acre_nf,       
      val_acre_duplicata,
      val_mercadoria,    
      val_duplicata,     
      val_nota_fiscal,   
      tip_venda) VALUES(p_fat_mestre.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_NF_MESTRE')
      RETURN FALSE
   END IF
   
   LET p_trans_nf = SQLCA.SQLERRD[2]

   IF p_nf_mestre.tip_nf = 'NFS' THEN
   ELSE
      IF NOT pol1136_ins_nf_eletronica('') THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_ind = 0
   
   IF p_nf_mestre.val_desc_incond > 0 THEN
      
      LET p_cod_desc = pol1136_le_par_omc('COD_DESC_INCOND')
      LET p_pct_desc   = p_nf_mestre.val_desc_incond * 100 / p_nf_mestre.val_bruto_nf

      IF NOT pol1136_ins_desc(p_nf_mestre.val_desc_incond) THEN
         RETURN FALSE
      END IF      
   END IF

   IF p_nf_mestre.val_desc_cenp > 0 THEN
      
      LET p_cod_desc = pol1136_le_par_omc('COD_DESC_CENP')
      LET p_pct_desc   = p_nf_mestre.val_desc_cenp * 100 / p_nf_mestre.val_bruto_nf

      IF NOT pol1136_ins_desc(p_nf_mestre.val_desc_cenp) THEN
         RETURN FALSE
      END IF      
   END IF
   
   LET p_cod_repres = pol1136_le_par_omc('COD_REPRESENTANTE')

   IF NOT p_tem_param THEN
      RETURN FALSE
   END IF
   
   SELECT cod_repres 
     INTO p_cod_repres
     FROM sol_de_para_repres
    WHERE cod_usuario = l_sol_cupom_mestre.vendedor
    
   INSERT INTO fat_nf_repr(
      empresa,
      trans_nota_fiscal,
      representante,
      seq_representante,
      pct_comissao,
      tem_comissao) 
    VALUES(p_fat_mestre.empresa,
           p_trans_nf,
           p_cod_repres,
           1,       
           0,       
           'N')     
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_NF_REPR')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#-----------------------------#
FUNCTION pol1136_le_nutureza() 
#-----------------------------#

  DEFINE p_cod_fiscal INTEGER
  
  LET p_cod_fiscal = 0
  
  DECLARE cq_nat CURSOR FOR
   SELECT DISTINCT cod_fiscal
     FROM nf_itens_509
    WHERE cod_empresa = p_nf_mestre.cod_empresa
      AND cod_cliente = p_nf_mestre.cod_cliente
      AND num_nf      = p_nf_mestre.num_nf
      AND ser_nf      = p_nf_mestre.ser_nf

   FOREACH cq_nat INTO p_cod_fiscal

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_itens_509:CFOP')
         RETURN FALSE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   IF p_cod_fiscal IS NULL OR
         p_cod_fiscal = 0 THEN
      LET p_msg = 'N�o foi poss�vel ler o primeiro\n',
                  'codigo fiscal da tabela nf_itens_509\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   SELECT cod_nat_oper
     INTO p_cod_nat_oper
     FROM cfop_x_natoper_509
    WHERE cod_fiscal = p_cod_fiscal

   IF STATUS = 100 THEN
      LET p_msg = 'CFOP ',p_cod_fiscal,
                  'n�o cadastrado no pol1144\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_itens_509:CFOP')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------------#
FUNCTION pol1136_le_nat_oper(p_cod_fiscal)#
#-----------------------------------------#

   DEFINE p_cod_fiscal INTEGER
   
   SELECT cod_nat_oper
     INTO p_cod_nat_oper
     FROM cfop_x_natoper_509
    WHERE cod_fiscal = p_cod_fiscal

   IF STATUS = 100 THEN
      LET p_msg = 'CFOP ',p_cod_fiscal,
                  'n�o cadastrado no pol1144\n'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_itens_509:CFOP')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION


#--------------------------------#
FUNCTION pol1136_ins_desc(p_valor)
#--------------------------------#

   DEFINE p_valor DECIMAL(17,2)
   
   LET p_ind = p_ind + 1

   INSERT INTO fat_dacre_nf (
      empresa, 
      trans_nota_fiscal, 
      desc_acre,
		  seq_desc_acre, 
		  val_dacre_nf, 
		  pct_dacre_nf)
	    VALUES(p_nf_mestre.cod_empresa,
	           p_trans_nf, 
	           p_cod_desc, 
	           p_ind, 
	           p_valor, 
	           p_pct_desc)
	           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_DACRE_NF')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1136_ins_desc_item(p_valor)
#-------------------------------------#

   DEFINE p_valor DECIMAL(17,2)
   
   INSERT INTO fat_dacre_item_nf (
			  empresa,
			  trans_nota_fiscal, 
			  seq_item_nf, 
			  desc_acre,
			  ind_desc_acre, 
			  aplic_desc_acre,
			  bas_calc_desc_acre, 
			  pct_desc_acre, 
			  val_desc_acre)
      VALUES(p_nf_item.cod_empresa,
			       p_trans_nf,
			       p_ind, 
			       p_cod_desc, 
			       'D',
			       'N', 
			       p_nf_item.val_bruto_item, 
			       p_pct_desc, 
			       p_valor)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_DACRE_ITEM_NF')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1136_grava_item_nf()
#------------------------------#

   DEFINE p_fat_item           RECORD
          empresa              char(2),      
          trans_nota_fiscal    integer,      
          seq_item_nf          integer,      
          pedido               integer,      
          seq_item_pedido      integer,      
          ord_montag           integer,      
          tip_item             char(1),      
          item                 char(15),     
          des_item             char(76),     
          unid_medida          char(3),      
          peso_unit            decimal(17,6),
          qtd_item             decimal(17,6),
          fator_conv           decimal(11,6),
          lista_preco          smallint,     
          versao_lista_preco   smallint,     
          tip_preco            char(1),      
          natureza_operacao    integer,      
          classif_fisc         char(10),     
          item_prod_servico    char(1),      
          preco_unit_bruto     decimal(17,6),
          pre_uni_desc_incnd   decimal(17,6),
          preco_unit_liquido   decimal(17,6),
          pct_frete            decimal(7,4), 
          val_desc_item        decimal(17,2),
          val_desc_merc        decimal(17,2),
          val_desc_contab      decimal(17,2),
          val_desc_duplicata   decimal(17,2),
          val_acresc_item      decimal(17,2),
          val_acre_merc        decimal(17,2),
          val_acresc_contab    decimal(17,2),
          val_acre_duplicata   decimal(17,2),
          val_fret_consig      decimal(17,2),
          val_segr_consig      decimal(17,2),
          val_frete_cliente    decimal(17,2),
          val_seguro_cliente   decimal(17,2),
          val_bruto_item       decimal(17,2),
          val_brt_desc_incnd   decimal(17,2),
          val_liquido_item     decimal(17,2),
          val_merc_item        decimal(17,2),
          val_duplicata_item   decimal(17,2),
          val_contab_item      decimal(17,2),
          fator_conv_cliente   decimal(11,6),
          uni_med_cliente      char(3)      
   END RECORD
   
  INITIALIZE p_fat_item TO NULL
   
  LET p_fat_item.empresa            = p_nf_mestre.cod_empresa                  
  LET p_fat_item.trans_nota_fiscal  = p_trans_nf  

  LET p_ind = 0
  LET p_peso_bruto = 0

  DECLARE cq_item CURSOR WITH HOLD FOR
   SELECT *
     FROM nf_itens_509
    WHERE cod_empresa = p_nf_mestre.cod_empresa
      AND cod_cliente = p_nf_mestre.cod_cliente
      AND num_nf      = p_nf_mestre.num_nf
      AND ser_nf      = p_nf_mestre.ser_nf
       
  FOREACH cq_item INTO p_nf_item.*
   
    IF STATUS <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_ITEM')
       RETURN FALSE
    END IF

    LET p_ind = p_ind + 1
    LET p_cod_item = p_nf_item.cod_item
	  LET p_fat_item.pedido  			     = 0
	  LET p_fat_item.seq_item_pedido   = 0                             
    LET p_fat_item.ord_montag        = 0                              
	  LET p_fat_item.seq_item_nf  	 	 = p_ind          
    LET p_fat_item.tip_item          = 'N'                             
	  LET p_fat_item.item     		 	   = p_cod_item            
    LET p_fat_item.des_item          = p_nf_item.den_item
    LET p_fat_item.unid_medida       = p_nf_item.cod_unidade
    LET p_fat_item.tip_preco         = 'F'                   
    
    IF NOT pol1136_le_nat_oper(p_nf_item.cod_fiscal) THEN
       RETURN FALSE
    END IF
             
    LET p_fat_item.natureza_operacao = p_cod_nat_oper                
    LET p_fat_item.qtd_item          = p_nf_item.qtd_item
    LET p_fat_item.item_prod_servico = p_tip_item                     
            
    SELECT pes_unit,
           cod_cla_fisc,
           fat_conver
      INTO p_fat_item.peso_unit,
           p_fat_item.classif_fisc,
           p_fat_item.fator_conv
      FROM item
     WHERE cod_empresa  = p_nf_item.cod_empresa
       AND cod_item     = p_cod_item
   
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','ITEM:CQ_ITEM')
       RETURN FALSE
    END IF

    IF p_nf_mestre.tip_nf = 'NFS' THEN
       LET p_fat_item.peso_unit = 0
    END IF
       
    LET p_peso_bruto = p_peso_bruto + (p_nf_item.qtd_item * p_fat_item.peso_unit)
    
    LET p_fat_item.preco_unit_bruto   = p_nf_item.pre_unit_bruto  
    LET p_fat_item.pre_uni_desc_incnd = p_nf_item.val_desc_incond / p_nf_item.qtd_item
    LET p_fat_item.preco_unit_liquido = p_nf_item.pre_unit_liq
    LET p_fat_item.pct_frete          = 0                              
    
    LET p_fat_item.val_desc_item      = p_nf_item.val_desc_incond + p_nf_item.val_desc_cenp
    LET p_fat_item.val_desc_merc      = p_nf_item.val_desc_incond + p_nf_item.val_desc_cenp                            
    LET p_fat_item.val_desc_contab    = p_nf_item.val_desc_incond + p_nf_item.val_desc_cenp                             
    LET p_fat_item.val_desc_duplicata = p_nf_item.val_desc_incond + p_nf_item.val_desc_cenp 
                                 
    LET p_fat_item.val_acresc_item    = 0                             
    LET p_fat_item.val_acre_merc      = 0  
    LET p_fat_item.val_acresc_contab  = 0
    LET p_fat_item.val_acre_duplicata = 0
    LET p_fat_item.val_fret_consig    = 0
    LET p_fat_item.val_segr_consig    = 0
    LET p_fat_item.val_frete_cliente  = 0
    LET p_fat_item.val_seguro_cliente = 0
    
    LET p_fat_item.val_bruto_item     = p_nf_item.val_bruto_item
    LET p_fat_item.val_brt_desc_incnd = p_nf_item.val_desc_incond
    LET p_fat_item.val_liquido_item   = p_nf_item.val_liq_item
    
    LET p_fat_item.val_merc_item      = p_nf_item.val_liq_item
    LET p_fat_item.val_duplicata_item = p_nf_item.val_item_dupl
    LET p_fat_item.val_contab_item    = p_nf_item.val_liq_item
   
   INSERT INTO fat_nf_item(
      empresa,           
      trans_nota_fiscal, 
      seq_item_nf,       
      pedido,            
      seq_item_pedido,   
      ord_montag,        
      tip_item,          
      item,              
      des_item,          
      unid_medida,       
      peso_unit,         
      qtd_item,          
      fator_conv,        
      lista_preco,       
      versao_lista_preco,
      tip_preco,         
      natureza_operacao, 
      classif_fisc,      
      item_prod_servico, 
      preco_unit_bruto,  
      pre_uni_desc_incnd,
      preco_unit_liquido,
      pct_frete,         
      val_desc_item,     
      val_desc_merc,     
      val_desc_contab,   
      val_desc_duplicata,
      val_acresc_item,   
      val_acre_merc,     
      val_acresc_contab, 
      val_acre_duplicata,
      val_fret_consig,   
      val_segr_consig,   
      val_frete_cliente, 
      val_seguro_cliente,
      val_bruto_item,    
      val_brt_desc_incnd,
      val_liquido_item,  
      val_merc_item,     
      val_duplicata_item,
      val_contab_item,   
      fator_conv_cliente,
      uni_med_cliente) VALUES(p_fat_item.*) 

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERT","fat_nf_item")
      RETURN FALSE
   END IF

   IF p_nf_item.txt_item IS NOT NULL THEN
      IF NOT pol1136_grava_texto_nf(p_nf_item.txt_item) THEN
         RETURN FALSE
      END IF
   END IF

   IF p_nf_item.val_desc_incond > 0 THEN
      
      LET p_cod_desc = pol1136_le_par_omc('COD_DESC_INCOND')
      LET p_pct_desc = p_nf_item.val_desc_incond  * 100 / p_nf_item.val_bruto_item

      IF NOT pol1136_ins_desc_item(p_nf_item.val_desc_incond) THEN
         RETURN FALSE
      END IF      
   END IF

   IF p_nf_item.val_desc_cenp > 0 THEN
      
      LET p_cod_desc = pol1136_le_par_omc('COD_DESC_CENP')
      LET p_pct_desc = p_nf_item.val_desc_cenp  * 100 / p_nf_item.val_bruto_item

      IF NOT pol1136_ins_desc_item(p_nf_item.val_desc_cenp) THEN
         RETURN FALSE
      END IF      
   END IF
   
   IF p_nf_item.val_iss > 0 THEN
      IF NOT pol1136_le_config('ISS') THEN
      ELSE 
		     IF NOT pol1136_grv_fisc('ISS', p_nf_item.pct_iss, 
				     p_nf_item.val_base_iss, p_nf_item.val_iss) THEN
			       RETURN FALSE
		     END IF
      END IF 
   END IF

 
   IF NOT pol1136_le_config('ICMS') THEN
   ELSE  
		  IF NOT pol1136_grv_fisc('ICMS', p_nf_item.pct_icms, 
		         p_nf_item.val_base_icms, p_nf_item.val_icms) THEN
		      RETURN FALSE
		  END IF
   END IF 

   IF NOT pol1136_le_config('IPI') THEN
      ELSE  
		     IF NOT pol1136_grv_fisc('IPI', p_nf_item.pct_icms, 
				    p_nf_item.val_base_icms, p_nf_item.val_icms) THEN
			      RETURN FALSE
		     END IF
   END IF 
   
   IF p_nf_item.val_irpj > 0 THEN
      IF NOT pol1136_le_config('IRPJ_RET') THEN
      ELSE 
		     IF NOT pol1136_grv_fisc('IRPJ_RET', p_nf_item.pct_irpj, 
				    p_nf_item.val_base_irpj, p_nf_item.val_irpj) THEN
			      RETURN FALSE
		     END IF
      END IF 
   END IF
   
   IF p_nf_item.val_csll > 0 THEN
      IF NOT pol1136_le_config('CSLL_RET') THEN
      ELSE 
		     IF NOT pol1136_grv_fisc('CSLL_RET', p_nf_item.pct_csll, 
				    p_nf_item.val_base_csll, p_nf_item.val_csll) THEN
			      RETURN FALSE
		     END IF
	    END IF 
   END IF

   IF p_nf_item.val_cofins > 0 THEN
      IF NOT pol1136_le_config('COFINS_RET') THEN
      ELSE 
		     IF NOT pol1136_grv_fisc('COFINS_RET', p_nf_item.pct_cofins, 
				    p_nf_item.val_base_cofins, p_nf_item.val_cofins) THEN
			      RETURN FALSE
		     END IF
	    END IF 
   END IF

   IF p_nf_item.val_pis > 0 THEN
      IF NOT pol1136_le_config('PIS_RET') THEN
      ELSE 
		     IF NOT pol1136_grv_fisc('PIS_RET', p_nf_item.pct_pis, 
				    p_nf_item.val_base_pis, p_nf_item.val_pis) THEN
			      RETURN FALSE
		     END IF 
      END IF
   END IF

   SELECT empresa
     FROM obf_oper_fiscal 
    WHERE empresa = p_nf_mestre.cod_empresa
      AND nat_oper_grp_desp = p_cod_nat_oper
      AND tributo_benef = 'PIS_REC'
      AND origem = 'S' 

   IF STATUS = 0 THEN
   	  CALL pol1136_le_config('PIS_REC') RETURNING p_status 
      IF p_config.incide =  'S'  THEN 
         LET l_val_pis_rec = p_nf_item.val_liq_item * p_config.aliquota / 100
         IF NOT pol1136_grv_fisc('PIS_REC', p_config.aliquota, 
                p_nf_item.val_liq_item, l_val_pis_rec) THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   SELECT empresa
     FROM obf_oper_fiscal 
    WHERE empresa = p_nf_mestre.cod_empresa
      AND nat_oper_grp_desp = p_cod_nat_oper
      AND tributo_benef = 'COFINS_REC'
      AND origem = 'S' 

   IF STATUS = 0 THEN
  	  CALL pol1136_le_config('COFINS_REC') RETURNING p_status 
      IF p_config.incide =  'S'  THEN 
         LET l_val_cofins_rec = p_nf_item.val_liq_item * p_config.aliquota / 100
         IF NOT pol1136_grv_fisc('COFINS_REC', p_config.aliquota, 
               p_nf_item.val_liq_item, l_val_cofins_rec) THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
 END FOREACH
 
 RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol1136_le_config(p_trib_benef)#
#---------------------------------------#	

   DEFINE p_trib_benef  CHAR(20),
          p_tem_tributo Char(01)

   LET p_tem_tributo = 'N'
   
   DECLARE cq_tributo CURSOR FOR       
      SELECT *
			  FROM obf_config_fiscal 
			 WHERE empresa = p_nf_mestre.cod_empresa
			   AND tributo_benef = p_trib_benef  
			   AND origem = 'S' 
			   AND nat_oper_grp_desp = p_cod_nat_oper

   FOREACH cq_tributo INTO p_config.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','obf_config_fiscal:cq_tributo')   
         RETURN FALSE
      END IF
      
      LET p_tem_tributo = 'S'
      
      EXIT FOREACH
      
   END FOREACH

   IF p_tem_tributo = 'N' THEN
      INITIALIZE p_config.incide to NULL
      IF p_trib_benef = 'PIS_REC' OR p_trib_benef = 'COFINS_REC' THEN
         LET p_msg = 'Tributo ', p_trib_benef, 'Nat Opera��o ', p_cod_nat_oper, '\n',
                     'n�o encontrado na obf_config_fiscal.'
         CALL log0030_mensagem(p_msg, 'excla')
         RETURN FALSE
      ELSE  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------------------------------#
FUNCTION pol1136_grv_fisc(p_tributo, p_pct, p_base, p_valor)#
#-----------------------------------------------------------#

   DEFINE p_tributo      CHAR(10),
          p_pct          DECIMAL(5,2),
          p_base         DECIMAL(17,2),
          p_valor        DECIMAL(17,2),
          p_trans_config INTEGER

   DEFINE p_fat_item_fisc      RECORD
          empresa              char(2),         
          trans_nota_fiscal    integer,      
          seq_item_nf          integer,      
          tributo_benef        char(20),     
          trans_config         integer,      
          bc_trib_mercadoria   decimal(17,2),
          bc_tributo_frete     decimal(17,2),
          bc_trib_calculado    decimal(17,2),
          bc_tributo_tot       decimal(17,2),
          val_trib_merc        decimal(17,2),
          val_tributo_frete    decimal(17,2),
          val_trib_calculado   decimal(17,2),
          val_tributo_tot      decimal(17,2),
          acresc_desc          char(1),      
          aplicacao_val        char(1),      
          incide               char(1),      
          origem_produto       smallint,     
          tributacao           smallint,     
          hist_fiscal          integer,      
          sit_tributo          char(1),      
          motivo_retencao      char(1),      
          retencao_cre_vdp     char(3),      
          cod_fiscal           integer,      
          inscricao_estadual   char(16),     
          dipam_b              char(3),      
          aliquota             decimal(7,4), 
          val_unit             decimal(17,6),
          pre_uni_mercadoria   decimal(17,6),
          pct_aplicacao_base   decimal(7,4), 
          pct_acre_bas_calc    decimal(7,4), 
          pct_red_bas_calc     decimal(7,4),
          pct_diferido_base    decimal(7,4),
          pct_diferido_val     decimal(7,4),
          pct_acresc_val       decimal(7,4),
          pct_reducao_val      decimal(7,4),
          pct_margem_lucro     decimal(7,4),
          pct_acre_marg_lucr   decimal(7,4),
          pct_red_marg_lucro   decimal(7,4),
          taxa_reducao_pct     decimal(7,4),
          taxa_acresc_pct      decimal(7,4),
          cotacao_moeda_upf    decimal(7,2),
          simples_nacional     decimal(5,0),
          iden_processo        integer     
   END RECORD

   INITIALIZE p_fat_item_fisc TO NULL

   LET p_fat_item_fisc.empresa            = p_nf_item.cod_empresa
   LET p_fat_item_fisc.trans_nota_fiscal  = p_trans_nf
   LET p_fat_item_fisc.seq_item_nf        = p_ind
   LET p_fat_item_fisc.tributo_benef      = p_tributo
   LET p_fat_item_fisc.trans_config       = p_config.trans_config
   LET p_fat_item_fisc.bc_trib_mercadoria = p_base
   LET p_fat_item_fisc.bc_tributo_frete   = 0
   LET p_fat_item_fisc.bc_trib_calculado  = 0
   LET p_fat_item_fisc.bc_tributo_tot     = p_base
   LET p_fat_item_fisc.val_trib_merc      = p_valor
   LET p_fat_item_fisc.val_tributo_frete  = 0
   LET p_fat_item_fisc.val_trib_calculado = 0
   LET p_fat_item_fisc.val_tributo_tot    = p_valor
   LET p_fat_item_fisc.acresc_desc        = p_config.acresc_desc
   LET p_fat_item_fisc.aplicacao_val      = p_config.aplicacao_val
   LET p_fat_item_fisc.incide             = p_config.incide
   LET p_fat_item_fisc.origem_produto     = p_config.origem_produto
   LET p_fat_item_fisc.tributacao         = p_config.tributacao
   LET p_fat_item_fisc.hist_fiscal        = p_config.hist_fiscal
   LET p_fat_item_fisc.sit_tributo        = p_config.sit_tributo
   LET p_fat_item_fisc.motivo_retencao    = p_config.motivo_retencao
   LET p_fat_item_fisc.retencao_cre_vdp   = p_config.retencao_cre_vdp
   IF p_nf_mestre.tip_nf = 'NFS' THEN
      LET p_fat_item_fisc.cod_fiscal      = 0
   ELSE
      LET p_fat_item_fisc.cod_fiscal      = p_nf_item.cod_fiscal
   END IF
   LET p_fat_item_fisc.inscricao_estadual = p_config.inscricao_estadual
   LET p_fat_item_fisc.dipam_b            = p_config.dipam_b
   LET p_fat_item_fisc.aliquota           = p_pct
   LET p_fat_item_fisc.val_unit           = p_config.val_unit
   LET p_fat_item_fisc.pre_uni_mercadoria = p_config.pre_uni_mercadoria
   LET p_fat_item_fisc.pct_aplicacao_base = p_config.pct_aplicacao_base
   LET p_fat_item_fisc.pct_acre_bas_calc  = p_config.pct_acre_bas_calc
   LET p_fat_item_fisc.pct_red_bas_calc   = p_config.pct_red_bas_calc
   LET p_fat_item_fisc.pct_diferido_base  = p_config.pct_diferido_base
   LET p_fat_item_fisc.pct_diferido_val   = p_config.pct_diferido_val
   LET p_fat_item_fisc.pct_acresc_val     = p_config.pct_acresc_val
   LET p_fat_item_fisc.pct_reducao_val    = p_config.pct_reducao_val
   LET p_fat_item_fisc.pct_margem_lucro   = p_config.pct_margem_lucro
   LET p_fat_item_fisc.pct_acre_marg_lucr = p_config.pct_acre_marg_lucr
   LET p_fat_item_fisc.pct_red_marg_lucro = p_config.pct_red_marg_lucro
   LET p_fat_item_fisc.taxa_reducao_pct   = p_config.taxa_reducao_pct
   LET p_fat_item_fisc.taxa_acresc_pct    = p_config.taxa_acresc_pct
   LET p_fat_item_fisc.cotacao_moeda_upf  = NULL
   LET p_fat_item_fisc.simples_nacional   = NULL
   LET p_fat_item_fisc.iden_processo      = NULL

   INSERT INTO fat_nf_item_fisc(
      empresa,           
      trans_nota_fiscal, 
      seq_item_nf,       
      tributo_benef,     
      trans_config,      
      bc_trib_mercadoria,
      bc_tributo_frete,  
      bc_trib_calculado, 
      bc_tributo_tot,    
      val_trib_merc,     
      val_tributo_frete, 
      val_trib_calculado,
      val_tributo_tot,   
      acresc_desc,       
      aplicacao_val,     
      incide,            
      origem_produto,    
      tributacao,        
      hist_fiscal,       
      sit_tributo,       
      motivo_retencao,   
      retencao_cre_vdp,  
      cod_fiscal,        
      inscricao_estadual,
      dipam_b,           
      aliquota,          
      val_unit,          
      pre_uni_mercadoria,
      pct_aplicacao_base,
      pct_acre_bas_calc, 
      pct_red_bas_calc,  
      pct_diferido_base, 
      pct_diferido_val,  
      pct_acresc_val,    
      pct_reducao_val,   
      pct_margem_lucro,  
      pct_acre_marg_lucr,
      pct_red_marg_lucro,
      taxa_reducao_pct,  
      taxa_acresc_pct,   
      cotacao_moeda_upf, 
      simples_nacional,  
      iden_processo) VALUES(p_fat_item_fisc.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERT","FAT_NF_ITEM_FISC")
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1136_grava_mestre_fisc()
#----------------------------------#

   DEFINE p_mest_fisc RECORD
          empresa             LIKE fat_mestre_fiscal.empresa,           
          trans_nota_fiscal   LIKE fat_mestre_fiscal.trans_nota_fiscal, 
          tributo_benef       LIKE fat_mestre_fiscal.tributo_benef,     
          bc_trib_mercadoria  LIKE fat_mestre_fiscal.bc_trib_mercadoria,
          bc_tributo_frete    LIKE fat_mestre_fiscal.bc_tributo_frete,  
          bc_trib_calculado   LIKE fat_mestre_fiscal.bc_trib_calculado, 
          bc_tributo_tot      LIKE fat_mestre_fiscal.bc_tributo_tot,    
          val_trib_merc       LIKE fat_mestre_fiscal.val_trib_merc,     
          val_tributo_frete   LIKE fat_mestre_fiscal.val_tributo_frete, 
          val_trib_calculado  LIKE fat_mestre_fiscal.val_trib_calculado,
          val_tributo_tot     LIKE fat_mestre_fiscal.val_tributo_tot 
   END RECORD            

   INITIALIZE p_mest_fisc TO NULL

   LET p_mest_fisc.empresa            = p_nf_mestre.cod_empresa  
   LET p_mest_fisc.trans_nota_fiscal  = p_trans_nf

   DECLARE cq_sum CURSOR FOR
    SELECT tributo_benef,
           SUM(bc_trib_mercadoria),
           SUM(bc_tributo_tot),
           SUM(val_trib_merc),
           SUM(val_tributo_tot)
      FROM fat_nf_item_fisc
     WHERE empresa = p_mest_fisc.empresa
       AND trans_nota_fiscal = p_trans_nf
     GROUP BY tributo_benef

   FOREACH cq_sum INTO 
           p_mest_fisc.tributo_benef,
           p_mest_fisc.bc_trib_mercadoria,
           p_mest_fisc.bc_tributo_tot,
           p_mest_fisc.val_trib_merc,
           p_mest_fisc.val_tributo_tot
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','FAT_NF_ITEM_FISC')
         RETURN FALSE
      END IF

      LET p_mest_fisc.bc_tributo_frete   = 0
      LET p_mest_fisc.bc_trib_calculado  = 0
      LET p_mest_fisc.val_tributo_frete  = 0
      LET p_mest_fisc.val_trib_calculado = 0

      INSERT INTO fat_mestre_fiscal(
          empresa,           
          trans_nota_fiscal, 
          tributo_benef,     
          bc_trib_mercadoria,
          bc_tributo_frete,  
          bc_trib_calculado, 
          bc_tributo_tot,    
          val_trib_merc,     
          val_tributo_frete, 
          val_trib_calculado,
          val_tributo_tot)  VALUES(p_mest_fisc.*)
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','FAT_MESTRE_FISCAL')
         RETURN FALSE
      END IF
   
   END FOREACH
    
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1136_grava_dupl()
#----------------------------#

   DEFINE p_nf_duplicata RECORD
          empresa               LIKE fat_nf_duplicata.empresa,          
          trans_nota_fiscal     LIKE fat_nf_duplicata.trans_nota_fiscal, 
          seq_duplicata         LIKE fat_nf_duplicata.seq_duplicata,     
          val_duplicata         LIKE fat_nf_duplicata.val_duplicata,     
          dat_vencto_cdesc      LIKE fat_nf_duplicata.dat_vencto_cdesc,  
          dat_vencto_sdesc      LIKE fat_nf_duplicata.dat_vencto_sdesc,  
          pct_desc_financ       LIKE fat_nf_duplicata.pct_desc_financ,   
          val_bc_comissao       LIKE fat_nf_duplicata.val_bc_comissao,   
          portador              LIKE fat_nf_duplicata.portador,          
          agencia               LIKE fat_nf_duplicata.agencia,           
          dig_agencia           LIKE fat_nf_duplicata.dig_agencia,       
          titulo_bancario       LIKE fat_nf_duplicata.titulo_bancario,   
          tip_duplicata         LIKE fat_nf_duplicata.tip_duplicata,     
          docum_cre             LIKE fat_nf_duplicata.docum_cre,         
          empresa_cre           LIKE fat_nf_duplicata.empresa_cre 
   END RECORD                
                

      INITIALIZE p_nf_duplicata to NULL
	  
# SE A NATUREZA DE OPERA��O N�O EMITE DUPLICATA N�O GRAVAMOS A NF_DUPLICATA E MARCAMOS A INTEGRA��O COMO FEITA
	  
	  IF p_ies_emite_dupl  =  'N'   THEN 
	     RETURN TRUE
	  END IF 
	  
      
      LET  p_nf_duplicata.empresa           = p_nf_mestre.cod_empresa 
      LET  p_nf_duplicata.trans_nota_fiscal = p_trans_nf    
      LET  p_nf_duplicata.seq_duplicata     = 1            
      LET  p_nf_duplicata.val_duplicata     = p_nf_mestre.val_duplicata   
      LET  p_nf_duplicata.dat_vencto_sdesc  = p_nf_mestre.dat_vencto  
      LET  p_nf_duplicata.dat_vencto_cdesc  = ''
      LET  p_nf_duplicata.pct_desc_financ   = 0             
      LET  p_nf_duplicata.val_bc_comissao   = 0             
      LET  p_nf_duplicata.agencia           = 0             
      LET  p_nf_duplicata.dig_agencia       = ' '           
      LET  p_nf_duplicata.titulo_bancario   = ' '           
      LET  p_nf_duplicata.docum_cre         = ' '           
      LET  p_nf_duplicata.empresa_cre       = ' '           
      
      INSERT INTO fat_nf_duplicata(
         empresa,          
         trans_nota_fiscal,
         seq_duplicata,    
         val_duplicata,    
         dat_vencto_cdesc, 
         dat_vencto_sdesc, 
         pct_desc_financ,  
         val_bc_comissao,  
         portador,         
         agencia,          
         dig_agencia,      
         titulo_bancario,  
         tip_duplicata,    
         docum_cre,        
         empresa_cre) VALUES(p_nf_duplicata.*)

	    IF STATUS <> 0 THEN 
	       CALL log003_err_sql('Inserindo','FAT_NF_DUPLICATA')
         RETURN FALSE
	    END IF 

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1136_grava_nf_integra()
#----------------------------------#

   DEFINE p_nf_integr        RECORD
          empresa            LIKE fat_nf_integr.empresa,           
          trans_nota_fiscal  LIKE fat_nf_integr.trans_nota_fiscal, 
          sit_nota_fiscal    LIKE fat_nf_integr.sit_nota_fiscal,   
          status_intg_est    LIKE fat_nf_integr.status_intg_est,   
          dat_hr_intg_est    LIKE fat_nf_integr.dat_hr_intg_est,   
          status_intg_contab LIKE fat_nf_integr.status_intg_contab,
          dat_hr_intg_contab LIKE fat_nf_integr.dat_hr_intg_contab,
          status_intg_creceb LIKE fat_nf_integr.status_intg_creceb,
          dat_hr_intg_creceb LIKE fat_nf_integr.dat_hr_intg_creceb,
          status_integr_obf  LIKE fat_nf_integr.status_integr_obf, 
          dat_hor_integr_obf LIKE fat_nf_integr.dat_hor_integr_obf,
          status_intg_migr   LIKE fat_nf_integr.status_intg_migr,  
          dat_hr_intg_migr   LIKE fat_nf_integr.dat_hr_intg_migr 
   END RECORD           
   
   INITIALIZE p_nf_integr TO NULL
   
   LET  p_nf_integr.empresa           	= p_nf_mestre.cod_empresa
   LET  p_nf_integr.trans_nota_fiscal 	= p_trans_nf
   LET  p_nf_integr.sit_nota_fiscal   	= 'N'
   LET  p_nf_integr.status_intg_est   	= 'I' 	 
   LET  p_nf_integr.status_intg_contab	= 'P'	
   IF p_ies_emite_dupl  =  'N'   THEN 
	  LET  p_nf_integr.status_intg_creceb	= 'I'
   ELSE
  	  LET  p_nf_integr.status_intg_creceb	= 'P' 
   END IF    
   LET  p_nf_integr.status_intg_creceb	= 'P'	 
   LET  p_nf_integr.status_integr_obf	= 'P'	 
   LET  p_nf_integr.status_intg_migr	= 'P'	 
	
	 INSERT INTO fat_nf_integr(
      empresa,           	 
	    trans_nota_fiscal, 
	    sit_nota_fiscal,   
	    status_intg_est,   
	    dat_hr_intg_est,   
	    status_intg_contab,
	    dat_hr_intg_contab,
	    status_intg_creceb,
	    dat_hr_intg_creceb,
	    status_integr_obf, 
	    dat_hor_integr_obf,
	    status_intg_migr,  
	    dat_hr_intg_migr) VALUES(p_nf_integr.*)	        
	 
	 IF STATUS <> 0 THEN 
	    CALL log003_err_sql('Inserindo','FAT_NF_INTEGR')
       RETURN FALSE
	 END IF 

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1136_grava_texto_nf(p_txt)
#------------------------------------#

   DEFINE p_nf_texto RECORD
          empresa            LIKE fat_nf_texto_hist.empresa,          
          trans_nota_fiscal  LIKE fat_nf_texto_hist.trans_nota_fiscal,
          sequencia_texto    LIKE fat_nf_texto_hist.sequencia_texto,  
          texto              LIKE fat_nf_texto_hist.texto,            
          des_texto          LIKE fat_nf_texto_hist.des_texto,        
          tip_txt_nf         LIKE fat_nf_texto_hist.tip_txt_nf
   END RECORD
   
   DEFINE p_txt LIKE fat_nf_texto_hist.des_texto
   
   SELECT MAX(sequencia_texto)
     INTO p_num_seq
     FROM fat_nf_texto_hist
    WHERE empresa = p_nf_mestre.cod_empresa  
      AND trans_nota_fiscal = p_trans_nf
   
	 IF STATUS <> 0 THEN 
	    CALL log003_err_sql('Lendo','FAT_NF_TEXTO_HIST')
       RETURN FALSE
	 END IF 
   
   IF p_num_seq IS NULL THEN
      LET p_num_seq = 0
   END IF
   
   LET p_num_seq = p_num_seq + 1
   
   LET p_nf_texto.empresa           = p_nf_mestre.cod_empresa                 
   LET p_nf_texto.trans_nota_fiscal = p_trans_nf               
   LET p_nf_texto.sequencia_texto   = p_num_seq              
   LET p_nf_texto.texto             = 0               
   LET p_nf_texto.des_texto         = p_txt               
   LET p_nf_texto.tip_txt_nf        = 2               
          
   INSERT INTO fat_nf_texto_hist(
      empresa,            
      trans_nota_fiscal,    
      sequencia_texto,  
      texto,            
      des_texto,        
      tip_txt_nf) VALUES(p_nf_texto.*)
      
	 IF STATUS <> 0 THEN 
	    CALL log003_err_sql('Inserindo','FAT_NF_TEXTO_HIST')
       RETURN FALSE
	 END IF 

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1136_le_clientes_509()
#--------------------------------#

   DECLARE cq_clientes CURSOR WITH HOLD FOR
    SELECT *
      FROM clientes_509
     WHERE cod_empresa = p_cod_empresa 
       AND cod_estatus = 'R'
   
   FOREACH cq_clientes INTO p_clientes.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_CLIENTES')
         RETURN FALSE
      END IF

      DELETE FROM rejeicao_cli_509
         WHERE id_cliente  = p_clientes.id_registro

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Deletando','rejeicao_cli_509:CQ_CLIENTES')
         RETURN FALSE
      END IF
      
      LET p_rejeitou = FALSE

      IF p_clientes.cli_fornec MATCHES '[CF]' THEN
         IF p_clientes.cli_fornec = 'C' THEN
            IF NOT pol1136_consiste_cliente() THEN
               RETURN FALSE
            END IF
         ELSE
            IF NOT pol1136_consiste_fornec() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         LET p_msg = 'IDENTIFICADOR CLIENTE/FORNECEDOR INVALIDO'
         CALL pol1136_ins_rejei_cli()
      END IF

      IF p_rejeitou THEN
         LET p_cli_rejei = p_cli_rejei + 1
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1136_consiste_cliente()
#---------------------------------#

   IF p_clientes.cod_cliente IS NULL THEN
      LET p_msg = 'CODIGO DO CLIENTE ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   END IF

   IF p_clientes.tip_cliente IS NULL THEN
      LET p_msg = 'TIPO DO CLIENTE ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   ELSE
      IF p_clientes.tip_cliente MATCHES '[AFJ]' THEN
      ELSE
         LET p_msg = 'TIPO DO CLIENTE INVALIDO'
         CALL pol1136_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.num_cnpj_cpf IS NULL THEN
      LET p_msg = 'CGC/CPF DO CLIENTE ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   ELSE
      IF LENGTH(p_clientes.num_cnpj_cpf) = 14 OR 
         LENGTH(p_clientes.num_cnpj_cpf) = 11 THEN
      ELSE
         LET p_msg = 'CGC/CPF DO CLIENTE INVALIDO'
         CALL pol1136_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.nom_cliente IS NULL THEN
      LET p_msg = 'NOME DO CLIENTE ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   END IF

   IF p_clientes.end_cliente IS NULL THEN
      LET p_msg = 'ENDERECO DO CLIENTE ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   ELSE
      SELECT count(cod_cliente) 
		    INTO p_count 
		    FROM clientes_509
		   WHERE cod_cliente = p_clientes.cod_cliente
		     AND end_cliente LIKE '%,%'  
		
      IF p_count = 0 THEN 
         LET p_msg = 'ENDERECO DO CLIENTE NAO CONTEM VIRGULA'
         CALL pol1136_ins_rejei_cli()
      END IF
   END IF
   
   IF p_clientes.cod_cidade IS NULL THEN
      SELECT a.cidade_logix,
             a.estado_logix,
             a.cidade_ibge
        INTO p_cod_cic_cli,
             l_estado,
			       p_cid_ibeg
        FROM obf_cidade_ibge a, cidades b
       WHERE a.cidade_logix = b.cod_cidade
         AND b.cod_uni_feder = p_clientes.estado
         AND b.den_cidade = p_clientes.cidade

      IF STATUS = 100 THEN
         LET p_msg = 'COD CIDADE NAO CADASTRADO NA OBF_CIDADE_IBGE'
         CALL pol1136_ins_rejei_cli()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CONSISTINDO COD CIDADE')
            RETURN FALSE
		     ELSE
            LET  p_clientes.cod_cidade	 = p_cid_ibeg 	 
         END IF
      END IF 	  
   ELSE
      LET p_cid_ibeg = p_clientes.cod_cidade
      
      SELECT cidade_logix, 
             estado_logix
        INTO p_cod_cic_cli,
             l_estado
        FROM obf_cidade_ibge
		   WHERE cidade_ibge = p_cid_ibeg
      
      IF STATUS = 100 THEN
         LET p_msg = 'COD CIDADE NAO CADASTRADO NA OBF_CIDADE_IBGE'
         CALL pol1136_ins_rejei_cli()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CHECANDO COD CIDADE')
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol1136_consiste_fornec()
#---------------------------------#

   IF p_clientes.cod_cliente IS NULL OR p_clientes.cod_cliente = ' ' THEN
      LET p_msg = 'CODIGO DO FORNECEDOR ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   END IF

   IF p_clientes.tip_cliente IS NULL OR p_clientes.tip_cliente = ' ' THEN
      LET p_msg = 'TIPO DO FORNECEDOR ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   ELSE
      IF p_clientes.tip_cliente MATCHES '[AFJ]' THEN
      ELSE
         LET p_msg = 'TIPO DO FORNECEDOR INVALIDO'
         CALL pol1136_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.num_cnpj_cpf IS NULL OR p_clientes.num_cnpj_cpf = ' ' THEN
      LET p_msg = 'CGC/CPF DO FORNECEDOR ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   ELSE
      IF LENGTH(p_clientes.num_cnpj_cpf) = 14 OR 
         LENGTH(p_clientes.num_cnpj_cpf) = 11 THEN
      ELSE
         LET p_msg = 'CGC/CPF DO FORNECEDOR INVALIDO'
         CALL pol1136_ins_rejei_cli()
      END IF
   END IF

   IF p_clientes.nom_cliente IS NULL OR p_clientes.nom_cliente = ' ' THEN
      LET p_msg = 'NOME DO FORNECEDOR ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   END IF

   IF p_clientes.cod_cidade IS NULL OR p_clientes.cod_cidade = ' ' THEN
      LET p_msg = 'COD CIDADE DO FORNECEDOR ESTA NULO'
      CALL pol1136_ins_rejei_cli()
   ELSE
      LET p_cid_ibeg = p_clientes.cod_cidade
      
      SELECT cidade_logix, 
             estado_logix
        INTO p_cod_cic_cli,
             l_estado
        FROM obf_cidade_ibge
		   WHERE cidade_ibge = p_cid_ibeg
      
      IF STATUS = 100 THEN
         LET p_msg = 'COD CIDADE NAO CADASTRADO NA OBF_CIDADE_IBGE'
         CALL pol1136_ins_rejei_cli()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CONSISTINDO COD CIDADE:F')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1136_ins_rejei_cli()
#-------------------------------#

   LET p_rejeitou = TRUE
   
   INSERT INTO rejeicao_cli_509
    VALUES(p_cod_empresa,
           p_clientes.nom_arquivo,
           p_clientes.id_registro,
           p_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','rejeicao_cli_509')
   END IF

END FUNCTION

#--------------------------------#
FUNCTION pol1136_grava_clientes()
#--------------------------------#

   DECLARE cq_grv_cli CURSOR WITH HOLD FOR
    SELECT *
      FROM clientes_509
     WHERE cod_empresa = p_cod_empresa 
       AND cod_estatus = 'R'
   
   FOREACH cq_grv_cli INTO p_clientes.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_GRV_CLI')
         RETURN FALSE
      END IF

      IF p_clientes.cod_cidade IS NULL THEN
         SELECT a.cidade_logix,
                a.estado_logix,
                a.cidade_ibge
           INTO p_cod_cic_cli,
                l_estado,
			          p_cid_ibeg
           FROM obf_cidade_ibge a, cidades b
          WHERE a.cidade_logix = b.cod_cidade
            AND b.cod_uni_feder = p_clientes.estado
            AND b.den_cidade = p_clientes.cidade

         IF STATUS <> 0 THEN
            CALL log003_err_sql('','LENDO COD CIDADE')
            RETURN FALSE
		     END IF

         LET  p_clientes.cod_cidade	 = p_cid_ibeg 	 
      ELSE
         LET p_cid_ibeg = p_clientes.cod_cidade
      
         SELECT cidade_logix, 
                estado_logix
           INTO p_cod_cic_cli,
                l_estado
           FROM obf_cidade_ibge
		      WHERE cidade_ibge = p_cid_ibeg
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('','CONSISTINDO COD CIDADE:C')
            RETURN FALSE
         END IF
      END IF

      SELECT COUNT(cod_cliente)
        INTO p_count
        FROM nf_mestre_509
       WHERE cod_empresa = p_cod_empresa
         AND (tip_nf = 'NFS' OR tip_nf = 'NF')

      IF p_count > 0 THEN
         LET p_clientes.cli_fornec = 'C'
         IF NOT pol1136_grava_cliente() THEN
            RETURN FALSE
         END IF
      END IF

      SELECT COUNT(cod_cliente)
        INTO p_count
        FROM nf_mestre_509
       WHERE cod_empresa = p_cod_empresa
         AND (tip_nf = 'NFD' OR tip_nf = 'NFE')

      IF p_count > 0 THEN
         LET p_clientes.cli_fornec = 'F'
         IF NOT pol1136_grava_fornec() THEN
            RETURN FALSE
         END IF
      END IF

      LET p_cli_grav = p_cli_grav + 1

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------#
FUNCTION pol1136_ins_email(p_email, p_seq)
#-----------------------------------------#

   DEFINE p_email LIKE clientes_509.email1,
          p_seq   INTEGER
   
   DELETE FROM vdp_cli_grp_email
		WHERE cliente     = p_clientes.cod_cliente
		  AND grupo_email = 1
		  AND seq_email   = p_seq

   INSERT INTO vdp_cli_grp_email 
			VALUES (p_clientes.cod_cliente,
			        1, p_seq, p_email, "C" )
			        
   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF 

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1136_grava_cliente()
#-------------------------------#
		
   IF p_clientes.Email1 IS NOT NULL AND p_clientes.Email1 <> ' ' THEN
		  IF NOT pol1136_ins_email(p_clientes.Email1, 1) THEN
		     RETURN FALSE
		  END IF
			INSERT INTO vdp_cliente_grupo 
			   VALUES (p_clientes.cod_cliente, 1,"NFE", "C" )
		END IF 			

   IF p_clientes.Email2 IS NOT NULL AND p_clientes.Email2 <> ' ' THEN
		  IF NOT pol1136_ins_email(p_clientes.Email2, 2) THEN
		     RETURN FALSE
		  END IF
		END IF 			

   IF p_clientes.email3 IS NOT NULL AND p_clientes.email3 <> ' ' THEN
		  IF NOT pol1136_ins_email(p_clientes.email3, 3) THEN
		     RETURN FALSE
		  END IF
		END IF 			

		IF p_clientes.nom_reduzido  IS NULL oR p_clientes.nom_reduzido  = ' ' THEN 
		     LET p_clientes.nom_reduzido = p_clientes.nom_cliente[1,15]
		END IF 	 

   SELECT cod_cliente
     FROM clientes
    WHERE cod_cliente = p_clientes.cod_cliente
 
   IF STATUS = 100 THEN
      IF NOT pol1136_ins_cliente() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF NOT pol1136_atu_cliente() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','clientes')
         RETURN FALSE
      END IF
   END IF
   
   UPDATE clientes_509
      SET cod_estatus = 'A'
    WHERE id_registro = p_clientes.id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','clientes_509')
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1136_atu_cliente()
#-----------------------------#
   
   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)

   IF NOT pol1136_end_com_virgula() THEN
      LET p_clientes.end_cliente[36] = ','
   END IF
   
   UPDATE clientes
			SET nom_cliente		=	p_clientes.nom_cliente,			
					nom_reduzido		=	p_clientes.nom_reduzido	,
					end_cliente			=	p_clientes.end_cliente,		
					den_bairro			=	p_clientes.den_bairro,
					cod_cidade			=	p_cod_cic_cli,
					cod_cep					=	p_clientes.cod_cep,	
					num_telefone		=	p_clientes.num_telefone,
					num_fax					=	p_clientes.num_fax,	
					dat_atualiz			= p_dat_atu, 
					ins_estadual		=	p_clientes.insc_estadual
		WHERE cod_cliente	=	p_clientes.cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','clientes')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1136_ins_cliente()
#----------------------------#
   
   DEFINE l_zona_franca  CHAR(01),
          p_cod_rota     INTEGER,
          p_cod_local    INTEGER,
          p_ies_cli_for  CHAR(01),
          p_ies_situa    CHAR(01),
          p_cod_carteira CHAR(03),
          p_cod_clinte   CHAR(15),
          p_email1       CHAR(40),
          p_email2       CHAR(40),
          p_cpf_cgc      CHAR(11)
   
   IF l_estado = "AM" THEN
	    LET l_zona_franca= 'S'
   ELSE
	    LET l_zona_franca= 'N'
   END IF

   IF p_clientes.tip_cliente = 'J' THEN 
			LET l_cpf_cgc = '0',p_clientes.num_cnpj_cpf[1,2],'.',
			                    p_clientes.num_cnpj_cpf[3,5],'.',
			                    p_clientes.num_cnpj_cpf[6,8],'/',
			                    p_clientes.num_cnpj_cpf[9,12],'-',
			                    p_clientes.num_cnpj_cpf[13,14]
			LET p_cod_tip_cli = '01'	
   ELSE
      LET l_cpf_cgc = p_clientes.num_cnpj_cpf[1,3],'.',
                      p_clientes.num_cnpj_cpf[4,6],'.',
										  p_clientes.num_cnpj_cpf[7,9],'/0000-',
										  p_clientes.num_cnpj_cpf[10,11]
			LET p_cod_tip_cli = '01'	
   END IF 

   IF NOT pol1136_end_com_virgula() THEN
      LET p_clientes.end_cliente[36] = ','
   END IF
	
   LET p_cod_clinte = p_clientes.cod_cliente
   LET p_clientes.cod_cep = p_clientes.cod_cep[1,5],'-',p_clientes.cod_cep[6,8]
   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)
   LET p_hor_atu = TIME
   LET p_cod_rota = 0
   LET p_cod_local = 0
   LET p_ies_cli_for = 'C'
   LET p_ies_situa = 'A'         
   LET p_cod_clas = pol1136_le_par_cli('COD_CLASSE_CLIENTE')
   
   INSERT INTO clientes(
      cod_cliente,        
      cod_class,      
      nom_cliente,    
      end_cliente,    
      den_bairro,     
      cod_cidade,     
      cod_cep,        
      num_telefone,   
      num_fax,        
      cod_tip_cli,    
      nom_reduzido,   
      num_cgc_cpf,    
      ins_estadual,   
      ies_cli_forn,   
      ies_zona_franca,
      ies_situacao,   
      cod_rota,       
      dat_cadastro,   
      dat_atualiz,    
      cod_local) VALUES(p_clientes.cod_cliente,
                        p_cod_clas,
                        p_clientes.nom_cliente,
                        p_clientes.end_cliente,
                        p_clientes.den_bairro,
                        p_cod_cic_cli,
                        p_clientes.cod_cep,
                        p_clientes.num_telefone,
                        p_clientes.num_fax,
                        p_cod_tip_cli,
                        p_clientes.nom_reduzido,
                        l_cpf_cgc,
                        p_clientes.insc_estadual,
                        p_ies_cli_for,
                        l_zona_franca,
                        p_ies_situa,
                        p_cod_rota,
                        p_dat_atu,
                        p_dat_atu,
                        p_cod_local)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','clientes')
      RETURN FALSE
   END IF

   LET p_email1 = p_clientes.email1
   LET p_email2 = p_clientes.email2
   
   SELECT cliente
     FROM vdp_cliente_compl
    WHERE cliente = vdp_cliente_compl
   
   IF STATUS = 100 THEN
      INSERT INTO vdp_cliente_compl (cliente, email, email_secund) 
			   VALUES(p_clientes.cod_cliente,
                p_email1,
                p_email1)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','vdp_cliente_compl')
         RETURN FALSE
      END IF
   
   END IF
   
   LET l_parametro				= 'ins_municipal'
	 LET l_des_parametro		= 'INSCRICAO MUNICIPAL'
	 LET l_tip_parametro		=	NULL
   
   IF NOT pol1136_ins_parametros() THEN
      RETURN FALSE
   END IF
   
	 LET l_parametro				= 'dat_validade_suframa'
	 LET l_des_parametro		= 'DATA DE VALIDADE DO SUFRAMA'
	 LET l_tip_parametro		=	NULL

   IF NOT pol1136_ins_parametros() THEN
      RETURN FALSE
   END IF
   
   LET l_parametro				= 'microempresa'
	 LET l_des_parametro		= 'INDICADOR SE O CLIENTE EH OU NAO MICROEMPRESA'
	 LET l_tip_parametro		=	'N'

   IF NOT pol1136_ins_parametros() THEN
      RETURN FALSE
   END IF
   
   LET l_parametro				= 'ies_depositante'
	 LET l_des_parametro		= 'INDICA SE O CADASTRO EH UM DEPOSITANTE'
   LET l_tip_parametro		=	NULL

   IF NOT pol1136_ins_parametros() THEN
      RETURN FALSE
   END IF
   
   LET l_parametro				= 'celular'
	 LET l_des_parametro		= 'CELULAR DO CLIENTE'
	 LET l_tip_parametro		=	NULL

   IF NOT pol1136_ins_parametros() THEN
      RETURN FALSE
   END IF

   LET p_cod_carteira =  pol1136_le_par_cli('COD_DA_CARTEIRA')
   
   IF p_cod_carteira IS NOT NULL THEN
      SELECT COUNT(*)
		    INTO p_count 
		    FROM cli_canal_venda
		   WHERE cod_cliente = p_clientes.cod_cliente
		     AND cod_tip_carteira = p_cod_carteira
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','cli_canal_venda')
         RETURN FALSE
      END IF
      
			IF p_count = 0 THEN 
				INSERT INTO cli_canal_venda 
				  VALUES(p_clientes.cod_cliente,99,1,0,0,0,0,0,02,p_cod_carteira)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','cli_canal_venda')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   SELECT COUNT(cod_cliente)
     INTO p_count
		 FROM cli_dist_geog
		WHERE cod_cliente = p_clientes.cod_cliente

   IF p_count = 0 THEN 
			CASE 
					WHEN l_estado = "ES" OR l_estado = "MG" OR l_estado = "RJ" OR l_estado = "SP" 
						LET l_cod_reg = 1
					WHEN l_estado = "AC" OR l_estado = "AP" OR l_estado = "AM" OR l_estado = "PA" OR 
					     l_estado = "RO" OR l_estado = "RR" OR l_estado = "TO"
						LET l_cod_reg = 2
					WHEN l_estado = "BA" OR l_estado = "CE" OR l_estado = "MA" OR l_estado = "PB" OR 
					     l_estado = "SE" OR l_estado = "PI" OR l_estado = "RN" OR l_estado = "AL" OR 
					     l_estado = "PE" 
						LET l_cod_reg = 3
					WHEN l_estado = "DF" OR l_estado = "GO" OR l_estado = "MT" OR l_estado = "MS"  
						LET l_cod_reg = 4
					WHEN l_estado = "RS" OR l_estado = "PR" OR l_estado = "SC"
						LET l_cod_reg = 5
			END CASE 
				
      INSERT INTO cli_dist_geog 
         VALUES(p_clientes.cod_cliente,'01',1,'001',l_cod_reg,l_estado)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','cli_dist_geog')
         RETURN FALSE
      END IF
   END IF 
   
   IF NOT pol1136_ins_cli_for('C') THEN 
      RETURN FALSE
   END IF
			
   LET p_msg = 'INCLUSAO DO CLIENTE ', p_clientes.cod_cliente

   INSERT INTO audit_logix(cod_empresa, 
        texto, num_programa, data, hora, usuario) 
		VALUES(p_cod_empresa,p_msg,'pol1136',p_dat_atu , p_hor_atu , p_user)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_logix')
      RETURN FALSE
   END IF
			
		
   INSERT INTO cli_credito(
      cod_cliente, qtd_dias_atr_dupl, qtd_dias_atr_med, 
			val_ped_carteira, val_dup_aberto, dat_ult_fat, 
			val_limite_cred, dat_val_lmt_cr, ies_nota_debito, dat_atualiz) 
    VALUES(p_clientes.cod_cliente, 0, 0, 0, 0, NULL, 0, NULL, 'N', p_dat_atu )
			
   IF (STATUS <> 0)   and 
      (STATUS <> -239)   THEN
      CALL log003_err_sql('Inserindo','cli_credito')
      RETURN FALSE
   END IF
			
   INSERT INTO cliente_alter(cod_cliente) VALUES(p_clientes.cod_cliente)

   IF (STATUS <> 0)   and 
      (STATUS <> -239)   THEN
      CALL log003_err_sql('Inserindo','cliente_alter')
      RETURN FALSE
   END IF
			
   INSERT INTO credcad_cli 
			VALUES(p_clientes.cod_cliente, 0, NULL, 0, NULL, 0, NULL, 0, 0, 0, 0, 0, 0, NULL, 
			   0, NULL, 0, 0, 0, NULL, 0, NULL, 0, 0, 0, 0, 0, 0, NULL, 0, NULL, 0, NULL, 
			   NULL, 'N', NULL, NULL, 'N', 'N', 'S', 0, 'N', NULL)

   IF (STATUS <> 0)   and 
      (STATUS <> -239)   THEN
      CALL log003_err_sql('Inserindo','credcad_cli')
      RETURN FALSE
   END IF
	 
	 LET p_cpf_cgc = l_cpf_cgc[1,11]
	 
   INSERT INTO credcad_cgc 
     VALUES(p_cpf_cgc, 0, NULL,0,NULL,0,NULL,0,0,0,0,0,0,NULL,0,NULL,0,0,0,
            NULL,0,NULL,0,0,0,0,0,0,NULL,0,NULL,0,NULL,NULL,'N','N','N','S',0,'N',NULL)

   IF (STATUS <> 0)   and 
      (STATUS <> -239)   THEN
      CALL log003_err_sql('Inserindo','credcad_cgc')
      RETURN FALSE
   END IF
			
   INSERT INTO credcad_rateio 
     VALUES(l_cpf_cgc[1,11], p_clientes.cod_cliente, 0, NULL)

    IF (STATUS <> 0)   and 
      (STATUS <> -239)   THEN
      CALL log003_err_sql('Inserindo','credcad_rateio')
      RETURN FALSE
   END IF
			
   INSERT INTO credcad_cod_cli 
			VALUES(p_clientes.cod_cliente, ' ', ' ', ' ', NULL, NULL)

   IF (STATUS <> 0)   and 
      (STATUS <> -239)   THEN
      CALL log003_err_sql('Inserindo','credcad_cod_cli')
      RETURN FALSE
   END IF
			
   SELECT MAX(chave_cliente) + 1
     INTO  p_count
     FROM sil_dimensao_cliente
			
   IF p_count IS NULL OR p_count = 0 THEN
      LET p_count = 1
   END IF 
			
   INSERT INTO sil_dimensao_cliente( 
			chave_cliente, 
			cliente, 
			nom_cliente, 
			nom_reduz, 
			dat_cadastro) 
		VALUES(p_count, 
		       p_clientes.cod_cliente,
		       p_clientes.nom_cliente, 
		       p_clientes.nom_reduzido, 
		       p_dat_atu)
			
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','sil_dimensao_cliente')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1136_ins_parametros()
#--------------------------------#

   SELECT cliente
     FROM vdp_cli_parametro
    WHERE cliente = p_clientes.cod_cliente
      AND parametro = l_parametro
      AND des_parametro = l_des_parametro

   IF STATUS = 100 THEN  
   ELSE
      RETURN TRUE
   END IF
      
   INSERT INTO vdp_cli_parametro(
      cliente, 
      parametro, 
      des_parametro, 
      tip_parametro) 
    VALUES(p_clientes.cod_cliente, 
           l_parametro, 
           l_des_parametro, 
           l_tip_parametro)
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','vdp_cli_parametro')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1136_ins_cli_for(p_cli_for)
#-------------------------------------#

   DEFINE p_cli_for Char(01)
   
   SELECT cliente_fornecedor
     FROM vdp_cli_fornec_cpl
    WHERE cliente_fornecedor = p_clientes.cod_cliente
      AND tip_cadastro = p_cli_for
   
   IF STATUS = 100 THEN
   ELSE
      RETURN TRUE
   END IF
   
   INSERT INTO vdp_cli_fornec_cpl( 
      cliente_fornecedor, 
      tip_cadastro, 
      razao_social, 
      razao_social_reduz, 
			bairro,
			telefone_1,
			logradouro) 
			   VALUES(p_clientes.cod_cliente,
			          p_cli_for, 
			          p_clientes.nom_cliente,
			          p_clientes.nom_reduzido, 
						    p_clientes.den_bairro,
						    p_clientes.num_telefone,
						    p_clientes.end_cliente) 
						
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','vdp_cli_fornec_cpl')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1136_grava_fornec()
#------------------------------#
		
   IF p_clientes.nom_reduzido  IS NULL oR p_clientes.nom_reduzido  = ' ' THEN 
		  LET p_clientes.nom_reduzido = p_clientes.nom_cliente[1,15]
	 END IF 	 

   CALL pol1136_checa_campos()

   LET p_raz_reduz = p_clientes.nom_reduzido
   
   SELECT cod_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = p_clientes.cod_cliente
 
   IF STATUS = 100 THEN
      IF NOT pol1136_ins_fornec() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF NOT pol1136_atu_fornec() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','fornecedor')
         RETURN FALSE
      END IF
   END IF
   
   UPDATE clientes_509
      SET cod_estatus = 'A'
    WHERE id_registro = p_clientes.id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','clientes_509')
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1136_atu_fornec()
#----------------------------#

   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)

   UPDATE fornecedor
				SET raz_social				=	p_clientes.nom_cliente,
						raz_social_reduz	=	p_raz_reduz,
						ins_estadual 			= p_clientes.insc_estadual,
						dat_atualiz 			= p_dat_atu ,
						end_fornec 				= p_clientes.end_cliente,
						den_bairro 				= p_clientes.den_bairro,
						cod_cep 					= p_clientes.cod_cep,
						cod_cidade				=	p_cod_cic_cli,
						cod_uni_feder 		=	l_estado,
						num_telefone			=	p_clientes.num_telefone,
						num_fax 					= p_clientes.num_fax,
						nom_contato 			= p_clientes.contato,
						nom_guerra				=	p_clientes.contato
    WHERE Cod_fornecedor = p_clientes.cod_cliente
					
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','fornecedor')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1136_checa_campos()#
#------------------------------#

   IF NOT pol1136_end_com_virgula() THEN
      LET p_clientes.end_cliente[36] = ','
   END IF

   IF p_clientes.num_telefone IS NULL OR p_clientes.num_telefone = ' ' THEN
      LET p_clientes.num_telefone = '1111111'
   END IF
   
   IF p_clientes.nom_cliente IS NULL THEN
      LET p_clientes.nom_cliente = ' '
   END IF

   IF p_clientes.nom_reduzido IS NULL THEN
      LET p_clientes.nom_reduzido = ' '
   END IF
   
   IF p_clientes.insc_estadual IS NULL THEN
      LET p_clientes.insc_estadual = ' '
   END IF
   
   IF p_clientes.end_cliente IS NULL THEN
      LET p_clientes.end_cliente = ' '
   END IF
   
   IF p_clientes.den_bairro IS NULL THEN
      LET p_clientes.den_bairro = ' '
   END IF
   
   IF p_clientes.cod_cep IS NULL THEN
      LET p_clientes.cod_cep = ' '
   END IF
   
   IF p_clientes.num_fax IS NULL THEN
      LET p_clientes.num_fax = ' '
   END IF
   
   IF p_clientes.contato IS NULL THEN
      LET p_clientes.contato = ' '
   END IF
   
   IF p_clientes.tip_cliente IS NULL THEN
      LET p_clientes.tip_cliente = ' '
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol1136_ins_fornec()
#----------------------------#

   DEFINE l_zona_franca      CHAR(01),
          p_cod_rota         INTEGER,
          p_cod_local        INTEGER,
          p_ies_cli_for      CHAR(01),
          p_ies_situa        CHAR(01),
          p_cod_carteira     CHAR(03),
          p_ies_tip_fornec   CHAR(01),
          p_ies_fornec_ativo CHAR(01),
          p_ies_contrib_ipi  CHAR(01),
          p_cod_pais         CHAR(03),
          p_tmp_transpor     INTEGER,
          p_num_lote_transf  INTEGER,
          p_pct_aceite_div   INTEGER,
          p_ies_tip_entrega  CHAR(01),
          p_ies_dep_cred     CHAR(01),
          p_ult_num_coleta   INTEGER

          
   IF l_estado = "AM" THEN
	    LET l_zona_franca= 'S'
   ELSE
	    LET l_zona_franca= 'N'
   END IF

   IF p_clientes.tip_cliente = 'J' THEN 
			LET l_cpf_cgc = '0',p_clientes.num_cnpj_cpf[1,2],'.',
			                    p_clientes.num_cnpj_cpf[3,5],'.',
			                    p_clientes.num_cnpj_cpf[6,8],'/',
			                    p_clientes.num_cnpj_cpf[9,12],'-',
			                    p_clientes.num_cnpj_cpf[13,14]
			LET p_cod_tip_cli = '01'	
   ELSE
      LET l_cpf_cgc = p_clientes.num_cnpj_cpf[1,3],'.',
                      p_clientes.num_cnpj_cpf[4,6],'.',
										  p_clientes.num_cnpj_cpf[7,9],'/0000-',
										  p_clientes.num_cnpj_cpf[10,11]
			LET p_cod_tip_cli = '01'	
   END IF 
		
   LET p_clientes.cod_cep = p_clientes.cod_cep[1,5],'-',p_clientes.cod_cep[6,8]
   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)
   LET p_hor_atu          = TIME
   LET p_ies_cli_for      = 'F'
	 LET p_ies_tip_fornec   = '1'
	 LET p_ies_fornec_ativo = 'A' 
	 LET p_ies_contrib_ipi  = 'N' 
	 LET p_cod_pais         = '001'
	 LET p_tmp_transpor     = 1
	 LET p_num_lote_transf  = 0
	 LET p_pct_aceite_div   = 0
	 LET p_ies_tip_entrega  = 'D'
	 LET p_ies_dep_cred     = 'N'
	 LET p_ult_num_coleta   = 0

   LET l_cod_fornecedor = p_clientes.cod_cliente        
   
   INSERT INTO fornecedor(
      num_cgc_cpf, 
      cod_fornecedor, 
      raz_social, 
      raz_social_reduz, 							
			ies_tip_fornec, 
			ies_fornec_ativo, 
			ies_contrib_ipi, 
			ies_fis_juridica,
			ins_estadual, 
			dat_cadast, 
			dat_atualiz, 
			dat_validade, 
			end_fornec, 
			den_bairro, 
			cod_cep, 
			cod_cidade, 
			cod_uni_feder, 
			cod_pais, 
			ies_zona_franca, 
			num_telefone, 
			num_fax, 
			nom_contato, 
			nom_guerra, 
			tmp_transpor, 
			num_lote_transf, 
			pct_aceite_div, 
			ies_tip_entrega, 
			ies_dep_cred, 
			ult_num_coleta) 
   VALUES(l_cpf_cgc, 
          l_cod_fornecedor, 
          p_clientes.nom_cliente,
          p_raz_reduz,
          p_ies_tip_fornec,
	        p_ies_fornec_ativo,
	        p_ies_contrib_ipi,
          p_clientes.tip_cliente,
					p_clientes.insc_estadual, 
					p_dat_atu,
					p_dat_atu,
					p_dat_atu, 
					p_clientes.end_cliente, 
					p_clientes.den_bairro, 
					p_clientes.cod_cep, 
					p_cod_cic_cli,
					l_estado,
					p_cod_pais,
					l_zona_franca, 
					p_clientes.num_telefone,
					p_clientes.num_fax, 
					p_clientes.contato, 
					p_clientes.contato,
					p_tmp_transpor, 
					p_num_lote_transf,
					p_pct_aceite_div, 
					p_ies_tip_entrega,
					p_ies_dep_cred, 
					p_ult_num_coleta)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fornecedor')
      RETURN FALSE
   END IF

   INSERT INTO fornec_compl (
      cod_fornecedor, 
      codigo_ret, 
      e_mail, 
      email_secund)
    VALUES(l_cod_fornecedor, 0, 
           p_clientes.email1, 
           p_clientes.email2)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fornec_compl')
      RETURN FALSE
   END IF

   LET l_parametro 				  =	'ies_depositante'
   LET l_des_parametro 	 	  =	'Indica se o cadastro eh um depositante    '
   LET l_parametro_booleano =	NULL
   LET l_parametro_texto		= NULL  

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

   LET l_parametro 	 			  =	'email_compras  '
   LET l_des_parametro 		  =	'E-mail do Setor de Compras do Fornecedor '
   LET l_parametro_booleano =	NULL 
   LET l_parametro_texto		= NULL 

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF
		
	 LET l_parametro 				=	'declara_isento '                          				
	 LET l_des_parametro 		=	'DECLARACAO DE ISENTO SIMPLES             '					
	 LET l_parametro_booleano =	'N'                                      					
	 LET l_parametro_texto		= NULL                                       					

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

   LET l_parametro 				=	'ies_contrib_pis'                              
	 LET l_des_parametro 		=	'Indicador de Contribuicao de PIS.        '    				
	 LET l_parametro_booleano =	'N'                                          				
	 LET l_parametro_texto		= NULL                                         				

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

	 LET l_parametro 				=	'ies_contrib_cofins  '                            
	 LET l_des_parametro 		=	'Indicador de Contribuicao de COFINS      '       					
	 LET l_parametro_booleano =	'N'                                             					
	 LET l_parametro_texto		= NULL                                              					

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

	 LET l_parametro 				=	'ies_contrib_csl'                                 
	 LET l_des_parametro 		=	'Indicador de Contribuicao de CSL         '       					
	 LET l_parametro_booleano =	'N'                                             					
	 LET l_parametro_texto		= NULL                                              					

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

   LET l_parametro 				=	'ind_ret_pis_cof'                                 
	 LET l_des_parametro 		=	'Indicador tipo retencao do PIS/COFINS/CSL'       				
	 LET l_parametro_booleano =	NULL                                            				
	 LET l_parametro_texto		= '0'                                             				

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

	 LET l_parametro 				=	'cred_pis_cofins'                           
	 LET l_des_parametro 		=	'Credito presumido PIS/COFINS             ' 					
	 LET l_parametro_booleano =	'N'                                       					
	 LET l_parametro_texto		= NULL                                        					

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

	 LET l_parametro 				=	'util_subcontratacao '                         
	 LET l_des_parametro 		=	'Indicador de Subcontratacao              '    				
	 LET l_parametro_booleano =	'N'                                          				
	 LET l_parametro_texto		= NULL                                         				

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

	 LET l_parametro 				=	'subtipo_fornecedor  '                     
	 LET l_des_parametro 		=	'Subtipo do fornecedor                    '					
	 LET l_parametro_booleano =	NULL                                     					
	 LET l_parametro_texto		= NULL                                       					

   IF NOT pol1136_ins_par_fornecedor() THEN
      RETURN FALSE
   END IF

   IF NOT pol1136_ins_cli_for('F') THEN 
      RETURN FALSE
   END IF

   SELECT MAX(chave_fornecedor)+1
		 INTO p_count
	   FROM sil_dimensao_fornecedor
			
   IF p_count IS NULL THEN
			LET p_count = 1
	 END IF 
			 
   INSERT INTO sil_dimensao_fornecedor ( 
      chave_fornecedor, 
      fornecedor, 
      cpf_cnpj_fornecedor, 
      razao_social, 
			razao_social_reduz) 
     VALUES(p_count, 
            l_cod_fornecedor, 
            l_cpf_cgc, 
            p_clientes.nom_cliente, 
						p_raz_reduz)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','sil_dimensao_fornecedor')
      RETURN FALSE
   END IF

   SELECT COUNT(fornecedor)
     INTO p_count
     FROM cap_par_fornec_imp
    WHERE fornecedor = l_cod_fornecedor
      AND parametro  = 'reten_iss_pag_ent'
   
   IF p_count = 0 THEN 
    
      INSERT INTO cap_par_fornec_imp (
         fornecedor, 
         parametro, 
         des_parametro)
        VALUES(l_cod_fornecedor,
               'reten_iss_pag_ent', 
               'RETEM ISS NO PAGAMENTO')

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','cap_par_fornec_imp')
         RETURN FALSE
      END IF
      
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1136_ins_par_fornecedor()
#------------------------------------#

   SELECT empresa
     FROM sup_par_fornecedor
    WHERE empresa = p_cod_empresa
      AND fornecedor = l_cod_fornecedor
      AND parametro = l_parametro
   
   IF STATUS = 100 THEN
      INSERT INTO sup_par_fornecedor (
         empresa, 
         fornecedor, 
         parametro, 
         des_parametro, 
         parametro_booleano, 
		     parametro_texto)
      VALUES(p_cod_empresa, 
           l_cod_fornecedor,
           l_parametro,
           l_des_parametro, 
           l_parametro_booleano,
           l_parametro_texto)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','sup_par_fornecedor')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1136_gera_num_ar()
#-----------------------------#

   SELECT par_val
     INTO p_num_prx_ar
     FROM par_sup_pad
    WHERE cod_empresa   = p_nf_mestre.cod_empresa
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_sup_pad')
      RETURN FALSE
   END IF

   UPDATE par_sup_pad
      SET par_val = (par_val + 1)
    WHERE cod_empresa   = p_nf_mestre.cod_empresa
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_sup_pad')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1136_troca_cod(p_cod_cfop) 
#-------------------------------------#

   DEFINE p_cfop      CHAR(05),
          p_cod_cfop  CHAR(04)

   LET p_cfop = p_cod_cfop[1],'.',p_cod_cfop[2,4]
   
   IF p_cfop[1] = '1' THEN
      LET p_cfop[1] = '5'
   ELSE
      IF p_cfop[1] = '2' THEN
         LET p_cfop[1] = '6'
      ELSE
         IF p_cfop[1] = '3' THEN
            LET p_cfop[1] = '7'
         END IF
      END IF
   END IF

   RETURN(p_cfop)

END FUNCTION

#-----------------------------#
FUNCTION pol1136_grava_entrda()
#-----------------------------#

   DEFINE p_cod_operacao    LIKE nf_sup.cod_operacao

   INITIALIZE p_trans_nf, p_ssr_nf,  p_dat_hor to NULL
   
   IF p_nf_mestre.tip_nf = 'NFD' THEN
      DECLARE cq_dev CURSOR FOR
       SELECT trans_nota_fiscal,
              subserie_nf,
              dat_hor_emissao
         FROM fat_nf_mestre
        WHERE empresa = p_nf_mestre.cod_empresa
          AND tip_nota_fiscal = 'FATPRDSV'
          AND nota_fiscal     = p_nf_mestre.num_nf_dev
          AND serie_nota_fiscal = p_nf_mestre.ser_nf_dev
          AND cliente = p_nf_mestre.cod_cliente
      
      FOREACH cq_dev INTO p_trans_nf, p_ssr_nf,  p_dat_hor

         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','cq_dev')
            RETURN FALSE
         END IF
         EXIT FOREACH
      END FOREACH
   END IF

   LET p_num_seq_erro = 0
          
   LET p_cod_operacao = pol1136_le_cfop()

   IF p_cod_operacao IS NULL THEN
      LET p_msg = 'Problemas lendo CFOP para a NF ',p_nf_mestre.num_nf, '\n',
                  'na tabela nf_itens_509.'
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN FALSE
   END IF

   LET p_cod_operacao = pol1136_troca_cod(p_cod_operacao)

   IF NOT pol1136_gera_num_ar() THEN
      RETURN FALSE
   END IF
      
   LET p_nf_sup.cod_empresa 				=	p_nf_mestre.cod_empresa
   LET p_nf_sup.cod_empresa_estab 	=	NULL 										
   LET p_nf_sup.num_nf 					    =	p_nf_mestre.num_nf						
   LET p_nf_sup.ser_nf 					    =	p_nf_mestre.ser_nf	
   
   IF p_nf_mestre.tip_nf = 'NFE' THEN					
      LET p_nf_sup.ssr_nf 					= pol1136_le_par_omc('SUB_SER_NF_ENTRADA')
   ELSE
      LET p_nf_sup.ssr_nf 					= pol1136_le_par_omc('SUB_SER_NF_DEVOLUCAO')
   END IF
   
   LET p_nf_sup.ies_especie_nf 			=	p_nf_mestre.tip_nf				
   LET p_nf_sup.cod_fornecedor 			=	p_nf_mestre.cod_cliente
   LET p_nf_sup.cod_operacao       	= p_cod_operacao   
   LET p_nf_sup.cod_regist_entrada	=	'1'
   LET p_nf_sup.num_conhec 		      =	0
	 LET p_nf_sup.ser_conhec 				  = 0
   LET p_nf_sup.ssr_conhec 				  =	0
   LET p_nf_sup.cod_transpor 				=	0
   LET p_nf_sup.num_aviso_rec       =	p_num_prx_ar
   LET p_nf_sup.dat_emis_nf 				=	p_nf_mestre.dat_emissao
   LET p_nf_sup.dat_entrada_nf 			=	p_nf_mestre.dat_emissao
   LET p_nf_sup.val_tot_nf_c 				=	p_nf_mestre.val_tot_nf	
   LET p_nf_sup.val_tot_nf_d 				=	p_nf_mestre.val_tot_nf	

   SELECT SUM(val_icms)
     INTO p_nf_sup.val_tot_icms_nf_d
     FROM nf_itens_509
    WHERE cod_empresa = p_nf_mestre.cod_empresa
      AND cod_cliente = p_nf_mestre.cod_cliente
      AND num_nf      = p_nf_mestre.num_nf
      AND ser_nf      = p_nf_mestre.ser_nf
		  
		IF p_nf_sup.val_tot_icms_nf_d IS NULL THEN
			 LET p_nf_sup.val_tot_icms_nf_d  =	0	
		END IF 
		
		LET p_nf_sup.val_tot_icms_nf_c      = p_nf_sup.val_tot_icms_nf_d 
		LET p_nf_sup.val_tot_desc 					=	p_nf_mestre.val_desc_incond + p_nf_mestre.val_desc_cenp
		LET p_nf_sup.val_tot_acresc 				=	0
		LET p_nf_sup.val_ipi_nf 						=	0
		LET p_nf_sup.val_ipi_calc 					=	0
		LET p_nf_sup.val_despesa_aces 			=	0
		LET p_nf_sup.val_adiant 						=	0
		LET p_nf_sup.ies_tip_frete 					=	0 #pol1136_le_par_omc('COD_TIP_FRETE') 
		LET p_nf_sup.cnd_pgto_nf 						=	pol1136_le_par_omc('COD_COND_PGTO_NFD_NFE')
		LET p_nf_sup.cod_mod_embar 					=	pol1136_le_par_omc('COD_MOD_EMBARQUE')
		LET p_nf_sup.nom_resp_aceite_er 		=	' '
		LET p_nf_sup.ies_incl_cap 					=	'N'
		LET p_nf_sup.ies_incl_contab 				=	'N'
		LET p_nf_sup.ies_calc_subst 				=	"N"
		LET p_nf_sup.val_bc_subst_d 				=	0
		LET p_nf_sup.val_icms_subst_d 			=	0
		LET p_nf_sup.val_bc_subst_c 				=	0
		LET p_nf_sup.val_icms_subst_c 			=	0
		LET p_nf_sup.cod_imp_renda 					=	''
		LET p_nf_sup.val_imp_renda 					=	0
		LET p_nf_sup.ies_situa_import 			=	' '
		LET p_nf_sup.val_bc_imp_renda 			=	0
		LET p_nf_sup.ies_nf_aguard_nfe 			=	'1'
    LET p_nf_sup.ies_nf_com_erro 				=	"S"

   INSERT INTO nf_sup VALUES (p_nf_sup.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','nf_sup')
      RETURN FALSE
   END IF

   LET p_msg = 'FALTA CONSISTIR A NOTA FISCAL'

   IF NOT pol1136_ins_nf_erro() THEN
      RETURN FALSE
   END IF

   LET p_trans_nf = 0
   LET p_ssr_nf  = 0

   IF NOT pol1136_ins_nf_eletronica(p_nf_sup.num_aviso_rec) THEN
      RETURN FALSE
   END IF

   IF NOT pol1136_ins_ar_compl() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1136_grava_ar() then
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1136_ins_ar_compl()
#-----------------------------#
   
   DEFINE p_ar_compl RECORD LIKE aviso_rec_compl.*
   
   LET p_ar_compl.cod_empresa      = p_nf_sup.cod_empresa
   LET p_ar_compl.num_aviso_rec    = p_nf_sup.num_aviso_rec
   LET p_ar_compl.cod_transpor     = p_nf_sup.cod_transpor
   LET p_ar_compl.den_transpor     = ''
   LET p_ar_compl.cod_fiscal_compl = '0'
   LET p_ar_compl.dat_proces       = ' '
   LET p_ar_compl.ies_situacao     = 'N'
   LET p_ar_compl.cod_operacao     = pol1136_le_par_omc('COD_OPER_NF_ENTRADA')
   LET p_ar_compl.nom_usuario      = p_user
   LET p_ar_compl.dat_proces       = DATE
   LET p_ar_compl.hor_operac       = TIME

   INSERT INTO aviso_rec_compl
       VALUES (p_ar_compl.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','aviso_rec_compl')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1136_ins_nf_erro()
#----------------------------#

   DEFINE p_nf_erro RECORD LIKE nf_sup_erro.*
   
   LET p_num_seq_erro               = p_num_seq_erro + 1
   LET p_nf_erro.empresa            = p_nf_mestre.cod_empresa
   LET p_nf_erro.num_aviso_rec      = p_num_prx_ar
   LET p_nf_erro.num_seq            = 0
   LET p_nf_erro.des_pendencia_item = p_msg
   LET p_nf_erro.ies_origem_erro    = p_num_seq_erro
   LET p_nf_erro.ies_erro_grave     = 'N'
   LET p_nf_erro.num_transac        = 0

   INSERT INTO nf_sup_erro(
      empresa,
      num_aviso_rec,
      num_seq,
      des_pendencia_item,
      ies_origem_erro,
      ies_erro_grave)
      VALUES(
         p_nf_erro.empresa,           
         p_nf_erro.num_aviso_rec,     
         p_nf_erro.num_seq,           
         p_nf_erro.des_pendencia_item,
         p_nf_erro.ies_origem_erro,   
         p_nf_erro.ies_erro_grave)     

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','nf_sup_erro')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1136_le_cfop()#
#-------------------------#
  
  DEFINE p_cod_fiscal CHAR(10)
  
  DECLARE cq_cfop CURSOR FOR
   SELECT cod_fiscal
     FROM nf_itens_509
    WHERE cod_empresa = p_nf_mestre.cod_empresa
      AND cod_cliente = p_nf_mestre.cod_cliente
      AND num_nf      = p_nf_mestre.num_nf
      AND ser_nf      = p_nf_mestre.ser_nf
      
  FOREACH cq_cfop INTO p_cod_fiscal
   
    IF STATUS <> 0 THEN
       CALL log003_err_sql('','cursor cq_cfop')
       RETURN FALSE
    END IF

    RETURN (p_cod_fiscal)
 
  END FOREACH

   RETURN NULL

END FUNCTION

#--------------------------#
FUNCTION pol1136_grava_ar()
#--------------------------#
   
  INITIALIZE p_aviso_rec TO NULL
   
  LET p_aviso_rec.cod_empresa    = p_nf_mestre.cod_empresa                  
  LET p_aviso_rec.num_aviso_rec  = p_nf_sup.num_aviso_rec  

  LET p_ind = 0

  DECLARE cq_ar CURSOR WITH HOLD FOR
   SELECT *
     FROM nf_itens_509
    WHERE cod_empresa = p_nf_mestre.cod_empresa
      AND cod_cliente = p_nf_mestre.cod_cliente
      AND num_nf      = p_nf_mestre.num_nf
      AND ser_nf      = p_nf_mestre.ser_nf
      
  FOREACH cq_ar INTO p_nf_item.*
   
    IF STATUS <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_AR')
       RETURN FALSE
    END IF

    LET p_ind = p_ind + 1
    LET p_cod_item = p_nf_item.cod_item

    IF NOT pol1136_ins_aviso() THEN
       RETURN FALSE
    END IF
    
    IF p_nf_mestre.tip_nf = 'NFD' THEN
       IF NOT pol1136_ins_sup_dev() THEN
          RETURN FALSE
       END IF
    END IF
        
  END FOREACH
  
  RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1136_ins_aviso()
#---------------------------#
  
  DEFINE p_audit_ar RECORD LIKE audit_ar.*,
         p_dest_ar  RECORD LIKE dest_aviso_rec.*
   
	LET p_aviso_rec.num_seq 				      =	p_ind
	LET p_aviso_rec.dat_inclusao_seq 		  =	TODAY
	LET p_aviso_rec.ies_situa_ar 			    =	"E"
	LET p_aviso_rec.ies_incl_almox 			  =	"N"
	LET p_aviso_rec.ies_receb_fiscal 		  =	"S"
	LET p_aviso_rec.ies_liberacao_ar 		  =	"1"
	LET p_aviso_rec.ies_liberacao_cont 		=	"S"
	LET p_aviso_rec.ies_liberacao_insp 		=	"S"
	LET p_aviso_rec.ies_diverg_listada 		=	"N"
	LET p_aviso_rec.ies_controle_lote 		=	"N"

	SELECT cod_comprador,
				gru_ctr_desp,
				cod_tip_despesa,
				num_conta,
				ies_tip_incid_ipi,
				ies_tip_incid_icms
	INTO 	p_aviso_rec.cod_comprador,
				p_aviso_rec.gru_ctr_desp_item,
				p_aviso_rec.cod_tip_despesa,
				p_num_conta,
				p_aviso_rec.ies_tip_incid_ipi,
				p_aviso_rec.ies_incid_icms_ite
	 FROM	item_sup
	WHERE cod_empresa = p_nf_item.cod_empresa
	  AND	cod_item    = p_nf_item.Cod_item  
	
	IF STATUS <> 0 THEN
		LET p_aviso_rec.cod_comprador			 = 0
		LET p_aviso_rec.gru_ctr_desp_item	 = 0
		LET p_aviso_rec.cod_tip_despesa		 = 0
		LET p_aviso_rec.ies_tip_incid_ipi  = "O"
		LET p_aviso_rec.ies_incid_icms_ite = "O"
	END IF 

	IF p_aviso_rec.gru_ctr_desp_item IS NULL THEN
		LET p_aviso_rec.gru_ctr_desp_item		= 0
	END IF 
	
	SELECT cod_cla_fisc,
				cod_local_estoq,
				cod_lin_prod, 
				cod_lin_recei,
				cod_seg_merc, 
				cod_cla_uso,
				ies_ctr_estoque             
	INTO 	p_aviso_rec.cod_cla_fisc,
				p_aviso_rec.cod_local_estoq,
				p_aen.cod_lin_prod,
				p_aen.cod_lin_recei,
				p_aen.cod_seg_merc,
				p_aen.cod_cla_uso,
				p_aviso_rec.ies_item_estoq
	 FROM	item  
	WHERE cod_empresa = p_nf_item.cod_empresa
	 AND 	cod_item    = p_nf_item.cod_item
	
	IF STATUS <> 0 THEN 
		LET p_aviso_rec.cod_cla_fisc = '0'
		LET p_aviso_rec.ies_item_estoq = p_nf_item.ctr_estoque
		LET p_aviso_rec.cod_local_estoq = 'ALMOX'
	END IF 
	
	IF p_aviso_rec.cod_local_estoq IS NULL THEN
	   LET p_aviso_rec.cod_local_estoq = ' '
	END IF

  IF p_nf_mestre.tip_nf = 'NFD' THEN
     SELECT cod_conta
       INTO p_num_conta
       FROM conta_dev_clientes
      WHERE cod_lin_prod   = p_aen.cod_lin_prod    
        AND cod_lin_recei  = p_aen.cod_lin_recei
        AND cod_seg_merc   = p_aen.cod_seg_merc 
        AND cod_cla_uso    = p_aen.cod_cla_uso  
     IF STATUS <> 0 THEN
        LET p_num_conta = 0
     END IF
  END IF
       
	IF	p_num_conta IS NULL THEN
		LET p_num_conta = 0
	END IF 
	
	LET	p_aviso_rec.cod_fiscal_item    = pol1136_troca_cod(p_nf_item.cod_fiscal)
	LET p_aviso_rec.cod_item 					 =	p_nf_item.cod_item
	LET p_aviso_rec.den_item 					 =	p_nf_item.den_item
	LET p_aviso_rec.cod_unid_med_nf 	 =	p_nf_item.cod_unidade
	LET p_aviso_rec.pre_unit_nf 			 =	p_nf_item.pre_unit_liq
	LET p_aviso_rec.val_despesa_aces_i =	0		
	LET p_aviso_rec.ies_da_bc_ipi 		 =	"N"

	CASE 
		WHEN p_aviso_rec.ies_tip_incid_ipi = "C"
			LET p_aviso_rec.cod_incid_ipi 			=	1
		WHEN p_aviso_rec.ies_tip_incid_ipi = "O"	
			LET p_aviso_rec.cod_incid_ipi 			=	3
		WHEN p_aviso_rec.ies_tip_incid_ipi = "I"
			LET p_aviso_rec.cod_incid_ipi 			=	2
		OTHERWISE
			LET p_aviso_rec.cod_incid_ipi 			=	0
	END CASE

	LET p_aviso_rec.pct_direito_cred 			=	100	
	LET p_aviso_rec.pct_ipi_tabela 				=	p_nf_item.pct_ipi
	LET p_aviso_rec.pct_ipi_declarad 			=	p_nf_item.pct_ipi
	LET p_aviso_rec.val_base_c_ipi_it 		=	p_nf_item.val_base_ipi
 	LET p_aviso_rec.val_ipi_calc_item 		=	p_nf_item.val_ipi
	LET p_aviso_rec.val_ipi_decl_item 		=	p_nf_item.val_ipi
	LET p_aviso_rec.val_base_c_ipi_da 		=	0
	LET p_aviso_rec.val_ipi_desp_aces 		=	0

	LET p_aviso_rec.ies_bitributacao 			=	"N"
	LET p_aviso_rec.val_desc_item 				=	p_nf_item.val_desc_incond + p_nf_item.val_desc_cenp
	LET p_aviso_rec.val_liquido_item 			=	p_nf_item.val_liq_item
	LET p_aviso_rec.val_contabil_item 		=	p_nf_item.val_liq_item
	LET p_aviso_rec.qtd_declarad_nf 			=	p_nf_item.qtd_item
	LET p_aviso_rec.qtd_recebida 				  =	p_nf_item.qtd_item
	LET p_aviso_rec.qtd_devolvid 				  =	0
	LET p_aviso_rec.val_devoluc 				  = 0
	LET p_aviso_rec.num_nf_dev 					  =	0
	LET p_aviso_rec.qtd_rejeit 					  =	0
	LET p_aviso_rec.qtd_liber 					  =	p_nf_item.qtd_item
	LET p_aviso_rec.qtd_liber_excep 			=	0
	LET p_aviso_rec.cus_tot_item 				  =	0
	LET p_aviso_rec.num_lote 						  =	' '
	
  SELECT cod_operac_estoq_c
    INTO p_aviso_rec.cod_operac_estoq
    FROM par_sup
   WHERE cod_empresa = p_nf_item.cod_empresa

  IF STATUS <>  0 THEN
	   LET p_aviso_rec.cod_operac_estoq =	'0'
	END IF
	
	LET p_aviso_rec.val_base_c_item_d			=	p_nf_item.val_liq_item
	LET p_aviso_rec.val_base_c_item_c 		=	p_nf_item.val_liq_item
	LET p_aviso_rec.pct_icms_item_c 			= p_nf_item.pct_icms
	LET p_aviso_rec.val_icms_item_c 			=	p_nf_item.val_icms
	LET p_aviso_rec.val_base_c_icms_da 	  =	p_nf_item.val_base_icms
	LET p_aviso_rec.pct_icms_item_d 			= p_nf_item.pct_icms
	LET p_aviso_rec.val_icms_item_d 			=	p_nf_item.val_icms
	LET p_aviso_rec.pct_red_bc_item_d 	  =	0
	LET p_aviso_rec.pct_red_bc_item_c 		=	0
	LET p_aviso_rec.pct_diferen_item_d 		=	0
	LET p_aviso_rec.pct_diferen_item_c 		=	0
	LET p_aviso_rec.val_icms_diferen_i 		=	0
	LET p_aviso_rec.val_icms_desp_aces 		=	0
	LET p_aviso_rec.val_frete 						=	0
	LET p_aviso_rec.val_icms_frete_d 			=	0
	LET p_aviso_rec.val_icms_frete_c 			=	0
	LET p_aviso_rec.val_base_c_frete_d 		=	0
	LET p_aviso_rec.val_base_c_frete_c 		=	0
	LET p_aviso_rec.val_icms_diferen_f 		=	0
	LET p_aviso_rec.pct_icms_frete_d 			=	0
	LET p_aviso_rec.pct_icms_frete_c 			=	0
	LET p_aviso_rec.pct_red_bc_frete_d 		=	0
	LET p_aviso_rec.pct_red_bc_frete_c 		=	0
	LET p_aviso_rec.pct_diferen_fret_d 		=	0
	LET p_aviso_rec.pct_diferen_fret_c 		=	0
	LET p_aviso_rec.val_acrescimos 				=	0
	LET p_aviso_rec.val_enc_financ 				=	0
	LET p_aviso_rec.ies_contabil 					=	'S'
	LET p_aviso_rec.ies_total_nf 					=	'S'
	LET p_aviso_rec.val_compl_estoque 		=	0
	LET p_aviso_rec.pct_enc_financ 				=	0
	LET p_aviso_rec.cod_cla_fisc_nf 			=	p_aviso_rec.cod_cla_fisc
	
	INSERT INTO aviso_rec
	  VALUES (p_aviso_rec.*)

  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','aviso_rec')
     RETURN FALSE
  END IF

  INSERT INTO aviso_rec_compl_sq 
   VALUES(p_aviso_rec.cod_empresa,'',
          p_aviso_rec.num_aviso_rec,
          p_aviso_rec.num_seq,0,0,NULL,NULL)

  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','aviso_rec_compl_sq')
     RETURN FALSE
  END IF

	LET p_audit_ar.cod_empresa    = p_aviso_rec.cod_empresa
	LET p_audit_ar.num_aviso_rec  = p_aviso_rec.num_aviso_rec
	LET p_audit_ar.num_seq        = p_aviso_rec.num_seq
	LET p_audit_ar.nom_usuario    = p_user
	LET p_audit_ar.dat_hor_proces = CURRENT
	LET p_audit_ar.num_prog       = 'pol1136'
	LET p_audit_ar.ies_tipo_auditoria = '1'
	
	INSERT INTO audit_ar VALUES(p_audit_ar.*)
	
  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','audit_ar')
     RETURN FALSE
  END IF
	
	LET p_dest_ar.cod_empresa        = p_aviso_rec.cod_empresa
	LET p_dest_ar.num_aviso_rec      = p_aviso_rec.num_aviso_rec
	LET p_dest_ar.num_seq            = p_aviso_rec.num_seq
	LET p_dest_ar.sequencia          = 1                                
	LET p_dest_ar.cod_area_negocio   = p_aen.cod_lin_prod
	LET p_dest_ar.cod_lin_negocio    = p_aen.cod_lin_recei
	LET p_dest_ar.pct_particip_comp  = 100
	LET p_dest_ar.num_conta_deb_desp = p_num_conta
	LET p_dest_ar.cod_secao_receb    = 0          
	LET p_dest_ar.qtd_recebida       = p_nf_item.qtd_item
	LET p_dest_ar.ies_contagem       = 'S' 
	
	INSERT INTO dest_aviso_rec
	  VALUES (p_dest_ar.*)
	
  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','dest_aviso_rec')
     RETURN FALSE
  END IF

  IF p_nf_item.val_pis > 0 or p_nf_item.val_cofins > 0 THEN
     IF NOT pol1136_ins_pis_cof() THEN
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol1136_ins_pis_cof()
#-----------------------------#

   DEFINE p_sup_ar     RECORD LIKE sup_ar_piscofim.*,
          p_sup_par_ar RECORD LIKE sup_par_ar.*

   LET p_sup_ar.empresa            =  p_aviso_rec.cod_empresa
   LET p_sup_ar.aviso_recebto      =  p_aviso_rec.num_aviso_rec
   LET p_sup_ar.seq_aviso_recebto  =  p_aviso_rec.num_seq
   LET p_sup_ar.val_bc_pis_import  =  p_nf_item.val_pis
   LET p_sup_ar.val_bc_cofins_imp  =  p_nf_item.val_cofins
   LET p_sup_ar.pct_pis_import     =  p_nf_item.pct_pis
   LET p_sup_ar.pct_cofins_import  =  p_nf_item.pct_cofins
   LET p_sup_ar.pct_red_pis_import =  0
   LET p_sup_ar.pct_red_cofins_imp =  0
   LET p_sup_ar.val_pis_import     =  p_nf_item.val_pis
   LET p_sup_ar.val_cofins_import  =  p_nf_item.val_cofins

   INSERT INTO sup_ar_piscofim
    VALUES(p_sup_ar.*)

  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','sup_ar_piscofim')
     RETURN FALSE
  END IF

  INSERT INTO ar_pis_cofins
    VALUES(p_sup_ar.empresa,
           p_sup_ar.aviso_recebto,
           p_sup_ar.seq_aviso_recebto,
           p_sup_ar.val_bc_pis_import,
           p_sup_ar.val_bc_cofins_imp,
           p_sup_ar.pct_pis_import,
           p_sup_ar.pct_cofins_import,
           p_sup_ar.val_pis_import,
           p_sup_ar.val_cofins_import,'U')

  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','ar_pis_cofins')
     RETURN FALSE
  END IF

	LET p_sup_par_ar.empresa         		=  p_aviso_rec.cod_empresa  
	LET p_sup_par_ar.aviso_recebto      =  p_aviso_rec.num_aviso_rec
	LET p_sup_par_ar.seq_aviso_recebto	=  p_aviso_rec.num_seq  
	LET p_sup_par_ar.parametro				  =  'cod_cst_COFINS'  	
	LET p_sup_par_ar.par_ind_especial		=  'M'  
	LET p_sup_par_ar.parametro_val			=  50

  INSERT INTO sup_par_ar
	   VALUES(p_sup_par_ar.*)	   

  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','sup_par_ar:cofins')
     RETURN FALSE
  END IF

	LET p_sup_par_ar.parametro = 'cod_cst_PIS'  	

  INSERT INTO sup_par_ar
	   VALUES(p_sup_par_ar.*)	   

  IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','sup_par_ar:pis')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1136_ins_sup_dev()
#-----------------------------#
   
   DEFINE p_dev_cli           RECORD LIKE sup_nf_devol_cli.*,
          p_trans_nota_fiscal INTEGER,
          p_seq_item_nf       INTEGER,
          p_val_pis           DECIMAL(12,2),
          p_val_cofins        DECIMAL(12,2),
          p_dh_protocolo      CHAR(20)

   LET p_dev_cli.seq_nf_fatura = p_nf_item.seq_nf_dev                
   
   {IF p_nf_item.seq_nf_dev = 0 THEN
        
      DECLARE cq_seq_item CURSOR FOR
       SELECT seq_item_nf
         FROM fat_nf_item
        WHERE empresa = p_nf_mestre.cod_empresa
          AND trans_nota_fiscal = p_trans_nf
        
      FOREACH cq_seq_item INTO p_seq_item_nf
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_item:cq_seq_dev')
            RETURN FALSE
         END IF
           
         LET p_dev_cli.seq_nf_fatura = p_seq_item_nf                
         EXIT FOREACH
        
      END FOREACH
        
   END IF
   
   IF p_dev_cli.seq_nf_fatura = 0 OR p_dev_cli.seq_nf_fatura IS NULL
      OR p_dev_cli.seq_nf_fatura = ' ' THEN
      LET p_dev_cli.seq_nf_fatura = 1
   END IF}
   
   LET p_dev_cli.seq_nf_fatura = 1
   LET p_dev_cli.empresa = p_nf_mestre.cod_empresa             
   LET p_dev_cli.aviso_recebto = p_aviso_rec.num_aviso_rec                 
   LET p_dev_cli.seq_aviso_recebto = p_aviso_rec.num_seq
   LET p_dev_cli.nota_fiscal_fatura = p_nf_mestre.num_nf_dev
   LET p_dev_cli.ser_nf_fatura = p_nf_mestre.ser_nf_dev                
   LET p_dev_cli.ped_nf_fatura = 0                
   LET p_dev_cli.dat_lancto = TODAY							      
   LET p_dev_cli.motivo_devolucao = p_nf_item.motivo_dev               
   LET p_dev_cli.cliente = p_nf_mestre.cod_cliente               
   LET p_dev_cli.representante = 1                 
   LET p_dev_cli.item = p_nf_item.cod_item                        
   LET p_dev_cli.qtd_item = p_nf_item.qtd_item                     
   LET p_dev_cli.preco_unit_item = p_nf_item.pre_unit_liq               
   LET p_dev_cli.nf_integra_vdp = 'S'               
   LET p_dev_cli.trans_nota_fiscal_fatura = p_trans_nf    
   LET p_dev_cli.seq_item_nota_fiscal_fatura = p_dev_cli.seq_nf_fatura
   LET p_dev_cli.subserie_nota_fiscal_fatura = p_ssr_nf  
   LET p_dev_cli.dat_hr_emis_nota_fiscal_fatura = p_dat_hor

   INSERT INTO sup_nf_devol_cli
	   VALUES(p_dev_cli.*)	   

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','sup_nf_devol_cli')
      RETURN FALSE
   END IF
   
   LET p_val_pis = ((p_aviso_rec.val_contabil_item * 0.65) / 100)
   LET p_val_cofins = ((p_aviso_rec.val_contabil_item * 3) /100)
   
   INSERT INTO obf_dvcli_piscofin VALUES(
         p_aviso_rec.cod_empresa,
         p_aviso_rec.num_aviso_rec,
         p_aviso_rec.num_seq,
         p_dev_cli.nota_fiscal_fatura,
         p_dev_cli.ser_nf_fatura,
         p_dev_cli.ped_nf_fatura,
         p_dev_cli.seq_nf_fatura,
         p_dev_cli.ord_montag,
         p_aviso_rec.val_contabil_item,
         p_aviso_rec.val_contabil_item,
         0.65,
         3,
         p_val_pis,
         p_val_cofins,
         p_dev_cli.trans_nota_fiscal_fatura,
         p_dev_cli.seq_item_nota_fiscal_fatura,
         p_dev_cli.subserie_nota_fiscal_fatura,
         p_dev_cli.dat_hr_emis_nota_fiscal_fatura)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','obf_dvcli_piscofin')
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar VALUES(
       p_aviso_rec.cod_empresa,
       p_aviso_rec.num_aviso_rec,
       0,
       'chav_aces_nf_eletr',
       NULL,
       p_nf_mestre.chave_acesso,
       NULL,
       NULL)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_par_ar:chav_aces_nf_eletr')
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar VALUES(
       p_aviso_rec.cod_empresa,
       p_aviso_rec.num_aviso_rec,
       0,
       'protocolo_nf_eletr',
       NULL,
       p_nf_mestre.protocolo,
       NULL,
       NULL)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_par_ar:protocolo_nf_eletr')
      RETURN FALSE
   END IF

   LET p_dh_protocolo = p_nf_mestre.dat_protocolo
   LET p_dh_protocolo = p_dh_protocolo CLIPPED, ' ', p_nf_mestre.hor_protocolo

   INSERT INTO sup_par_ar VALUES(
       p_aviso_rec.cod_empresa,
       p_aviso_rec.num_aviso_rec,
       0,
       'dat_hr_prot_nf_eletr',
       NULL,
       p_dh_protocolo,
       NULL,
       NULL)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_par_ar:dat_hr_prot_nf_eletr')
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar VALUES(
       p_aviso_rec.cod_empresa,
       p_aviso_rec.num_aviso_rec,
       0,
       'data_hora_nf_entrada',
       NULL,
       p_dh_protocolo,
       NULL,
       NULL)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','sup_par_ar:dat_hr_prot_nf_eletr')
      RETURN FALSE
   END IF

  RETURN TRUE

END FUNCTION

#-------------------------------------------#
FUNCTION pol1136_ins_nf_eletronica(p_num_ar)#
#-------------------------------------------#

   DEFINE p_sup RECORD    LIKE sup_nf_eletronica.*,
          p_num_aleatorio INTEGER,
          p_num_txt       CHAR(09),
          p_dat_prot      CHAR(19),
          p_num_ar        INTEGER

   LET p_num_txt = p_nf_mestre.chave_acesso[36,44]
   LET p_dat_prot = p_nf_mestre.dat_protocolo
   LET p_dat_prot = p_dat_prot CLIPPED, ' ', p_nf_mestre.hor_protocolo
   
   IF p_num_txt IS NULL OR p_num_txt = ' ' THEN
      LET p_num_aleatorio = 0
   ELSE
      LET p_num_aleatorio = p_num_txt        
   END IF
   
   LET p_sup.empresa            = p_nf_mestre.cod_empresa   #not null
   LET p_sup.nota_fiscal        = p_nf_mestre.num_nf        #not null
   LET p_sup.serie_nota_fiscal  = p_nf_mestre.ser_nf        #not null
   LET p_sup.nf_eletronica      = p_nf_mestre.num_nf        #not null
   LET p_sup.chave_acesso       = p_nf_mestre.chave_acesso  #not null
   LET p_sup.forma_emissao      = '1'                       #not null
   LET p_sup.num_aleatorio      = p_num_aleatorio           #not null
   LET p_sup.tip_nota_fiscal    = 'FATPRDSV'                #not null
   LET p_sup.aviso_recebto      = p_num_ar                  #null
   LET p_sup.sit_nota_fiscal    = p_nf_mestre.ies_situa_nf  #not null
   LET p_sup.protocolo          = p_nf_mestre.protocolo     #null
   LET p_sup.protoc_nf_servico  = ''                        #null
   LET p_sup.arq_nf_el          = ''                        #null
   LET p_sup.trans_nota_fiscal  = p_trans_nf                #not null
   LET p_sup.subser_nota_fiscal = p_ssr_nf                  #not null
   LET p_sup.dat_hr_rec_protoc  = p_dat_prot
   LET p_sup.registro_dpec      = ' '
   
   INSERT INTO sup_nf_eletronica VALUES (p_sup.*)                                                                                                                                                                                             
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','sup_nf_eletronica')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------FIM DO PROGRAMA - BL---------------#
{ALTERA��ES:
27/08/2012 - Se telefone do fornecedor estiver nulo, gravar 1111111.
31/10/2012 - Se a nota que deu origem � devolu��o n�o estiver no fat_nf_mestre,
             verificar sua exist�ncia na tabela nf_mestre_509.
14/08/2013 V44 - corre��o de erro na grava��o da cidade do cliente/fornecedor             