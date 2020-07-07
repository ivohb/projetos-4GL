#------------------------------------------------------------------------------#
# SISTEMA.: CUSTOS                                                             #
# PROGRAMA: POL0156                                                            #
# MODULOS.: POL0156                                                            #
# OBJETIVO: PROGRAMA GRAVA NOS TEMPOS UTILIZADOS O TEMPO PADRAO                #
# AUTOR...: CAIRU  INTERNO                                                     #
# DATA....: 21/05/2001                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa   CHAR(02),
         p_cancel        INTEGER,
         p_num_nf        LIKE wfat_item.num_nff,
         p_ies_processou SMALLINT,
         comando         CHAR(80),
         p_ind           SMALLINT,
         p_leu           CHAR(1),
         p_data          DATE,
         p_ini           CHAR(16),
         p_fim           CHAR(16),
         w_ini           CHAR(16),
         w_fim           CHAR(16),
         p_hora          CHAR(05),
      #  p_versao        CHAR(17),               
         p_versao        CHAR(18),               
         p_apo           RECORD LIKE apo_oper.*,
         p_hapo          RECORD LIKE his_apo_oper.*,
         p_cfp_apms      RECORD LIKE cfp_apms.*,
         p_cfp_appr      RECORD LIKE cfp_appr.*,
         p_cfp_aptm      RECORD LIKE cfp_aptm.*,
         w_cfp_apms      RECORD LIKE cfp_apms.*,
         w_cfp_appr      RECORD LIKE cfp_appr.*,
         w_cfp_aptm      RECORD LIKE cfp_aptm.*,
         p_qtd_horas     LIKE consumo.qtd_horas,
         p_tempo_total   DECIMAL(11,7),
         p_registro      INTEGER,       
         p_pecas_dia     LIKE apo_oper.qtd_boas,
         p_sobrou        LIKE apo_oper.qtd_boas,
         p_horas         DECIMAL(2,0),
         p_minutos       DECIMAL(2,0),
         p_msg           CHAR(500) 

 DEFINE  p_last_row          SMALLINT,
         p_ies_impressao     CHAR(01),
         g_ies_ambiente      CHAR(01),
         p_nom_arquivo       CHAR(100),
         w_comando           CHAR(80),
         p_caminho           CHAR(080)


 DEFINE p_tela          RECORD
                         dat_apo_de      LIKE apo_oper.dat_producao,
                         dat_apo_ate     LIKE apo_oper.dat_producao
                       END RECORD

 DEFINE p_user            LIKE usuario.nom_usuario,
        p_status          SMALLINT,
        p_ies_situa       SMALLINT,
        p_nom_help        CHAR(200),
        p_nom_tela        CHAR(200) 

 DEFINE p_relat         RECORD
                            cod_empresa    LIKE empresa.cod_empresa,
                            num_ordem      LIKE apo_oper.num_ordem,
                            cod_item       LIKE item.cod_item,
                            cod_operac     LIKE apo_oper.cod_operac,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            des_msg        CHAR(050),
                            erro_sql       decimal (4)
                         END RECORD

END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
	LET p_versao = "pol0156-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0156.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

# CALL log001_acessa_usuario("SUPRIMEN")
   CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0156_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0156_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0156") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol01560 AT 7,13 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa intervalo de processamento"
      HELP 001  
      LET int_flag = 0
      MESSAGE ""
      IF pol0156_informa_dados() THEN
         NEXT OPTION "Processar"
      ELSE
         ERROR "Processamento cancelado"
      END IF
    COMMAND "Processar" "Processa alteracao de apontamento"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
        IF log004_confirm(16,30) THEN  
          IF pol0156_processa() THEN
             ERROR "Processamento Efetuado com Sucesso"
             NEXT OPTION "Fim"
          ELSE
             ERROR "Processamento Cancelado"
          END IF
        ELSE
          ERROR "Processamento Cancelado"          
        END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0156_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim" "Sai do programa"
      IF p_ies_processou = FALSE THEN
         ERROR "Funcao deve ser processada"
         NEXT OPTION "Processar"
      ELSE
         EXIT MENU
      END IF
  END MENU
  CLOSE WINDOW w_pol01560
