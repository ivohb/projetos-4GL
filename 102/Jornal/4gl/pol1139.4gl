#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# MÓDULO..: INTEGRAÇÃO LOGIX X OMC                                  #
# PROGRAMA: pol1139                                                 #
# OBJETIVO: CONSULTA E ACERTO DE NOTAS CRITICADAS                   #
# AUTOR...: IVO                                                     #
# DATA....: 22/03/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_critica_demis      INTEGER,
          p_mensagem           CHAR(60),
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
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_cpf                CHAR(14),
          p_cod_bco            DECIMAL(3,0),
          p_ano_mes_demis      CHAR(07)   

   DEFINE p_id_registro        INTEGER,
          p_id_registroa       INTEGER,
          p_excluiu            SMALLINT,
          p_nom_cliente        CHAR(30),
          p_rejeitou           SMALLINT,
          p_tip_docum          CHAR(10),
          p_den_item           CHAR(76)

   DEFINE pr_motivo           ARRAY[100] OF RECORD      
          num_seq             DECIMAL(2,0),
          motivo              CHAR(70)
   END RECORD
   
   DEFINE p_chave             RECORD
          cod_empresa         CHAR(02),
          cod_cliente         CHAR(15),
          num_nf              DECIMAL(6,0),
          ser_nf              CHAR(02)
   END RECORD
   
   DEFINE p_nf_item           RECORD LIKE nf_itens_509.*,
          p_nf_itema          RECORD LIKE nf_itens_509.*

   DEFINE p_tela      RECORD
      nom_arquivo     CHAR(30),
      cod_cliente     CHAR(14),
      num_nf          INTEGER,
      ser_nf          CHAR(02),
      tip_nf          CHAR(03)
   END RECORD
                
   DEFINE p_nf_mestre RECORD
      cod_empresa	    char(02),          
      tip_nf 	        Char(03),          
      num_nf	        decimal(6,0),    
      ser_nf	        Char(02),        
      cod_cliente	    Char(15),            
      dat_emissao	    DATETIME YEAR TO DAY,
      dat_vencto 	    DATETIME YEAR TO DAY,
      val_bruto_nf 	  decimal(17,2),     
      val_desc_incond	decimal(17,2),     
      val_liq_nf 	    decimal(17,2),     
      val_desc_cenp   decimal(17,2),    
      val_tot_nf 	    decimal(17,2),       
      val_duplicata	  decimal(17,2),     
      num_boleto	    Char(15),            
      ies_situa_nf	  char(1),           
      dat_cancel	    DATETIME YEAR TO DAY,
      txt_nf     	    Char(300),         
      tip_nf_dev	    Char(03),          
      num_nf_dev	    decimal(6,0),        
      ser_nf_dev      Char(02),         
      chave_acesso    char(44),
      protocolo       char(15),
      dat_protocolo   DATETIME YEAR TO DAY,
      hor_protocolo   char(08),
      cod_estatus     char(01),         
      nom_arquivo     char(30),         
      id_registro     integer           
   END RECORD

   DEFINE p_data         RECORD
          dat_emissao    DATE,
          dat_vencto     DATE, 	   
          dat_cancel     DATE, 	   
          dat_protocolo  DATE 	   
  END RECORD
             
END GLOBALS
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1139-10.02.07"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1139_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1139_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1139") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1139 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
     
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1139_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1139_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1139_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Nota" "Modifica dados da NF."
         IF p_ies_cons THEN
            CALL pol1139_nota() RETURNING p_status  
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Itens" "Modifica itens da NF."
         IF p_ies_cons THEN
            CALL pol1139_item() RETURNING p_status  
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui NF da tela"
         IF p_ies_cons THEN
            CALL pol1139_exclui() RETURNING p_status  
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1139_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1139

END FUNCTION


#-----------------------#
 FUNCTION pol1139_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1139_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION

#--------------------------#
FUNCTION pol1139_consulta()
#--------------------------#

   DEFINE sql_stmt CHAR(800)

   CALL pol1139_limpa_tela()
   LET p_id_registroa = p_id_registro
   LET INT_FLAG = FALSE

   INITIALIZE p_tela TO NULL
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

   AFTER FIELD nom_arquivo
      
      ON KEY (control-z)
         CALL pol1139_popup()
         
   END INPUT
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1139_limpa_tela()
         ELSE
            LET p_id_registro = p_id_registroa
            CALL pol1139_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE

   LET sql_stmt = "SELECT a.id_registro, a.nom_arquivo, ",
                  "       a.cod_empresa, a.cod_cliente, a.num_nf ",
                  "  FROM nf_mestre_509 a, rejeicao_nf_509 b ",
                  " WHERE a.cod_empresa = '",p_cod_empresa,"' ", 
                  "   AND a.cod_estatus = 'R' ",
                  "   AND a.cod_empresa = b.cod_empresa ",
                  "   AND a.id_registro = b.id_nf_mestre ",
                  "   AND a.nom_arquivo LIKE '","%",p_tela.nom_arquivo CLIPPED,"%","' ",
                  "   AND a.cod_cliente LIKE '","%",p_tela.cod_cliente CLIPPED,"%","' ",
                  "   AND a.tip_nf LIKE '","%",p_tela.tip_nf CLIPPED,"%","' ",
                  "   AND a.ser_nf LIKE '","%",p_tela.ser_nf CLIPPED,"%","' "

   IF p_tela.num_nf > 0  THEN
      LET sql_stmt = sql_stmt CLIPPED, "   AND num_nf = '",p_tela.num_nf,"' "
   END IF   

   LET sql_stmt = sql_stmt CLIPPED, " ORDER BY a.nom_arquivo, a.cod_empresa, a.cod_cliente, a.num_nf"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro, p_nom_arquivo

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1139_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1139_exibe_dados()
#------------------------------#
   
   SELECT *
     INTO p_nf_mestre.*
     FROM nf_mestre_509
    WHERE id_registro = p_id_registro
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "nf_mestre_509")
      RETURN FALSE
   END IF
   
   LET p_chave.cod_empresa = p_nf_mestre.cod_empresa
   LET p_chave.cod_cliente = p_nf_mestre.cod_cliente
   LET p_chave.num_nf = p_nf_mestre.num_nf
   LET p_chave.ser_nf = p_nf_mestre.ser_nf
   
   DISPLAY BY NAME 
      p_nf_mestre.nom_arquivo,
      p_nf_mestre.cod_cliente,
      p_nf_mestre.num_nf,
      p_nf_mestre.ser_nf,
      p_nf_mestre.tip_nf,
      p_nf_mestre.dat_emissao
                        
   CALL pol1039_le_empresa()
   CALL pol1039_le_cliente()

   DISPLAY p_nom_cliente TO nom_cliente
            
   CALL pol1139_le_motivo()

   IF p_ind > 10 THEN
      DISPLAY ARRAY pr_motivo TO sr_motivo.*
   ELSE
      INPUT ARRAY pr_motivo WITHOUT DEFAULTS FROM sr_motivo.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1039_le_cliente()
#----------------------------#

 IF p_nf_mestre.tip_nf = 'NF' OR p_nf_mestre.tip_nf = 'NFS' THEN

   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_nf_mestre.cod_cliente

 ELSE

   SELECT raz_social
     INTO p_nom_cliente
     FROM fornecedor
    WHERE cod_fornecedor = p_nf_mestre.cod_cliente
 
 END IF
    
 IF STATUS <> 0 THEN 
    LET p_nom_cliente = NULL
 END IF

END FUNCTION

#----------------------------#
FUNCTION pol1039_le_empresa()
#----------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_nf_mestre.cod_empresa
        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','empresa')
      LET p_den_empresa = NULL
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1139_le_motivo()
#--------------------------#

   INITIALIZE pr_motivo to null
   LET p_ind = 1
   
   DECLARE cq_mot CURSOR FOR
    SELECT num_seq,
           motivo
      FROM rejeicao_nf_509
     WHERE id_nf_mestre = p_id_registro

   FOREACH cq_mot INTO pr_motivo[p_ind].num_seq, pr_motivo[p_ind].motivo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_MOT')       
         RETURN
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 100 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   CALL SET_COUNT(p_ind - 1)
   
END FUNCTION
   
   

#-----------------------------------#
 FUNCTION pol1139_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_id_registroa = p_id_registro
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_id_registro
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_id_registro
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_empresa
           FROM nf_mestre_509
          WHERE id_registro = p_id_registro
            
         IF STATUS = 0 THEN
            CALL pol1139_exibe_dados() RETURNING p_status
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

#----------------------------------#
 FUNCTION pol1139_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT num_nf 
      FROM nf_mestre_509  
     WHERE id_registro = p_id_registro
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

