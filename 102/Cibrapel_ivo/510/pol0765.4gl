#-------------------------------------------------------------------#
# SISTEMA.: COMERCIAL                                               #
# OBJETIVO: CANCELA PROCESSAMENTO DE COMISSOES                      #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_num_pedido        LIKE pedidos.num_pedido, 
         p_ano_ref           CHAR(4),                   
         p_mes_ref           CHAR(2),                   
         p_quinz_ref         CHAR(1),                   
         p_nff_ch            CHAR(6),
         p_nff_nu            CHAR(6),                   
         p_comissao_par      RECORD LIKE comissao_par.*,
         p_nf_mestre         RECORD LIKE nf_mestre.*,
         p_docum             RECORD LIKE docum.*,     
         p_docum_pgto        RECORD LIKE docum_pgto.*,
         p_dev_mestre        RECORD LIKE dev_mestre.*,
         p_dev_item          RECORD LIKE dev_item.*,   
         p_lanc_acerto_com_885 RECORD LIKE lanc_acerto_com_885.*,
         p_repres_885        RECORD LIKE repres_885.*,
         p_empresas_885      RECORD LIKE empresas_885.*,
         p_lanc_com_885      RECORD LIKE lanc_com_885.*,
         p_status            SMALLINT,
         p_erro              SMALLINT,
         p_count             SMALLINT,
         comando             CHAR(80),
         p_nom_arquivo       CHAR(100),
         p_caminho           CHAR(080),
         p_nom_tela          CHAR(200),
         p_nom_help          CHAR(200),
         p_versao            CHAR(18),
         p_ind               SMALLINT,
         p_pct_pagto         DECIMAL(8,5),
         p_val_base          DECIMAL(15,2),
         p_val_base_com      DECIMAL(15,2),
         p_val_base_dev      DECIMAL(15,2),
         p_val_com_dev       DECIMAL(15,2),
         p_val_pago          DECIMAL(15,2),
         i                   SMALLINT,
         pa_curr, sc_curr    SMALLINT,
         p_ies_cons          SMALLINT,
         p_primeira_vez      SMALLINT,
         p_last_row          SMALLINT,
         p_qtd_reg           INTEGER,
         p_i                 SMALLINT,
         p_msg               CHAR(100) 

  DEFINE p_tela     RECORD
               cod_empresa      LIKE empresa.cod_empresa,
               dat_pagto        DATE
                    END RECORD

END GLOBALS

MAIN

  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao ="POL0765-10.02.00"
  INITIALIZE p_nom_help TO NULL
  CALL log140_procura_caminho("pol0765.iem") RETURNING p_nom_help
  LET p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help   ,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol0765_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0765_controle()
#--------------------------#
 CALL log006_exibe_teclas("01",p_versao)
 INITIALIZE p_nom_tela TO NULL
 CALL log130_procura_caminho("pol0765") RETURNING p_nom_tela
 LET  p_nom_tela = p_nom_tela CLIPPED
 OPEN WINDOW w_pol0765 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 MENU "OPCAO"

      COMMAND "Informar" "Informa parametros para processamento. " 
      HELP 000
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","pol0765","IN")  THEN
         CALL pol0765_entrada_dados()
         NEXT OPTION "Processar"
      END IF 

      COMMAND "Processar" "Processa informacoes."
      HELP 000
      MESSAGE ""
      LET int_flag = 0
      IF log004_confirm(10,20)  THEN
         CALL pol0765_processa_cancelamento()
      END IF    
      
      NEXT OPTION "Fim"
      ERROR "Fim de processamento"
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0765_sobre()
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
 CLOSE WINDOW w_pol0765
 END FUNCTION

#--------------------------------#
 FUNCTION pol0765_entrada_dados()
#--------------------------------#

 INITIALIZE p_tela.*   TO NULL
 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol0765
 CLEAR FORM
 LET p_tela.cod_empresa = p_cod_empresa
 DISPLAY BY NAME p_tela.cod_empresa
 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

    BEFORE FIELD dat_pagto 
      SELECT * INTO p_empresas_885.* 
        FROM empresas_885 
       WHERE cod_emp_oficial = p_cod_empresa   

    AFTER FIELD dat_pagto     
       IF p_tela.dat_pagto IS NOT NULL THEN
          LET p_qtd_reg = 0 
          SELECT COUNT(*)
            INTO p_qtd_reg
            FROM lanc_com_885 
          WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
            AND dat_pagto    = p_tela.dat_pagto
          IF p_qtd_reg= 0 THEN 
             ERROR 'NAO EXISTEM DADOS COM ESTA DATA DE PAGAMENTO '
             NEXT FIELD dat_pagto
          END IF 
       ELSE
          ERROR 'INFORME A DATA DE PAGAMENTO '
          NEXT FIELD dat_pagto
       END IF 

END INPUT
IF int_flag <> 0 THEN
   ERROR "Funcao Cancelada"
   INITIALIZE p_tela.* TO NULL
   RETURN
END IF
CURRENT WINDOW IS w_pol0765

END FUNCTION

#----------------------------------------#
 FUNCTION pol0765_processa_cancelamento()
#----------------------------------------#
### nao ira deletar os registros de devolucao devido controle de cliches
   DELETE FROM lanc_com_885 
   WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
     AND dat_pagto    = p_tela.dat_pagto
     AND ies_origem   <> 'V'
     
   UPDATE com_fut_885
      SET dat_libera = NULL 
         WHERE cod_empresa IN (p_cod_empresa, p_empresas_885.cod_emp_gerencial) 
           AND dat_libera = p_tela.dat_pagto

END FUNCTION

#-----------------------#
 FUNCTION pol0765_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION