#------------------------------------------------------------------------------#
# PROGRAMA: POL0157                                                            #
# MODULOS.: POL0157                                                            #
# OBJETIVO: RELACIONA ITENS PENDENTES ENTRE OPERACOES APONTADAS PARA O PERIODO #
# AUTOR...: CAIRU  INTERNO                                                     #
# DATA....: 27/06/2001                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE 
         p_cod_empresa   CHAR(02),
         p_ies_processou SMALLINT,
         comando         CHAR(80),
         p_cancel        CHAR(1),
         p_comprime      CHAR(1),
         p_descomprime   CHAR(1),
         p_ver_tot       CHAR(1),
         p_erro          CHAR(1),
         p_erro2         CHAR(1),
         p_erro3         CHAR(1),
         p_hora          CHAR(05),
      #  p_versao        CHAR(17),               
         p_versao        CHAR(18),               
         p_registro      INTEGER,       
         p_item_ant      LIKE apo_oper.cod_item,
         p_diferenca     LIKE apo_oper.qtd_boas,
         p_qtd_atual     LIKE apo_oper.qtd_boas,
         p_qtd_planejada  DECIMAL(10,03),
         p_qtd_boas       DECIMAL(10,03),
         p_ies_oper_final CHAR(01),       
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

 DEFINE p_apo_oper      RECORD
                            cod_empresa    LIKE apo_oper.cod_empresa,
                            dat_producao   LIKE apo_oper.dat_producao,
                            cod_item       LIKE apo_oper.cod_item,
                            num_ordem      LIKE apo_oper.num_ordem,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_operac     LIKE apo_oper.cod_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust, 
                            qtd_boas       LIKE apo_oper.qtd_boas,
                            qtd_refugo     LIKE apo_oper.qtd_refugo,    
                            cod_tip_movto  LIKE apo_oper.cod_tip_movto
                         END RECORD

 DEFINE t_total_oper    RECORD
                            cod_item       LIKE apo_oper.cod_item,
                            den_item_reduz CHAR(18),
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_operac     LIKE apo_oper.cod_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust, 
                            qtd_ant        LIKE apo_oper.qtd_boas,          
                            qtd_boas       LIKE apo_oper.qtd_boas,
                            ies_oper_final LIKE ord_oper.ies_oper_final
                         END RECORD

 DEFINE p_apo_cairu     RECORD LIKE apo_cairu.*

 DEFINE p_saldo_cairu   RECORD LIKE saldo_cairu.*
 DEFINE p_saldo         RECORD LIKE saldo_cairu.*

 DEFINE t_apo_oper      RECORD
                            cod_empresa    LIKE apo_oper.cod_empresa,
                            dat_producao   LIKE apo_oper.dat_producao,
                            cod_item       LIKE apo_oper.cod_item,
                            num_ordem      LIKE apo_oper.num_ordem,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_operac     LIKE apo_oper.cod_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust, 
                            qtd_boas       LIKE apo_oper.qtd_boas,
                            qtd_refugo     LIKE apo_oper.qtd_refugo,    
                            cod_tip_movto  LIKE apo_oper.cod_tip_movto,
                            ies_oper_final LIKE ord_oper.ies_oper_final
                         END RECORD
 DEFINE p_relat         RECORD
                            cod_empresa    LIKE empresa.cod_empresa,
                            num_ordem      LIKE apo_oper.num_ordem,
                            cod_item       LIKE item.cod_item,
                            cod_operac     LIKE apo_oper.cod_operac,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust,
                            qtd_boas       DECIMAL(10,3)
                         END RECORD

 DEFINE p_relat1        RECORD
                            cod_item       LIKE item.cod_item,
                            cod_operac     LIKE apo_oper.cod_operac,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust,
                            qtd_ant        DECIMAL(10,3),
                            qtd_entrada    DECIMAL(10,3),
                            qtd_atual      DECIMAL(10,3),
                            qtd_diferenca  DECIMAL(10,3),
                            den_item_reduz LIKE item.den_item_reduz 
                         END RECORD

 DEFINE p_total         RECORD
                            cod_item       LIKE item.cod_item,
                            num_ordem      LIKE apo_oper.num_ordem,       
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_operac     LIKE apo_oper.cod_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust,
                            qtd_boas       DECIMAL(10,3),
                            ies_oper_final LIKE ord_oper.ies_oper_final
                        END RECORD

 DEFINE p_total_ant     RECORD
                            cod_item       LIKE apo_oper.cod_item,
                            den_item_reduz CHAR(18),
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_operac     LIKE apo_oper.cod_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust,
                            qtd_ant        LIKE apo_oper.qtd_boas,          
                            qtd_boas       LIKE apo_oper.qtd_boas,
                            ies_oper_final LIKE ord_oper.ies_oper_final
                        END RECORD
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
	LET p_versao = "pol0157-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0157.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       PREVIOUS KEY control-b

