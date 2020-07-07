#-------------------------------------------------------------------#
# PROGRAMA: pol0729                                                 #
# OBJETIVO: DEVOLUÇAO DE CLIENTES                                   #
# CLIENTE.: CIBRAPEL                                                #
# DATA....: 27/01/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         P_comprime           CHAR(01),
         p_descomprime        CHAR(01),
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(75),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_cons           SMALLINT

  
   DEFINE p_cod_item          LIKE item.cod_item,
          p_nf_dev            LIKE nf_sup.num_nf,
          p_nf_orig           LIKE nf_sup.num_nf,
          p_num_aviso_rec     LIKE nf_sup.num_aviso_rec,
          p_num_pedido        LIKE pedidos.num_pedido,
          p_pct_desc_valor    LIKE desc_nat_oper_885.pct_desc_valor,
          p_pct_desc_qtd      LIKE desc_nat_oper_885.pct_desc_qtd,
          p_pct_desc_oper     LIKE desc_nat_oper_885.pct_desc_oper,
          p_efetivo           CHAR(01),
          p_pct_desc          DECIMAL(2,0),
          p_tip_desc          CHAR(01),
          p_qtd_lanc          DECIMAL(9,2),
          p_val_lanc          DECIMAL(9,2),
          p_pct_lanc          DECIMAL(5,2),
          p_qtd_dev           DECIMAL(9,2),
          p_val_dev           DECIMAL(9,2)

   DEFINE p_tela         RECORD
          cod_cliente    LIKE clientes.cod_cliente,
          nom_cliente    LIKE clientes.nom_cliente,
          dat_ini        LIKE nf_sup.dat_emis_nf,
          dat_fim        LIKE nf_sup.dat_emis_nf
          #exib_efetiv    CHAR(01)
   END RECORD 

   DEFINE pr_notas       ARRAY[1000] OF RECORD
          nf_dev         DECIMAL(6,0),
          cod_item       CHAR(15),
          qtd_dev        DECIMAL(9,2),
          val_dev        DECIMAL(9,2),
          nf_orig        DECIMAL(5,0),
          pct_desc       DECIMAL(2,0),
          tip_desc       CHAR(01),
          qtd_lanc       DECIMAL(9,2),
          val_lanc       DECIMAL(9,2),
          efetivar       CHAR(01)
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol0729-05.10.00"
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("VDP","LIC_LIB")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0729_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0729_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0729") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0729 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL pol0729_limpa_tela()
   
   MENU "OPCAO"
    COMMAND "Informar" "Informa parâmetros p/ a pesquisa"
       CALL pol0729_informar() RETURNING p_ies_cons
       IF p_ies_cons THEN      
          ERROR 'Parâmetros infomados com sucesso !!!'
          NEXT OPTION 'Consultar'
       ELSE
          CALL pol0729_limpa_tela()
          ERROR 'Operação cancelada !!!'
       END IF
    COMMAND "Efetivar" "Efetiva notas de devolução"
       IF p_ies_cons THEN
          IF log004_confirm(18,35) THEN
             MESSAGE 'AGUARDE!... PROCESSANDO.'
             CALL pol0729_efetivar() RETURNING p_status
             IF p_status THEN      
                ERROR 'Processamento efetuado com sucesso !!!'
             ELSE 
                ERROR 'Operação cancelada !!!'
             END IF
             LET p_ies_cons = FALSE
             CALL pol0729_limpa_tela()
             NEXT OPTION 'Fim'
          END IF
       ELSE
          ERROR 'Informe previamente os parâmetros!!!'
          NEXT OPTION 'Informar'
       END IF
      COMMAND "Listar" "Lista os Dados Cadastrados"
       IF NOT p_ies_cons THEN
           ERROR 'Informe previamente os parâmetros!!!'
           NEXT OPTION 'Informar'
       ELSE     
         IF log005_seguranca(p_user,"VDP","pol0729","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               CALL pol0729_emite_relatorio()   
            END IF                                                     
         END IF 
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET INT_FLAG = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0729

END FUNCTION

#----------------------------#
FUNCTION pol0729_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol0729_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CALL pol0729_limpa_tela()
   LET INT_FLAG = FALSE

   #LET p_tela.exib_efetiv = 'N'
    
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
         IF p_tela.dat_ini IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD dat_ini       
         END IF 

         AFTER FIELD dat_fim   
         IF p_tela.dat_fim IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD dat_fim
         ELSE
            IF p_tela.dat_ini > p_tela.dat_fim THEN
               ERROR "Data Inicial nao pode ser maior que data Final"
               NEXT FIELD dat_ini
            END IF 
            IF p_tela.dat_fim - p_tela.dat_ini > 720 THEN 
               ERROR "Periodo nao pode ser maior que 720 Dias"
               NEXT FIELD dat_ini
            END IF 
         END IF 
      
      AFTER FIELD cod_cliente
         IF p_tela.cod_cliente IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD cod_cliente       
         END IF 
       
         SELECT nom_cliente
           INTO p_tela.nom_cliente
           FROM clientes
          WHERE cod_cliente = p_tela.cod_cliente

         IF STATUS <> 0 THEN
            ERROR 'cliente Inexistente !!!'
            NEXT FIELD cod_cliente
         END IF
      
         DISPLAY p_tela.nom_cliente TO nom_cliente

      ON KEY (control-z)
         CALL pol0729_popup()

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT pol0729_carrega_dados() THEN
      RETURN FALSE
   END IF

   SELECT COUNT(nf_dev)
     INTO p_count
     FROM notas_tmp_885
   
   IF p_count = 0 THEN
      LET p_msg = 'Não há dados a serem exibidos p/ os parâmetros informados'
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN FALSE
   END IF

   CALL pol0729_exibe_dados()
   
   INPUT ARRAY pr_notas 
         WITHOUT DEFAULTS FROM sr_notas.*

      BEFORE INPUT
         AFTER INPUT
                
   END INPUT 
   
   RETURN TRUE
   
END FUNCTION


#-----------------------#
FUNCTION pol0729_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0508
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF
   END CASE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0729_carrega_dados()
#-------------------------------#

   IF NOT pol0729_cria_tmp() THEN
      RETURN FALSE
   END IF

   DECLARE cq_dev CURSOR FOR 
    SELECT num_nff,
           num_nff_origem
      FROM dev_mestre
     WHERE cod_empresa = p_cod_empresa
       AND cod_cliente = p_tela.cod_cliente
       AND dat_lancamento BETWEEN p_tela.dat_ini AND p_tela.dat_fim
     ORDER BY dat_lancamento

   FOREACH cq_dev INTO 
           p_nf_dev,
           p_nf_orig

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","dev_mestre:cq_dev")       
         RETURN FALSE
      END IF

      IF NOT pol0729_le_nfs_efetivas() THEN
         RETURN FALSE
      END IF

      IF p_efetivo = 'S' THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol0729_le_itens() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0729_le_nfs_efetivas()
#--------------------------------#

   SELECT cod_empresa
     FROM nf_efetivas_885
    WHERE cod_empresa = p_cod_empresa
      AND nf_dev      = p_nf_dev
      AND nf_orig     = p_nf_orig

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql("LEITURA","nf_efetivas_885")       
      RETURN FALSE
   END IF

   IF STATUS = 0 THEN
      LET p_efetivo = 'S'
   ELSE
      LET p_efetivo = 'N'
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol0729_cria_tmp()
#--------------------------#

   DROP TABLE notas_tmp_885

   IF STATUS = 0 OR STATUS -206 THEN 
 
      CREATE TEMP TABLE notas_tmp_885(
          nf_dev         DECIMAL(6,0),
          cod_item       CHAR(15),
          qtd_dev        DECIMAL(9,2),
          val_dev        DECIMAL(9,2),
          nf_orig        DECIMAL(5,0),
          pct_desc       DECIMAL(2,0),
          tip_desc       CHAR(01),
          qtd_lanc       DECIMAL(9,2),
          val_lanc       DECIMAL(9,2),
          efetivar       CHAR(01)
       );
         
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","notas_tmp_885")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0729_le_itens()
#-------------------------#

   IF NOT pol0729_le_nf_sup() THEN
      RETURN FALSE
   END IF

   DECLARE cq_ar CURSOR FOR
    SELECT cod_item,
           qtd_recebida,
           val_liquido_item
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_aviso_rec
   
   FOREACH cq_ar INTO 
           p_cod_item,
           p_qtd_dev,
           p_val_dev

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aviso_rec:cq_ar')
         RETURN FALSE
      END IF     

      IF NOT pol0729_le_nf_item() THEN
         RETURN FALSE
      END IF

      IF NOT pol0729_le_desc() THEN
         RETURN FALSE
      END IF
            
      INSERT INTO notas_tmp_885 VALUES(
          p_nf_dev,
          p_cod_item,
          p_qtd_dev,
          p_val_dev,
          p_nf_orig,
          p_pct_desc,
          p_tip_desc,
          p_qtd_lanc,
          p_val_lanc,
          p_efetivo)
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','notas_tmp_885')
         RETURN FALSE
      END IF     
      
   END FOREACH      

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0729_le_nf_sup()
#---------------------------#
   
   SELECT num_aviso_rec
     INTO p_num_aviso_rec
     FROM nf_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_nf      = p_nf_dev

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','nf_sup')
      RETURN FALSE
   END IF     

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0729_le_nf_item()
#----------------------------#

   SELECT num_pedido
     INTO p_num_pedido
     FROM nf_item
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_nf_orig
      AND cod_item    = p_cod_item
      
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","nf_mestre")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0729_le_desc()
#-------------------------#

   SELECT pct_desc_valor,
          pct_desc_qtd,
          pct_desc_oper
     INTO p_pct_desc_valor,
          p_pct_desc_qtd,
          p_pct_desc_oper
     FROM desc_nat_oper_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido
      
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","desc_nat_oper_885")
      RETURN FALSE
   END IF

   IF p_pct_desc_valor > 0 THEN
      LET p_pct_desc = p_pct_desc_valor
      LET p_tip_desc = 'V'
      LET p_qtd_lanc = p_qtd_dev
      LET p_pct_lanc = 100 - p_pct_desc
      LET p_val_lanc = p_val_dev * p_pct_desc / p_pct_lanc
   ELSE
      IF p_pct_desc_qtd > 0 THEN
         LET p_pct_desc = p_pct_desc_qtd
         LET p_tip_desc = 'Q'
         LET p_qtd_lanc = p_qtd_dev * ((100 - p_pct_desc) / 100)
         LET p_val_lanc = p_val_dev
      ELSE
         LET p_pct_desc = 0
         LET p_tip_desc = 'N'   
         LET p_qtd_lanc = p_qtd_dev
         LET p_val_lanc = p_val_dev
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0729_exibe_dados()
#----------------------------#

   INITIALIZE pr_notas TO NULL

   LET p_index = 1

   DECLARE cq_tmp CURSOR FOR
    SELECT *
      FROM notas_tmp_885

   FOREACH cq_tmp INTO
           pr_notas[p_index].nf_dev,
           pr_notas[p_index].cod_item,
           pr_notas[p_index].qtd_dev,
           pr_notas[p_index].val_dev,
           pr_notas[p_index].nf_orig,
           pr_notas[p_index].pct_desc,
           pr_notas[p_index].tip_desc,
           pr_notas[p_index].qtd_lanc,
           pr_notas[p_index].val_lanc,
           pr_notas[p_index].efetivar

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("Lendo","notas_tmp_885:cq_tmp")
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1

      IF p_index > 1000 THEN
         LET p_msg = 'Limite de Linhas da Grade Ultrapassados'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF

   END FOREACH

END FUNCTION

#-------------------------#
FUNCTION pol0729_efetivar()
#-------------------------#

   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_notas 
         WITHOUT DEFAULTS FROM sr_notas.*

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
                         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT pol0729_efetiva_nf() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0729_efetiva_nf()
#----------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_notas[p_ind].nf_dev IS NOT NULL THEN
          IF pr_notas[p_ind].efetivar = 'S' THEN
             IF NOT pol0729_insere_nf() THEN
                RETURN FALSE
             END IF
          END IF
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0729_insere_nf()
#----------------------------#

   INSERT INTO nf_efetivas_885 
      VALUES(p_cod_empresa, 
             pr_notas[p_ind].nf_dev, 
             pr_notas[p_ind].nf_orig)
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','nf_efetivas_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#---------------------------------#
FUNCTION pol0729_emite_relatorio()
#---------------------------------#


   ERROR "Aguarde!.. Processando a Extracao do Relatorio..." 
   IF p_ies_impressao = "S" THEN
      CALL log150_procura_caminho ('LST') RETURNING p_caminho
      LET p_caminho = p_caminho CLIPPED, 'pol0729.tmp'
      START REPORT pol0729_relat  TO p_caminho
   ELSE
      START REPORT pol0729_relat TO p_nom_arquivo
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_relat CURSOR FOR
    SELECT nf_dev,
           cod_item,
           qtd_dev,
           val_dev,
           nf_orig,
           pct_desc,
           tip_desc,
           qtd_lanc,
           val_lanc,
           efetivar
      FROM notas_tmp_885
   
   FOREACH cq_relat INTO
          p_nf_dev,
          p_cod_item,
          p_qtd_dev,
          p_val_dev,
          p_nf_orig,
          p_pct_desc,
          p_tip_desc,
          p_qtd_lanc,
          p_val_lanc,
          p_efetivo
   
      IF NOT pol0729_le_nfs_efetivas() THEN
         RETURN FALSE
      END IF
      
      OUTPUT TO REPORT pol0729_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0729_relat   

   IF p_ies_impressao = "S" THEN
      ERROR "Relatorio Impresso na Impressora ", p_nom_arquivo
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
         RUN comando
      END IF
   ELSE
      ERROR "Relatorio Gravado no Arquivo ", p_nom_arquivo
   END IF                              

END FUNCTION

#----------------------#
 REPORT pol0729_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 051, "LISTAGEM DA ESTRUTURA DE KITS",
               COLUMN 115, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "POL0729                     DEVOLUCAO DE CLIENTES",
               COLUMN 062, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "NF DEV  ITEM            QTD DEV   VAL DEV     NF SAID DESC QTD DESC  VAL DESC"
         PRINT COLUMN 001, "------- --------------- --------- ---------- ------- ---- --------- ----------"
      
      ON EVERY ROW

         PRINT COLUMN 001, p_nf_dev   USING '#######',
               COLUMN 009, p_cod_item,
               COLUMN 025, p_qtd_dev  USING '######.##',
               COLUMN 035, p_val_dev  USING '######.##',
               COLUMN 045, p_nf_orig  USING '#######',
               COLUMN 053, p_pct_desc USING '##',
               COLUMN 056, p_tip_desc,
               COLUMN 058, p_qtd_lanc USING '######.##',
               COLUMN 068, p_val_lanc USING '######.##',
               COLUMN 079, p_efetivo

      ON LAST ROW

         
         PRINT COLUMN 020, '* * * ULTIMA FOLHA * * *'
         
                        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#

