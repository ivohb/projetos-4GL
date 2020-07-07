DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_docum              RECORD LIKE docum.*,
          p_msg                CHAR(70),
          p_salto              SMALLINT,
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_ind                SMALLINT,
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
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_chave              CHAR(400),
          p_query              CHAR(600)


   DEFINE p_tela               RECORD
          cod_cliente          LIKE clientes.cod_cliente,
          nom_cliente          LIKE clientes.nom_cliente,
          dat_ini              DATE,
          dat_fim              DATE
   END RECORD 

   DEFINE pr_doc                ARRAY[1000] OF RECORD
          nom_cli              CHAR(26),
          num_docum            LIKE docum.num_docum,
          dat_vencto           DATE,
          val_saldo            LIKE docum.val_saldo,
          baixar               CHAR(01)       
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1058-05.10.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1058.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol1058_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol1058_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1058") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1058 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Iforma os parâmetros p/ a consulta "
         CALL pol1058_informar() RETURNING p_status
         IF p_status THEN
            CALL pol1058_exibir()
            NEXT OPTION 'Baixar'
         ELSE
            ERROR "Operação Cancelada !!!"
         END IF
      COMMAND "Baixar" "Baixa duplicatas marcadas "
         IF p_ies_cons THEN
            IF pol1058_marca_dupl() THEN 
               CALL pol1058_Proc_bx() RETURNING p_status
               IF p_status THEN
                  ERROR 'Baixa efetuada com sucesso !!!'
                  LET p_ies_cons = FALSE
               ELSE
                  ERROR 'Operação cancelada !!!'
               END IF
            END IF          
         ELSE
            ERROR 'Informe os parâmetros previamente!'
         END IF
         NEXT OPTION 'Informar'
         
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1058

END FUNCTION

#--------------------------#
FUNCTION pol1058_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD cod_cliente

         IF p_tela.cod_cliente IS NOT NULL THEN
            IF NOT pol1058_le_cliente() THEN
               ERROR p_msg
               NEXT FIELD cod_cliente
            END IF
         END IF
      
         DISPLAY p_tela.nom_cliente TO nom_cliente

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_tela.dat_fim IS NOT NULL THEN
               IF p_tela.dat_ini IS NOT NULL THEN
                  IF p_tela.dat_ini > p_tela.dat_fim THEN
                     ERROR "Data Inicial nao pode ser maior que data Final"
                     NEXT FIELD dat_ini
                  END IF
               END IF 
            END IF
         END IF
            
      ON KEY (control-z)
         CALL pol1058_popup()

   END INPUT

   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

   LET p_ies_cons = TRUE
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1058_le_cliente()
#-------------------------------#

   SELECT nom_cliente
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente

   IF STATUS <> 0 THEN
      LET p_msg = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1058_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1058
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF

   END CASE
   
END FUNCTION

#------------------------#
FUNCTION pol1058_exibir()
#------------------------#

   LET p_chave = " a.cod_empresa = '", p_cod_empresa,"' "
   
   IF p_tela.cod_cliente IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND a.cod_cliente = '",p_tela.cod_cliente,"' "
   END IF
 
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND a.dat_vencto_s_desc >= '",p_tela.dat_ini,"' "
   END IF

   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND a.dat_vencto_s_desc <= '",p_tela.dat_fim,"' "
   END IF

   LET p_chave = p_chave CLIPPED, 
        " AND a.cod_cliente = b.cod_cliente AND a.val_saldo > 0 AND a.ies_situa_docum = 'N' and a.ies_pgto_docum <> 'T' "

   LET p_query =
    "SELECT b.nom_cliente, a.num_docum, a.dat_vencto_s_desc, ",
    "       a.val_saldo ",
    "  FROM docum a, clientes b  WHERE ",p_chave CLIPPED,
    " ORDER BY b.nom_cliente,a.dat_vencto_s_desc "


   INITIALIZE pr_doc TO NULL
   
   LET p_index = 1

   PREPARE var_query FROM p_query 
   DECLARE cq_nf CURSOR FOR var_query
   
   FOREACH cq_nf INTO 
           pr_doc[p_index].nom_cli,
           pr_doc[p_index].num_docum,
           pr_doc[p_index].dat_vencto,
           pr_doc[p_index].val_saldo
   
      LET p_index = p_index + 1
              
   END FOREACH

   CALL SET_COUNT(p_index - 1)
      
   DISPLAY ARRAY pr_doc TO sr_doc.*
   
      LET p_ind   = p_index
      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE()
    
END FUNCTION

#-----------------------------#
 FUNCTION pol1058_marca_dupl()
#-----------------------------#

   CALL SET_COUNT(p_ind)
   
   INPUT ARRAY pr_doc
      WITHOUT DEFAULTS FROM sr_doc.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
    
      AFTER FIELD baixar      
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_doc[p_index+1].nom_cli IS NULL THEN
               NEXT FIELD baixar 
            END IF
         END IF
         
   END INPUT
   
  RETURN TRUE   
   
END FUNCTION


#-----------------------------#
 FUNCTION pol1058_proc_bx()
#-----------------------------#

  LET p_ind = 1 

  CALL log085_transacao("BEGIN")
  
  FOR p_ind =1 TO 1000
      IF pr_doc[p_ind].nom_cli IS NULL THEN
         EXIT FOR
      END IF    

      IF pr_doc[p_ind].baixar = 'S'  THEN
         IF pol1058_efetiva_baixa() THEN 
         ELSE
            RETURN FALSE
         END IF    
      END IF 

  END FOR

  CALL log085_transacao("COMMIT")   
  
  RETURN TRUE 
   
END FUNCTION

#-------------------------------#
 FUNCTION pol1058_efetiva_baixa()
#-------------------------------#
  DEFINE  t_num_seq   INTEGER
  
  SELECT * 
    INTO p_docum.*
    FROM docum 
   WHERE cod_empresa = p_cod_empresa 
     AND num_docum   = pr_doc[p_ind].num_docum  

  UPDATE docum 
     SET val_saldo = 0,ies_pgto_docum = 'T',
         cod_portador=900,ies_tip_portador='C'  
   WHERE cod_empresa = p_cod_empresa 
     AND num_docum   = pr_doc[p_ind].num_docum  
     
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('UPDATE', 'DOCUM')
     CALL log085_transacao("ROLLBACK")
     RETURN FALSE
  END IF 

  LET t_num_seq = 0

  SELECT MAX(num_seq_docum)
    INTO t_num_seq
    FROM docum_pgto
   WHERE cod_empresa = p_cod_empresa 
     AND num_docum   = p_docum.num_docum  
    
  IF t_num_seq IS NULL THEN 
     LET t_num_seq = 1
  ELSE
     LET t_num_seq = t_num_seq + 1
  END IF    

  INSERT INTO docum_pgto VALUES (p_cod_empresa, 
                                 p_docum.num_docum,
                                 p_docum.ies_tip_docum,
                                 t_num_seq,
                                 TODAY,
                                 TODAY,
                                 TODAY, 
                                 p_docum.val_saldo,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 0,
                                 'N',
                                 'BC',
                                 900,
                                 'C',
                                 0,
                                 0,
                                 TODAY)
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('INSERT', 'DOCUM_PGTO')
     CALL log085_transacao("ROLLBACK")
     RETURN FALSE
  ELSE
     RETURN TRUE   
  END IF 

END FUNCTION