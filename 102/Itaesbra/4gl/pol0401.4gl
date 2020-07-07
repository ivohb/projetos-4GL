#------------------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO DO LOGIX x EGA                                          #
# PROGRAMA: POL0401                                                            #
# OBJETIVO: EXPORTAÇÃO DO LOGIX x EGA                                          #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 11/11/2005                                                         #
# ALTERADO: 15/07/2008 por Ana Faustino - versao 41                            #
# COMENTARIOS: Tela para exibir os erros da exportação                         #
#              exportar ciclos por peça e peças por ciclos                     #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_user                 LIKE usuario.nom_usuario,
          l_ies_tip_recur        LIKE recurso.ies_tip_recur,
          p_cod_item             LIKE item.cod_item,
          p_num_ordem            LIKE ordens.num_ordem,
          m_num_ordem            LIKE ordens.num_ordem,
          p_dat_abert            LIKE ordens.dat_abert,
          p_cod_operac           LIKE operacao.cod_operac,
          p_dat_ini              LIKE ordens.dat_ini,
          l_qtd_sdo_oper         LIKE ord_oper.qtd_planejada,
          l_num_seq              LIKE consumo.num_seq_operac,
          p_cod_roteiro          LIKE ordens.cod_roteiro,
          p_num_altern_roteiro   LIKE ordens.num_altern_roteiro,         
          p_houve_erro           SMALLINT,
          p_qtd_pc_geme          SMALLINT,
          p_status               SMALLINT,
          p_qtd_peca_ciclo       INTEGER,
          p_qtd_ciclo_peca       INTEGER,
          p_pc_hora              INTEGER,
          p_nom_tela             CHAR(200),
          p_count                SMALLINT,
          p_index                SMALLINT,
          s_index                SMALLINT,
          p_achou_oper           SMALLINT,
          p_msg                  CHAR(500)
          
   DEFINE p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          w_caminho              CHAR(50),
          p_nom_arquivo          CHAR(100),
          p_nom_arquivo_back     CHAR(100),
          g_usa_visualizador     SMALLINT,
          p_ies_multipl_100      CHAR(01)

   DEFINE g_ies_grafico          SMALLINT

    DEFINE p_versao               CHAR(18)

     DEFINE m_den_empresa          LIKE empresa.den_empresa,
            m_consulta_ativa       SMALLINT,
            m_esclusao_ativa       SMALLINT,
            sql_stmt               CHAR(5000),
            where_clause           CHAR(5000),
            comando                CHAR(080),
            m_comando              CHAR(080),
            p_caminho              CHAR(60),
            p_men                  CHAR(100),
            p_txt                  CHAR(600),
            m_caminho              CHAR(150),
            p_last_row             SMALLINT,
            m_processa             SMALLINT,
            m_primeira_vez         SMALLINT, 
            m_arquivo_nf           CHAR(150),
            m_arquivo_ud           CHAR(150),
            m_msg                  CHAR(100),
            p_den_empresa          LIKE empresa.den_empresa

    DEFINE l_relat              SMALLINT,
           l_pes_unit           LIKE item.pes_unit,
           w_operac             decimal(9,0),
           l_hora               CHAR(8)
    
    DEFINE lr_dados_item        RECORD 
                                cod_item          CHAR(26),    
                                den_item          CHAR(40),    
                                cod_operac        CHAR(5),
                                cod_oper_ega      DECIMAL(9,0),   
                                pecas_hora        DECIMAL(10,0),
                                pecas_setup       DECIMAL(3,0), 
                                alarme_rej        DECIMAL(3,0),  
                                pecas_operac      DECIMAL(5,0),
                                peso_unit         DECIMAL(15,0),
                                tmp_de_prod       DECIMAL(3,0)

   END RECORD      

   DEFINE pr_op      ARRAY[900] OF RECORD
          num_ordem  LIKE ordens.num_ordem,
          ies_situa  LIKE ordens.ies_situa,
          cod_item   LIKE ordens.cod_item,
          qtd_saldo  LIKE ordens.qtd_planej
   END RECORD

   DEFINE pr_criticas   ARRAY[1000] OF RECORD
         cod_peca_princ LIKE item.cod_item,
         sdo_princ      LIKE ordens.qtd_planej,
         cod_peca_gemea LIKE item.cod_item,
         sdo_gemea      LIKE ordens.qtd_planej,
         qtd_difer      LIKE ordens.qtd_planej
 END RECORD

   DEFINE pr_erro   ARRAY[1000] OF RECORD
         num_ordem      LIKE ordens.num_ordem,
         den_critica    CHAR(70)
 END RECORD

   DEFINE lr_dados_ordem      RECORD 
             num_ordem           DECIMAL(9,0),
             cod_item            CHAR(26),          
             cod_operac          DECIMAL(9,0),
             cod_maquina         DECIMAL(3,0),
             num_seq_operac      DECIMAL(2,0),
             cod_status          CHAR(2),
             qtd_ordem           DECIMAL(8,0),
             cod_roteiro         LIKE ordens.cod_roteiro,
             num_altern_roteiro  LIKE ordens.num_altern_roteiro
   END RECORD

   
END GLOBALS

MAIN
     LET p_versao = "POL0401-10.02.06"
     WHENEVER ANY ERROR CONTINUE

     SET ISOLATION TO DIRTY READ
     SET LOCK MODE TO WAIT 120

     WHENEVER ANY ERROR STOP

     DEFER INTERRUPT

     CALL log140_procura_caminho("pol.iem") RETURNING m_caminho

     OPTIONS
         PREVIOUS KEY control-b,
         NEXT     KEY control-f,
         INSERT   KEY control-i,
         DELETE   KEY control-e,
         HELP    FILE m_caminho

     CALL log001_acessa_usuario("ESPEC999","")
          RETURNING p_status, p_cod_empresa, p_user
     
     IF  p_status = 0 THEN
         CALL pol0401_controle()
     END IF
 END MAIN

#--------------------------#
 FUNCTION pol0401_controle()
#--------------------------#

   CALL log006_exibe_teclas('01', p_versao)
   CALL log130_procura_caminho("pol0401") RETURNING m_caminho

   OPEN WINDOW w_pol0401 AT 2,2  WITH FORM  m_caminho 
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


   CURRENT WINDOW IS w_pol0401
   DISPLAY p_cod_empresa TO cod_empresa           
            
   MENU 'OPCAO'
       COMMAND 'Cadastrar' 'Cadastra Ordens p/ Exportação'
           HELP 001
           IF pol0401_cadastrar() then
              ERROR 'Cadastro de ordens efetuado com sucesso !!!'
           ELSE
              ERROR 'Operação cancelada !!!'
           END IF
       COMMAND 'Exportar' 'Exporta as Ordens e Produtos p/ Sistema EGA.'
           HELP 002
           MESSAGE ''
           CALL pol0401_exportar() RETURNING p_status
           IF p_status THEN
              SELECT COUNT(num_ordem)
                INTO p_count
                FROM ord_criticada_970
               WHERE cod_empresa = p_cod_empresa
              IF p_count > 0 THEN
                 ERROR 'HOUVE ERRO NA EXPORTAÇÃO'
                 NEXT OPTION 'Erros'
              END IF
           END IF
       COMMAND 'Erros' 'Exibe erros da exportação'
           CALL pol0401_erros()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0401_sobre() 
       COMMAND KEY ("!")
           PROMPT "Digite o comando : " FOR m_comando
           RUN m_comando

       COMMAND 'Fim'       'Retorna ao menu anterior.'
           HELP 008
           EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0401

END FUNCTION

#-----------------------#
FUNCTION pol0401_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----------------------#
FUNCTION pol0401_erros()
#-----------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04013") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04013 AT 4,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_index = 1
   INITIALIZE pr_erro TO NULL
   
   DECLARE cq_erros CURSOR FOR
    SELECT num_ordem,
           den_critica
      FROM ord_criticada_970
     WHERE cod_empresa = p_cod_empresa
  
   FOREACH cq_erros INTO 
           pr_erro[p_index].num_ordem,
           pr_erro[p_index].den_critica
           
      LET p_index = p_index + 1
   
      IF p_index > 100 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH

   IF p_index = 1 THEN
      CALL log0030_mensagem('Não há erros de exportação','excla')
   ELSE   
      CALL SET_COUNT(p_index - 1)
      DISPLAY ARRAY pr_erro TO sr_erro.*
   END IF
   
   CLOSE WINDOW w_pol04013

END FUNCTION

