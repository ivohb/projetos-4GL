#-------------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                       #
# PROGRAMA: pol0787                                                       #
# OBJETIVO: Quebra galho para incluir operação PAL como última operação   #
# AUTOR...: Manuel Pier Sobrido                                           #
# DATA....: 03/04/2008                                                    #
#-------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_item_ant       LIKE item.cod_item,
          p_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_help                 CHAR(80),
          comando              CHAR(80),
          p_ies_impressao      CHAR(01), 
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_prx_processo       DEC(7,0),
          p_num_transac        INTEGER,
          p_msg                CHAR(100)
          
   DEFINE p_parametro1        CHAR(150),
          p_parametro2        CHAR(150), 
          w_parametro1        CHAR(150), 
          p_consumo           RECORD LIKE consumo.*,
          p_consumo_compl     RECORD LIKE consumo_compl.*, 
          p_fprocess          RECORD LIKE fprocess.*,
          w_consumo           RECORD LIKE consumo.*,
          w_consumo_compl     RECORD LIKE consumo_compl.*,
          w_fprocess          RECORD LIKE fprocess.* 
   DEFINE p_den_familia         LIKE familia.den_familia,
          p_cod_familia         LIKE familia.cod_familia


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0787-10.02.00"
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 7
   WHENEVER ERROR STOP
   DEFER INTERRUPT
  
   CALL log140_procura_caminho("POL.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP     FILE p_help,
      INSERT   KEY control-i,
      DELETE   KEY control-e,
      PREVIOUS KEY control-b,
      NEXT     KEY control-f
  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  

   IF p_status = 0 THEN 
      CALL pol0787_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0787_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0787") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0787 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Processa" "Inclui operacao PAL na tabela CONSUMO"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0787_processa() THEN
            ERROR 'Processamento efetuado com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0787_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0787

END FUNCTION

#--------------------------#
 FUNCTION pol0787_processa()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_consumo.*, p_consumo_compl.* TO NULL


   IF pol0787_entrada_dados("I") THEN
         
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      IF pol0787_efetua_acerto() = FALSE THEN    
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0787_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01) 

   LET INT_FLAG =  FALSE
   INPUT   p_cod_familia  WITHOUT DEFAULTS FROM cod_familia  
   

      AFTER FIELD cod_familia
         IF LENGTH(p_cod_familia) = 0  OR 
            p_cod_familia =  NULL  THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_familia 
         END IF

         CALL pol0787_le_familia()
         
         DISPLAY p_den_familia TO den_familia

         IF STATUS = 100 THEN
            ERROR 'Familia não cadastrada !!!'
            NEXT FIELD cod_familia
         ELSE
           IF STATUS <> 0 THEN
              CALL log003_err_sql("LEITURA","FAMILIA")       
              LET INT_FLAG = TRUE
              EXIT INPUT
           END IF
         END IF
    
{      ON KEY (control-z)
         CALL pol0787_popup()}

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol0787_le_familia()
#-----------------------------------#

   SELECT den_familia 
    INTO  p_den_familia
     FROM familia
    WHERE cod_empresa  = p_cod_empresa
      AND cod_familia  = p_cod_familia

END FUNCTION

#-----------------------------------#
 FUNCTION pol0787_efetua_acerto()
#-----------------------------------#

    LET p_count  =  0 
    LET  p_cod_item_ant    =  '99999999'
  

    DECLARE cq_consumo CURSOR FOR
    SELECT * 
      FROM consumo 
     WHERE cod_empresa = p_cod_empresa
     AND   cod_item  IN(SELECT cod_item FROM item 
     									WHERE cod_familia = p_cod_familia
                        AND cod_empresa=p_cod_empresa)
     AND cod_item NOT IN (select cod_item
                          from consumo
                          where cod_empresa=p_cod_empresa
                          and   cod_operac='PAL')                   
     ORDER BY  cod_item, cod_roteiro,  num_seq_operac
  
     FOREACH cq_consumo INTO p_consumo.*
   
          IF  p_consumo.cod_item =  p_cod_item_ant  THEN
          ELSE
             IF p_cod_item_ant    =  '99999999'         THEN    
             ELSE            
                IF pol0787_insere() = FALSE THEN 
                   RETURN FALSE
                END IF 
             END IF  
             LET  p_cod_item_ant = p_consumo.cod_item 
          END IF 
   
          SELECT * 
          INTO p_consumo_compl.*
          FROM consumo_compl
          WHERE cod_empresa  = p_cod_empresa
            AND cod_item     = p_consumo.cod_item
            AND num_processo = p_consumo.parametro
   
          IF STATUS <> 0 THEN
             CALL log003_err_sql("LEITURA","CONSUMO_COMPL")  
             RETURN FALSE          
          END IF
          
          IF p_consumo_compl.ies_apontamento  = 'S'   THEN 
             UPDATE consumo_compl 
                SET ies_apontamento = 'N'
              WHERE cod_empresa  		= p_cod_empresa
                AND cod_item        = p_consumo.cod_item
                AND num_processo 		= p_consumo.parametro   
                                 
             IF STATUS <> 0 THEN
                CALL log003_err_sql("UPDATE","CONSUMO_COMPL")  
                RETURN FALSE          
             END IF
          END IF   
          
          LET w_consumo.*  				= p_consumo.* 
          LET w_consumo_compl.*  	= p_consumo_compl.* 
          
      LET p_count = 1
      DISPLAY p_count AT 6,6
      
   END FOREACH
  
  RETURN TRUE
END FUNCTION 
#-----------------------------------#
 FUNCTION pol0787_insere()
#-----------------------------------#
 
 
      INITIALIZE p_parametro1, p_parametro2, w_parametro1   TO NULL 
 
      SELECT substring(parametros,35,7),
             substring(parametros,1,150), 
             substring(parametros,151,150)
      INTO p_prx_processo,
           p_parametro1,
           p_parametro2
      FROM par_pcp
      WHERE cod_empresa=p_cod_empresa
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","PAR_PCP")  
         RETURN FALSE          
      END IF
          
      
      LET p_prx_processo = p_prx_processo + 1 
 
      LET w_parametro1 = p_parametro1[1,34] 
      LET w_parametro1 = w_parametro1  CLIPPED, p_prx_processo, p_parametro1[42,150]
      
      UPDATE par_pcp 
         SET parametros = w_parametro1 + p_parametro2
       WHERE par_pcp.cod_empresa =    p_cod_empresa
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","PAR_PCP")  
         RETURN FALSE          
      END IF
   
      LET      w_consumo.cod_empresa   			= p_cod_empresa
      LET      w_consumo.cod_item           = p_cod_item_ant
      LET      w_consumo.num_seq_operac     = w_consumo.num_seq_operac   + 1
      LET      w_consumo.cod_operac         = 'PAL'
      LET      w_consumo.cod_cent_trab      = 'PAL'  
      LET      w_consumo.cod_arranjo        = 'PAL'  
      LET      w_consumo.cod_cent_cust      = 2308 
      LET      w_consumo.qtd_horas          = 0 
      LET      w_consumo.qtd_pecas_ciclo    = 0 
      LET      w_consumo.parametro          = p_prx_processo 

   
      INSERT INTO consumo(cod_empresa ,
    											cod_item ,
    											cod_roteiro ,
    											num_altern_roteiro ,
    											num_seq_operac ,
    											cod_operac ,
    											cod_cent_trab ,
    											cod_arranjo ,
    											cod_cent_cust ,
    											qtd_horas ,
    											qtd_pecas_ciclo ,
    											qtd_horas_setup,
    											parametro)
    											VALUES   (w_consumo.cod_empresa , 
    																w_consumo.cod_item ,
    																w_consumo.cod_roteiro ,
    																w_consumo.num_altern_roteiro ,
    																w_consumo.num_seq_operac ,
    																w_consumo.cod_operac ,
    																w_consumo.cod_cent_trab ,
    																w_consumo.cod_arranjo ,
    																w_consumo.cod_cent_cust ,
    																w_consumo.qtd_horas ,
    																w_consumo.qtd_pecas_ciclo ,
    																w_consumo.qtd_horas_setup,
    																w_consumo.parametro)
    													 
          IF STATUS <> 0 THEN
             CALL log003_err_sql("INSERT","CONSUMO")  
             RETURN FALSE          
          END IF
             
      LET      w_consumo_compl.ies_apontamento         = 'S'          
      LET      w_consumo_compl.num_processo            = p_prx_processo 
      LET      w_consumo_compl.ies_oper_final          = 'S'  
      LET      w_consumo_compl.pct_refug               = 0 
      LET      w_consumo_compl.tmp_producao            = 0  
      LET      w_consumo_compl.parametros              = ' '       
      
      
      
      
      INSERT INTO consumo_compl(cod_empresa,
    														num_processo,
    														cod_item,
    														ies_apontamento,
    														ies_impressao,
    														ies_oper_final,
    														pct_refug,
    														tmp_producao,
    														dat_validade_ini,
    														dat_validade_fim,
    														parametros)
    											VALUES   (w_consumo_compl.cod_empresa,
    																w_consumo_compl.num_processo,
    																w_consumo_compl.cod_item,
    																w_consumo_compl.ies_apontamento,
    																w_consumo_compl.ies_impressao, 
    																w_consumo_compl.ies_oper_final,
    																w_consumo_compl.pct_refug,
    																w_consumo_compl.tmp_producao,
    																w_consumo_compl.dat_validade_ini,
    																w_consumo_compl.dat_validade_fim,
    																w_consumo_compl.parametros)
          IF STATUS <> 0 THEN
             CALL log003_err_sql("INSERT","CONSUMO_COMPL")  
             RETURN FALSE          
          END IF
          
          LET      w_fprocess.dat_proces 			= TODAY       
          LET      w_fprocess.hor_proces 			= TIME    
          LET      w_fprocess.nom_usuario  			= 'logix' 
          LET      w_fprocess.ies_tip_operac  			= 'I' 
          
             INSERT INTO fprocess(cod_empresa,
    															cod_item,
    															cod_roteiro,
    															num_seq_operac,
    															nom_usuario,
    															dat_proces,
    															hor_proces,
    															ies_tip_operac)
    											VALUES   (w_consumo.cod_empresa, 
    																w_consumo.cod_item,
    																w_consumo.cod_roteiro,
    																w_consumo.num_seq_operac,
    																w_fprocess.nom_usuario,
    																w_fproces.dat_proces,
    																w_fprocess.hor_proces,
    																w_fprocess.ies_tip_operac)

          IF STATUS <> 0 THEN
             CALL log003_err_sql("INSERT","FPROCESS")  
             RETURN FALSE          
          END IF
          
         RETURN TRUE    


END FUNCTION

#-----------------------#
 FUNCTION pol0787_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