END FUNCTION
#--------------------------------#
 FUNCTION pol0156_informa_dados()
#--------------------------------#
  INITIALIZE p_tela.* TO NULL
  DISPLAY p_cod_empresa TO cod_empresa
  LET p_tela.dat_apo_de  = TODAY
  LET p_tela.dat_apo_ate = TODAY
  INPUT BY NAME p_tela.* WITHOUT DEFAULTS
   AFTER FIELD dat_apo_de
      IF p_tela.dat_apo_de IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD dat_apo_de
      END IF

   AFTER FIELD dat_apo_ate
      IF p_tela.dat_apo_ate IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD dat_apo_ate
      ELSE
         IF p_tela.dat_apo_ate < p_tela.dat_apo_de THEN
            ERROR "Dat_ate nao pode ser menor que Dat_de"
            NEXT FIELD dat_apo_ate
          END IF
      END IF

 END INPUT

 IF int_flag = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
END IF
END FUNCTION
#-----------------------------#
 FUNCTION pol0156_processa()
#-----------------------------#

 WHENEVER ERROR STOP

   LET p_ies_processou = TRUE
   LET p_hora = TIME

  IF log028_saida_relat(17,40) IS NOT NULL THEN
    IF p_ies_impressao = "S" THEN
       IF g_ies_ambiente = "U" THEN
          START REPORT pol0156_relat TO PIPE p_nom_arquivo
       ELSE
          CALL log150_procura_caminho ('LST') RETURNING p_caminho
          LET p_caminho = p_caminho CLIPPED, 'pol0156.tmp'
          START REPORT pol0156_relat TO p_caminho
       END IF
    ELSE
       START REPORT pol0156_relat TO p_nom_arquivo
    END IF
  END IF

  MESSAGE "Processando conversao ..." ATTRIBUTE(REVERSE)

 DECLARE cq_apo  CURSOR FOR 
   SELECT *  
     FROM apo_oper    
    WHERE cod_empresa = "01"           
      AND date(dat_producao) >= p_tela.dat_apo_de
      AND date(dat_producao) <= p_tela.dat_apo_ate
      AND hor_inicio            <> "00:00"             

 FOREACH cq_apo INTO p_apo.* 
  
  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("FOREACH","APO_OPER")
     LET p_ies_situa = 2 
     EXIT FOREACH
  END IF

   LET p_ies_situa = 1 

   DISPLAY " Ordem/seq : " , p_apo.num_ordem,"/",p_apo.num_seq_operac  AT  11,5

   LET p_leu = 'N' 
   LET p_pecas_dia = 0 

     DECLARE cq_cons CURSOR FOR 
         SELECT qtd_horas
           FROM consumo   
          WHERE cod_empresa    = "01"          
            AND cod_item       = p_apo.cod_item 
            AND cod_operac     = p_apo.cod_operac
########    AND num_seq_operac = p_apo.num_seq_operac

     FOREACH cq_cons INTO p_qtd_horas 

        IF sqlca.sqlcode <>  0
           THEN
           LET p_leu = 'N' 
           EXIT FOREACH
        ELSE
           LET p_leu = 'S' 
           EXIT FOREACH        
        END IF

     END FOREACH

  IF p_leu  =  "N" THEN 
###  LET p_ies_situa = 2 
     LET p_relat.num_ordem        =  p_apo.num_ordem
     LET p_relat.cod_operac       =  p_apo.cod_operac
     LET p_relat.num_seq_operac   =  p_apo.num_seq_operac
     LET p_relat.cod_item         =  p_apo.cod_item       
     LET p_relat.des_msg          =  "Operac/seq nao cadastrada na tabela  consumo" 
     LET p_relat.erro_sql         =  sqlca.sqlcode        
     OUTPUT TO REPORT pol0156_relat(p_relat.*)
     CONTINUE FOREACH
  END IF   

  LET p_hapo.*   = p_apo.*

###------ CFP_APTM

  SELECT *
    INTO p_cfp_aptm.*
    FROM cfp_aptm
   WHERE cod_empresa="01" 
     AND num_seq_registro=p_hapo.num_processo
      
    
  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("SELECT","CFP_APTM")
     LET p_ies_situa = 2 
     EXIT FOREACH
  END IF

###------ CFP_APPR

  SELECT *
    INTO p_cfp_appr.*
    FROM cfp_appr
   WHERE cod_empresa="01" 
     AND num_seq_registro=p_hapo.num_processo
      
    
  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("SELECT","CFP_APPR")
     LET p_ies_situa = 2 
     EXIT FOREACH
  END IF

###------ CFP_APMS

  SELECT *
    INTO p_cfp_apms.*
    FROM cfp_apms
   WHERE cod_empresa="01" 
     AND num_seq_registro=p_hapo.num_processo
      
    
  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("SELECT","CFP_APMS")
     LET p_ies_situa = 2 
     EXIT FOREACH
  END IF

  IF p_leu =  "S"   THEN  
     LET p_tempo_total  =  p_qtd_horas * p_apo.qtd_boas

     IF  p_tempo_total    > 23.00   THEN 
         IF pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF  pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF  pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF  pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF  pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF  pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     IF  p_tempo_total    > 23.00   THEN 
         IF  pol0156_inclui_reg()  THEN 
         ELSE
            EXIT FOREACH 
         END IF         
     END IF         

     LET p_horas     = p_tempo_total 
    
     IF  p_horas    > p_tempo_total   THEN 
         LET p_horas    = p_horas    - 1
     END IF 

     LET p_minutos  = ((p_tempo_total - p_horas) * 60)

     LET p_hapo.hor_inicio = "00:00" 
     LET p_hapo.hor_fim = (p_hapo.hor_inicio + p_horas units hour)  

     LET p_hapo.hor_fim = (p_hapo.hor_fim    + p_minutos units minute)  

     LET p_hapo.qtd_horas = p_tempo_total                                 

  END IF 


  UPDATE  apo_oper set  hor_inicio=p_hapo.hor_inicio, 
                           hor_fim=p_hapo.hor_fim, 
                          qtd_boas=p_hapo.qtd_boas, 
                         qtd_horas=p_hapo.qtd_horas
   WHERE cod_empresa='01'   
     AND cod_item=p_apo.cod_item
     AND num_ordem=p_apo.num_ordem
     AND num_processo=p_apo.num_processo

  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("UPDATE", "HIS_APO_OPER")
     LET p_ies_situa = 2 
     EXIT FOREACH
  END IF

###----  atualiza a cfp_appr

  UPDATE cfp_appr SET   qtd_produzidas=p_hapo.qtd_boas,
                        qtd_pecas_boas=p_hapo.qtd_boas
   WHERE cod_empresa="01"  
     AND num_seq_registro=p_cfp_appr.num_seq_registro 


  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("UPDATE","APO_OPER")
     LET p_ies_situa = 2 
     EXIT FOREACH
  END IF

###----  atualiza a cfp_aptm

  LET   w_ini = p_cfp_aptm.hor_ini_periodo 
  LET   w_ini[12,16]=p_hapo.hor_inicio

  LET   w_fim = p_cfp_aptm.hor_fim_periodo 
  LET   w_fim[12,16]=p_hapo.hor_fim    


  UPDATE cfp_aptm SET   hor_ini_periodo=w_ini,             
                        hor_fim_periodo=w_fim,            
                        hor_ini_assumido=w_ini,            
                        hor_fim_assumido=w_fim,    
                        hor_tot_periodo=p_tempo_total,
                        hor_tot_assumido=p_tempo_total
   WHERE cod_empresa="01"  
     AND num_seq_registro=p_cfp_aptm.num_seq_registro 

  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("UPDATE","CFP_APTM")
     LET p_ies_situa = 2 
     EXIT FOREACH
  END IF


END FOREACH

  FINISH REPORT pol0156_relat

  IF p_ies_impressao = "S" AND
     g_ies_ambiente = "W" THEN
     LET w_comando = "lpdos.bat" ,p_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
     RUN w_comando
  END IF


  IF p_ies_impressao = "S" THEN
     MESSAGE "Relatorio impresso com sucesso "  ATTRIBUTE(REVERSE)
  ELSE
     MESSAGE "Relatorio gravado no arquivo ", p_nom_arquivo ATTRIBUTE(REVERSE)
  END IF

  IF p_ies_situa = 1   THEN 
     RETURN TRUE  
  ELSE
     RETURN FALSE 
  END IF

 
END FUNCTION  
#-----------------------------#
 FUNCTION pol0156_inclui_reg()
#-----------------------------#
  
   SELECT MAX(num_processo) 
     INTO p_registro 
     FROM apo_oper
    WHERE cod_empresa='01'  
  
   IF sqlca.sqlcode <>  0
      THEN
      CALL log003_err_sql("SELECT 2","APO_OPER")
   END IF

   LET p_registro = p_registro + 1      

   LET p_tempo_total = p_tempo_total  - 23.00
   LET p_hapo.hor_fim = "23:00" 
   LET p_hapo.hor_inicio = "00:00" 
   LET p_hapo.qtd_horas = 23.00 
   LET p_pecas_dia = (1 / p_qtd_horas) * 23.00    
   LET p_sobrou = p_hapo.qtd_boas  - p_pecas_dia
   LET p_hapo.qtd_boas  = p_pecas_dia     
   LET p_hapo.num_processo   =  p_registro
   INSERT INTO apo_oper   VALUES (p_hapo.*) 

   IF sqlca.sqlcode <>  0
      THEN
      CALL log003_err_sql("INSERT","HIS_APO_OPER")
      RETURN FALSE
   END IF
   
   LET w_cfp_apms.cod_empresa = "01" 
   LET w_cfp_apms.num_seq_registro = p_registro
   LET w_cfp_apms.cod_tip_movto = p_cfp_apms.cod_tip_movto
   LET w_cfp_apms.ies_situa     = p_cfp_apms.ies_situa
   LET w_cfp_apms.dat_producao  = p_hapo.dat_producao
   LET w_cfp_apms.num_ordem     = p_hapo.num_ordem   
   LET w_cfp_apms.cod_equip     = "0"               
   LET w_cfp_apms.cod_ferram    = "0"               
   LET w_cfp_apms.cod_cent_trab = p_hapo.cod_cent_trab
   LET w_cfp_apms.cod_unid_prod = "CAIRU"              
   LET w_cfp_apms.cod_roteiro   = p_hapo.cod_item      
   LET w_cfp_apms.num_altern_roteiro   = 1                           
   LET w_cfp_apms.num_seq_operac       = p_hapo.num_seq_operac       
   LET w_cfp_apms.cod_operacao         = p_hapo.cod_operac           
   LET w_cfp_apms.cod_item             = p_hapo.cod_item                 
   LET w_cfp_apms.num_conta            = " "                         
   LET w_cfp_apms.cod_local            = p_hapo.cod_local            
   LET w_cfp_apms.dat_apontamento      = date(p_hapo.dat_apontamento)      
   LET w_cfp_apms.hor_apontamento      = "09:00:00"                        
   LET w_cfp_apms.nom_usuario_resp     = p_hapo.nom_usuario                

   INSERT INTO cfp_apms   VALUES (w_cfp_apms.*)
   
   IF sqlca.sqlcode <>  0
      THEN
      CALL log003_err_sql("INSERT","HIS_CFP_APMS")
      RETURN FALSE
   END IF

   
   LET w_cfp_aptm.cod_empresa = "01" 
   LET w_cfp_aptm.num_seq_registro = p_registro
   LET w_cfp_aptm.dat_producao     = p_hapo.dat_producao
   LET w_cfp_aptm.cod_turno        = p_hapo.cod_turno     
   LET w_cfp_aptm.ies_periodo      = p_cfp_aptm.ies_periodo
   LET p_ini  = year(p_hapo.dat_producao) using "&&&&", 
                "-", month(p_hapo.dat_producao) using "&&", 
                "-",   day(p_hapo.dat_producao) using "&&",
                " ", p_hapo.hor_inicio    
   LET w_cfp_aptm.hor_ini_periodo  = p_ini                                     
   LET p_fim  = year(p_hapo.dat_producao) using "&&&&", 
                "-", month(p_hapo.dat_producao) using "&&", 
                "-",   day(p_hapo.dat_producao) using "&&",
                " ", p_hapo.hor_fim       
   LET w_cfp_aptm.hor_fim_periodo  = p_fim                                    
   LET w_cfp_aptm.hor_ini_assumido = p_ini                                   
   LET w_cfp_aptm.hor_fim_assumido = p_fim                                    
   LET w_cfp_aptm.hor_tot_periodo  = p_hapo.qtd_horas  
   LET w_cfp_aptm.hor_tot_assumido = p_hapo.qtd_horas  
   
 
   INSERT INTO cfp_aptm   VALUES (w_cfp_aptm.*)
   
   IF sqlca.sqlcode <>  0
      THEN
      CALL log003_err_sql("INSERT","HIS_CFP_APTM")
      RETURN FALSE
   END IF
      

   LET w_cfp_appr.cod_empresa = "01" 
   LET w_cfp_appr.num_seq_registro = p_registro
   LET w_cfp_appr.dat_producao     = p_hapo.dat_producao
   LET w_cfp_appr.cod_turno        = p_hapo.cod_turno     
   LET w_cfp_appr.cod_item         = p_hapo.cod_item             
   LET w_cfp_appr.qtd_ciclos       = 0                           
   LET w_cfp_appr.qtd_produzidas   = p_hapo.qtd_boas             
   LET w_cfp_appr.qtd_pecas_boas   = p_hapo.qtd_boas             
   LET w_cfp_appr.qtd_defeito_real = 0                           
   LET w_cfp_appr.qtd_defeito_padrao = 0                         


   INSERT INTO cfp_appr   VALUES (w_cfp_appr.*)
   
   IF sqlca.sqlcode <>  0
      THEN
      CALL log003_err_sql("INSERT","HIS_CFP_APPR")
      RETURN FALSE
   END IF

   LET p_hapo.qtd_boas  = p_sobrou        
   RETURN TRUE 