#---------------------------#
FUNCTION pol0401_cadastrar()
#---------------------------# 

   IF pol0401_aceita_itens() THEN
      IF pol0401_grava_ordens() THEN
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0401_aceita_itens()
#-----------------------------#

   CALL log130_procura_caminho("pol04011") RETURNING m_caminho
   LET m_caminho = m_caminho CLIPPED
   OPEN WINDOW w_pol04011 AT 7,13 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_op CURSOR FOR 
    SELECT num_ordem
      FROM ordens_export_970
     WHERE cod_empresa = p_cod_empresa
   
   LET p_index = 1
   
   FOREACH cq_op INTO pr_op[p_index].num_ordem
 
      CALL pol0401_le_ordem()                 
         
      LET p_index = p_index + 1

      IF p_index > 900 THEN
         ERROR 'Quantidade de linhas da grade ultrapassada !!!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_op
      WITHOUT DEFAULTS FROM sr_op.*
      ATTRIBUTES(INSERT ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      BEFORE FIELD num_ordem
         LET p_num_ordem = pr_op[p_index].num_ordem
         
      AFTER FIELD num_ordem
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_op[p_index].num_ordem IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_op[p_index].num_ordem = p_num_ordem
               NEXT FIELD num_ordem
            END IF
         END IF
         IF pr_op[p_index].num_ordem IS NOT NULL THEN
            IF pol0401_repetiu_cod() THEN
               ERROR "Ordem ",pr_op[p_index].num_ordem," já Informada !!!"
               LET pr_op[p_index].num_ordem = p_num_ordem
               NEXT FIELD num_ordem
            ELSE
               CALL pol0401_le_ordem()
               IF NOT pol0401_consiste_ordem() THEN
                  NEXT FIELD num_ordem
               END IF
               DISPLAY pr_op[p_index].ies_situa TO sr_op[s_index].ies_situa
               DISPLAY pr_op[p_index].cod_item  TO sr_op[s_index].cod_item
               DISPLAY pr_op[p_index].qtd_saldo TO sr_op[s_index].qtd_saldo
            END IF
         END IF
         
   END INPUT 

   CLOSE WINDOW w_pol04011
   CURRENT WINDOW IS w_pol0401
   
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF   
   
END FUNCTION

#--------------------------#
FUNCTION pol0401_le_ordem()
#--------------------------#

   INITIALIZE pr_op[p_index].ies_situa,
              pr_op[p_index].cod_item,
              pr_op[p_index].qtd_saldo,
              p_dat_ini TO NULL

   SELECT ies_situa,
          cod_item,
          dat_ini,
          qtd_planej - qtd_boas - qtd_refug - qtd_sucata
     INTO pr_op[p_index].ies_situa,
          pr_op[p_index].cod_item,
          p_dat_ini,
          pr_op[p_index].qtd_saldo
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = pr_op[p_index].num_ordem


END FUNCTION

#-------------------------------#
FUNCTION pol0401_consiste_ordem()
#-------------------------------#

   IF STATUS <> 0 THEN 
      ERROR "Ordem inexistente !!!"
   ELSE
      IF pr_op[p_index].ies_situa <> '4' THEN
         ERROR "Ordem não está liberada !!!"
      ELSE
         IF pr_op[p_index].qtd_saldo <= 0 THEN
            ERROR "Ordem sem saldo !!!"
         ELSE
            IF p_dat_ini IS NULL THEN
               ERROR "Ordem sem data de início !!!"
            ELSE
               RETURN TRUE
            END IF
         END IF
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0401_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_op[p_ind].num_ordem = pr_op[p_index].num_ordem THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0401_grava_ordens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
   
   WHENEVER ERROR CONTINUE
#   CALL log085_transacao("BEGIN")

   DELETE FROM ordens_export_970
     WHERE cod_empresa = p_cod_empresa

   IF SQLCA.sqlcode <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","ORDENS_EXPORT_970")
#      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   FOR p_ind = 1 TO ARR_COUNT()
   
       IF pr_op[p_ind].num_ordem IS NOT NULL THEN

          INSERT INTO ordens_export_970
          VALUES (p_cod_empresa, pr_op[p_ind].num_ordem)
   
          IF STATUS <> 0 THEN 
             CALL log003_err_sql("INCLUSÃO","ORDENS_EXPORT_970")
#             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
          END IF
          
       END IF
   END FOR
         
#   CALL log085_transacao("COMMIT")	      

   WHENEVER ERROR STOP

   RETURN TRUE
   
END FUNCTION


#--------------------------#
 FUNCTION pol0401_exportar()
#--------------------------# 
   
   DEFINE l_ver_sincr1           CHAR(100),
          l_ver_sincr2           SMALLINT,
          p_hor_atu              DATETIME HOUR TO SECOND,
          p_hor_proces           CHAR(08),
          p_h_m_s                CHAR(10),
          p_time                 DATETIME HOUR TO SECOND,
          p_qtd_segundo          INTEGER,
          p_data                 DATETIME YEAR TO DAY,
          p_hora                 DATETIME HOUR TO SECOND,
          p_processa             SMALLINT,
          p_encontrou            SMALLINT,
          p_hh                   INTEGER,
          p_mm                   INTEGER,
          p_ss                   INTEGER,
          p_ht                   CHAR(02),
          p_mt                   CHAR(02),
          p_st                   CHAR(02),
          p_hoje                 DATE

   LET p_processa = FALSE
   LET p_encontrou = FALSE
   LET p_hor_atu = CURRENT HOUR TO SECOND
   
   DECLARE cq_audit CURSOR FOR
    SELECT data,
           hora
      FROM audit_logix
     WHERE cod_empresa  = p_cod_empresa
       AND num_programa = 'pol0401'
     ORDER BY data desc, hora DESC

   FOREACH cq_audit INTO p_data, p_hora
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_audit')
         RETURN FALSE
      END IF

      LET p_encontrou = TRUE

  
      IF p_hora > p_hor_atu THEN
         LET p_h_m_s = '24:00:00' - (p_hora - p_hor_atu)
      ELSE
         LET p_h_m_s = (p_hor_atu - p_hora)
      END IF
   
      LET p_hor_proces = p_h_m_s[2,9]
   
      LET p_hh = p_hor_proces[1,2]
      LET p_mm = p_hor_proces[4,5]
      LET p_ss = p_hor_proces[7,8]
      
      LET p_qtd_segundo = (p_hh * 3600) + (p_mm * 60) + p_ss
         
      IF p_qtd_segundo > 120 THEN
         LET p_processa = TRUE
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   IF p_encontrou THEN
      IF NOT p_processa THEN
         LET p_txt = 'Tempo da exportação anterior','\n',
                     'inferior a 2 minuto. ','\n',
                     'Processamento anterior: ',p_hora,'\n',
                     'Processamento    atual: ',p_hor_atu,'\n',
                     'Tempo       percorrido: ',p_qtd_segundo,' seg.','\n'
         CALL log0030_mensagem(p_txt,"excla")
         RETURN FALSE
      END IF
   END IF 
   
   LET p_hoje = TODAY
   LET p_hor_proces = p_hor_atu
   LET p_men = 'EXPORTACAO DE ORDENS P/ EGA'
   INSERT INTO audit_logix
    VALUES(p_cod_empresa,
           p_men,
           'pol0401',
           p_hoje,
           p_hor_proces,
           p_user)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_logix')
      RETURN FALSE
   END IF

   DELETE FROM ord_criticada_970
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ord_criticada_970')
      RETURN FALSE
   END IF
      
   INITIALIZE p_caminho TO NULL
   
   SELECT nom_caminho,
          ies_multipl_100
     INTO w_caminho,
          p_ies_multipl_100
     FROM pct_ajust_man912
    WHERE cod_empresa = p_cod_empresa
   
#   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE

   LET p_houve_erro = FALSE
   
   IF pol0401_exporta_ordens() THEN
      IF pol0401_exporta_item() THEN
         IF pol0401_delete_ops() THEN
            LET p_men = 'Exportado nos Arquivos: ',p_men CLIPPED
            CALL log0030_mensagem(p_men,"orientation")
            IF LENGTH(pr_criticas[1].cod_peca_princ) > 0 THEN
                CALL pol0401_exibe_criticas()
            END IF
         ELSE
            LET p_houve_erro = TRUE
         END IF   
      ELSE
         LET p_houve_erro = TRUE
      END IF   
   END IF

   IF p_houve_erro THEN
#      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
#      CALL log085_transacao("COMMIT")
      RETURN TRUE
   END IF      
   
END FUNCTION 

#----------------------------#
FUNCTION pol0401_delete_ops()
#----------------------------#

   DELETE FROM ordens_export_970
    WHERE cod_empresa = p_cod_empresa
    
   IF SQLCA.sqlcode <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","ORDENS_EXPORT_970")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0401_exibe_criticas()
#-------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol04012") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol04012 AT 4,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY pr_criticas TO sr_criticas.*

   CLOSE WINDOW w_pol04012
   
END FUNCTION

#----------------------------#
FUNCTION pol0401_le_roteiro()      #Ivo - 14/02/11
#----------------------------#
   
   SELECT cod_roteiro,
          num_altern_roteiro
     INTO p_cod_roteiro,
          p_num_altern_roteiro
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Lendo','ordens:roteiro')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
 FUNCTION pol0401_exporta_item()
#------------------------------#
    
    MESSAGE "Processando exportação Itens..." ATTRIBUTE(REVERSE)  
   
    INITIALIZE p_caminho TO NULL

    LET l_hora = CURRENT HOUR TO SECOND
    LET l_hora = l_hora[1,2],l_hora[4,5], l_hora[7,8]
    
      INITIALIZE p_caminho TO NULL
      LET p_caminho = w_caminho CLIPPED
      LET p_caminho = p_caminho CLIPPED, "EGAPCNV.TXT"
      LET p_men = p_men CLIPPED," e ", p_caminho CLIPPED

   START REPORT pol0401_relat_exp_item TO p_caminho 
   
   LET m_num_ordem = 0
       
   DECLARE cq_item CURSOR FOR
    SELECT a.num_ordem,
           a.cod_item,
           a.cod_operac,
           b.den_item, 
           b.pes_unit 
      FROM ordens_temp a, item b
     WHERE b.cod_item = a.cod_item
       AND b.cod_empresa  = p_cod_empresa
       AND b.ies_situacao = 'A'
     ORDER BY a.num_ordem
   
   FOREACH cq_item INTO
           p_num_ordem,
           lr_dados_item.cod_item,
           p_cod_operac,
           lr_dados_item.den_item,    
           l_pes_unit
                              
      LET lr_dados_item.peso_unit = l_pes_unit * 100000

      IF NOT pol0401_le_roteiro() THEN   #Ivo - 14/02/11
         RETURN FALSE
      END IF
         
      DECLARE cq_operit CURSOR FOR 
       SELECT a.cod_operac, 
              a.qtd_horas,
              a.qtd_pecas_ciclo, 
              a.qtd_horas_setup,
              b.cod_operac_ega
         FROM consumo a, oper_ega_man912 b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_item    = lr_dados_item.cod_item
          AND a.cod_operac  = p_cod_operac
          AND b.cod_empresa = a.cod_empresa
          AND b.cod_operac  = a.cod_operac
          AND a.cod_roteiro = p_cod_roteiro                #Ivo - 14/02/11
          AND a.num_altern_roteiro = p_num_altern_roteiro  #Ivo - 14/02/11
      
      FOREACH cq_operit INTO lr_dados_item.cod_operac,
                             lr_dados_item.tmp_de_prod,
                             lr_dados_item.pecas_hora,
                             lr_dados_item.pecas_setup,
                             lr_dados_item.cod_oper_ega

         SELECT COUNT(cod_peca_gemea)
           INTO p_qtd_pc_geme
           FROM peca_geme_man912
          WHERE cod_empresa    = p_cod_empresa
            AND cod_peca_princ = lr_dados_item.cod_item
         
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('Lendo','peca_geme_man912')
            RETURN FALSE
         END IF
         
         LET p_qtd_pc_geme = p_qtd_pc_geme + 1
         #LET lr_dados_item.tmp_de_prod = lr_dados_item.tmp_de_prod / p_qtd_pc_geme
         LET lr_dados_item.pecas_hora  = lr_dados_item.pecas_hora / p_qtd_pc_geme
         LET lr_dados_item.alarme_rej = 0
         LET lr_dados_item.pecas_hora = lr_dados_item.pecas_hora * 100
         
         LET p_cod_item = lr_dados_item.cod_item
         CALL pol0401_le_ciclo_peca()

         LET lr_dados_item.pecas_operac = p_qtd_peca_ciclo
         LET lr_dados_item.tmp_de_prod  = p_qtd_ciclo_peca
         
         OUTPUT TO REPORT pol0401_relat_exp_item(lr_dados_item.*)
      
         INITIALIZE lr_dados_item.* TO NULL

         CALL pol0401_exporta_item_compon()

         EXIT FOREACH

      END FOREACH
      
     { A rotina pol0401_exp_item_oper() serve para gerar dados de itens referente a OP's nas quais o usuário
       trocou a operação original do MAN0214, antes de incluir essa rotina o programa somente enviava 
       itens no arquivo de itens do EGA se a operação da ordem era igual a do MAN0214, se fossem diferentes
       o programa nào enviava gerando mensagem de erro no EGA }      
      
      IF lr_dados_item.cod_operac IS NULL THEN 
         CALL pol0401_exp_item_oper()
      END IF   
       
       
      INITIALIZE lr_dados_item.* TO NULL
      
   END FOREACH  

   FINISH REPORT pol0401_relat_exp_item    
    
   RETURN(l_relat)

END FUNCTION 

#-------------------------------------#
FUNCTION pol0401_exporta_item_compon()
#-------------------------------------#

   IF m_num_ordem = p_num_ordem THEN
      RETURN
   END IF
   
   LET m_num_ordem = p_num_ordem

   DECLARE cq_item_compon CURSOR FOR
    SELECT DISTINCT a.cod_item_compon, b.den_item, b.pes_unit
      FROM ord_compon a, item b
     WHERE a.cod_empresa  = p_cod_empresa
       AND a.num_ordem    = p_num_ordem
       AND b.cod_empresa  = a.cod_empresa
       AND b.cod_item     = a.cod_item_compon
       AND b.ies_situacao = 'A'

   FOREACH cq_item_compon 
           INTO lr_dados_item.cod_item,
                lr_dados_item.den_item,    
                l_pes_unit
                         
      LET lr_dados_item.peso_unit = l_pes_unit * 100000
      LET lr_dados_item.cod_oper_ega  = 0
      LET lr_dados_item.pecas_hora  = 0
      LET lr_dados_item.pecas_setup = 0
      LET lr_dados_item.alarme_rej = 0

      LET p_cod_item = lr_dados_item.cod_item
      CALL pol0401_le_ciclo_peca()
      LET lr_dados_item.pecas_operac = p_qtd_peca_ciclo
      LET lr_dados_item.tmp_de_prod  = p_qtd_ciclo_peca
         
      OUTPUT TO REPORT pol0401_relat_exp_item(lr_dados_item.*)
         
   END FOREACH
      

END FUNCTION

#------------------------------#
FUNCTION pol0401_exp_item_oper()
#------------------------------#

      DECLARE cq_operit2 CURSOR FOR 
       SELECT a.cod_operac, 
              a.qtd_horas,
              (1/a.qtd_horas),  
              a.qtd_horas_setup,
              b.cod_operac_ega
         FROM ord_oper a, oper_ega_man912 b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_item    = lr_dados_item.cod_item
          AND a.cod_operac  = p_cod_operac
          AND b.cod_empresa = a.cod_empresa
          AND b.cod_operac  = a.cod_operac
          AND a.num_ordem   = p_num_ordem
      
      FOREACH cq_operit2 INTO lr_dados_item.cod_operac,
                              lr_dados_item.tmp_de_prod,
                              lr_dados_item.pecas_hora,
                              lr_dados_item.pecas_setup,
                              lr_dados_item.cod_oper_ega

         SELECT COUNT(cod_peca_gemea)
           INTO p_qtd_pc_geme
           FROM peca_geme_man912
          WHERE cod_empresa    = p_cod_empresa
            AND cod_peca_princ = lr_dados_item.cod_item
         
         LET p_qtd_pc_geme = p_qtd_pc_geme + 1
         #LET lr_dados_item.tmp_de_prod = lr_dados_item.tmp_de_prod / p_qtd_pc_geme
         LET lr_dados_item.pecas_hora  = lr_dados_item.pecas_hora / p_qtd_pc_geme
         LET lr_dados_item.alarme_rej = 0
         LET lr_dados_item.pecas_hora = lr_dados_item.pecas_hora * 100

         LET p_cod_item = lr_dados_item.cod_item
         CALL pol0401_le_ciclo_peca()

         LET lr_dados_item.pecas_operac = p_qtd_peca_ciclo
         LET lr_dados_item.tmp_de_prod  = p_qtd_ciclo_peca
         
         OUTPUT TO REPORT pol0401_relat_exp_item(lr_dados_item.*)
      
         INITIALIZE lr_dados_item.* TO NULL

         CALL pol0401_exporta_item_compon()

         EXIT FOREACH

      END FOREACH
      

END FUNCTION      
#------------------------------------------------#
 REPORT pol0401_relat_exp_item(lr_dados_item)
#------------------------------------------------#
   DEFINE lr_dados_item        RECORD 
      cod_item              CHAR(26),    
      den_item              CHAR(40),
      cod_operac            CHAR(5),    
      cod_oper_ega          DECIMAL(3,0),   
      pecas_hora            DECIMAL(10,0), 
      pecas_setup           DECIMAL(3,0), 
      alarme_rej            DECIMAL(3,0),    
      pecas_operac          DECIMAL(5,0),
      peso_unit             DECIMAL(10,0),
      tmp_de_prod           DECIMAL(3,0)
                                END RECORD 
                                  
    OUTPUT LEFT   MARGIN 0  
           TOP    MARGIN 0  
           BOTTOM MARGIN 0
           PAGE   LENGTH 1
    
    FORMAT 
       ON EVERY ROW 
          PRINT COLUMN 001, lr_dados_item.cod_item,
                COLUMN 027, lr_dados_item.den_item[1,40],
                COLUMN 067, lr_dados_item.cod_oper_ega USING '&&&&&&&&&',
                COLUMN 076, lr_dados_item.pecas_hora USING '&&&&&&&&&&', 
                COLUMN 086, lr_dados_item.pecas_setup USING '&&&',
                COLUMN 089, lr_dados_item.alarme_rej USING '&&&',
                COLUMN 092, lr_dados_item.pecas_operac USING '&&&&&',
                COLUMN 097, lr_dados_item.peso_unit USING '&&&&&&&&&&',
                COLUMN 107, lr_dados_item.tmp_de_prod USING '&&&'
          
END REPORT 

#--------------------------------#
 FUNCTION pol0401_exporta_ordens()
#--------------------------------#

   DEFINE l_cont                 INTEGER,
          l_cod_arranjo          LIKE rec_arranjo.cod_arranjo,
          l_cod_recur            LIKE rec_arranjo.cod_recur,
          l_hora                 CHAR(8),
          l_cod_operac           LIKE ord_oper.cod_operac,
          p_exportou             SMALLINT
           

   INITIALIZE pr_criticas TO NULL
   LET p_index = 0

   DROP TABLE ordens_temp;

   CREATE TEMP TABLE ordens_temp
   (
      num_ordem    INTEGER,
      cod_item     CHAR(15),
      cod_operac   CHAR(05)
   );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","ordens_temp")
      RETURN FALSE
   END IF
   
   MESSAGE "Processando exportação Ordens..." ATTRIBUTE(REVERSE)  

   LET l_relat = FALSE

   INITIALIZE p_caminho TO NULL
   
   LET l_hora = CURRENT HOUR TO SECOND
   LET l_hora = l_hora[1,2],l_hora[4,5], l_hora[7,8]
    
   INITIALIZE p_caminho, p_men TO NULL
   LET p_caminho = w_caminho CLIPPED
   LET p_caminho = p_caminho CLIPPED, "EGAOFNV.TXT"
   LET p_men = p_caminho CLIPPED

   START REPORT pol0401_relat_ordem TO p_caminho 
   
   DECLARE cq_dados_op CURSOR FOR 
    SELECT a.num_ordem,
           a.cod_item,
           a.cod_roteiro,
           a.num_altern_roteiro,
           a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata
      FROM ordens a
     WHERE (a.cod_empresa = p_cod_empresa
             AND a.ies_situa   = '4'
             AND a.dat_ini IS NULL
             AND a.qtd_planej>(a.qtd_boas + a.qtd_refug + a.qtd_sucata))
             OR
           (a.num_ordem in (select b.num_ordem from ordens_export_970 b
                              where b.cod_empresa = a.cod_empresa
                                AND a.qtd_planej>(a.qtd_boas + a.qtd_refug + a.qtd_sucata)))
       ORDER BY a.num_ordem
                        
   FOREACH cq_dados_op INTO lr_dados_ordem.num_ordem,
                            lr_dados_ordem.cod_item,
                            lr_dados_ordem.cod_roteiro,
                            lr_dados_ordem.num_altern_roteiro,
                            lr_dados_ordem.qtd_ordem
      
     LET p_num_ordem = lr_dados_ordem.num_ordem   #Ivo - 14/02/11
     
     SELECT UNIQUE num_ordem
       FROM ord_apontada_912
      WHERE num_ordem   = lr_dados_ordem.num_ordem
        AND cod_empresa = p_cod_empresa
      
     IF STATUS = 0 THEN
        CONTINUE FOREACH
     END IF

      SELECT UNIQUE cod_empresa
        FROM peca_geme_man912
       WHERE cod_empresa = p_cod_empresa
         AND cod_peca_gemea = lr_dados_ordem.cod_item

      IF STATUS = 0 THEN 
         CONTINUE FOREACH
      END IF
      
      SELECT COUNT(cod_peca_gemea)
        INTO p_qtd_pc_geme
        FROM peca_geme_man912
       WHERE cod_empresa    = p_cod_empresa
         AND cod_peca_princ = lr_dados_ordem.cod_item
      
      IF p_qtd_pc_geme > 0 THEN
         IF NOT pol0401_checa_saldos(lr_dados_ordem.cod_item) THEN
            CONTINUE FOREACH
         END IF
      END IF
      
      LET p_exportou = FALSE      
      LET lr_dados_ordem.cod_status = '00'
      LET p_achou_oper = FALSE
      
      DECLARE cq_operacoes CURSOR FOR                  
       SELECT cod_operac, 
              num_seq_operac, 
              cod_arranjo,
              qtd_planejada - qtd_boas - qtd_refugo - qtd_sucata
         FROM ord_oper
        WHERE cod_empresa     = p_cod_empresa
          AND num_ordem       = lr_dados_ordem.num_ordem
          AND ies_apontamento = 'S'
      
      FOREACH cq_operacoes INTO l_cod_operac,
                                lr_dados_ordem.num_seq_operac,
                                l_cod_arranjo,
                                l_qtd_sdo_oper
      
         LET p_achou_oper = TRUE   
         
         IF l_qtd_sdo_oper <= 0 THEN
            LET p_msg = 'OPERACAO:', l_cod_operac, ' SEM SALDO'
            IF NOT pol0401_grava_critica() THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF

         LET l_num_seq = lr_dados_ordem.num_seq_operac
         LET lr_dados_ordem.num_seq_operac = -1
         
         SELECT cod_operac_ega
           INTO lr_dados_ordem.cod_operac
           FROM oper_ega_man912
          WHERE cod_empresa = p_cod_empresa
            AND cod_operac  = l_cod_operac
     
         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'OPERACAO EGA INEXISTENTE P/ OPER LOGIX:',l_cod_operac
            IF NOT pol0401_grava_critica() THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF
          
         INITIALIZE l_ies_tip_recur TO NULL
          
         DECLARE cq_recur CURSOR FOR
          SELECT cod_recur
            FROM rec_arranjo
           WHERE cod_empresa = p_cod_empresa
             AND cod_arranjo = l_cod_arranjo
         
         FOREACH cq_recur INTO l_cod_recur
         
             SELECT ies_tip_recur
                INTO l_ies_tip_recur
             FROM recurso
             WHERE cod_empresa = p_cod_empresa
               AND cod_recur = l_cod_recur
               AND ies_tip_recur = '2'

             IF STATUS = 0 THEN
                EXIT FOREACH
             END IF 
         
         END FOREACH
         
         IF l_ies_tip_recur IS NULL THEN
            LET p_msg = 'ARRANJO:',l_cod_arranjo,'RECURSO NAO CADASTRADO'
            IF NOT pol0401_grava_critica() THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF
           
         SELECT COUNT(*)
           INTO l_cont
           FROM ct_rec_equip
          WHERE cod_empresa = p_cod_empresa
            AND cod_recur   = l_cod_recur
         
         IF l_cont IS NULL OR l_cont = 0 THEN
            LET p_msg = 'RECURSO:',l_cod_recur,'NAO CADASTRADO NA TAB CT_REC_EQUIP'
            IF NOT pol0401_grava_critica() THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF

         LET lr_dados_ordem.cod_maquina = '000'

         CALL pol0401_le_roteiro()     #Ivo - 14/02/11
         
		     LET p_pc_hora = 0
		 
         DECLARE cq_cons CURSOR FOR
         SELECT qtd_pecas_ciclo
           FROM consumo
          WHERE cod_empresa    = p_cod_empresa
            AND cod_item       = lr_dados_ordem.cod_item
            AND cod_operac     = l_cod_operac
            AND num_seq_operac = l_num_seq
            AND cod_roteiro = p_cod_roteiro                  #Ivo - 14/02/11
            AND num_altern_roteiro = p_num_altern_roteiro    #Ivo - 14/02/11
       
         FOREACH cq_cons INTO p_pc_hora
            IF STATUS <> 0 THEN
               CALL log003_err_sql("Lendo","consumo")
               RETURN FALSE
            END IF
            EXIT FOREACH
         END FOREACH
         
         IF p_pc_hora IS NULL THEN
            LET p_pc_hora = 0
         END IF
         
         LET p_qtd_pc_geme = p_qtd_pc_geme + 1
         LET p_pc_hora  = p_pc_hora / p_qtd_pc_geme
         
         IF p_ies_multipl_100 = 'S' THEN
            LET p_pc_hora  = p_pc_hora * 100
         END IF

         LET p_cod_item = lr_dados_ordem.cod_item
         CALL pol0401_le_ciclo_peca()
         
         OUTPUT TO REPORT pol0401_relat_ordem()
         
         LET p_exportou = TRUE
      
         LET l_relat = TRUE

         INSERT INTO ordens_temp
            VALUES(lr_dados_ordem.num_ordem,
                   lr_dados_ordem.cod_item,
                   l_cod_operac)
                   
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","ordens_temp")
            RETURN FALSE
         END IF                                           
         
      END FOREACH

      IF NOT p_achou_oper THEN
         LET p_msg = 'NENHUMA OPERACAO DA OP ESTA MARCADA PARA APONTAMENTO, VERIQUE MAN0593'
         IF NOT pol0401_grava_critica() THEN
            RETURN FALSE
         END IF
      END IF
            
      INITIALIZE lr_dados_ordem.* TO NULL
      
   END FOREACH 
    
   FINISH REPORT pol0401_relat_ordem

   IF NOT l_relat THEN
      ERROR 'NENHUMA ORDEM FOI EXPORTADA'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION 

#--------------------------------#
FUNCTION pol0401_le_ciclo_peca()
#--------------------------------#

   SELECT qtd_ciclo_peca,
          qtd_peca_ciclo
     INTO p_qtd_ciclo_peca,
          p_qtd_peca_ciclo
     FROM ciclo_peca_970
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      LET p_qtd_ciclo_peca = 0
      LET p_qtd_peca_ciclo = 0
   END IF
   
END FUNCTION


#---------------------------------------------#
FUNCTION pol0401_checa_saldos(p_cod_peca_princ)
#---------------------------------------------#

   DEFINE p_sdo_princ      LIKE ordens.qtd_planej,
          p_sdo_gemea      LIKE ordens.qtd_planej,
          p_cod_peca_princ LIKE item.cod_item,
          p_cod_peca_gemea LIKE item.cod_item,
          p_sem_saldo      SMALLINT

   SELECT SUM(a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata)
     INTO p_sdo_princ
     FROM ordens a, 
          ord_oper b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_peca_princ
      AND a.ies_situa   = '4'
      AND b.cod_empresa = a.cod_empresa
      AND b.num_ordem   = a.num_ordem
      AND b.ies_apontamento = 'S'      
   
   IF p_sdo_princ IS NULL THEN
      LET p_sdo_princ = 0
   END IF
   
   LET p_sem_saldo = FALSE
   
   DECLARE cq_gemea CURSOR FOR
    SELECT cod_peca_gemea
      FROM peca_geme_man912
     WHERE cod_empresa    = p_cod_empresa
       AND cod_peca_princ = p_cod_peca_princ

   FOREACH cq_gemea INTO p_cod_peca_gemea
   
      SELECT SUM(a.qtd_planej - a.qtd_boas - a.qtd_refug - a.qtd_sucata)
        INTO p_sdo_gemea
        FROM ordens a, 
             ord_oper b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_cod_peca_gemea
         AND a.ies_situa   = '4'
         AND b.cod_empresa = a.cod_empresa
         AND b.num_ordem   = a.num_ordem
         AND b.ies_apontamento = 'S'      

      IF p_sdo_gemea IS NULL THEN
         LET p_sdo_gemea = 0
      END IF
   
      IF p_sdo_princ > p_sdo_gemea THEN
         LET p_index = p_index + 1
         IF p_index > 1000 THEN
            EXIT FOREACH
         END IF
         LET pr_criticas[p_index].cod_peca_princ = p_cod_peca_princ
         LET pr_criticas[p_index].sdo_princ      = p_sdo_princ
         LET pr_criticas[p_index].cod_peca_gemea = p_cod_peca_gemea
         LET pr_criticas[p_index].sdo_gemea      = p_sdo_gemea
         LET pr_criticas[p_index].qtd_difer      = p_sdo_princ - p_sdo_gemea
         LET p_sem_saldo = TRUE
         LET p_msg = 'SALDO DAS GEMEAS < SALDO DA PECA PRINCIPAL'
         IF NOT pol0401_grava_critica() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
   IF p_sem_saldo THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION 

#-------------------------------#
FUNCTION pol0401_grava_critica()
#-------------------------------#

   INSERT INTO ord_criticada_970
    VALUES(p_cod_empresa,
           lr_dados_ordem.num_ordem,
           p_msg)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ord_criticada_970')
     RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
 REPORT pol0401_relat_ordem()
#----------------------------#
                                 
   OUTPUT LEFT   MARGIN 0  
          TOP    MARGIN 0  
          BOTTOM MARGIN 0  
          PAGE   LENGTH 1

   FORMAT ON EVERY ROW 
      
         PRINT COLUMN 001, lr_dados_ordem.num_ordem USING '&&&&&&&&&',
               COLUMN 010, lr_dados_ordem.cod_item,
               COLUMN 036, lr_dados_ordem.cod_operac USING '&&&&&&&&&',
               COLUMN 045, p_pc_hora USING '&&&&&&&&&&',
               COLUMN 055, p_qtd_peca_ciclo USING '&&&&&',
               COLUMN 060, lr_dados_ordem.cod_maquina USING '&&&',  
               COLUMN 063, lr_dados_ordem.num_seq_operac USING '--',
               COLUMN 065, lr_dados_ordem.cod_status,        
               COLUMN 067, lr_dados_ordem.qtd_ordem USING '&&&&&&&&'
                  
END REPORT                  


#------------------FIM DO PROGRAMA BL--------------------#
{ALTERAÇÕES:
24/08/12: multiplicar o valor de p_pc_hora por 100, se o pct_ajust_man912.ies_multipl_100 = 'S'

