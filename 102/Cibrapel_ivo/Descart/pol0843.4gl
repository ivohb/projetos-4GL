#-----------------------------------------------------------------#
# PROGRAMA: pol0843                                               #
# OBJETIVO: CONSULTA ESTOQUE MATERIAL DEBITO DIRETO - ESPECIFICOS #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_saldo_ar_dd_885      RECORD LIKE saldo_ar_dd_885.*

   DEFINE p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_qtd_saldo        LIKE aviso_rec.qtd_declarad_nf,
          p_cod_item         LIKE item.cod_item,
          p_ies_tip_cons     CHAR(01),
          p_ies_cons         SMALLINT,
          p_last_row         SMALLINT,
          p_conta            SMALLINT,
          p_cont             SMALLINT,
          pa_curr            SMALLINT,
          sc_curr            SMALLINT,
          pa_curr1           SMALLINT,
          sc_curr1           SMALLINT,
          p_status           SMALLINT,
          p_funcao           CHAR(15),
          p_houve_erro       SMALLINT,
          p_den_item         CHAR(67), 
          p_cod_usuario      CHAR(08),
          p_comando          CHAR(80),
          p_caminho          CHAR(80),
          p_help             CHAR(80),
          p_cancel           INTEGER,
          p_nom_tela         CHAR(80),
          p_mensag           CHAR(200),
          z_i                SMALLINT,
          w_i                SMALLINT,
          p_i                SMALLINT

   DEFINE t_estoq ARRAY[500] OF RECORD
      cod_item         LIKE item.cod_item,
      num_ar           LIKE aviso_rec.num_aviso_rec,
      num_seq          LIKE aviso_rec.num_seq,
      den_item         CHAR(40),
      qtd_saldo        LIKE saldo_ar_dd_885.qtd_retirada  
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   LET p_versao = "POL0843-05.10.01" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0843_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0843_controle()
#--------------------------#
 DEFINE l_count INTEGER

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0843") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0843 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Entrada de dados"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0843","CO") THEN 
            IF pol0843_entrada_dados() THEN
               IF p_ies_cons THEN 
                  NEXT OPTION "Informa"
               END IF
            ELSE
               ERROR "Processo cancelado"
            END IF    
         END IF

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0843

END FUNCTION

#-------------------------------#
 FUNCTION pol0843_entrada_dados()
#-------------------------------#
   INITIALIZE  p_saldo_ar_dd_885.*,
               t_estoq            TO NULL
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0843

   LET INT_FLAG = FALSE  
   INPUT p_ies_tip_cons,
         p_cod_item
   WITHOUT DEFAULTS  
    FROM ies_tip_cons,
         cod_item  

    BEFORE FIELD ies_tip_cons
      LET p_ies_tip_cons = 'F'
      ERROR 'Informe F - ESTOQUE POR FAMILIA ou I - EESTOQUE POR ITEM / AR'

    AFTER FIELD ies_tip_cons
       IF p_ies_tip_cons IS NULL THEN     
          ERROR 'INFORME TIPO DE CONSULTA'
          NEXT FIELD ies_tip_cons
       ELSE
          IF p_ies_tip_cons <> 'F' AND 
             p_ies_tip_cons <> 'I' THEN     
             ERROR 'Informe F - ESTOQUE POR FAMILIA ou I - EESTOQUE POR ITEM / AR'
             NEXT FIELD ies_tip_cons
          ELSE
             ERROR ''
          END IF                         
       END IF 

    AFTER FIELD cod_item
       IF p_ies_tip_cons = 'I' AND 
          p_cod_item IS NULL  THEN 
          ERROR 'PARA CONSULTA POR ITEM INFORME O CODIGO'
          NEXT FIELD cod_item
       END IF  
       
       IF p_ies_tip_cons = 'I' THEN   
          CALL pol0843_carrega_tela_it()
       ELSE
          CALL pol0843_carrega_tela_fam()
       END IF    

      ON KEY (control-z)
         CALL pol0843_popup()
         
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0843
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE
      RETURN TRUE 
   END IF
 
END FUNCTION

#--------------------------------#
FUNCTION pol0843_carrega_tela_it()
#--------------------------------#
 DEFINE sql_stmt, 
        where_clause   CHAR(300)
        
 LET p_i =  1

 DECLARE cq_cr_it CURSOR FOR  
   SELECT *
     FROM saldo_ar_dd_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item 
      AND (qtd_item - qtd_retirada) > 0   
   ORDER BY num_ar    
 FOREACH cq_cr_it INTO p_saldo_ar_dd_885.*
    LET t_estoq[p_i].cod_item       = p_saldo_ar_dd_885.cod_item
    LET t_estoq[p_i].num_ar         = p_saldo_ar_dd_885.num_ar
    LET t_estoq[p_i].num_seq        = p_saldo_ar_dd_885.num_seq
    LET t_estoq[p_i].den_item       = p_saldo_ar_dd_885.den_item    
    LET t_estoq[p_i].qtd_saldo      = p_saldo_ar_dd_885.qtd_item  - p_saldo_ar_dd_885.qtd_retirada
    LET p_i = p_i + 1
 END FOREACH       

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_estoq TO s_estoq.*
   END DISPLAY

END FUNCTION

#---------------------------------#
FUNCTION pol0843_carrega_tela_fam()
#---------------------------------#
 DEFINE sql_stmt, 
        where_clause   CHAR(300)
        
 LET p_i =  1

 LET where_clause = "a.cod_item LIKE '%",p_cod_item CLIPPED,"%" 

 LET sql_stmt = "SELECT a.cod_item,b.den_item,SUM(qtd_item - qtd_retirada) FROM saldo_ar_dd_885 a, ",
                " item b WHERE ", where_clause CLIPPED,"'", 
                " AND a.cod_empresa = '", p_cod_empresa,"'",
                " AND a.cod_empresa = b.cod_empresa AND a.cod_item = b.cod_item ",
                " GROUP BY a.cod_item,b.den_item",
                " ORDER BY b.den_item"

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao CURSOR FOR var_query
 FOREACH cq_padrao INTO p_saldo_ar_dd_885.cod_item, p_saldo_ar_dd_885.den_item, p_saldo_ar_dd_885.qtd_item 
    LET t_estoq[p_i].cod_item       = p_saldo_ar_dd_885.cod_item
    LET t_estoq[p_i].num_ar         = 0
    LET t_estoq[p_i].num_seq        = 0
    LET t_estoq[p_i].den_item       = p_saldo_ar_dd_885.den_item    
    LET t_estoq[p_i].qtd_saldo      = p_saldo_ar_dd_885.qtd_item 
    LET p_i = p_i + 1
 END FOREACH       

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_estoq TO s_estoq.*
   END DISPLAY

END FUNCTION

#-----------------------#
FUNCTION pol0843_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0823
         IF p_codigo IS NOT NULL THEN
           LET p_cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE
   
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#