END FUNCTION  
#------------------------------#
 REPORT pol0156_relat(p_relat)
#------------------------------#
 DEFINE p_relat         RECORD
                            cod_empresa    LIKE empresa.cod_empresa,
                            num_ordem      LIKE apo_oper.num_ordem,
                            cod_item       LIKE item.cod_item,
                            cod_operac     LIKE apo_oper.cod_operac,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            des_msg        CHAR(050),
                            erro_sql       decimal (4)
                         END RECORD

  OUTPUT LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1
  FORMAT
    PAGE HEADER
      PRINT COLUMN 001, "POL0156",
            COLUMN 043, "LISTAGEM CONSISTENCIA DA CONVERSAO DO APONTAMENTO",
            COLUMN 125, "FL. ", PAGENO USING "####"
      PRINT COLUMN 096, "EXTRAIDO EM ", TODAY USING "dd/mm/yy",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      SKIP 1 LINE
      PRINT COLUMN 001, "     ITEM           ORDEM      OPERAC.   SEQ.    MENSAGEM DE ERRO                                 ERRO SQL  "     

      PRINT COLUMN 001, "---------------  -----------  --------  ------  ------------------------------------------------- ----------" 

    ON EVERY ROW
      PRINT COLUMN 001, p_relat.cod_item,
            COLUMN 019, p_relat.num_ordem,  
            COLUMN 032, p_relat.cod_operac, 
            COLUMN 042, p_relat.num_seq_operac, 
            COLUMN 050, p_relat.des_msg,
            COLUMN 100, p_relat.erro_sql

    ON LAST ROW
      LET p_last_row = true

    PAGE TRAILER
      IF p_last_row = true THEN
         PRINT " "
      ELSE
         PRINT " "
      END IF
END REPORT

#-----------------------#
 FUNCTION pol0156_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION