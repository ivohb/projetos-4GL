#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1260                                                 #
# OBJETIVO: STATUS POR OPERAÇÃO                                     #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 27/05/14                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_status             SMALLINT
             
END GLOBALS

DEFINE p_last_row           SMALLINT,
       p_opcao              CHAR(01),  
       p_excluiu            SMALLINT,      
       p_6lpp               CHAR(100),    
       p_8lpp               CHAR(100),    
       p_nom_tela           CHAR(200),    
       p_ies_cons           SMALLINT,     
       p_salto              SMALLINT,     
       p_erro_critico       SMALLINT,     
       p_existencia         SMALLINT,     
       p_num_seq            SMALLINT,     
       P_Comprime           CHAR(01),     
       p_descomprime        CHAR(01),     
       p_rowid              INTEGER,      
       p_retorno            SMALLINT,     
       p_index              SMALLINT,     
       s_index              SMALLINT,     
       p_count              SMALLINT,     
       p_houve_erro         SMALLINT,    
       p_msg                CHAR(500),    
       p_query              CHAR(500), 
       where_clause         CHAR(500),
       p_ies_nota           CHAR(01),
       p_num_ar             INTEGER,
       p_dat_atu            DATE,
       p_hor_atu            CHAR(08),
       p_cod_status         CHAR(01),
       p_dat_emis_nf        DATE

DEFINE p_dat_fecha_ult_sup  LIKE par_estoque.dat_fecha_ult_sup,
       p_dat_fecha_fiscal   LIKE par_sup.dat_fecha_ultimo
       
DEFINE pr_notas             ARRAY[3000] OF RECORD
       num_aviso_rec        LIKE nf_sup.num_aviso_rec, 
       num_nf               LIKE nf_sup.num_nf,        
       ser_nf               LIKE nf_sup.ser_nf,        
       dat_emis_nf          LIKE nf_sup.dat_emis_nf,   
       cod_fornecedor       LIKE nf_sup.cod_fornecedor,
       raz_social           LIKE fornecedor.raz_social    
END RECORD

DEFINE p_rodape             RECORD
       dat_entrada_nf       DATE,
       recebto_fiscal       DATE,
       recebto_fisico       DATE,
       cod_operacao         CHAR(06),
       cod_usuario          CHAR(08),
       dat_proces           DATE,
       hor_proces           CHAR(08)
END RECORD

DEFINE p_periodo            RECORD
       dat_ini              DATE,
       dat_fim              DATE
END RECORD

DEFINE p_relat RECORD
  cod_empresa           CHAR(02),
  num_ar                INTEGER, 
  recebto_fiscal        DATE,
  recebto_fisico        DATE,
  cod_usuario           CHAR(08),
  dat_proces            DATE,
  hor_proces            CHAR(08)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1260-10.02.09"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'; LET p_status = 0; LET p_user = 'admlog'

   IF p_status = 0 THEN
      CALL pol1260_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1260_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1260") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1260 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1260_le_param() THEN
      RETURN FALSE
   END IF
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela."
         CALL pol1260_consulta() RETURNING p_status
      COMMAND "Listar" "Listagem dos recebimentos divergentes"
         CALL pol1260_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1260_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1260

END FUNCTION

#-----------------------#
 FUNCTION pol1260_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n",
               "      LOGIX 10.02\n\n",
               "   Autor: Ivo H Barbosa\n\n",
               "   www.grupoaceex.com.br\n\n",
               " ibarbosa@totvspartners.com.br.com\n\n",
               "  (11) 4991-6667   Com.\n",
               "  (11) 9-4179-6633 Vivo\n",
               "  (11) 9-4918-6225 Tim\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1260_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol1260_le_param()#
#--------------------------#

   SELECT dat_fecha_ult_sup
     INTO p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_estoque')
      RETURN FALSE
   END IF
   
   SELECT dat_fecha_ultimo
     INTO p_dat_fecha_fiscal
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','par_sup')
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION   

#---------------------------#
 FUNCTION pol1260_consulta()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1260a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1260a AT 6,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1260_limpa_tela()
   
   CALL pol1260_informar() RETURNING p_status
   CLOSE WINDOW w_pol1260a
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1260_modificar() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1260_informar()#
#--------------------------#
   
   LET INT_FLAG = FALSE
   LET p_ies_nota = 'T'
   
   INPUT p_ies_nota WITHOUT DEFAULTS FROM ies_nota
      
      AFTER INPUT
         IF INT_FLAG THEN
            RETURN FALSE 
         END IF
         
   END INPUT
   
   CONSTRUCT BY NAME where_clause ON 
      nf_sup.dat_emis_nf,
      nf_sup.dat_entrada_nf,
      nf_sup.cod_fornecedor,
      nf_sup.num_aviso_rec, 
      nf_sup.num_nf,        
      nf_sup.ser_nf,        
      nf_sup.ssr_nf,        
      nf_sup.ies_especie_nf

      ON KEY (control-z)
         CALL pol1260_popup()

   END CONSTRUCT
         
   IF INT_FLAG THEN
      RETURN FALSE 
   END IF
      
   LET p_query =
       "SELECT nf_sup.num_aviso_rec, nf_sup.num_nf, nf_sup.ser_nf, nf_sup.dat_emis_nf, ",
       " nf_sup.cod_fornecedor, fornecedor.raz_social FROM nf_sup, fornecedor ",
       " WHERE ", where_clause CLIPPED,
       "   AND nf_sup.cod_empresa = '",p_cod_empresa,"' ",
       "   AND nf_sup.cod_fornecedor = fornecedor.cod_fornecedor "

   IF p_ies_nota = 'T' THEN
      LET p_query = p_query CLIPPED, " AND nf_sup.ies_nf_aguard_nfe = '7' "
   ELSE
      LET p_query = p_query CLIPPED, 
           " AND nf_sup.ies_nf_aguard_nfe <> '7' ",
           " AND nf_sup.num_aviso_rec IN (",
           " SELECT nf_recebida_ronc.num_ar FROM nf_recebida_ronc ",
           "  WHERE nf_recebida_ronc.cod_empresa = '",p_cod_empresa,"')"
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY nf_sup.dat_emis_nf "

   INITIALIZE pr_notas TO NULL
   LET p_index = 1
   
   PREPARE var1_query FROM p_query   
   DECLARE cq_nfe CURSOR WITH HOLD FOR var1_query

   FOREACH cq_nfe INTO 
      pr_notas[p_index].num_aviso_rec, 
      pr_notas[p_index].num_nf,        
      pr_notas[p_index].ser_nf,        
      pr_notas[p_index].dat_emis_nf,   
      pr_notas[p_index].cod_fornecedor,
      pr_notas[p_index].raz_social    

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_nfe')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 3000 THEN
         LET p_msg = 'Limite de linhas da\n grade ultrapassou.'
         CALL log0030_mensagem(p_msg, 'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Não há notas, para os\n parâmetros informados.'
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1260_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1260a
         IF p_codigo IS NOT NULL THEN
            DISPLAY p_codigo TO cod_fornecedor
         END IF

   END CASE 

END FUNCTION 

#---------------------------#
FUNCTION pol1260_modificar()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1260b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1260b AT 3,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1260_exibe_dados() RETURNING p_status
   CLOSE WINDOW w_pol1260b
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1260_exibe_dados()#
#-----------------------------#

   DEFINE p_qtd_linha INTEGER
   
   LET p_qtd_linha = p_index - 1
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_notas
      WITHOUT DEFAULTS FROM sr_notas.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         LET p_num_ar = pr_notas[p_index].num_aviso_rec
         
         IF p_num_ar IS NOT NULL THEN
            IF NOT pol1260_exibe_rodape() THEN
               EXIT INPUT
            END IF
         END IF

      BEFORE FIELD num_aviso_rec
         LET p_num_ar = pr_notas[p_index].num_aviso_rec
         
      AFTER FIELD num_aviso_rec

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_index >= p_qtd_linha THEN
               LET p_num_ar = pr_notas[p_index].num_aviso_rec
               NEXT FIELD num_aviso_rec
            END IF
         END IF                     
      
      ON KEY (control-r)
         IF p_ies_nota = 'T' THEN
            IF pol1260_le_status() THEN
              LET p_dat_emis_nf = pr_notas[p_index].dat_emis_nf
              CALL pol1260_receb_fisico() RETURNING p_status
            END IF
         ELSE
            LET p_msg = 'Essa operação está disponível\n',
                        'somente para NFs em trânsito.'      
            CALL log0030_mensagem(p_msg,'info')         
         END IF

      ON KEY (control-t)
         CALL pol1260_contagem() RETURNING p_status
         
   END INPUT
   
   
   RETURN TRUE

END FUNCTION
      
#------------------------------#
FUNCTION pol1260_exibe_rodape()#
#------------------------------#

   INITIALIZE p_rodape TO NULL
      
   SELECT dat_entrada_nf,
          cod_operacao
     INTO p_rodape.dat_entrada_nf,
          p_rodape.cod_operacao
     FROM nf_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','nf_sup')
      RETURN FALSE
   END IF

   SELECT recebto_fiscal,
          recebto_fisico,
          cod_usuario,   
          dat_proces,    
          hor_proces       
     INTO p_rodape.recebto_fiscal, 
          p_rodape.recebto_fisico, 
          p_rodape.cod_usuario,    
          p_rodape.dat_proces,     
          p_rodape.hor_proces     
     FROM nf_recebida_ronc
    WHERE cod_empresa = p_cod_empresa
      AND num_ar = p_num_ar

   IF STATUS = 100 THEN
      LET p_rodape.recebto_fiscal = p_rodape.dat_entrada_nf
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','nf_recebida_ronc')
         RETURN FALSE
      END IF
   END IF
        
   DISPLAY BY NAME p_rodape.*
   
   RETURN TRUE   

END FUNCTION

#---------------------------#
FUNCTION pol1260_le_status()#
#---------------------------#
   
   SELECT cod_status
     INTO p_cod_status
     FROM status_nf_ronc
    WHERE cod_operacao = p_rodape.cod_operacao

   IF STATUS = 100 THEN
      LET p_msg = ' Operação: ', p_rodape.cod_operacao CLIPPED,
        ' não\n cadastrada no pol1259.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','status_nf_ronc')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE      
   
END FUNCTION

#------------------------------#
FUNCTION pol1260_receb_fisico()#
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1260c") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1260c AT 09,32 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1260_info_data() RETURNING p_status
   CLOSE WINDOW w_pol1260c
   
   IF p_status THEN
      CALL pol1260_exibe_rodape() RETURNING p_status
      DISPLAY BY NAME p_rodape.*
      LET p_msg = 'Operação efetuada\n com sucesso.'
      CALL log0030_mensagem(p_msg,'info')
   END IF
   
   RETURN p_status
   
END FUNCTION

#---------------------------#
FUNCTION pol1260_info_data()#
#---------------------------#
   
   DEFINE p_dat_receb   DATE,
          p_mes_rec     INTEGER,
          p_mes_atu     INTEGER
      
   LET p_dat_receb = p_rodape.recebto_fisico
   
   IF p_dat_receb IS NULL THEN
      LET p_dat_receb = TODAY
   END IF
   
   INPUT p_dat_receb 
      WITHOUT DEFAULTS FROM dat_receb
      
      AFTER FIELD dat_receb
      
         IF p_dat_receb IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD dat_receb
         END IF
         
         IF p_dat_receb > TODAY OR 
               p_dat_receb < p_dat_emis_nf THEN
            LET p_msg = 'Informe uma data entre\n',
                   p_dat_emis_nf, ' e ', TODAY
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD dat_receb
         END IF

         IF p_dat_receb <= p_dat_fecha_ult_sup THEN
            LET p_msg = 'Para essa data, o\n estoque já está fechado.'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD dat_receb
         END IF

         IF p_dat_receb <= p_dat_fecha_fiscal THEN
            LET p_msg = 'Data de entrada da NF\n',
                        'deve ser maior que o\n',
                        'último Fechamento Fiscal.'
            CALL log0030_mensagem(p_msg,'info')
            NEXT FIELD dat_receb
         END IF
         
         LET p_mes_atu = MONTH(TODAY)
         LET p_mes_rec = MONTH(p_dat_receb)
         
         IF p_mes_rec < p_mes_atu THEN
            LET p_msg = 'Mês do recebimento inferior\n',
                        'ao mês de lançamento.\n ',
                        'Confirma a data ',p_dat_receb,'como\n', 
                        'sendo a data do recebimento?'
       	    IF NOT log0040_confirm(20,25,p_msg) THEN
               NEXT FIELD dat_receb
            END IF
         END IF
                        
         
   END INPUT
   
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   END IF
   
   IF p_rodape.recebto_fisico = p_dat_receb THEN
      RETURN TRUE
   END IF
      
   LET p_rodape.recebto_fisico = p_dat_receb
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1260_grava_tabs() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
      
   RETURN TRUE      
   
END FUNCTION

#----------------------------#
FUNCTION pol1260_grava_tabs()#
#----------------------------#

   LET p_rodape.dat_proces = TODAY
   LET p_rodape.hor_proces = TIME
   LET p_rodape.cod_usuario = p_user

   SELECT recebto_fiscal
     FROM nf_recebida_ronc
    WHERE cod_empresa = p_cod_empresa
      AND num_ar = p_num_ar
    
   IF STATUS = 0 THEN
      CALL pol1260_atu_nf_recebida() RETURNING p_status
   ELSE
      IF STATUS = 100 THEN
         CALL pol1260_ins_nf_recebida() RETURNING p_status
      ELSE
         CALL log003_err_sql('SELECT','nf_recebida_ronc')
         RETURN FALSE
      END IF
   END IF   

   IF p_status THEN
      CALL pol1260_atu_nf_sup() RETURNING p_status
   END IF
   
   RETURN p_status

END FUNCTION

#---------------------------------#
FUNCTION pol1260_atu_nf_recebida()#
#---------------------------------#

   UPDATE nf_recebida_ronc
      SET recebto_fisico = p_rodape.recebto_fisico,
          cod_usuario = p_rodape.cod_usuario,
          dat_proces = p_rodape.dat_proces,
          hor_proces = p_rodape.hor_proces          
    WHERE cod_empresa = p_cod_empresa
      AND num_ar = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','nf_recebida_ronc')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1260_ins_nf_recebida()#
#---------------------------------#
         
   INSERT INTO nf_recebida_ronc (
    cod_empresa,   
    num_ar,        
    recebto_fiscal,
    recebto_fisico,
    cod_usuario,   
    dat_proces,    
    hor_proces)
   VALUES(p_cod_empresa,
          p_num_ar,
          p_rodape.recebto_fiscal,
          p_rodape.recebto_fisico,
          p_rodape.cod_usuario,
          p_rodape.dat_proces,
          p_rodape.hor_proces)
        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','nf_recebida_ronc')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
         
#----------------------------#
FUNCTION pol1260_atu_nf_sup()#
#----------------------------#
   
   DEFINE l_ies_especie      CHAR(03)
   
   UPDATE nf_sup
      SET ies_nf_aguard_nfe = p_cod_status,
          dat_entrada_nf = p_rodape.recebto_fisico
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','nf_sup')
      RETURN FALSE
   END IF

   SELECT ies_especie_nf INTO l_ies_especie
     FROM nf_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','nf_sup.ies_especie_nf')
      RETURN FALSE
   END IF
   
   IF l_ies_especie = 'NFR' THEN

      UPDATE avis_rec
         SET ies_situa_ar      =  'E',  
             ies_liberacao_ar  =  '2',
             ies_liberacao_cont=  'N',
             ies_liberacao_insp=  'S',
             ies_diverg_listada=  'S'
       WHERE cod_empresa = p_cod_empresa
         AND num_aviso_rec = p_num_ar
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','avis_rec')
         RETURN FALSE
      END IF
      
   END IF
   
   RETURN TRUE

END FUNCTION
         
#--------------------------#
FUNCTION pol1260_contagem()#
#--------------------------#
   
   DEFINE p_param   CHAR(10)

   LET p_param = p_num_ar
   
   CALL log120_procura_caminho("sup0530") RETURNING comando
   LET comando = comando CLIPPED, " ", p_cod_empresa, " ", p_num_ar, " 0 ", 3760
   RUN comando RETURNING p_status         

END FUNCTION

#------------------------------#
FUNCTION pol1260_info_periodo()#
#------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1260d") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1260d AT 7,15 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   CALL pol1260_enfo_datas() RETURNING p_status
   CLOSE WINDOW w_pol1260d
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1260_enfo_datas()#
#----------------------------#

   INITIALIZE p_periodo TO NULL
   
   INPUT BY NAME p_periodo.*
   
      AFTER INPUT
         IF INT_FLAG THEN
            RETURN FALSE
         ELSE
            IF p_periodo.dat_ini IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD dat_ini
            END IF
            
            IF p_periodo.dat_fim IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD dat_fim
            END IF
   
            IF p_periodo.dat_fim <  p_periodo.dat_ini THEN
               ERROR 'A data final não deve ser menor que a data inicial.'
               NEXT FIELD dat_ini
            END IF
         END IF
   
   END INPUT
   
   RETURN TRUE
   
END FUNCTION   
   
#--------------------------#
 FUNCTION pol1260_listagem()
#--------------------------#     

   DEFINE p_mes_rec     INTEGER,
          p_mes_atu     INTEGER

   IF NOT pol1260_info_periodo() THEN
      LET p_msg = 'Operação cancelada.'
      CALL log0030_mensagem(p_msg,'info')
   		RETURN 
   END IF

   IF NOT pol1260_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1260_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    SELECT * 
      FROM nf_recebida_ronc 
     WHERE cod_empresa = p_cod_empresa 
       AND recebto_fisico < dat_proces
       AND dat_proces >= p_periodo.dat_ini
       AND dat_proces <= p_periodo.dat_fim
     ORDER BY recebto_fisico
   
  
   FOREACH cq_impressao INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      LET p_mes_atu = MONTH(p_relat.dat_proces)
      LET p_mes_rec = MONTH(p_relat.recebto_fisico)
      
      IF p_mes_rec >= p_mes_atu THEN
         CONTINUE FOREACH
      END IF
      
      OUTPUT TO REPORT pol1260_relat() 

      LET p_count = 1
      
   END FOREACH

   CALL pol1260_finaliza_relat()

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1260_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1260_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1260.tmp'
         START REPORT pol1260_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1260_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1260_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1260_finaliza_relat()#
#--------------------------------#

   FINISH REPORT pol1260_relat   

   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

END FUNCTION

#----------------------#
 REPORT pol1260_relat()
#----------------------#
    
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1260",
               COLUMN 010, "RECEBIMENTOS DIVERGENTES - RECEB. < MES LANCAMENTO",
               COLUMN 062, "EMISSAO: ", TODAY USING "dd/mm/yyyy"
         
         PRINT COLUMN 001, ''
         PRINT
         PRINT COLUMN 010, '  NUM AR   RECEB FISICO    PROCESSAMENTO     USUARIO'
         PRINT COLUMN 010, '---------- ------------ -------------------- --------'
      
      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, ''
         PRINT
         PRINT COLUMN 010, '  NUM AR   RECEB FISICO    PROCESSAMENTO     USUARIO'
         PRINT COLUMN 010, '---------- ------------ -------------------- --------'

      ON EVERY ROW

         PRINT COLUMN 010, p_relat.num_ar USING '#########&',
               COLUMN 021, p_relat.recebto_fisico,
               COLUMN 034, p_relat.dat_proces,
               COLUMN 046, p_relat.hor_proces,
               COLUMN 055, p_relat.cod_usuario
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  

#-------------------------------- FIM DE PROGRAMA BL-----------------------------#