# CALL log001_acessa_usuario("SUPRIMEN")
   CALL log001_acessa_usuario("ESPEC999","")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      LET p_ies_processou = FALSE
      CALL pol0157_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0157_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0157") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol01570 AT 7,13 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Informar" "Informa intervalo de processamento"
      HELP 001  
      LET int_flag = 0
      MESSAGE ""
      IF pol0157_informa_dados() THEN
         NEXT OPTION "Processar"
      ELSE
         ERROR "Processamento cancelado"
      END IF
    COMMAND "Processar" "Processa o relatorio"
      HELP 001
      MESSAGE ""
      LET p_ies_situa  = 0
      LET int_flag = 0
        IF log004_confirm(16,30) THEN  
          IF pol0157_processa() THEN
             ERROR "Processamento Efetuado com Sucesso"
             NEXT OPTION "Fim"
          ELSE
             ERROR "Processamento Cancelado"
          END IF
        ELSE
          ERROR "Processamento Cancelado"          
        END IF
     COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol01574_sobre()
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
  CLOSE WINDOW w_pol01570
END FUNCTION
#--------------------------------#
 FUNCTION pol0157_informa_dados()
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
         ELSE
            IF MONTH(p_tela.dat_apo_ate) <> MONTH(p_tela.dat_apo_de) THEN
               ERROR "Mes inicio nao pode ser diferente de fim"
               NEXT FIELD dat_apo_ate
            ELSE
               IF pol0157_ver_total()   THEN 
                  ERROR "Ja existe resumo p/ o periodo, deseja reprocessar ?"
                  IF  log004_confirm(18,38) THEN
                      CALL pol0157_exclui_movto() 
                  ELSE
                      ERROR "Exclusao de movimento cancelada"
                      NEXT FIELD dat_apo_ate
                  END IF
               END IF
            END IF
         END IF
      END IF

 END INPUT

 IF int_flag = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
END IF
END FUNCTION
#---------------------------#
 FUNCTION pol0157_ver_total()
#---------------------------#
 DEFINE  p_num_reg           INTEGER  

 LET p_num_reg = 0 

         SELECT count(*)
           INTO p_num_reg
           FROM apo_cairu 
          WHERE  dat_referencia  >= p_tela.dat_apo_de
            AND  dat_referencia  <= p_tela.dat_apo_ate 

          IF  sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("SELECT","APO_CAIRU")
              RETURN FALSE 
          ELSE
              IF p_num_reg  > 0    THEN 
                 RETURN TRUE  
              ELSE
                 RETURN FALSE 
              END IF 
          END IF 
END FUNCTION
#-----------------------------#
 FUNCTION pol0157_exclui_movto()
#-----------------------------#

##-----EXCLUI A DIFERENCA ENTRE OPERACOES

         DELETE FROM apo_cairu 
          WHERE  dat_referencia  >= p_tela.dat_apo_de
            AND  dat_referencia  <= p_tela.dat_apo_ate 

         IF  sqlca.sqlcode = 0 THEN
             IF  sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("DELETE","APO_CAIRU")
             ELSE
                 MESSAGE " Exclusao efetuada com sucesso. "
                           ATTRIBUTE(REVERSE)
             END IF
         ELSE
             CALL log003_err_sql("EXCLUSAO","APO_CAIRU" )
         END IF

##-----EXCLUI O SALDO ANTERIOR DOS APONTAMENTOS        

         DELETE FROM saldo_cairu 
          WHERE  dat_saldo  >= p_tela.dat_apo_de
            AND  dat_saldo  <= p_tela.dat_apo_ate 

         IF  sqlca.sqlcode = 0 THEN
             IF  sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("DELETE","SALDO_CAIRU")
             ELSE
                 MESSAGE " Exclusao efetuada com sucesso. "
                           ATTRIBUTE(REVERSE)
             END IF
         ELSE
             CALL log003_err_sql("EXCLUSAO","SALDO_CAIRU" )
         END IF
END FUNCTION
#-----------------------------#
 FUNCTION pol0157_processa()
#-----------------------------#

 WHENEVER ERROR STOP

   CALL pol0157_cria_tabelas()  

   LET p_comprime = ascii 15
   LET p_descomprime = ascii 18

   LET p_ies_processou = TRUE
   LET p_hora = TIME