#------------------------#
FUNCTION pol1139_exclui()
#------------------------#

   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      LET p_msg = "Não há dados na tela a serem excluidos !!!" 
      CALL log0030_mensagem(p_msg, "exclamation")
      RETURN p_retorno
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   IF pol1139_prende_registro() THEN
         
      DELETE FROM rejeicao_nf_509
       WHERE id_nf_mestre = p_id_registro
         AND num_seq = 0

      DELETE FROM nf_itens_509
       WHERE cod_empresa = p_chave.cod_empresa
         AND cod_cliente = p_chave.cod_cliente
         AND num_nf      = p_chave.num_nf
         AND ser_nf      = p_chave.ser_nf

      IF STATUS <> 0 THEN
         CALL log003_err_sql("DELETANDO", "NF_ITENS_509")
      ELSE
         DELETE FROM nf_mestre_509
          WHERE id_registro = p_id_registro
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE", "nf_mestre_509")
         ELSE
            LET p_retorno = TRUE
            LET p_excluiu = TRUE
         END IF
      END IF
               
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      CALL pol1139_limpa_tela()
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#----------------------#
FUNCTION pol1139_nota()
#----------------------#

   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      LET p_msg = "Não há dados á serem modificados !!!" 
      CALL log0030_mensagem(p_msg, "exclamation")
      RETURN p_retorno
   END IF
   
   IF pol1139_prende_registro() THEN
      IF pol1139_edita_nota() THEN
         
         DELETE FROM rejeicao_nf_509
          WHERE id_nf_mestre = p_id_registro
            AND num_seq = 0

         UPDATE nf_itens_509
            SET cod_empresa = p_nf_mestre.cod_empresa,
                cod_cliente = p_nf_mestre.cod_cliente,
                num_nf      = p_nf_mestre.num_nf,
                ser_nf      = p_nf_mestre.ser_nf
          WHERE cod_empresa = p_chave.cod_empresa
            AND cod_cliente = p_chave.cod_cliente
            AND num_nf      = p_chave.num_nf
            AND ser_nf      = p_chave.ser_nf

         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE", "nf_itens_509")
         ELSE
            UPDATE nf_mestre_509
               SET nf_mestre_509.* = p_nf_mestre.*
             WHERE id_registro = p_id_registro
       
            IF STATUS <> 0 THEN
               CALL log003_err_sql("UPDATE", "nf_mestre_509")
            ELSE
               IF pol1139_consiste_nota() THEN
                  LET p_retorno = TRUE
               END IF
            END IF
         END IF
               
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   CALL pol1139_exibe_dados()
   
   RETURN p_retorno

END FUNCTION

#---------------------------#
FUNCTION pol1139_edita_nota()
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11391") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11391 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_data.dat_emissao = p_nf_mestre.dat_emissao
   LET p_data.dat_vencto = p_nf_mestre.dat_vencto
   LET p_data.dat_cancel = p_nf_mestre.dat_cancel
   LET p_data.dat_protocolo = p_nf_mestre.dat_protocolo
   
   INPUT BY NAME 
      p_nf_mestre.cod_empresa,	   
      p_nf_mestre.tip_nf, 	       
      p_nf_mestre.num_nf,	       
      p_nf_mestre.ser_nf,	       
      p_nf_mestre.cod_cliente,	   
      p_data.dat_emissao,	   
      p_data.dat_vencto, 	   
      p_nf_mestre.val_bruto_nf, 	 
      p_nf_mestre.val_desc_incond,
      p_nf_mestre.val_liq_nf,	   
      p_nf_mestre.val_desc_cenp,  
      p_nf_mestre.val_tot_nf,	   
      p_nf_mestre.val_duplicata,	 
      p_nf_mestre.num_boleto,	   
      p_nf_mestre.ies_situa_nf,	 
      p_data.dat_cancel,	   
      p_nf_mestre.tip_nf_dev,	   
      p_nf_mestre.num_nf_dev,	   
      p_nf_mestre.ser_nf_dev, 
      p_nf_mestre.chave_acesso,
      p_nf_mestre.protocolo,   
      p_data.dat_protocolo,
      p_nf_mestre.hor_protocolo WITHOUT DEFAULTS
      
      BEFORE INPUT
         
         DISPLAY p_den_empresa TO den_empresa
         DISPLAY p_nom_cliente TO nom_cliente
         
      AFTER FIELD cod_empresa

         CALL pol1039_le_empresa()
         
         IF p_den_empresa IS NULL THEN
            NEXT FIELD cod_empresa
         END IF
   
         DISPLAY p_den_empresa TO den_empresa
         
      AFTER FIELD cod_cliente

         CALL pol1039_le_cliente()

         IF p_nom_cliente IS NULL THEN
            ERROR 'Cliente/fornecedor inexistente!'
            NEXT FIELD cod_cliente
         END IF

         DISPLAY p_nom_cliente TO nom_cliente

      BEFORE FIELD dat_cancel
         
         IF p_nf_mestre.ies_situa_nf <> 'C' THEN
            LET p_data.dat_cancel = NULL
            DISPLAY p_data.dat_cancel TO dat_cancel
            NEXT FIELD tip_nf_dev
         END IF

      BEFORE FIELD tip_nf_dev
         
         IF p_nf_mestre.tip_nf <> 'NFD' THEN
            LET p_nf_mestre.tip_nf_dev = NULL
            DISPLAY p_nf_mestre.tip_nf_dev TO tip_nf_dev
            NEXT FIELD num_nf_dev
         END IF

      BEFORE FIELD num_nf_dev
         
         IF p_nf_mestre.tip_nf <> 'NFD' THEN
            LET p_nf_mestre.num_nf_dev = NULL
            DISPLAY p_nf_mestre.num_nf_dev TO num_nf_dev
            NEXT FIELD ser_nf_dev
         END IF

      BEFORE FIELD ser_nf_dev
         
         IF p_nf_mestre.tip_nf <> 'NFD' THEN
            LET p_nf_mestre.ser_nf_dev = NULL
            DISPLAY p_nf_mestre.ser_nf_dev TO ser_nf_dev
            NEXT FIELD chave_acesso
         END IF

      BEFORE FIELD chave_acesso
         
         IF p_nf_mestre.tip_nf <> 'NF' AND p_nf_mestre.tip_nf <> 'NFD' THEN
            LET p_nf_mestre.chave_acesso = NULL
            DISPLAY p_nf_mestre.chave_acesso TO chave_acesso
            NEXT FIELD protocolo
         END IF

      BEFORE FIELD protocolo
         
         IF p_nf_mestre.tip_nf <> 'NF' AND p_nf_mestre.tip_nf <> 'NFD' THEN
            LET p_nf_mestre.protocolo = NULL
            DISPLAY p_nf_mestre.protocolo TO protocolo
            NEXT FIELD dat_protocolo
         END IF

      BEFORE FIELD dat_protocolo
         
         IF p_nf_mestre.tip_nf <> 'NF' AND p_nf_mestre.tip_nf <> 'NFD' THEN
            LET p_data.dat_protocolo = NULL
            DISPLAY p_data.dat_protocolo TO dat_protocolo
            NEXT FIELD hor_protocolo
         END IF

      BEFORE FIELD hor_protocolo
         
         IF p_nf_mestre.tip_nf <> 'NF' AND p_nf_mestre.tip_nf <> 'NFD' THEN
            LET p_nf_mestre.hor_protocolo = NULL
            DISPLAY p_nf_mestre.hor_protocolo TO hor_protocolo
            EXIT INPUT
         END IF

      AFTER INPUT
      
         IF NOT INT_FLAG THEN
            IF p_nf_mestre.cod_empresa IS NULL THEN
               ERROR 'Informe o código da empresa!'
               NEXT FIELD cod_empresa
            END IF
            IF p_nf_mestre.cod_cliente IS NULL THEN
               ERROR 'Informe o código do cliente!'
               NEXT FIELD cod_cliente
            END IF
            IF p_nf_mestre.num_nf IS NULL THEN
               ERROR 'Informe o número da NF!'
               NEXT FIELD num_nf
            END IF
            IF p_nf_mestre.ser_nf IS NULL THEN
               ERROR 'Informe a série da NF!'
               NEXT FIELD ser_nf
            END IF
         END IF
                        
      ON KEY (control-z)
         CALL pol1139_popup()

   END INPUT
   
   CLOSE WINDOW w_pol11391
   
	 IF INT_FLAG THEN
      RETURN FALSE
	 END IF

   LET  p_nf_mestre.dat_emissao = p_data.dat_emissao
   LET  p_nf_mestre.dat_vencto = p_data.dat_vencto
   LET  p_nf_mestre.dat_cancel = p_data.dat_cancel
   LET  p_nf_mestre.dat_protocolo = p_data.dat_protocolo
	 
	 RETURN TRUE
	 
END FUNCTION

#-----------------------#
FUNCTION pol1139_popup()
#-----------------------#

   DEFINE p_codigo CHAR(30)

   CASE

      WHEN INFIELD(cod_empresa)
         CALL log009_popup(8,25,"EMPRESAS","empresa",
                     "cod_empresa","den_empresa","","","1=1 order by den_empresa") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol11391
         IF p_codigo IS NOT NULL THEN
            LET p_nf_mestre.cod_empresa = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_empresa
         END IF

      WHEN INFIELD(grupo_item)
         CALL log009_popup(8,25,"GRUPOS","grupo_item_509",
                     "grupo_item","cod_item","","S","1=1 order by grupo_item") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol11392
         IF p_codigo IS NOT NULL THEN
            LET p_nf_item.grupo_item = p_codigo CLIPPED
            DISPLAY p_codigo TO grupo_item
         END IF

      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol11391
         IF p_codigo IS NOT NULL THEN
            LET p_nf_mestre.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol11392
         IF p_codigo IS NOT NULL THEN
           LET p_nf_item.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

      WHEN INFIELD(nom_arquivo)
         LET p_codigo = pol1139_sel_arquivo()
         CURRENT WINDOW IS w_pol11392
         IF p_codigo IS NOT NULL THEN
            LET p_tela.nom_arquivo = p_codigo
           DISPLAY p_codigo TO nom_arquivo
         END IF

   END CASE   

END FUNCTION

#------------------------------#
FUNCTION pol1139_sel_arquivo()
#------------------------------#

   DEFINE pr_arquivo      ARRAY[500] OF RECORD
          nom_arquivo     Char(28)
   END RECORD
   
   DEFINE p_ind INTEGER
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11393") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11393 AT 5,30 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_ind = 1
   
   DECLARE cq_arq CURSOR FOR
    SELECT DISTINCT a.nom_arquivo
      FROM nf_mestre_509 a,
           rejeicao_nf_509 b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_estatus = 'R'
       AND a.cod_empresa = b.cod_empresa
       AND a.nom_arquivo = b.nom_arquivo

   FOREACH cq_arq INTO pr_arquivo[p_ind].nom_arquivo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_mestre_509:cq_arq')
         EXIT FOREACH
      END IF
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassado!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Notas criticadas!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN ""
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_arquivo TO sr_arquivo.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol11393
   
   IF NOT INT_FLAG THEN
      RETURN pr_arquivo[p_ind].nom_arquivo
   ELSE
      RETURN ""
   END IF
   
END FUNCTION


#-------------------------------#
FUNCTION pol1139_consiste_nota()
#-------------------------------#

   LET p_nf_item.num_seq_nf = 0
         
   IF p_nf_mestre.cod_empresa IS NULL THEN
      LET p_msg = 'CODIGO DA EMPRESA ESTA NULO'
      CALL pol1139_grava_rejeicao()
   ELSE
      SELECT cod_empresa
        FROM empresa
       WHERE cod_empresa = p_nf_mestre.cod_empresa
      
      IF STATUS = 100 THEN
         LET p_msg = 'EMPRESA NAO CADASTRADA'
         CALL pol1139_grava_rejeicao()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','CONSISTINDO EMPRESA')
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_nf_mestre.tip_nf IS NULL THEN
      LET p_msg = 'TIPO DE NOTA ESTA NULO'
      CALL pol1139_grava_rejeicao()
   ELSE
      IF p_nf_mestre.tip_nf = 'NF'  OR
         p_nf_mestre.tip_nf = 'NFS' OR
         p_nf_mestre.tip_nf = 'NFE' OR
         p_nf_mestre.tip_nf = 'NFD' THEN
      ELSE
         LET p_msg = 'TIPO DE NOTA INVALIDO'
         CALL pol1139_grava_rejeicao()
      END IF
   END IF

   IF p_nf_mestre.num_nf IS NULL THEN
      LET p_msg = 'NUMERO DA NOTA ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.ser_nf IS NULL THEN
      LET p_msg = 'SERIE DA NOTA ESTA NULA'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.cod_cliente IS NULL THEN
      LET p_msg = 'CODIGO DO CLIENTE ESTA NULO'
      CALL pol1139_grava_rejeicao()
   ELSE
      SELECT cod_cliente
        FROM clientes
       WHERE cod_cliente = p_nf_mestre.cod_cliente
      
      IF STATUS = 100 THEN
         LET p_msg = 'CLIENTE NAO CADASTRADO'
         CALL pol1139_grava_rejeicao()
      ELSE   
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','CONSISTINDO CLIENTE')
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_nf_mestre.dat_emissao IS NULL THEN
      LET p_msg = 'DATA DA EMISSAO ESTA NULA'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.dat_vencto IS NULL THEN
      LET p_msg = 'DATA DE VENCIMENTO ESTA NULA'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_bruto_nf IS NULL THEN
      LET p_msg = 'VALOR BRUTO DA NF ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_desc_incond IS NULL THEN
      LET p_msg = 'VALOR DESCONTO INCONDICIONAL ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_liq_nf IS NULL THEN
      LET p_msg = 'VALOR LIQUIDO DA NF ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_desc_cenp IS NULL THEN
      LET p_msg = 'VALOR DESCONTO CENP ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_tot_nf IS NULL THEN
      LET p_msg = 'VALOR TOTAL DA NF ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.val_duplicata IS NULL THEN
      LET p_msg = 'VALOR REFERENCIA P/ DUPLICATA ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF

   IF p_nf_mestre.ies_situa_nf MATCHES '[NC]' THEN
      IF p_nf_mestre.ies_situa_nf = 'C' THEN
         IF p_nf_mestre.dat_cancel IS NULL THEN
            LET p_msg = 'DATA DO CANCELAMENTO ESTA NULA'
            CALL pol1139_grava_rejeicao()
         END IF
      END IF
   ELSE
      LET p_msg = 'COUNTEUDO DA SITUACAO DA NF INVALIDO'
      CALL pol1139_grava_rejeicao()
   END IF
   
   IF p_nf_mestre.tip_nf = 'NFD' THEN
      IF NOT pol1139_consist_nfd() THEN 
         RETURN FALSE
      END IF
   END IF

   IF p_nf_mestre.tip_nf = 'NF' THEN
      CALL pol1139_consist_protocolo()
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1139_consist_nfd()
#-----------------------------#

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
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_mestre.num_nf_dev IS NULL THEN
         LET p_msg = 'NUMERO DA NF ORIGEM DA DEVOLUCAO INVALIDO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_mestre.ser_nf_dev IS NULL THEN
         LET p_msg = 'SERIE DA NF ORIGEM DA DEVOLUCAO INVALIDO'
         CALL pol1139_grava_rejeicao()
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
            CALL log003_err_sql('SELECT','CONSISTINDO NUM. NF DEV')
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
               CALL pol1139_grava_rejeicao()
            END IF
         END IF
         
      END IF
      
      RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1139_consist_protocolo()
#-----------------------------------#

   IF p_nf_mestre.chave_acesso IS NULL THEN
      LET p_msg = 'CHAVE DE ACESSO ESTA NULA'
      CALL pol1139_grava_rejeicao()
   END IF
   IF p_nf_mestre.protocolo IS NULL THEN
      LET p_msg = 'PROTOCULO ESTA NULO'
      CALL pol1139_grava_rejeicao()
   END IF
   IF p_nf_mestre.dat_protocolo IS NULL THEN
      LET p_msg = 'DATA DO PROTOCOLO ESTA NULA'
      CALL pol1139_grava_rejeicao()
   END IF
   IF p_nf_mestre.hor_protocolo IS NULL THEN
      LET p_msg = 'HORA DO PROTOCOLO ESTA NULA'
      CALL pol1139_grava_rejeicao()
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol1139_consiste_itens()
#-------------------------------#

   DEFINE p_tem_itens SMALLINT
   
   LET p_tem_itens = FALSE
   
   DECLARE cq_ci CURSOR FOR
    SELECT *
      FROM nf_itens_509
     WHERE cod_empresa = p_nf_mestre.cod_empresa
       AND cod_cliente = p_nf_mestre.cod_cliente
       AND num_nf      = p_nf_mestre.num_nf
       AND ser_nf      = p_nf_mestre.ser_nf
       AND num_seq_nf  = p_nf_item.num_seq_nf
       
   FOREACH cq_ci INTO p_nf_item.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_CI')
         RETURN FALSE
      END IF
      
      LET p_tem_itens = TRUE
      LET p_rejeitou = FALSE

      IF p_nf_item.num_seq_nf IS NULL THEN
         LET p_msg = 'A SEQUENCIA DA NF ESTA NULA'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.grupo_item IS NULL THEN
         LET p_msg = 'GRUPO DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      ELSE
         SELECT grupo_item
           FROM grupo_item_509
          WHERE grupo_item = p_nf_item.grupo_item
         IF STATUS = 100 THEN
            LET p_msg = 'GRUPO DO PRODUTO NAO CADASRADO'
            CALL pol1139_grava_rejeicao()
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','CONSISTINDO GRUPO_ITEM')
               RETURN FALSE
            END IF
         END IF
      END IF
      
      IF p_nf_item.cod_item IS NULL THEN
         LET p_msg = 'CODIGO DO ITEM ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.qtd_item IS NULL THEN
         LET p_msg = 'QUANTIDADE DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.pre_unit_bruto IS NULL THEN
         LET p_msg = 'PRECO BRUTO DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.pre_unit_liq IS NULL THEN
         LET p_msg = 'PRECO LIQUIDO BRUTO DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_bruto_item IS NULL THEN
         LET p_msg = 'VALOR BRUTO DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_liq_item IS NULL THEN
         LET p_msg = 'VALOR LIQUIDO DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.cod_unidade IS NULL THEN
         LET p_msg = 'UNIDADE DO PRODUTO ESTA NULA'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.ctr_estoque IS NULL THEN
         LET p_msg = 'CONTROLE DE ESTOQUE ESTA NULO'
         CALL pol1139_grava_rejeicao()
      ELSE
         IF p_nf_item.ctr_estoque MATCHES '[SN]' THEN
         ELSE
            LET p_msg = 'CONTROLE DE ESTOQUE INVALIDO'
            CALL pol1139_grava_rejeicao()
         END IF
      END IF

      IF p_nf_item.pct_iss IS NULL THEN
         LET p_msg = '% DE ISS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_iss IS NULL THEN
         LET p_msg = 'VALOR BASE DE ISS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_iss IS NULL THEN
         LET p_msg = 'VALOR DO ISS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.pct_icms IS NULL THEN
         LET p_msg = '% DE ICMS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_icms IS NULL THEN
         LET p_msg = 'BASE DE ICMS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_icms IS NULL THEN
         LET p_msg = 'VALOR DO ICMS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.pct_irpj IS NULL THEN
         LET p_msg = '% DE IR DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_irpj IS NULL THEN
         LET p_msg = 'BASE DE IR DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_irpj IS NULL THEN
         LET p_msg = 'VALOR DO IR DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.pct_csll IS NULL THEN
         LET p_msg = '% DE CSLL DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_csll IS NULL THEN
         LET p_msg = 'BASE DE CSLL DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_csll IS NULL THEN
         LET p_msg = 'VALOR DO CSLL DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.pct_cofins IS NULL THEN
         LET p_msg = '% DE COFINS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_cofins IS NULL THEN
         LET p_msg = 'BASE DE COFINS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_cofins IS NULL THEN
         LET p_msg = 'VALOR DO COFINS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.pct_pis IS NULL THEN
         LET p_msg = '% DE PIS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_base_pis IS NULL THEN
         LET p_msg = 'BASE DE PIS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_item.val_pis IS NULL THEN
         LET p_msg = 'VALOR DO PIS DO PRODUTO ESTA NULO'
         CALL pol1139_grava_rejeicao()
      END IF

      IF p_nf_mestre.tip_nf = 'NFS' THEN
      ELSE
         IF p_nf_item.cod_fiscal IS NULL THEN
            LET p_msg = 'CODIGO FISCAL DO PRODUTO ESTA NULO'
            CALL pol1139_grava_rejeicao()
         ELSE
            SELECT den_cod_fiscal
              FROM codigo_fiscal
             WHERE cod_fiscal = p_nf_item.cod_fiscal
            IF STATUS = 100 THEN
               LET p_msg = 'CODIGO FISCAL INEXISTENTE NO LOGIX'
               CALL pol1139_grava_rejeicao()
            ELSE   
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('','CONSISTINDO CODIGO FISCAL')
                  RETURN FALSE
               END IF
            END IF
         END IF       
      END IF
      
   END FOREACH
   
   IF NOT p_tem_itens THEN
      LET p_msg = 'NF SEM OS ITENS CORRESPONDENTES'
      CALL pol1139_grava_rejeicao()
   END IF
   
   RETURN TRUE

