#-------------------------------------------------------------------#
# SISTEMA.: MANUFATURA                                              #
# PROGRAMA: pol0744                                                 #
# OBJETIVO: RELATÓRIO DE CARGA MÁQUINA                              #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 19/02/2008                                              #
# ALTERAÇAO: 	THIAGO - 08/05/2009 - AO CLICAR EM INFORMAR ELE 			#
#							O PROGRAMA ESTAVA CANCELANDO OPERAÇAO									#
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          p_salto              SMALLINT,
          p_dat_ini            DATE,
          p_dat_fim            DATE,
          p_dat_aux            CHAR(10),
          p_dia_aux            CHAR(02),
          p_mes_aux            CHAR(02),
          p_ano_mes            CHAR(07),
          p_ano_mes_ini        CHAR(07),
          p_ano_mes_fim        CHAR(07),
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          sql_stmt             CHAR(500),
          p_msg                CHAR(500)
   
   DEFINE p_cod_recur          LIKE grupo_recurso_970.cod_recurso
   
   DEFINE p_qtd_hs_disp        DECIMAL(9,2),
          p_qtd_hs_neces       DECIMAL(9,2)

          
   DEFINE p_tela RECORD
      mes_ini           DECIMAL(2,0),
      ano_ini           DECIMAL(4,0),
      mes_fim           DECIMAL(2,0),
      ano_fim           DECIMAL(4,0)
   END RECORD 

   DEFINE p_relat         RECORD 
          cod_grupo       LIKE grupo_desc_970.cod_grupo,
          hs_disp         LIKE ds_recur_pm.qtd_horas,
          hs_neces        LIKE ds_recur_pm.qtd_horas,
          hs_saldo        LIKE ds_recur_pm.qtd_horas,
          den_grupo       CHAR(25),
          qtd_recur       SMALLINT,
          pct_utiliz      DECIMAL(6,2)
   END RECORD
   
   DEFINE pr_grupo    ARRAY[500] OF RECORD
          cod_grupo LIKE grupo_desc_970.cod_grupo,
          den_grupo LIKE grupo_desc_970.descricao_grupo
   END RECORD
      
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol0744-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0744.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0744_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0744_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0744") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0744 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Listagem"
         HELP 001 
         MESSAGE ""
            LET p_count = 0
            IF pol0744_cria_temp() THEN
               IF pol0744_informar() THEN
                  ERROR "Parâmetros informados com sucesso !!!"
                  LET p_ies_cons = TRUE
                  NEXT OPTION "Listar"
               ELSE
                  CLEAR FORM
                  DISPLAY p_cod_empresa TO cod_empresa
                  ERROR "Operação Cancelada !!!"
                  NEXT OPTION "Fim"
               END IF
            ELSE
               ERROR "Operação cancelada !!!"
            END IF
      COMMAND "Listar" "Lista Relatório de Vendas"
         HELP 007
         IF NOT p_ies_cons THEN
            ERROR 'Informe previamente os parâmetros!!!'
            NEXT OPTION 'Informar'
         ELSE     
               IF log028_saida_relat(18,35) IS NOT NULL THEN
                  CALL pol0744_emite_relatorio()   
               END IF                                                     
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0744_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol0744

END FUNCTION

#-----------------------------#
FUNCTION pol0744_cria_temp()
#-----------------------------#
{Thiago - Removi esse if pois na versão 102 ele dropava a tabela e dava um status diferente
dos que estavam determinado retornando um valor falso cancelando operação - 08/05/2009}
   WHENEVER ANY ERROR CONTINUE
   DROP  TABLE grupo_sel_970
   CREATE TEMP  TABLE grupo_sel_970(
          cod_grupo CHAR(06)
       );
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("Criacao","grupo_tmp_970:1")
         RETURN FALSE
      END IF
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0744_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
 
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD mes_ini    
      IF p_tela.mes_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD mes_ini       
      END IF 

      IF p_tela.mes_ini < 1 OR p_tela.mes_ini > 12 THEN
         ERROR "Valor ilegal p/ o campo"
         NEXT FIELD mes_ini       
      END IF 

      AFTER FIELD ano_ini    
      IF p_tela.ano_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD ano_ini       
      END IF 

      IF p_tela.ano_ini < 100 THEN
         LET p_tela.ano_ini = p_tela.ano_ini + 2000
         DISPLAY p_tela.ano_ini TO ano_ini
      END IF

      AFTER FIELD mes_fim
      IF p_tela.mes_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD mes_fim       
      END IF 

      IF p_tela.mes_fim < 1 OR p_tela.mes_fim > 12 THEN
         ERROR "Valor ilegal p/ o campo"
         NEXT FIELD mes_fim       
      END IF 

      AFTER FIELD ano_fim
      IF p_tela.ano_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD ano_fim       
      END IF 

      IF p_tela.ano_fim < 100 THEN
         LET p_tela.ano_fim = p_tela.ano_fim + 2000
         DISPLAY p_tela.ano_fim TO ano_fim
      END IF

      IF p_tela.ano_fim < p_tela.ano_ini THEN
         ERROR "Ano Final < Ano Inicial - Entrada Inválida!!!"
         NEXT FIELD ano_fim       
      END IF 

      IF p_tela.mes_fim < p_tela.mes_ini THEN
         IF p_tela.ano_fim = p_tela.ano_ini THEN
            ERROR "Valor ilegal p/ o campo"
            NEXT FIELD mes_fim       
         END IF
      END IF 

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0744_aceita_grupo() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0744_aceita_grupo()
#-----------------------------#

   INITIALIZE pr_grupo TO NULL
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_grupo
      WITHOUT DEFAULTS FROM sr_grupo.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD cod_grupo
         
         IF pr_grupo[p_index].cod_grupo IS NOT NULL THEN

            IF pol0744_repetiu_cod() THEN
               ERROR "Grupo já Indormado !!!"
               NEXT FIELD cod_grupo
            END IF

            SELECT descricao_grupo
              INTO pr_grupo[p_index].den_grupo
              FROM grupo_desc_970
             WHERE cod_empresa  = p_cod_empresa
               AND cod_grupo     = pr_grupo[p_index].cod_grupo

            IF SQLCA.sqlcode = NOTFOUND THEN
               ERROR 'Grupo não cadastrado!!!'
               NEXT FIELD cod_grupo
            END IF
            
            SELECT COUNT (cod_recurso)
              INTO p_count
              FROM grupo_recurso_970
             WHERE cod_empresa = p_cod_empresa
               AND cod_grupo   = pr_grupo[p_index].cod_grupo

            IF SQLCA.sqlcode <> 0 THEN
               CALL log003_err_sql('Contando recursos','grupo_recurso_970')
               RETURN FALSE
            END IF
            
            IF p_count = 0 THEN
               ERROR 'Grupo sem maáquinas cadastradas na GRUPO_RECURSO_970!!!'
               NEXT FIELD cod_grupo
            END IF
             
            DISPLAY pr_grupo[p_index].den_grupo TO
                    sr_grupo[s_index].den_grupo
         ELSE
            IF FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 27 THEN
               DISPLAY '' TO sr_grupo[s_index].den_grupo
            ELSE
               ERROR 'campo com preenchiento obrigatório!'
               NEXT FIELD cod_grupo
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0744_popup()
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0744_grava_grupo() THEN
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0744_repetiu_cod()
#-----------------------------#

   DEFINE m_ind SMALLINT

   FOR m_ind = 1 TO ARR_COUNT()
       IF m_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_grupo[m_ind].cod_grupo = pr_grupo[p_index].cod_grupo THEN
          RETURN TRUE
       END IF
   END FOR
   
   RETURN FALSE
   
END FUNCTION

#----------------------------#
FUNCTION pol0744_grava_grupo()
#----------------------------#

   FOR p_ind = 1 TO ARR_COUNT()

       IF pr_grupo[p_ind].cod_grupo IS NULL THEN
             CONTINUE FOR
       END IF

       INSERT INTO grupo_sel_970
         VALUES (pr_grupo[p_ind].cod_grupo)

       IF SQLCA.SQLCODE <> 0 THEN 
          CALL log003_err_sql("INCLUSÃO","grupo_sel_970:2")
          RETURN FALSE
       END IF
          
   END FOR

   SELECT COUNT(cod_grupo)
     INTO p_count
     FROM grupo_sel_970
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","grupo_sel_970:3")
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN

      INSERT INTO grupo_sel_970
       SELECT cod_grupo
         FROM grupo_desc_970
        WHERE cod_empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         CALL log003_err_sql("Inserindo","grupo_sel_970:4")
         RETURN FALSE
      END IF

   END IF        

   RETURN TRUE
      
END FUNCTION

#-----------------------#
FUNCTION pol0744_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_grupo)
         CALL log009_popup(08,10,"GRUPOS CADSTRADOS","grupo_desc_970",
                     "cod_grupo","descricao_grupo","pol0706","S","") 
            RETURNING p_codigo

         CALL log006_exibe_teclas("01 02 03 07", p_versao)
 
         CURRENT WINDOW IS w_pol0744
 
         IF p_codigo IS NOT NULL THEN
           LET pr_grupo[p_index].cod_grupo = p_codigo
           DISPLAY p_codigo TO sr_grupo[s_index].cod_grupo
         END IF
 
   END CASE
   
END FUNCTION

#---------------------------------#
 FUNCTION pol0744_emite_relatorio()
#---------------------------------#

   ERROR "Aguarde!.. Processando a Extracao do Relatorio..." 

   CALL pol0744_prepara_datas()

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol0744_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol0744.tmp'
         START REPORT pol0744_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol0744_relat TO p_nom_arquivo
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   DECLARE cq_grupo CURSOR FOR
    SELECT cod_grupo
      FROM grupo_sel_970
     ORDER BY cod_grupo
   
   FOREACH cq_grupo INTO p_relat.cod_grupo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','grupo_sel_970:cq_grupo')
         RETURN FALSE
      END IF

      SELECT descricao_grupo
        INTO p_relat.den_grupo
        FROM grupo_desc_970
       WHERE cod_empresa = p_cod_empresa
         AND cod_grupo   = p_relat.cod_grupo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','grupo_desc_970:cq_grupo')
         RETURN FALSE
      END IF
         
      SELECT COUNT(cod_recurso)
        INTO p_relat.qtd_recur
        FROM grupo_recurso_970
       WHERE cod_empresa = p_cod_empresa
         AND cod_grupo   = p_relat.cod_grupo
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','grupo_recurso_970:count')
         RETURN FALSE
      END IF

      LET p_relat.hs_disp  = 0
      LET p_relat.hs_neces = 0
      LET p_relat.hs_saldo = 0
      LET p_relat.pct_utiliz = 0
      
      DECLARE cq_recur CURSOR FOR       
       SELECT cod_recurso
       FROM grupo_recurso_970
      WHERE cod_empresa = p_cod_empresa
        AND cod_grupo   = p_relat.cod_grupo
      ORDER BY cod_recurso
      
      FOREACH cq_recur INTO p_cod_recur

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','grupo_recurso_970:cq_recur')
            RETURN FALSE
         END IF
      
         SELECT SUM(qtd_horas)
           INTO p_qtd_hs_disp
           FROM ds_recur_pm
          WHERE cod_empresa = p_cod_empresa      
            AND cod_recur   = p_cod_recur
            AND dat_ref BETWEEN p_dat_ini AND p_dat_fim
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ds_recur_pm:somando')
            RETURN FALSE
         END IF

         IF p_qtd_hs_disp IS NULL THEN
            LET p_qtd_hs_disp = 0
         END IF
      
         LET p_relat.hs_disp = p_relat.hs_disp + p_qtd_hs_disp
      
         SELECT SUM(qtd_recur)
           INTO p_qtd_hs_neces
           FROM cons_plan
          WHERE cod_empresa = p_cod_empresa      
            AND cod_recur   = p_cod_recur
            AND mes_ref BETWEEN MONTH(p_dat_ini) AND MONTH(p_dat_fim)
            AND ano_ref BETWEEN YEAR(p_dat_ini) AND YEAR(p_dat_fim)
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cons_plan:somando')
            RETURN FALSE
         END IF

         IF p_qtd_hs_neces IS NULL THEN
            LET p_qtd_hs_neces = 0
         END IF
      
         LET p_relat.hs_neces = p_relat.hs_neces + p_qtd_hs_neces
      
      END FOREACH

      LET p_relat.hs_saldo   = p_relat.hs_disp - p_relat.hs_neces
      LET p_relat.pct_utiliz = p_relat.hs_neces / p_relat.hs_disp * 100
      
      OUTPUT TO REPORT pol0744_relat() 
       
   END FOREACH
   
   FINISH REPORT pol0744_relat
   
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
REPORT pol0744_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 040, "RELATORIO DE CARGA MAQUINA",
               COLUMN 072, "PAG: ", PAGENO USING "###&"
               
         PRINT COLUMN 001, "POL0744",
               COLUMN 015, "PERIODO: ", p_dat_ini, " - ", p_dat_fim,
               COLUMN 053, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "GRUPO  DESCRICAO                 QTD MAQ  HS DISPON   HS NECES   SALDO HS % UTIL"
         PRINT COLUMN 001, "------ ------------------------- ------- ---------- ---------- ---------- ------"
      
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_grupo,
               COLUMN 008, p_relat.den_grupo,
               COLUMN 034, p_relat.qtd_recur  USING '####&',
               COLUMN 042, p_relat.hs_disp    USING '###,##&.&&',
               COLUMN 053, p_relat.hs_neces   USING '###,##&.&&',
               COLUMN 064, p_relat.hs_saldo   USING '---,--&.&&',
               COLUMN 075, p_relat.pct_utiliz USING '##&.&&'

      ON LAST ROW

         LET p_salto = 62 - LINENO          
         SKIP p_salto LINES
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'

      
END REPORT

#-------------------------------#
FUNCTION pol0744_prepara_datas()
#-------------------------------#

   DEFINE p_resto SMALLINT
   
   INITIALIZE p_dat_aux, p_mes_aux TO NULL
   
   IF p_tela.mes_ini < 10 THEN
      LET p_mes_aux = '0',p_tela.mes_ini
   ELSE
      LET p_mes_aux = p_tela.mes_ini
   END IF
   
   LET p_dia_aux = '01'
   
   LET p_dat_aux = p_dia_aux,'/',p_mes_aux,'/',p_tela.ano_ini
   
   LET p_dat_ini = p_dat_aux
   
   #LET p_ano_mes_ini = p_dat_aux[7,10],'/',p_dat_aux[4,5]

   INITIALIZE p_dat_aux, p_dia_aux, p_mes_aux TO NULL
   
   IF p_tela.mes_fim = 4 OR 
      p_tela.mes_fim = 6 OR 
      p_tela.mes_fim = 9 OR 
      p_tela.mes_fim = 11 THEN
      LET p_dia_aux = 30
   ELSE
      IF p_tela.mes_fim <> 2 THEN
         LET p_dia_aux = 31
      ELSE
         LET p_resto = (p_tela.ano_fim MOD 4)
         IF p_resto = 0 THEN
            LET p_dia_aux = 29
         ELSE
            LET p_dia_aux = 28
         END IF
      END IF
   END IF

   IF p_tela.mes_fim < 10 THEN
      LET p_mes_aux = '0',p_tela.mes_fim
   ELSE
      LET p_mes_aux = p_tela.mes_fim
   END IF
      
   LET p_dat_aux = p_dia_aux,'/',p_mes_aux,'/',p_tela.ano_fim
   
   LET p_dat_fim = p_dat_aux
   
   #LET p_ano_mes_fim = p_dat_aux[7,10],'/',p_dat_aux[4,5]

END FUNCTION

#-----------------------#
 FUNCTION pol0744_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

###-----------------FIM DO PROGRAMA-------------------------###