#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0857                                                 #
# OBJETIVO: EXPORTAÇÃO DE ITENS P/ EGA                              #
# AUTOR...: IVO HONÓRIO BARBOSA                                     #
# DATA....: 07/10/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item           LIKE item.cod_item,
          p_qtd_pc_geme        SMALLINT,
          p_qtd_peca_ciclo     INTEGER,
          p_qtd_ciclo_peca     INTEGER,
          p_erro_critico       SMALLINT,
          l_relat              SMALLINT,
          p_last_row           SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_msg                CHAR(500),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_men                CHAR(200),
          l_pes_unit           LIKE item.pes_unit,
          p_txt                CHAR(600)

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
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0857-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0857.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0857_controle()
   END IF
END MAIN


#--------------------------#
 FUNCTION pol0857_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0857") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0857 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Processar" "Processa a exportação dos itens p/ o EGA"
         CALL pol0857_processar() RETURNING p_status
         IF p_status THEN
            LET p_men = 'Exportado no Arquivo: ',p_men CLIPPED
            CALL log0030_mensagem(p_men,"orientation")
            ERROR 'Processamento efetuado com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND KEY ("S") "Sobre" "Exibe a versão do programa"
         CALL pol0857_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0857

END FUNCTION

#---------------------------#
FUNCTION pol0857_processar()
#---------------------------#
  
   DEFINE lr_nf_mestre           RECORD LIKE nf_mestre.*,
          lr_nf_item             RECORD LIKE nf_item.*,
          l_ver_sincr1           CHAR(100),
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
   
   IF NOT log004_confirm(18,35) THEN 
      RETURN FALSE 
   END IF 
   
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


# fim de mensagem de tempo 

    SELECT nom_caminho INTO p_caminho
     FROM pct_ajust_man912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','pct_ajust_man912')
      RETURN FALSE
   END IF

   
   MESSAGE 'Aguarde!... Exportando item:' ATTRIBUTE(REVERSE)
   
 
   LET l_relat = FALSE
   LET p_caminho = p_caminho CLIPPED, "EGAPCNV.TXT"
   LET p_men = p_caminho CLIPPED


   START REPORT pol0857_relat_exp_item TO p_caminho 

   DECLARE cq_it CURSOR FOR
    SELECT cod_item,
           den_item,
           pes_unit
      FROM item
     WHERE cod_empresa = p_cod_empresa
       AND ies_tip_item IN ('F','P')
   
   FOREACH cq_it INTO 
           lr_dados_item.cod_item,
           lr_dados_item.den_item,
           l_pes_unit
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item') 
         RETURN FALSE
      END IF
      
      LET lr_dados_item.peso_unit = l_pes_unit * 100000 
      
      DECLARE cq_operit CURSOR FOR 
       SELECT a.cod_operac, 
              a.qtd_horas,
              a.qtd_pecas_ciclo, 
              a.qtd_horas_setup,
              b.cod_operac_ega
         FROM consumo a, oper_ega_man912 b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_item    = lr_dados_item.cod_item
          AND b.cod_empresa = a.cod_empresa
          AND b.cod_operac  = a.cod_operac
      
      FOREACH cq_operit INTO 
              lr_dados_item.cod_operac,
              lr_dados_item.tmp_de_prod,
              lr_dados_item.pecas_hora,
              lr_dados_item.pecas_setup,
              lr_dados_item.cod_oper_ega

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','Consumo')
            RETURN FALSE
         END IF

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
         LET lr_dados_item.pecas_hora  = lr_dados_item.pecas_hora / p_qtd_pc_geme
         LET lr_dados_item.alarme_rej = 0
         LET lr_dados_item.pecas_hora = lr_dados_item.pecas_hora * 100
         
         LET p_cod_item = lr_dados_item.cod_item
         CALL pol0857_le_ciclo_peca()

         LET lr_dados_item.pecas_operac = p_qtd_peca_ciclo
         LET lr_dados_item.tmp_de_prod  = p_qtd_ciclo_peca

         DISPLAY lr_dados_item.cod_item AT 21,30
           
         OUTPUT TO REPORT pol0857_relat_exp_item()
         
         LET l_relat = TRUE
      
      END FOREACH
      
   END FOREACH  

   FINISH REPORT pol0857_relat_exp_item    
   
   MESSAGE ''
   
   RETURN(l_relat)

END FUNCTION 

#--------------------------------#
FUNCTION pol0857_le_ciclo_peca()
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



#-------------------------------#
 REPORT pol0857_relat_exp_item()
#-------------------------------#
 
                                  
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

#-----------------------#
 FUNCTION pol0857_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION