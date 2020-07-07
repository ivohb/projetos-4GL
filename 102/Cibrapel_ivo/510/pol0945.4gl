#-----------------------------------------#
# PROGRAMA: pol0945                       #
# OBJETIVO: CANCELAMENTO DE PEDIDO        #
#-----------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_empresas_885       RECORD LIKE empresas_885.*,
          p_nf_mestre          RECORD LIKE nf_mestre.*,
          p_nf_item            RECORD LIKE nf_item.*,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_emp_aux        LIKE empresa.cod_empresa,
          p_cod_emp_ord        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_num_docum          LIKE ordens.num_docum,
          p_pct_max_cliche     LIKE par_vdp_885.pct_max_cliche,
          p_val_cliche         LIKE nf_item.val_liq_item,
          p_ies_can_op         CHAR(1),
          p_num_ped_ch         CHAR(6),
          p_num_seq_ch         CHAR(4),
          p_ies_tem_it         CHAR(1),
          p_ies_cons           SMALLINT,
          p_last_row           SMALLINT,
          p_conta              SMALLINT,
          p_cont               SMALLINT,
          pa_curr              SMALLINT,
          sc_curr              SMALLINT,
          p_status             SMALLINT,
          p_funcao             CHAR(15),
          p_houve_erro         SMALLINT, 
          p_comando            CHAR(80),
          p_caminho            CHAR(80),
          p_help               CHAR(80),
          p_cancel             INTEGER,
          p_nom_tela           CHAR(80),
          p_mensag             CHAR(200),
          w_i                  SMALLINT,
          p_i                  SMALLINT, 
          p_den_item           LIKE item.den_item,
          p_data_ent           DATE,
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_msg                CHAR(100)

   DEFINE p_tela         RECORD
          cod_empresa    LIKE nf_mestre.cod_empresa,  
          cod_item       LIKE item.cod_item,  
          den_item       LIKE item.den_item,  
          val_cliche     LIKE nf_item.val_liq_item,     
          val_fat_tot    LIKE nf_item.val_liq_item
                     END RECORD 	

   DEFINE t_notas ARRAY[500] OF RECORD
      num_nff       LIKE nf_mestre.num_nff,
      dat_emissao   LIKE nf_mestre.dat_emissao,
      val_liq_item  LIKE nf_item.val_liq_item,
      val_a_fat    LIKE nf_item.val_liq_item
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

MAIN
   LET p_versao = "pol0945-10.02.00" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0945_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0945_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0945") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0945 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE p_empresas_885.* TO NULL

    SELECT * 
      INTO p_empresas_885.*		
      FROM empresas_885 
     WHERE cod_emp_oficial = p_cod_empresa
    IF SQLCA.sqlcode <> 0 THEN  
       SELECT * 
         INTO p_empresas_885.*		
         FROM empresas_885 
        WHERE cod_emp_gerencial = p_cod_empresa
       IF SQLCA.sqlcode = 0 THEN  
          LET p_cod_emp_aux = p_empresas_885.cod_emp_oficial 
       END IF 
    ELSE
       LET p_cod_emp_aux = p_empresas_885.cod_emp_gerencial 
    END IF 
        
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Cliche"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0945","CO") THEN 
            CALL pol0945_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0945_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0945

END FUNCTION

#--------------------------#
 FUNCTION pol0945_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0945

   LET p_tela.cod_item = NULL 
   IF pol0945_entrada_dados() THEN
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_tela.cod_item = NULL 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0945_entrada_dados()
#-------------------------------#
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0945

   LET INT_FLAG = FALSE  
   LET p_tela.cod_empresa = p_cod_empresa
   DISPLAY p_tela.cod_empresa TO cod_empresa
   
   INPUT p_tela.cod_item
    FROM cod_item

      AFTER FIELD cod_item
      
      IF p_tela.cod_item IS NOT NULL THEN
         SELECT den_item
           INTO p_tela.den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_tela.cod_item
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "ITEM NAO CADASTRADO" 
            NEXT FIELD cod_item
         END IF 
             
         SELECT val_cliche 
           INTO p_val_cliche
           FROM custo_cliche_885                 
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial          
            AND cod_item  = p_tela.cod_item
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "ITEM NAO POSSUI CLICHE" 
            NEXT FIELD cod_item
         ELSE
            LET p_tela.val_cliche =  p_val_cliche
            SELECT pct_max_cliche
              INTO p_pct_max_cliche 
              FROM par_vdp_885
             WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
            LET p_tela.val_fat_tot =   p_val_cliche / (p_pct_max_cliche/100)
            DISPLAY p_tela.val_cliche  TO val_cliche
            DISPLAY p_tela.val_fat_tot TO val_fat_tot
            DISPLAY p_tela.den_item    TO den_item
            CALL pol0945_monta_array()
         END IF
      ELSE 
         ERROR "O Campo Item nao pode ser Nulo"
         NEXT FIELD cod_item        
      END IF

   ON KEY (control-z)
        CALL pol0945_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0945
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#------------------------------#
 FUNCTION pol0945_monta_array()
#------------------------------#
DEFINE l_val_saldo  LIKE nf_item.val_liq_item

   INITIALIZE t_notas TO NULL

   DECLARE c_notas CURSOR FOR
   SELECT a.num_nff,a.dat_emissao,SUM(b.val_liq_item) 
     FROM nf_mestre a,nf_item b
    WHERE a.cod_empresa IN (p_empresas_885.cod_emp_gerencial, p_empresas_885.cod_emp_oficial)
      AND b.cod_item = p_tela.cod_item
      AND a.cod_empresa = b.cod_empresa
      AND a.num_nff     = b.num_nff
      AND a.ies_situacao = 'N' 
    GROUP BY a.num_nff,a.dat_emissao   
   
   LET p_i = 1
   FOREACH c_notas INTO p_nf_mestre.num_nff,p_nf_mestre.dat_emissao,p_nf_item.val_liq_item

      LET t_notas[p_i].num_nff      = p_nf_mestre.num_nff
      LET t_notas[p_i].dat_emissao  = p_nf_mestre.dat_emissao
      LET t_notas[p_i].val_liq_item = p_nf_item.val_liq_item
      IF p_i = 1 THEN 
         LET t_notas[p_i].val_a_fat = p_tela.val_fat_tot - p_nf_item.val_liq_item
         LET l_val_saldo = p_tela.val_fat_tot - p_nf_item.val_liq_item
      ELSE
         LET t_notas[p_i].val_a_fat = l_val_saldo - p_nf_item.val_liq_item
         LET l_val_saldo = l_val_saldo - p_nf_item.val_liq_item
      END IF    
   
      LET p_i = p_i + 1
   END FOREACH

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_notas TO s_notas.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0945_popup()
#-----------------------#
  DEFINE p_cod_item      LIKE item.cod_item
  
  CASE
     WHEN INFIELD(cod_item)
         LET p_cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)

         CURRENT WINDOW IS w_pol0945
         LET p_tela.cod_item = p_cod_item
      
         DISPLAY p_tela.cod_item TO cod_item

  END CASE
END FUNCTION

#-----------------------#
 FUNCTION pol0945_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION