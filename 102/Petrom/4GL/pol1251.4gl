#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1251                                                 #
# OBJETIVO: LIBERAÇÃO DE CONHECIMENTOS DE FRETE                     #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 06/01/2014                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_last_row           SMALLINT,
          p_caminho            CHAR(080)

END GLOBALS

   DEFINE p_salto              SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho_jar        CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_texto              CHAR(10),
          p_linha              CHAR(30),
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT,
          p_erro               CHAR(10),
          p_qtd_linha          INTEGER,
          p_motivo             CHAR(210),
          p_liberar            CHAR(01),
          p_preco_ant          DECIMAL(12,2),
          p_den_transpor       CHAR(40),
          p_cod_transpor       CHAR(15),
          p_tip_transp         CHAR(02),
          p_tip_transp_auto    CHAR(02),
          p_id_cf_proces       INTEGER
          
   DEFINE p_dat_atu            DATE,
          p_hor_atu            CHAR(08),
          p_cod_funcao         CHAR(01),
          p_ies_imprimiu       SMALLINT,
          p_dat_ini            DATE,
          p_dat_fim            DATE,
          p_query              CHAR(800),
          p_mot_01             CHAR(70),
          p_mot_02             CHAR(70),
          p_mot_03             CHAR(70)
          
   DEFINE pr_liberar           ARRAY[1000] OF RECORD
          liberar              CHAR(01),
          num_conhec           DECIMAL(7,0),
          ser_conhec           CHAR(03),
          ssr_conhec           DECIMAL(2,0),
          dat_emis_conhec      DATE,
          cod_transpor         CHAR(15),
          val_frete            DECIMAL(12,2),
          val_calculado        DECIMAL(12,2),
          val_tolerancia       DECIMAL(12,2)
   END RECORD

   DEFINE pr_compl             ARRAY[1000] OF RECORD
          motivo               CHAR(210)
   END RECORD

   DEFINE pr_diverg             ARRAY[1000] OF RECORD
          divergencia           CHAR(80),
          id_cf_proces          INTEGER
   END RECORD   

   DEFINE p_parametro     RECORD
       cod_empresa   LIKE audit_logix.cod_empresa,
       texto         LIKE audit_logix.texto,
       num_programa  LIKE audit_logix.num_programa,
       usuario       LIKE audit_logix.usuario
   END RECORD

   DEFINE p_tela           RECORD
          transportadora   CHAR(15),
          descricao        CHAR(40),
          conhecimento     DECIMAL(7,0),
          dat_ini          DATE,
          dat_fim          DATE
   END RECORD

   DEFINE pr_integrado         ARRAY[3000] OF RECORD
          dat_confer           DATE, 
          cod_transpor         CHAR(15),
          num_conhec           DECIMAL(7,0),
          ser_conhec           CHAR(03),
          ssr_conhec           DECIMAL(2,0),
          dat_conhec           DATE,
          val_frete            DECIMAL(12,2),
          val_calculado        DECIMAL(12,2),
          #val_tolerancia       DECIMAL(12,2),
          sit_frete            CHAR(01)
   END RECORD

   DEFINE pr_mesnsagem          ARRAY[3000] OF RECORD
          divergencia           CHAR(80),
          motivo                CHAR(80)
   END RECORD   
             
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT

   LET p_versao = "pol1251-10.02.08  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_cod_empresa = '21'; LET p_status = 0; LET p_user = 'admlog'

   LET p_parametro.num_programa = 'pol1251'
   LET p_parametro.cod_empresa = p_cod_empresa
   LET p_parametro.usuario = p_user
  
   IF p_status = 0 THEN
      CALL pol1251_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1251_menu()
#----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1251") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1251 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Bloqueados" "Liberar/Deletar Conhecimentos Bloqueados"
         IF pol1251_consultar() THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1251_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Erros" "Consultar Conhecimentos com erros"
         CALL log120_procura_caminho("pol1250") RETURNING comando
         LET comando = comando CLIPPED, " ","pol1251"
         RUN comando RETURNING p_status         
      COMMAND "Integrados" "Consulta os Conhecimentos integrados"
         IF pol1251_integrado() THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1251_sobre() 
      #COMMAND "Listar" "Listagem das ordens liberadas"
      #   CALL pol1251_relatorio() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1251

END FUNCTION

#------------------------#
 FUNCTION pol1251_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1251_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------------#
FUNCTION pol1251_le_tip_traspor()#
#--------------------------------#
   
   DEFINE p_param LIKE par_vdp.par_vdp_txt
   
   SELECT par_vdp_txt
     INTO p_param
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp')
      RETURN FALSE
   END IF
   
   LET p_tip_transp = p_param[215,216]
   
   SELECT par_txt
     INTO p_tip_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
          
#---------------------------#
FUNCTION pol1251_consultar()#
#---------------------------#

   CALL pol1251_limpa_tela()
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1251b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1251b AT 05,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1251_par_con() RETURNING p_status
   
   CLOSE WINDOW w_pol1251b
   
   CURRENT WINDOW IS w_pol1251
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF

   IF NOT pol1251_modificar() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol1251_par_con()#
#-------------------------#

   IF NOT pol1251_le_tip_traspor() THEN
      RETURN FALSE
   END IF

   CALL pol1251_limpa_tela()

   INITIALIZE p_tela TO NULL
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD transportadora
         
         IF p_tela.transportadora IS NOT NULL THEN
            LET p_cod_transpor = p_tela.transportadora
            LET p_tela.descricao = pol1251_le_den_transpor()
            IF p_tela.descricao IS NULL THEN
               NEXT FIELD transportadora
            END IF
         END IF
         
         DISPLAY p_tela.descricao TO descricao
         
      ON KEY (control-z)
         CALL pol1251_popup()

      AFTER INPUT
         IF INT_FLAG THEN
            CALL pol1251_limpa_tela()
            RETURN FALSE
         END IF

   END INPUT 
  
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1251_le_den_transpor()#
#---------------------------------#

   SELECT raz_social
     INTO p_den_transpor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_transpor
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Codigo inexistente ou nao eh um transportador'
      ERROR p_msg
      LET p_den_transpor = ''
   END IF
   
   RETURN p_den_transpor

END FUNCTION   

#-----------------------#
 FUNCTION pol1251_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(transportadora)
         LET p_codigo = sup162_popup_fornecedor()
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tela.transportadora = p_codigo CLIPPED
            DISPLAY p_codigo TO transportadora
         END IF

   END CASE 

END FUNCTION 

#-----------------------------#
FUNCTION pol1251_monta_query()#
#-----------------------------#

   LET p_query = 
      "SELECT num_conhec, ser_conhec, ssr_conhec, dat_emis_conhec, cod_transpor ",
      "  FROM frete_sup WHERE cod_empresa = '",p_cod_empresa,"' ",
      "   AND ies_incl_cap = 'X' "

   IF p_tela.transportadora IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND cod_transpor = ", p_tela.transportadora
   END IF

   IF p_tela.conhecimento IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND num_conhec = ",p_tela.conhecimento
   END IF
   
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_emis_conhec >= '",p_tela.dat_ini,"' "
   END IF
   
   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_emis_conhec <= '",p_tela.dat_fim,"' "
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY dat_emis_conhec, cod_transpor, num_conhec "

END FUNCTION

#-------------------------------#
FUNCTION pol1251_carrega_dados()#
#-------------------------------#
   
   PREPARE var_query FROM p_query
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' preparando query' 
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_ind = 1
   INITIALIZE pr_liberar, pr_compl, pr_diverg TO NULL
   
   DECLARE cq_docum CURSOR FOR var_query
   FOREACH cq_docum INTO 
           pr_liberar[p_ind].num_conhec,
           pr_liberar[p_ind].ser_conhec,
           pr_liberar[p_ind].ssr_conhec,
           pr_liberar[p_ind].dat_emis_conhec, 
           pr_liberar[p_ind].cod_transpor

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_docum')
         RETURN FALSE
      END IF

      SELECT val_frete, 
             val_calculado, 
             val_tolerancia,
             divergencia, 
             id_registro
        INTO pr_liberar[p_ind].val_frete,
             pr_liberar[p_ind].val_calculado,
             pr_liberar[p_ind].val_tolerancia,
             pr_diverg[p_ind].divergencia,
             pr_diverg[p_ind].id_cf_proces
        FROM conhec_proces_455
       WHERE cod_empresa  = p_cod_empresa
         AND cod_transpor = pr_liberar[p_ind].cod_transpor
         AND num_conhec   = pr_liberar[p_ind].num_conhec
         AND ser_conhec   = pr_liberar[p_ind].ser_conhec
         AND ssr_conhec   = pr_liberar[p_ind].ssr_conhec
      
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','conhec_proces_455')
            RETURN FALSE
         END IF
      END IF
      
      LET pr_liberar[p_ind].liberar = 'N'
      
      LET p_ind = p_ind + 1
   
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   IF p_ind = 1 THEN
      LET p_msg = 'Não a dados, para os\n',
                  'parâmetros informados.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_qtd_linha = p_ind - 1
   CALL SET_COUNT(p_ind - 1)
   
END FUNCTION
     
#----------------------------#
FUNCTION pol1251_info_compl()#
#----------------------------#
   
   DEFINE p_divergencia  char(78)
   
   CALL pol1251_le_den_transpor() RETURNING p_msg 
   DISPLAY p_den_transpor TO den_transpor
   DISPLAY pr_compl[p_ind].motivo TO motivo
   LET p_divergencia = pr_diverg[p_ind].divergencia
   DISPLAY p_divergencia TO divergencia
      
END FUNCTION

#---------------------------#
FUNCTION pol1251_modificar()#
#---------------------------#

   CALL pol1251_monta_query()
   
   IF NOT pol1251_carrega_dados() THEN
      CALL pol1251_limpa_tela()
      RETURN FALSE
   END IF

   LET INT_FLAG = FALSE

   INPUT ARRAY pr_liberar
      WITHOUT DEFAULTS FROM sr_liberar.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

         IF pr_liberar[p_ind].cod_transpor IS NOT NULL THEN
            LET p_cod_transpor = pr_liberar[p_ind].cod_transpor
            CALL pol1251_info_compl()        
         END IF
         
      BEFORE FIELD liberar
         LET p_liberar = pr_liberar[p_ind].liberar
         
      AFTER FIELD liberar

         IF pr_liberar[p_ind].liberar MATCHES '[LDN]' THEN
         ELSE
            ERROR 'Valor inválido para o campo'
            NEXT FIELD liberar
         END IF
         
         IF pr_liberar[p_ind].liberar = 'L' THEN
            IF pr_liberar[p_ind].liberar <> p_liberar THEN
               CALL pol1251_info_motivo()
               LET p_liberar = pr_liberar[p_ind].liberar
               NEXT FIELD liberar
            END IF
         ELSE
            LET pr_compl[p_ind].motivo = ''
            DISPLAY '' TO motivo
         END IF
         
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               LET p_liberar = pr_liberar[p_ind].liberar
               NEXT FIELD liberar
            END IF
         END IF                     

      ON KEY (control-t)
         IF pr_liberar[p_ind].liberar = 'N' THEN
         ELSE
            CALL pol1251_info_motivo()
         END IF

      ON KEY (control-d)
         IF pr_liberar[p_ind].num_conhec IS NOT NULL THEN
            LET p_id_cf_proces = pr_diverg[p_ind].id_cf_proces
            CALL pol1251_exibe_calculos()
         END IF

      AFTER INPUT
       
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         LET p_count = 0
         
         FOR p_index = 1 TO p_qtd_linha
            IF pr_liberar[p_index].liberar MATCHES '[LD]' THEN
               LET p_count = p_count + 1
               EXIT FOR
            END IF
         END FOR
         
         IF p_count = 0 THEN
            LET p_msg = 'Nenhuma conhecimento foi selecionada\n para liberação\deletar'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD liberar
         END IF
               
   END INPUT

   LET p_msg = 'Confirma a liberação dos\n conhecimentos selecionadas?'

   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1251_grava_modificaoes() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   RETURN TRUE
   
END FUNCTION   


#-----------------------------#
FUNCTION pol1251_info_motivo()#
#-----------------------------#
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1251a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1251a AT 05,07 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1251_dig_motivo()

   CLOSE WINDOW w_pol1251a
   
   CURRENT WINDOW IS w_pol1251
   
   DISPLAY p_motivo TO motivo
   
END FUNCTION

#----------------------------#
FUNCTION pol1251_dig_motivo()#
#----------------------------#

   LET p_motivo = pr_compl[p_ind].motivo
   
   INPUT p_motivo WITHOUT DEFAULTS
     FROM motivo

      BEFORE FIELD motivo
         DISPLAY p_motivo to motivo

      AFTER FIELD motivo
         
         IF p_motivo IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD p_motivo
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
       LET INT_FLAG = FALSE
        RETURN
   END IF
         
   LET pr_compl[p_ind].motivo = p_motivo

END FUNCTION

#-----------------------------------#
FUNCTION pol1251_grava_modificaoes()#
#-----------------------------------#

   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   
   FOR p_ind = 1 to p_qtd_linha
       
       IF pr_liberar[p_ind].liberar = 'L' THEN
          IF NOT pol1251_libera_odocum() THEN
             RETURN FALSE
          END IF
       END IF

       IF pr_liberar[p_ind].liberar = 'D' THEN
          IF NOT pol1251_deleta_odocum() THEN
             RETURN FALSE
          END IF
       END IF
       
       CALL pol1251_del_erros()
              
   END FOR
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#   
FUNCTION pol1251_libera_odocum()#
#-------------------------------#

   UPDATE frete_sup
      SET ies_incl_cap = 'N'
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor = pr_liberar[p_ind].cod_transpor
      AND num_conhec   = pr_liberar[p_ind].num_conhec
      AND ser_conhec   = pr_liberar[p_ind].ser_conhec
      AND ssr_conhec   = pr_liberar[p_ind].ssr_conhec
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'frete_sup')
      RETURN FALSE
   END IF

   IF NOT pol1251_gra_motivo() THEN
      RETURN FALSE
   END IF
      
   UPDATE audit_conhec_455
      SET cod_usuario = p_user,
          dat_liberac = p_dat_atu,
          hor_liberac = p_hor_atu
    WHERE cod_empresa = p_cod_empresa
      AND id_cf_proces = pr_diverg[p_ind].id_cf_proces
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'audit_conhec_455')
      RETURN FALSE
   END IF            

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1251_del_erros()#
#---------------------------#

   DELETE FROM erro_conhec_455
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor = pr_liberar[p_ind].cod_transpor
      AND num_conhec   = pr_liberar[p_ind].num_conhec
      AND ser_conhec   = pr_liberar[p_ind].ser_conhec
      AND ssr_conhec   = pr_liberar[p_ind].ssr_conhec
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'erro_conhec_455')
   END IF

END FUNCTION

#-------------------------------#   
FUNCTION pol1251_deleta_odocum()#
#-------------------------------#
      
   DELETE FROM audit_conhec_455
    WHERE cod_empresa = p_cod_empresa
      AND id_cf_proces = pr_diverg[p_ind].id_cf_proces
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'audit_conhec_455')
      RETURN FALSE
   END IF            

   DELETE FROM conhec_proces_455
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = pr_diverg[p_ind].id_cf_proces
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'conhec_proces_455')
      RETURN FALSE
   END IF            

   DELETE FROM calculo_conhec_455
    WHERE cod_empresa = p_cod_empresa
      AND id_cf_proces = pr_diverg[p_ind].id_cf_proces

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'calculo_conhec_455')
      RETURN FALSE
   END IF            

   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol1251_gra_motivo()#
#-----------------------------#

   UPDATE conhec_proces_455
      SET motivo = pr_compl[p_ind].motivo
    WHERE cod_empresa = p_cod_empresa
      AND cod_transpor = pr_liberar[p_ind].cod_transpor
      AND num_conhec   = pr_liberar[p_ind].num_conhec
      AND ser_conhec   = pr_liberar[p_ind].ser_conhec
      AND ssr_conhec   = pr_liberar[p_ind].ssr_conhec

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE', 'conhec_proces_455')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1251_integrado()#
#---------------------------#

   CALL pol1251_limpa_tela()
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1251b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1251b AT 05,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1251_par_con() RETURNING p_status
   
   CLOSE WINDOW w_pol1251b
      
   IF NOT p_status THEN
      RETURN FALSE
   END IF

   IF NOT pol1251_exibir() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol1251_exibir()#
#------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1251c") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1251c AT 05,01 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL pol1251_cons_integ() RETURNING p_status
   
   CLOSE WINDOW w_pol1251c
   
   RETURN p_status

END FUNCTION

#----------------------------#
FUNCTION pol1251_cons_integ()#
#----------------------------#

   INITIALIZE pr_integrado, pr_mesnsagem TO NULL
   
   LET p_query = 
      "SELECT b.dat_confer, a.cod_transpor, a.num_conhec, a.ser_conhec, a.ssr_conhec, ",
      "       a.dat_conhec, a.val_frete, a.val_calculado, a.divergencia, a.motivo ",
      "  FROM conhec_proces_455 a, audit_conhec_455 b ",
      " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
      "   AND b.cod_empresa = a.cod_empresa ",
      "   AND a.id_registro = b.id_cf_proces "

   IF p_tela.transportadora IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.cod_transpor = ", p_tela.transportadora
   END IF

   IF p_tela.conhecimento IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.num_conhec = ",p_tela.conhecimento
   END IF
   
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.dat_conhec >= '",p_tela.dat_ini,"' "
   END IF
   
   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.dat_conhec <= '",p_tela.dat_fim,"' "
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY b.dat_confer, a.cod_transpor, a.dat_conhec  "
   
   PREPARE v_query FROM p_query
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'Erro ',p_erro CLIPPED, ' preparando query' 
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_ind = 1
   INITIALIZE pr_integrado TO NULL
   
   DECLARE cq_integ CURSOR FOR v_query
   FOREACH cq_integ INTO 
           pr_integrado[p_ind].dat_confer,    
           pr_integrado[p_ind].cod_transpor,  
           pr_integrado[p_ind].num_conhec,    
           pr_integrado[p_ind].ser_conhec,    
           pr_integrado[p_ind].ssr_conhec,    
           pr_integrado[p_ind].dat_conhec,    
           pr_integrado[p_ind].val_frete,     
           pr_integrado[p_ind].val_calculado,
           pr_mesnsagem[p_ind].divergencia,
           pr_mesnsagem[p_ind].motivo
           

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_integ')
         RETURN FALSE
      END IF

      SELECT ies_incl_cap
        INTO pr_integrado[p_ind].sit_frete
        FROM frete_sup
       WHERE cod_empresa  = p_cod_empresa
         AND cod_transpor = pr_integrado[p_ind].cod_transpor
         AND num_conhec   = pr_integrado[p_ind].num_conhec
         AND ser_conhec   = pr_integrado[p_ind].ser_conhec
         AND ssr_conhec   = pr_integrado[p_ind].ssr_conhec
      
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','frete_sup:cq_integ')
            RETURN FALSE
         END IF
      END IF
            
      LET p_ind = p_ind + 1
   
      IF p_ind > 1000 THEN
         LET p_msg = 'Limite de linhas da grade ultrapassou.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   IF p_ind = 1 THEN
      LET p_msg = 'Não a dados, para os\n',
                  'parâmetros informados.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   LET p_ind = p_ind - 1
   CALL SET_COUNT(p_ind)
   
   DISPLAY ARRAY pr_integrado TO sr_integrado.*
      
      BEFORE ROW
         
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE() 
            
         DISPLAY pr_mesnsagem[p_ind].divergencia TO divergencia
         DISPLAY pr_mesnsagem[p_ind].motivo      TO motivo

         LET p_cod_transpor = pr_integrado[p_ind].cod_transpor
         LET p_den_transpor = pol1251_le_den_transpor()
         DISPLAY p_den_transpor TO den_transpor

   END DISPLAY
   
END FUNCTION

#--------------------------------#
FUNCTION pol1251_exibe_calculos()#
#--------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1251d") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1251d AT 08,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1251_le_calculos() 
   
   CLOSE WINDOW w_pol1251d
   
   CURRENT WINDOW IS w_pol1251
      
END FUNCTION

#-----------------------------#
FUNCTION pol1251_le_calculos()#
#-----------------------------#
   DEFINE p_tecla        char(01)
   
   DEFINE p_calculo      RECORD
     val_frete      decimal(12,2),
     val_calculo    decimal(12,2),
     val_tolerancia decimal(12,2),
     val_tabela     decimal(12,2),
     val_pedagio    decimal(12,2),
     tip_cobranca   char(01),        
     peso_minimo    decimal(10,3),
     peso_nf        decimal(10,3),
     qtd_eixo       integer,
     val_ad_valorem decimal(12,2),
     val_gris       decimal(12,2),
     val_despacho   decimal(12,2),
     val_tas        decimal(12,2),
     val_trt        decimal(12,2)
   END RECORD


   LET p_calculo.val_frete = pr_liberar[p_ind].val_frete
   LET p_calculo.val_calculo = pr_liberar[p_ind].val_calculado
   LET p_calculo.val_tolerancia = pr_liberar[p_ind].val_tolerancia
       
   SELECT val_tabela,    
          val_pedagio,   
          tip_cobranca,  
          peso_minimo,   
          peso_nf,       
          qtd_eixo,      
          val_ad_valorem,
          val_gris,      
          val_despacho,  
          val_tas,       
          val_trt       
      INTO p_calculo.val_tabela,    
           p_calculo.val_pedagio,   
           p_calculo.tip_cobranca,  
           p_calculo.peso_minimo,   
           p_calculo.peso_nf,       
           p_calculo.qtd_eixo,      
           p_calculo.val_ad_valorem,
           p_calculo.val_gris,      
           p_calculo.val_despacho,  
           p_calculo.val_tas,       
           p_calculo.val_trt       
     FROM calculo_conhec_455
    WHERE cod_empresa = p_cod_empresa
      AND id_cf_proces = p_id_cf_proces

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','calculo_conhec_455')
      RETURN
   END IF
   
   DISPLAY BY NAME p_calculo.*  
   
   PROMPT "Tecle enter p/ continuar " FOR p_tecla
  
END FUNCTION
