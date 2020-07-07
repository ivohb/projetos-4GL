#-----------------------------------------------------------------#
# PROGRAMA: pol0839                                               #
# OBJETIVO: SOLICITACAO DE MATERIAL DEBITO DIRETO - ESPECIFICOS   #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_aviso_rec         RECORD LIKE aviso_rec.*,
          p_saldo_ar_dd_885   RECORD LIKE saldo_ar_dd_885.*,
          p_solicit_dd_885    RECORD LIKE solicit_dd_885.*,
          p_cad_cc            RECORD LIKE cad_cc.* 

   DEFINE p_cod_empresa      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_nom_fornecedor   LIKE fornecedor.raz_social,
          p_cod_item         LIKE item.cod_item,
          p_qtd_saldo        LIKE aviso_rec.qtd_declarad_nf,
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
          p_i                SMALLINT,
          p_msg              CHAR(100)

   DEFINE t_itens ARRAY[500] OF RECORD
      num_ar           LIKE aviso_rec.num_aviso_rec, 
      num_seq          LIKE aviso_rec.num_seq,
      den_item         LIKE aviso_rec.den_item,
      qtd_saldo        LIKE aviso_rec.qtd_declarad_nf,
      qtd_solicitada   LIKE aviso_rec.qtd_declarad_nf   
   END RECORD

   DEFINE t_cod_it ARRAY[500] OF RECORD
      num_seq          LIKE aviso_rec.num_seq,
      cod_item         LIKE aviso_rec.cod_item 
   END RECORD

   DEFINE t_ars ARRAY[500] OF RECORD
     ies_sel           CHAR(01),
     num_ar            LIKE aviso_rec.num_aviso_rec,           
     num_seq           LIKE aviso_rec.num_seq,                
     den_item          LIKE aviso_rec.den_item,           
     qtd_saldo         LIKE aviso_rec.qtd_declarad_nf,               
     qtd_dispon        LIKE aviso_rec.qtd_declarad_nf, 
     qtd_solicit       LIKE aviso_rec.qtd_declarad_nf  
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   LET p_versao = "POL0839-10.02.00" #Favor nao alterar esta linha (SUPORTE)
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
      CALL pol0839_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0839_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0839") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0839 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Entrada de dados"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0839","CO") THEN 
            IF pol0839_entrada_dados() THEN
               IF p_ies_cons THEN 
                  NEXT OPTION "Processa"
               END IF
            ELSE
               ERROR "Processo cancelado"
            END IF    
         END IF
      COMMAND "Processa" "Grava solicitacao"
         HELP 2011
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0839","MO") THEN 
            IF p_ies_cons THEN 
               CALL pol0839_processa()
               IF p_houve_erro THEN
                  ERROR "Processamento Cancelado " 
                  NEXT OPTION "Consultar"
               END IF  
               COMMIT WORK
               ERROR "Inclusao efetuada com sucesso " 
               NEXT OPTION "Informar"
            ELSE
               ERROR "Informe os dados antes de Processar"
               NEXT OPTION "Consultar"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0839_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0839

END FUNCTION

#-------------------------------#
 FUNCTION pol0839_entrada_dados()
#-------------------------------#
   INITIALIZE  p_aviso_rec.*,
               p_saldo_ar_dd_885.*,  
               p_solicit_dd_885.*,
               p_cad_cc.*,
               t_itens,
               t_cod_it,
               t_ars  TO NULL
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0839

   LET INT_FLAG = FALSE  
   INPUT p_cod_usuario,
         p_solicit_dd_885.cod_cent_cust,
         p_solicit_dd_885.den_justif
   WITHOUT DEFAULTS  
    FROM cod_usuario,
         cod_cent_cust,
         den_justif   

    AFTER FIELD cod_usuario     
    IF p_cod_usuario IS NOT NULL THEN
       SELECT nom_funcionario
        INTO p_solicit_dd_885.nom_solicit
       FROM usuarios
       WHERE cod_usuario = p_cod_usuario
       IF SQLCA.SQLCODE <> 0 THEN
          ERROR "Usuario nao cadastrado" 
          NEXT FIELD cod_usuario
       ELSE
          DISPLAY p_solicit_dd_885.nom_solicit TO nom_solicit       
       END IF
    ELSE 
       ERROR "O Campo Solicitante nao pode ser Nulo"
       NEXT FIELD cod_usuario       
    END IF
    
    AFTER FIELD cod_cent_cust
    IF p_solicit_dd_885.cod_cent_cust IS NOT NULL THEN
       SELECT nom_cent_cust
         INTO p_cad_cc.nom_cent_cust
         FROM cad_cc
        WHERE cod_empresa   = p_cod_empresa
          AND cod_cent_cust = p_solicit_dd_885.cod_cent_cust
       IF SQLCA.sqlcode <> 0 THEN 
          ERROR "Centro de custo invalido"
          NEXT FIELD cod_cent_cust
       ELSE
          DISPLAY p_cad_cc.nom_cent_cust TO nom_cent_cust
       END IF    
    END IF 

    AFTER FIELD den_justif
    IF p_solicit_dd_885.den_justif IS NULL THEN
       ERROR "Justificativa deve ser preenchida"
       NEXT FIELD den_justif
    END IF 

   CALL pol0839_entrada_itens()

   ON KEY (control-z)
        CALL pol0839_popup()
           
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0839
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      LET p_ies_cons = TRUE
      RETURN TRUE 
   END IF
 
END FUNCTION

#--------------------------------#
 FUNCTION pol0839_entrada_itens()
#--------------------------------#
DEFINE l_count        INTEGER,
       l_qtd_saldo    DECIMAL(12,3),
       l_qtd_solicit  DECIMAL(12,3),
       l_cod_item     CHAR(15)
       
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0811

   LET INT_FLAG = FALSE
   INPUT ARRAY t_itens WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD num_ar    
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD num_ar
        IF t_itens[pa_curr].num_ar IS NOT NULL THEN
           LET l_count = 0
           SELECT COUNT(*)
             INTO l_count
             FROM saldo_ar_dd_885
            WHERE cod_empresa = p_cod_empresa
              AND num_ar      = t_itens[pa_curr].num_ar
           IF l_count = 0 THEN
              ERROR 'AR Nao possui itens em estoque' 
              NEXT FIELD num_ar
           END IF     
        END IF

      AFTER FIELD num_seq
        IF t_itens[pa_curr].num_seq IS NOT NULL THEN
           LET l_count = 0
           SELECT COUNT(*)
             INTO l_count
             FROM saldo_ar_dd_885
            WHERE cod_empresa = p_cod_empresa
              AND num_ar      = t_itens[pa_curr].num_ar
              AND num_seq     = t_itens[pa_curr].num_seq
           IF l_count = 0 THEN
              ERROR 'AR/SEQ Nao possui itens em estoque' 
              NEXT FIELD num_seq
           END IF     
        END IF

      AFTER FIELD qtd_solicitada
        IF t_itens[pa_curr].qtd_solicitada IS NOT NULL THEN
           LET l_count = 0
           SELECT cod_item,
                  (qtd_item - qtd_retirada) 
             INTO l_cod_item,
                  l_qtd_saldo
             FROM saldo_ar_dd_885
            WHERE cod_empresa = p_cod_empresa
              AND num_ar      = t_itens[pa_curr].num_ar
              AND num_seq     = t_itens[pa_curr].num_seq
           IF l_qtd_saldo IS NULL THEN 
              LET l_qtd_saldo = 0 
           END IF   
           SELECT SUM(qtd_solicitada)
             INTO l_qtd_solicit
             FROM solicit_dd_885
            WHERE cod_empresa = p_cod_empresa
              AND num_ar      = t_itens[pa_curr].num_ar
              AND num_seq     = t_itens[pa_curr].num_seq
           IF l_qtd_solicit IS NULL THEN 
              LET l_qtd_solicit = 0 
           END IF   
           IF l_qtd_saldo < t_itens[pa_curr].qtd_solicitada THEN
              ERROR 'Qtd solicitada ',t_itens[pa_curr].qtd_solicitada, ' maior que saldo em estoque - ', l_qtd_saldo
              NEXT FIELD qtd_solicitada
           ELSE
              LET t_itens[pa_curr].qtd_saldo = l_qtd_saldo 
              LET t_cod_it[pa_curr].cod_item = l_cod_item
              LET t_cod_it[pa_curr].num_seq  = t_itens[pa_curr].num_seq  
           END IF     
        END IF

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_itens[pa_curr+1].num_ar IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD num_ar
         END IF  
      END IF  

   ON KEY (control-z)
        LET z_i = pa_curr 
        CALL pol0839_popupit()
        CURRENT WINDOW IS w_pol0839
        LET z_i = z_i - 1
        CALL SET_COUNT(z_i)
        DISPLAY ARRAY t_itens TO s_itens.*
        END DISPLAY

   END INPUT

   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN 
   END IF

END FUNCTION

#---------------------------#
 FUNCTION pol0839_processa()
#---------------------------#
DEFINE l_num_solicit  INTEGER

   LET p_houve_erro = FALSE
   BEGIN WORK

   FOR w_i = 1  TO 500 

      IF t_itens[w_i].num_ar IS NULL THEN
         EXIT FOR 
      END IF

      SELECT MAX(num_solicit)
        INTO l_num_solicit
        FROM solicit_dd_885
      IF l_num_solicit IS NULL THEN
         LET l_num_solicit = 0
      END IF     

      LET p_solicit_dd_885.cod_empresa    = p_cod_empresa
      LET p_solicit_dd_885.num_solicit    = l_num_solicit + 1
      LET p_solicit_dd_885.dat_solicit    = TODAY
      LET p_solicit_dd_885.num_ar         = t_itens[w_i].num_ar
      LET p_solicit_dd_885.cod_item       = t_cod_it[w_i].cod_item
      LET p_solicit_dd_885.num_seq        = t_itens[w_i].num_seq
      LET p_solicit_dd_885.den_item       = t_itens[w_i].den_item
      LET p_solicit_dd_885.qtd_solicitada = t_itens[w_i].qtd_solicitada
      LET p_solicit_dd_885.ies_aprovado   = 'N'
      INSERT INTO solicit_dd_885    VALUES   (p_solicit_dd_885.*)
      
   END FOR
   
   LET p_ies_cons = FALSE
   MESSAGE ""
   
END FUNCTION

#-----------------------#
 FUNCTION pol0839_popup()
#-----------------------#

   CASE
      WHEN INFIELD(cod_usuario)
         CALL log009_popup(6,25,"USUARIOS","usuarios",
                          "cod_usuario","nom_funcionario",
                          "","N","") 
            RETURNING p_cod_usuario
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0839 
         IF p_cod_usuario IS NOT NULL THEN
            DISPLAY p_cod_usuario TO cod_usuario
         END IF
         
      WHEN INFIELD(cod_cent_cust)
         CALL log009_popup(6,25,"CENTRO CUSTO","cad_cc",
                          "cod_cent_cust","nom_cent_cust",
                          "con0480","N","") 
            RETURNING p_solicit_dd_885.cod_cent_cust
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0839  
         IF p_solicit_dd_885.cod_cent_cust IS NOT NULL THEN
            DISPLAY BY NAME p_solicit_dd_885.cod_cent_cust
         END IF
   END CASE

END FUNCTION


#----------------------------#
FUNCTION pol0839_popupit()
#----------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("pol08391") RETURNING p_nom_tela
  OPEN WINDOW w_pol08391 AT 5,03 WITH FORM p_nom_tela
    ATTRIBUTE(BORDER, FORM LINE 1, MESSAGE LINE LAST-1, PROMPT LINE LAST)

   INPUT p_den_item
   WITHOUT DEFAULTS  
    FROM den_item 

    BEFORE FIELD den_item
       INITIALIZE p_den_item TO NULL 

    AFTER FIELD den_item
       CALL pol0839_monta_ars()

   END INPUT 

   INPUT ARRAY t_ars WITHOUT DEFAULTS FROM s_ars.*

      BEFORE FIELD ies_sel    
         LET pa_curr1 = ARR_CURR()
         LET sc_curr1 = SCR_LINE()

      AFTER FIELD ies_sel
        IF t_ars[pa_curr1].ies_sel <> 'N' AND 
           t_ars[pa_curr1].ies_sel <> 'S' THEN
           ERROR 'INFORME (S) OU (N)' 
           NEXT FIELD ies_sel
        END IF

      AFTER FIELD qtd_solicit
        IF t_ars[pa_curr1].qtd_solicit = 0 AND 
           t_ars[pa_curr1].ies_sel = 'S'   THEN
           ERROR 'INFORME A QUANTIDADE SOLICITADA'
           NEXT FIELD qtd_solicit
        ELSE
           IF t_ars[pa_curr1].qtd_solicit > t_ars[pa_curr1].qtd_dispon THEN
              ERROR 'QUANTIDADE SOLICITADA MAIOR QUE SALDO DISPONIVEL'
              NEXT FIELD qtd_solicit
           END IF           
        END IF

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_ars[pa_curr1+1].num_ar IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD ies_sel
         END IF  
      END IF  

   END INPUT

   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN 
   ELSE
      CALL pol0839_monta_tela_ar()   
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol0839_monta_ars()
#--------------------------#
 DEFINE sql_stmt, where_clause   CHAR(300),
        l_qtd_dispon      LIKE   saldo_ar_dd_885.qtd_item,
        l_qtd_solic       LIKE   saldo_ar_dd_885.qtd_item

 LET p_i =  1

 LET where_clause = '%',p_den_item CLIPPED,'%' 

 LET sql_stmt = "SELECT * FROM saldo_ar_dd_885 ",
                " WHERE den_item LIKE '", where_clause CLIPPED,"'", 
                " AND cod_empresa = '", p_cod_empresa,"'",
                " ORDER BY num_ar "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao CURSOR FOR var_query
 FOREACH cq_padrao INTO p_saldo_ar_dd_885.*
    IF p_saldo_ar_dd_885.qtd_retirada < p_saldo_ar_dd_885.qtd_item THEN 
       LET l_qtd_solic = 0 
       SELECT SUM(qtd_solicitada)
         INTO l_qtd_solic
         FROM solicit_dd_885
        WHERE cod_empresa = p_cod_empresa
          AND num_ar      = p_saldo_ar_dd_885.num_ar
          AND num_seq     = p_saldo_ar_dd_885.num_seq
       IF l_qtd_solic IS NULL THEN 
          LET l_qtd_solic = 0 
       END IF 
       LET l_qtd_dispon =  p_saldo_ar_dd_885.qtd_item - p_saldo_ar_dd_885.qtd_retirada - l_qtd_solic
       IF l_qtd_dispon > 0 THEN 
          LET t_ars[p_i].ies_sel     = 'N' 
          LET t_ars[p_i].num_ar      = p_saldo_ar_dd_885.num_ar   
          LET t_ars[p_i].num_seq     = p_saldo_ar_dd_885.num_seq     
          LET t_ars[p_i].den_item    = p_saldo_ar_dd_885.den_item    
          LET t_ars[p_i].qtd_saldo   = p_saldo_ar_dd_885.qtd_item - p_saldo_ar_dd_885.qtd_retirada   
          LET t_ars[p_i].qtd_dispon  = l_qtd_dispon
          LET t_ars[p_i].qtd_solicit = 0
          LET t_cod_it[p_i].cod_item = p_saldo_ar_dd_885.cod_item 
          LET p_i = p_i + 1
       END IF    
    END IF   
 END FOREACH       

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_ars TO s_ars.*
   END DISPLAY

END FUNCTION

#-------------------------------#
FUNCTION pol0839_monta_tela_ar()
#-------------------------------#
DEFINE l_i INTEGER

  FOR l_i = 1  TO 500 
  
    IF t_ars[l_i].ies_sel = 'S' THEN 
       LET t_itens[z_i].num_ar           = t_ars[l_i].num_ar
       LET t_itens[z_i].num_seq          = t_ars[l_i].num_seq        
       LET t_itens[z_i].den_item         = t_ars[l_i].den_item    
       LET t_itens[z_i].qtd_saldo        = t_ars[l_i].qtd_saldo               
       LET t_itens[z_i].qtd_solicitada   = t_ars[l_i].qtd_solicit
       LET t_cod_it[z_i].cod_item        = t_cod_it[l_i].cod_item
       LET z_i = z_i + 1
    END IF 
    
  END FOR 
END FUNCTION

#-----------------------#
 FUNCTION pol0839_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#