END FUNCTION      

#-------------------------------#
FUNCTION pol1139_grava_rejeicao()
#-------------------------------#

   LET p_rejeitou = TRUE
   
   INSERT INTO rejeicao_nf_509
    VALUES(p_nf_mestre.cod_empresa,
           p_nf_mestre.nom_arquivo,
           p_nf_mestre.id_registro,
           p_nf_item.num_seq_nf,
           p_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','rejeicao_nf_509')
   END IF

END FUNCTION

#----------------------#
FUNCTION pol1139_item()
#----------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11392") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11392 AT 4,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol1139_le_itens() THEN
      CLOSE WINDOW w_pol11392
      RETURN FALSE
   END IF

   MENU "OPCAO"
      COMMAND "Seguinte" "Exibe o próximo item da NF."
         IF p_ies_cons THEN
            CALL pol1139_pag_item("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior da NF."
         IF p_ies_cons THEN
            CALL pol1139_pag_item("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados do item da NF."
         CALL pol1139_modif_item() RETURNING p_status  
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol11392

   CALL pol1139_le_motivo()

   INPUT ARRAY pr_motivo WITHOUT DEFAULTS FROM sr_motivo.*
      BEFORE INPUT
      EXIT INPUT
   END INPUT

END FUNCTION

#--------------------------#
FUNCTION pol1139_le_itens()
#--------------------------#

   DECLARE cq_item SCROLL CURSOR WITH HOLD FOR 
    SELECT * FROM nf_itens_509
     WHERE cod_empresa = p_nf_mestre.cod_empresa
       AND cod_cliente = p_nf_mestre.cod_cliente
       AND num_nf      = p_nf_mestre.num_nf
       AND ser_nf      = p_nf_mestre.ser_nf

   OPEN cq_item

   FETCH cq_item INTO p_nf_item.*

   IF STATUS <> 0 THEN
      CALL log003_err_sql('FETCH','CQ_ITEM')
      RETURN FALSE
   END IF

   CALL pol1139_exib_item()
   
   RETURN TRUE

END FUNCTION

#---------------------------#   
FUNCTION pol1139_exib_item()
#---------------------------#

   SELECT * 
     INTO p_nf_itema.*
     FROM nf_itens_509
    WHERE cod_empresa = p_nf_item.cod_empresa
      AND cod_cliente = p_nf_item.cod_cliente
      AND num_nf      = p_nf_item.num_nf
      AND ser_nf      = p_nf_item.ser_nf
      AND num_seq_nf  = p_nf_item.num_seq_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'nf_itens_509:exib_item')
   END IF
       
   LET p_nf_item.* = p_nf_itema.*

   INPUT BY NAME
      p_nf_item.cod_item,
      p_nf_item.den_item,
      p_nf_item.cod_fiscal,
      p_nf_item.qtd_item,
      p_nf_item.pre_unit_liq,
      p_nf_item.val_liq_item,
      p_nf_item.grupo_item,
      p_nf_item.cod_unidade,
      p_nf_item.ctr_estoque, 
      p_nf_item.pct_iss,
      p_nf_item.val_base_iss,	       
      p_nf_item.val_iss,             
      p_nf_item.pct_icms,
      p_nf_item.val_base_icms,       
      p_nf_item.val_icms,	           
      p_nf_item.pct_irpj,
      p_nf_item.val_base_irpj,	     
      p_nf_item.val_irpj,	           
      p_nf_item.pct_csll,
      p_nf_item.val_base_csll,
      p_nf_item.val_csll,	           
      p_nf_item.pct_cofins,
      p_nf_item.val_base_cofins,
      p_nf_item.val_cofins,	         
      p_nf_item.pct_pis,
      p_nf_item.val_base_pis,
      p_nf_item.val_pis WITHOUT DEFAULTS
   
   BEFORE INPUT
      EXIT INPUT
   END INPUT
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1139_pag_item(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_nf_itema.* = p_nf_item.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_item INTO p_nf_item.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_item INTO p_nf_item.*
      
      END CASE

      IF STATUS = 100 THEN
         ERROR "Não existem mais itens nesta direção !!!"
         LET p_nf_item.* = p_nf_itema.*
      ELSE
         IF STATUS = 0 THEN
            CALL pol1139_exib_item()
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
      END IF    

      EXIT WHILE

   END WHILE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1139_bloqueia_item()
#--------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_bloqueia CURSOR FOR
    SELECT num_nf 
      FROM nf_itens_509  
     WHERE cod_empresa = p_nf_mestre.cod_empresa
       AND cod_cliente = p_nf_mestre.cod_cliente
       AND num_nf      = p_nf_mestre.num_nf
       AND ser_nf      = p_nf_mestre.ser_nf
       FOR UPDATE 
    
    OPEN cq_bloqueia
   FETCH cq_bloqueia
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("FETCH","CQ_PRENDE")
      RETURN FALSE
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1139_modif_item()
#----------------------------#

   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      LET p_msg = "Não há dados á serem modificados !!!" 
      CALL log0030_mensagem(p_msg, "exclamation")
      RETURN p_retorno
   END IF
   
   IF pol1139_bloqueia_item() THEN
      
      IF pol1139_edita_item() THEN
         
         DELETE FROM rejeicao_nf_509
          WHERE id_nf_mestre = p_id_registro
            AND num_seq      = p_nf_item.num_seq_nf 

         UPDATE nf_itens_509
            SET nf_itens_509.* = p_nf_item.*
          WHERE cod_empresa = p_nf_item.cod_empresa
            AND cod_cliente = p_nf_item.cod_cliente
            AND num_nf      = p_nf_item.num_nf
            AND ser_nf      = p_nf_item.ser_nf
            AND num_seq_nf  = p_nf_item.num_seq_nf 

         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE", "nf_itens_509")
         ELSE
            IF pol1139_consiste_itens() THEN
               LET p_retorno = TRUE
            END IF
         END IF
               
      END IF
      
      CLOSE cq_bloqueia
      
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   CALL pol1139_exib_item()
   
   RETURN p_retorno

END FUNCTION


#----------------------------#
FUNCTION pol1139_edita_item()
#----------------------------#

   LET INT_FLAG = FALSE

   INPUT BY NAME
      p_nf_item.cod_item,
      p_nf_item.den_item,
      p_nf_item.cod_fiscal,
      p_nf_item.qtd_item,
      p_nf_item.pre_unit_liq,
      p_nf_item.val_liq_item,
      p_nf_item.grupo_item,
      p_nf_item.cod_unidade,
      p_nf_item.ctr_estoque, 
      p_nf_item.pct_iss,
      p_nf_item.val_base_iss,	       
      p_nf_item.val_iss,             
      p_nf_item.pct_icms,
      p_nf_item.val_base_icms,       
      p_nf_item.val_icms,	           
      p_nf_item.pct_irpj,
      p_nf_item.val_base_irpj,	     
      p_nf_item.val_irpj,	           
      p_nf_item.pct_csll,
      p_nf_item.val_base_csll,
      p_nf_item.val_csll,	           
      p_nf_item.pct_cofins,
      p_nf_item.val_base_cofins,
      p_nf_item.val_cofins,	         
      p_nf_item.pct_pis,
      p_nf_item.val_base_pis,
      p_nf_item.val_pis WITHOUT DEFAULTS
      
      AFTER FIELD cod_item

         IF p_nf_item.cod_item IS NOT NULL THEN
         
            SELECT den_item
              INTO p_den_item
              FROM item
             WHERE cod_empresa = p_nf_item.cod_empresa
               AND cod_item    = p_nf_item.cod_item
         
            IF STATUS = 0 THEN
               DISPLAY p_den_item to den_item
            END IF
         END IF
                             
      ON KEY (control-z)
         CALL pol1139_popup()

   END INPUT
   
	 IF INT_FLAG THEN
      RETURN FALSE
	 END IF
	 
	 RETURN TRUE
	 
END FUNCTION

#-----------------FIM DO PROGRAMA - BL---------------#
      