##IF log028_saida_relat(17,40) IS NOT NULL THEN
##  IF p_ies_impressao = "S" THEN
##     IF g_ies_ambiente = "U" THEN
##        START REPORT pol0157_relat TO PIPE p_nom_arquivo
##     ELSE
##        CALL log150_procura_caminho ('LST') RETURNING p_caminho
##        LET p_caminho = p_caminho CLIPPED, 'pol0157.tmp'
##        START REPORT pol0157_relat TO p_caminho
##     END IF
##  ELSE
##     START REPORT pol0157_relat TO p_nom_arquivo
##  END IF
##END IF

## MESSAGE "Processando relatorio ..." ATTRIBUTE(REVERSE)

 IF pol0157_grava_ordem()  THEN 
 ELSE
    LET p_ies_situa = 2 
 END IF       

 CALL pol0157_grava_anterior()

 CALL pol0157_trata_ordem()

 CALL pol0157_imprime_total()

## FINISH REPORT pol0157_relat

   FINISH REPORT pol0157_relat1

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
 FUNCTION pol0157_ver_cancel()
#-----------------------------#

  LET p_cancel = "N" 

  SELECT ies_situa   
    INTO p_cancel  
    FROM ordens 
   WHERE cod_empresa=p_cod_empresa
     AND num_ordem=p_apo_oper.num_ordem 

   IF sqlca.sqlcode = NOTFOUND   THEN 
      SELECT ies_situa   
        INTO p_cancel  
        FROM hist_ordens 
       WHERE cod_empresa=p_cod_empresa
         AND num_ordem=p_apo_oper.num_ordem 
       IF sqlca.sqlcode = NOTFOUND   THEN 
          LET  p_cancel = "N" 
       END IF 
   END IF 
      
   IF p_cancel  =  "9"   THEN 
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF 

END FUNCTION  
#---------------------------------#
 FUNCTION pol0157_grava_anterior()
#---------------------------------#
  
  INITIALIZE p_saldo_cairu.* TO NULL  
 
 WHENEVER ERROR CONTINUE
  DECLARE cq_saldo   CURSOR FOR 
  SELECT *          FROM  saldo_cairu
    WHERE  month(dat_saldo)= ((month(p_tela.dat_apo_ate)) - 1)
     ORDER BY cod_item, num_seq_operac, cod_operac, cod_cent_cust 

    FOREACH cq_saldo INTO  p_saldo_cairu.*

       IF sqlca.sqlcode <>  0
       THEN
          CALL log003_err_sql("FOREACH","SALDO_CAIRU")
          EXIT FOREACH
       END IF

      LET t_total_oper.cod_item         =    p_saldo_cairu.cod_item 

      SELECT den_item_reduz 
        INTO t_total_oper.den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa 
         AND cod_item = t_total_oper.cod_item 
       
      IF sqlca.sqlcode <> 0 THEN
         LET t_total_oper.den_item_reduz = "inexistente" 
      END IF

      LET t_total_oper.num_seq_operac   =    p_saldo_cairu.num_seq_operac
      LET t_total_oper.cod_operac       =    p_saldo_cairu.cod_operac
      LET t_total_oper.qtd_ant          =    p_saldo_cairu.qtd_saldo 
      LET t_total_oper.qtd_boas         =    0                       
      LET t_total_oper.ies_oper_final   =    p_saldo_cairu.ies_oper_final 
      LET t_total_oper.cod_cent_cust    =    p_saldo_cairu.cod_cent_cust    

      INSERT INTO t_total_oper   VALUES (t_total_oper.*)

      IF   sqlca.sqlcode =  -239    
      OR   sqlca.sqlcode =  -100  THEN 
           UPDATE t_total_oper SET qtd_boas=(qtd_boas + p_saldo_cairu.qtd_saldo)
                WHERE        cod_item=p_saldo_cairu.cod_item     
                  AND      cod_operac=p_saldo_cairu.cod_operac
                  AND  num_seq_operac=p_saldo_cairu.num_seq_operac   
                  AND   cod_cent_cust=p_saldo_cairu.cod_cent_cust   
           IF   sqlca.sqlcode <>  0
                THEN
                CALL log003_err_sql("UPDATE","T_TOTAL_OPER ANTERIOR")
                EXIT FOREACH 
           END IF
      ELSE
         IF   sqlca.sqlcode <>  0
            THEN
            CALL log003_err_sql("INSERT","T_TOTAL_OPER ANTERIOR")
            EXIT FOREACH 
         END IF
      END IF

 END FOREACH
 WHENEVER ERROR STOP     

END FUNCTION  
#-----------------------------#
 FUNCTION pol0157_trata_ordem()
#-----------------------------#

   LET p_erro3 = "N" 
   LET p_diferenca  =  0

   INITIALIZE p_total.*, p_total_ant.* TO NULL  

   DECLARE cp_ordem   CURSOR FOR 
     SELECT cod_item , num_ordem, 
        num_seq_operac, cod_operac, cod_cent_cust, SUM(qtd_boas),
        ies_oper_final 	
       FROM t_apo_oper
      WHERE cod_empresa = "01"           
      AND date(dat_producao) >= p_tela.dat_apo_de
      AND date(dat_producao) <= p_tela.dat_apo_ate
      GROUP BY cod_item ,      num_ordem,  num_seq_operac, cod_operac,
               cod_cent_cust,  ies_oper_final
      ORDER BY cod_item ,num_ordem,  num_seq_operac DESC, 
              cod_operac, cod_cent_cust

    FOREACH cp_ordem INTO  p_total.*

       IF sqlca.sqlcode <>  0
       THEN
          CALL log003_err_sql("FOREACH","T_APO_OPER")
          LET p_erro3 = "S" 
          EXIT FOREACH
       END IF

       LET p_relat.cod_item       = p_total.cod_item
       LET p_relat.num_ordem      = p_total.num_ordem    
       LET p_relat.cod_item       = p_total.cod_item       
       LET p_relat.cod_operac     = p_total.cod_operac     
       LET p_relat.num_seq_operac = p_total.num_seq_operac  
       LET p_relat.cod_cent_cust  = p_total.cod_cent_cust   
       LET p_relat.qtd_boas       = p_total.qtd_boas
       CALL pol0157_grava_total()
#####  OUTPUT TO REPORT pol0157_relat(p_relat.*)
       CONTINUE FOREACH

     END FOREACH
               
END FUNCTION  
#-----------------------------#
 FUNCTION pol0157_grava_ordem()
#-----------------------------#
  
 LET p_erro  =  "N" 

 WHENEVER ERROR CONTINUE
 DECLARE cq_ord  CURSOR FOR 
   SELECT   cod_empresa,              
            dat_producao,                              
            cod_item,                                  
            num_ordem,                                 
            num_seq_operac,                             
            cod_operac,                                
            cod_cent_cust,
            qtd_boas,                                  
            qtd_refugo,                                 
            cod_tip_movto
     FROM apo_oper    
    WHERE cod_empresa = p_cod_empresa           
      AND dat_producao >= p_tela.dat_apo_de 
      AND dat_producao <= p_tela.dat_apo_ate
      AND cod_tip_movto<> "E"                
      ORDER BY num_ordem , cod_item , 
               num_seq_operac, cod_operac,
               cod_tip_movto

 FOREACH cq_ord INTO p_apo_oper.* 
  
   IF sqlca.sqlcode <>  0
      THEN
      CALL log003_err_sql("FOREACH","APO_OPER")
      LET p_erro  = "S"  
      EXIT FOREACH
   END IF
 
   IF pol0157_ver_cancel()  THEN 
   ELSE
      CONTINUE FOREACH
   END IF

   DISPLAY " Ordem: " , p_apo_oper.num_ordem AT  11,5          

      SELECT ies_oper_final
        INTO t_apo_oper.ies_oper_final 
        FROM ord_oper
       WHERE num_ordem=p_apo_oper.num_ordem
         AND cod_empresa=p_apo_oper.cod_empresa
         AND cod_item  =p_apo_oper.cod_item    
         AND cod_operac=p_apo_oper.cod_operac  
         AND num_seq_operac=p_apo_oper.num_seq_operac
  
      IF sqlca.sqlcode =  NOTFOUND   THEN 
         SELECT ies_oper_final
           INTO t_apo_oper.ies_oper_final 
           FROM hist_ord_oper
           WHERE      num_ordem=p_apo_oper.num_ordem
             AND    cod_empresa=p_apo_oper.cod_empresa
             AND    cod_item   =p_apo_oper.cod_item    
             AND     cod_operac=p_apo_oper.cod_operac  
             AND num_seq_operac=p_apo_oper.num_seq_operac
          IF sqlca.sqlcode =  NOTFOUND   THEN 
             LET  t_apo_oper.ies_oper_final  = "N"
          END IF 
      END IF   

      LET t_apo_oper.cod_empresa      =    p_apo_oper.cod_empresa               
      LET t_apo_oper.dat_producao     =    p_apo_oper.dat_producao              
      LET t_apo_oper.cod_item         =    p_apo_oper.cod_item 
      LET t_apo_oper.num_ordem        =    p_apo_oper.num_ordem
      LET t_apo_oper.num_seq_operac   =    p_apo_oper.num_seq_operac
      LET t_apo_oper.cod_operac       =    p_apo_oper.cod_operac
      LET t_apo_oper.qtd_boas         =    p_apo_oper.qtd_boas
      LET t_apo_oper.qtd_refugo       =    p_apo_oper.qtd_refugo
      LET t_apo_oper.cod_tip_movto    =    p_apo_oper.cod_tip_movto
      LET t_apo_oper.cod_cent_cust    =    p_apo_oper.cod_cent_cust

      INSERT INTO t_apo_oper   VALUES (t_apo_oper.*)


      IF   sqlca.sqlcode =  -239    
      OR   sqlca.sqlcode =  -100  THEN 
           UPDATE t_apo_oper    SET qtd_boas=(qtd_boas + p_apo_oper.qtd_boas)
                WHERE     cod_empresa=p_apo_oper.cod_empresa
                  AND       num_ordem=p_apo_oper.num_ordem
                  AND      cod_operac=p_apo_oper.cod_operac
                  AND  num_seq_operac=p_apo_oper.num_seq_operac   
                  AND        cod_item=p_apo_oper.cod_item    
                  AND   cod_cent_cust=p_apo_oper.cod_cent_cust    
           IF   sqlca.sqlcode <>  0
                THEN
                CALL log003_err_sql("UPDATE","T_APO_OPER")
                LET p_erro  =  "S" 
                EXIT FOREACH 
           END IF
      ELSE
         IF   sqlca.sqlcode <>  0
            THEN
            CALL log003_err_sql("INSERT","T_APO_OPER")
            LET p_erro  =  "S" 
            EXIT FOREACH 
         END IF
      END IF
      
 END FOREACH

 WHENEVER ERROR STOP     

  IF p_erro    =   "N"   THEN 
      RETURN TRUE
  ELSE
      RETURN FALSE
  END IF 
 
END FUNCTION  
#-----------------------------#
 FUNCTION pol0157_grava_total()
#-----------------------------#

 WHENEVER ERROR CONTINUE
      LET t_total_oper.cod_item         =    p_total.cod_item 
      LET t_total_oper.num_seq_operac   =    p_total.num_seq_operac
      LET t_total_oper.cod_operac       =    p_total.cod_operac
      LET t_total_oper.qtd_ant          =    0                       
      LET t_total_oper.qtd_boas         =    p_total.qtd_boas
      LET t_total_oper.ies_oper_final   =    p_total.ies_oper_final
      LET t_total_oper.cod_cent_cust    =    p_total.cod_cent_cust    

      INSERT INTO t_total_oper   VALUES (t_total_oper.*)

      IF   sqlca.sqlcode =  -239    
      OR   sqlca.sqlcode =  -100  THEN 
           UPDATE t_total_oper    SET qtd_boas=(qtd_boas + p_total.qtd_boas)
                WHERE        cod_item=p_total.cod_item     
                  AND      cod_operac=p_total.cod_operac
                  AND  num_seq_operac=p_total.num_seq_operac   
                  AND   cod_cent_cust=p_total.cod_cent_cust   
           IF   sqlca.sqlcode <>  0
                THEN
                CALL log003_err_sql("UPDATE","T_TOTAL_OPER")
           END IF
      ELSE
         IF   sqlca.sqlcode <>  0
            THEN
            CALL log003_err_sql("INSERT","T_TOTAL_OPER")
         END IF
      END IF

 WHENEVER ERROR STOP    
END FUNCTION  
#--------------------------------#
 FUNCTION pol0157_imprime_total()
#--------------------------------#

  IF log028_saida_relat(17,40) IS NOT NULL THEN
    IF p_ies_impressao = "S" THEN
       IF g_ies_ambiente = "U" THEN
          START REPORT pol0157_relat1 TO PIPE p_nom_arquivo
       ELSE
          CALL log150_procura_caminho ('LST') RETURNING p_caminho
          LET p_caminho = p_caminho CLIPPED, 'pol01571.tmp'
          START REPORT pol0157_relat1 TO p_caminho
       END IF
    ELSE
       START REPORT pol0157_relat1 TO p_nom_arquivo
    END IF
  END IF

 MESSAGE "Processando resumo ..." ATTRIBUTE(REVERSE)


 DECLARE cq_total   CURSOR FOR 
  SELECT    cod_item       ,                       
            den_item_reduz ,                            
            num_seq_operac ,                            
            cod_operac     ,                              
            cod_cent_cust  ,                             
            qtd_ant        ,                                
            qtd_boas       ,                             
            ies_oper_final                              
    FROM t_total_oper 
  ORDER BY 1, 2 desc, 3, 4       
  
 FOREACH cq_total INTO t_total_oper.*                          

  IF sqlca.sqlcode <>  0
     THEN
     CALL log003_err_sql("FOREACH","T_TOTAL_OPER")
     EXIT FOREACH
  END IF

  LET p_qtd_atual = t_total_oper.qtd_ant + t_total_oper.qtd_boas

  IF t_total_oper.cod_item   = p_total_ant.cod_item   THEN 
     LET p_diferenca  =  (t_total_oper.qtd_boas + t_total_oper.qtd_ant) 
                       - (p_total_ant.qtd_boas  + p_total_ant.qtd_ant)

     IF p_diferenca  =   0   THEN
        LET p_relat1.cod_item       = t_total_oper.cod_item
        LET p_relat1.den_item_reduz = t_total_oper.den_item_reduz
        LET p_relat1.cod_operac     = t_total_oper.cod_operac     
        LET p_relat1.num_seq_operac = t_total_oper.num_seq_operac  
        LET p_relat1.cod_cent_cust  = t_total_oper.cod_cent_cust   
        LET p_relat1.qtd_ant        = t_total_oper.qtd_ant 
        LET p_relat1.qtd_entrada    = t_total_oper.qtd_boas
        LET p_relat1.qtd_atual      = p_qtd_atual           
        LET p_relat1.qtd_diferenca  = p_diferenca  
        OUTPUT TO REPORT pol0157_relat1(p_relat1.*)
        LET p_total_ant.* = t_total_oper.*
        CALL pol0157_grava_saldo()
        CONTINUE FOREACH
     ELSE
        LET p_relat1.cod_item       = t_total_oper.cod_item
        LET p_relat1.den_item_reduz = t_total_oper.den_item_reduz
        LET p_relat1.cod_operac     = t_total_oper.cod_operac     
        LET p_relat1.num_seq_operac = t_total_oper.num_seq_operac  
        LET p_relat1.cod_cent_cust  = t_total_oper.cod_cent_cust   
        LET p_relat1.qtd_ant        = t_total_oper.qtd_ant 
        LET p_relat1.qtd_entrada    = t_total_oper.qtd_boas
        LET p_relat1.qtd_atual      = p_qtd_atual           
        LET p_relat1.qtd_diferenca  = p_diferenca  
        OUTPUT TO REPORT pol0157_relat1(p_relat1.*)
        LET p_total_ant.* = t_total_oper.*
        CALL pol0157_grava_saldo()
        CALL pol0157_grava_tot_cairu()
        CONTINUE FOREACH
      END IF
  ELSE
      IF  t_total_oper.ies_oper_final  <>   "S"   THEN 
          LET p_relat1.cod_item       = t_total_oper.cod_item       
          LET p_relat1.den_item_reduz = t_total_oper.den_item_reduz
          LET p_relat1.cod_operac     = t_total_oper.cod_operac     
          LET p_relat1.num_seq_operac = t_total_oper.num_seq_operac  
          LET p_relat1.cod_cent_cust  = t_total_oper.cod_cent_cust   
          LET p_relat1.qtd_ant        = t_total_oper.qtd_ant 
          LET p_relat1.qtd_entrada    = t_total_oper.qtd_boas
          LET p_relat1.qtd_atual      = p_qtd_atual           
          LET p_relat1.qtd_diferenca  = p_qtd_atual
          OUTPUT TO REPORT pol0157_relat1(p_relat1.*)
          LET p_total_ant.* = t_total_oper.*
          CALL pol0157_grava_saldo()
          CALL pol0157_grava_tot_cairu()
          CONTINUE FOREACH   
      ELSE 
          LET p_relat1.cod_item       = t_total_oper.cod_item       
          LET p_relat1.den_item_reduz = t_total_oper.den_item_reduz
          LET p_relat1.cod_operac     = t_total_oper.cod_operac     
          LET p_relat1.num_seq_operac = t_total_oper.num_seq_operac  
          LET p_relat1.cod_cent_cust  = t_total_oper.cod_cent_cust   
          LET p_relat1.qtd_ant        = t_total_oper.qtd_ant 
          LET p_relat1.qtd_entrada    = t_total_oper.qtd_boas
          LET p_relat1.qtd_atual      = p_qtd_atual           
          LET p_relat1.qtd_diferenca  = 0                     
          OUTPUT TO REPORT pol0157_relat1(p_relat1.*)
          LET p_total_ant.* = t_total_oper.*
          CALL pol0157_grava_saldo()
          CONTINUE FOREACH   
      END IF
   END IF

 END FOREACH

END FUNCTION  
#-----------------------------#
 FUNCTION pol0157_grava_saldo()
#-----------------------------#
 WHENEVER ERROR CONTINUE
      LET p_saldo.cod_item         =    t_total_oper.cod_item 
      LET p_saldo.dat_saldo        =    p_tela.dat_apo_ate
      LET p_saldo.num_seq_operac   =    t_total_oper.num_seq_operac
      LET p_saldo.cod_operac       =    t_total_oper.cod_operac
      LET p_saldo.cod_cent_cust    =    t_total_oper.cod_cent_cust    
      LET p_saldo.ies_oper_final   =    t_total_oper.ies_oper_final   
      LET p_saldo.qtd_saldo        =    p_qtd_atual            

      INSERT INTO saldo_cairu      VALUES (p_saldo.*)


     IF   sqlca.sqlcode <>  0
          THEN
          CALL log003_err_sql("INSERT","SALDO_CAIRU")
     END IF

 WHENEVER ERROR STOP    

END FUNCTION  
#----------------------------------#
 FUNCTION pol0157_grava_tot_cairu()
#----------------------------------#

 WHENEVER ERROR CONTINUE
      LET p_apo_cairu.cod_item         =    t_total_oper.cod_item 
      LET p_apo_cairu.dat_referencia   =    p_tela.dat_apo_ate
      LET p_apo_cairu.num_seq_operac   =    t_total_oper.num_seq_operac
      LET p_apo_cairu.cod_operac       =    t_total_oper.cod_operac
      LET p_apo_cairu.cod_cent_cust    =    t_total_oper.cod_cent_cust    
      LET p_apo_cairu.qtd_diferenca    =    p_diferenca            

      INSERT INTO apo_cairu      VALUES (p_apo_cairu.*)


      IF   sqlca.sqlcode =  -239    
      OR   sqlca.sqlcode =  -100  THEN 
           UPDATE apo_cairu       
              SET qtd_diferenca=(qtd_diferenca + p_diferenca)
                WHERE         cod_item=p_total_oper.cod_item     
                  AND       cod_operac=p_total_oper.cod_operac
                  AND   num_seq_operac=p_total_oper.num_seq_operac   
                  AND    cod_cent_cust=p_total_oper.cod_cent_cust   
                  AND   dat_referencia=p_total_oper.dat_referencia  
           IF   sqlca.sqlcode <>  0
                THEN
                CALL log003_err_sql("UPDATE","APO_CAIRU")
           END IF
      ELSE
         IF   sqlca.sqlcode <>  0
            THEN
            CALL log003_err_sql("INSERT", "APO_CAIRU")
         END IF
      END IF

 WHENEVER ERROR STOP    

END FUNCTION  
#-----------------------------#
 FUNCTION pol0157_cria_tabelas()
#-----------------------------#
  
 WHENEVER ERROR STOP


  CREATE    TEMP  TABLE t_apo_oper
  (
    cod_empresa char(2) not null,                                 
    dat_producao   date,                                        
    cod_item char(15) not null ,                                
    num_ordem integer not null ,                               
    num_seq_operac decimal(3,0) not null ,                             
    cod_operac char(5) not null ,                               
    cod_cent_cust    decimal(4,0), 
    qtd_boas decimal(10,3) not null ,                               
    qtd_refugo decimal(10,3) ,                              
    cod_tip_movto char(1) ,                                
    ies_oper_final char(1) 
  );

  CREATE UNIQUE INDEX ix_pol0157_1 on t_apo_oper (cod_empresa,
    num_ordem,cod_operac,num_seq_operac,cod_item, cod_cent_cust);

   IF sqlca.sqlcode <> 0  THEN
      CALL log003_err_sql("CREATE","T_APO_OPER")
      RETURN FALSE
   END IF

  CREATE TEMP   TABLE t_total_oper
  (
    cod_item         char(15)      not null,  
    den_item_reduz   char(18)      not null,                                
    num_seq_operac   decimal(3,0)  not null,                             
    cod_operac       char(5)       not null,                               
    cod_cent_cust    decimal(4,0)  ,         
    qtd_ant          decimal(10,3) not null,
    qtd_boas         decimal(10,3) not null,                               
    ies_oper_final   char(1) 
  );

  CREATE UNIQUE INDEX ix_pol0157_2 on t_total_oper 
    (cod_item, cod_operac,num_seq_operac);

   IF sqlca.sqlcode <> 0  THEN
      CALL log003_err_sql("CREATE","T_TOTAL_OPER")
      RETURN FALSE
   END IF

END FUNCTION  
#------------------------------#
 REPORT pol0157_relat(p_relat)
#------------------------------#
 DEFINE p_relat         RECORD
                            cod_empresa    LIKE empresa.cod_empresa,
                            num_ordem      LIKE apo_oper.num_ordem,
                            cod_item       LIKE item.cod_item,
                            cod_operac     LIKE apo_oper.cod_operac,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust,
                            qtd_boas       DECIMAL(10,3)
                         END RECORD

  OUTPUT LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1
  FORMAT
    PAGE HEADER
      PRINT COLUMN 001, "POL0157",
            COLUMN 043, "LISTAGEM DE ITENS EM PROCESSO REF= ",
            COLUMN 078, MONTH(p_tela.dat_apo_ate),                
            COLUMN 080, "/",                                      
            COLUMN 081, YEAR(p_tela.dat_apo_ate),                
            COLUMN 125, "FL. ", PAGENO USING "####"
      PRINT COLUMN 096, "EXTRAIDO EM ", TODAY USING "dd/mm/yy",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      SKIP 1 LINE
      PRINT COLUMN 001, "     ITEM           ORDEM      OPERAC.   SEQ.   CENTRO DE CUSTO     QUANTIDADE                                                 "     

      PRINT COLUMN 001, "---------------  ----------  --------  ------  -----------------   --------------------"                                         

    ON EVERY ROW
      PRINT COLUMN 001, p_relat.cod_item,
            COLUMN 019, p_relat.num_ordem,  
            COLUMN 032, p_relat.cod_operac, 
            COLUMN 042, p_relat.num_seq_operac, 
            COLUMN 050, p_relat.cod_cent_cust, 
            COLUMN 070, p_relat.qtd_boas      

    ON LAST ROW
      LET p_last_row = true

    PAGE TRAILER
      IF p_last_row = true THEN
         PRINT " "
      ELSE
         PRINT " "
      END IF
END REPORT
#------------------------------#
 REPORT pol0157_relat1(p_relat1)
#------------------------------#
 DEFINE p_relat1        RECORD
                            cod_item       LIKE item.cod_item,
                            cod_operac     LIKE apo_oper.cod_operac,
                            num_seq_operac LIKE apo_oper.num_seq_operac,
                            cod_cent_cust  LIKE apo_oper.cod_cent_cust,
                            qtd_ant        DECIMAL(10,3),
                            qtd_entrada    DECIMAL(10,3),
                            qtd_atual      DECIMAL(10,3),
                            qtd_diferenca  DECIMAL(10,3),
                            den_item_reduz LIKE item.den_item_reduz
                         END RECORD

  OUTPUT LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1
  FORMAT
    PAGE HEADER
      PRINT COLUMN 001, p_comprime,"POL0157",
            COLUMN 043, "RESUMO DE ITENS EM PROCESSO REF= ",
            COLUMN 076, MONTH(p_tela.dat_apo_ate),                
            COLUMN 078, "/",                                      
            COLUMN 079, YEAR(p_tela.dat_apo_ate),                
            COLUMN 125, "FL. ", PAGENO USING "####"
      PRINT COLUMN 096, "EXTRAIDO EM ", TODAY USING "dd/mm/yy",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      SKIP 1 LINE
      PRINT COLUMN 001, "ITEM            DESCRICAO       OPERAC.  SEQ.  CEN.CUSTO        ANTERIOR        ENTRADA          ATUAL      DIFERENCA" 


      PRINT COLUMN 001, "--------------- ------------------ -----  ----  ---------  -------------- -------------- -------------- --------------"                                         
    ON EVERY ROW
         PRINT COLUMN 001, p_relat1.cod_item,
               COLUMN 017, p_relat1.den_item_reduz,
               COLUMN 036, p_relat1.cod_operac, 
               COLUMN 041, p_relat1.num_seq_operac, 
               COLUMN 046, p_relat1.cod_cent_cust, 
               COLUMN 059, p_relat1.qtd_ant       USING "--,---,--&.&&&",
               COLUMN 074, p_relat1.qtd_entrada   USING "--,---,--&.&&&",
               COLUMN 089, p_relat1.qtd_atual     USING "--,---,--&.&&&",
               COLUMN 102, p_relat1.qtd_diferenca USING "--,---,--&.&&&" 

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
 FUNCTION pol0157_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

