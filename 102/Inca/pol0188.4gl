#-------------------------------------------------------------------#
# PROGRAMA: POL0188                                                 #
# MODULOS.: POL0188 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO CARTEIRA DE PEDIDOS x PLANEJ x ESTOQUE        #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_den_empresa       LIKE empresa.den_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_dat_pgto          DATE,
         p_status            SMALLINT,
         p_erro              SMALLINT,
         comando             CHAR(80),
         p_qtd_total         DECIMAL(12,3),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(200),
         p_nom_tela1         CHAR(200),
         p_nom_tela2         CHAR(200),
         p_cont              SMALLINT,
         p_numero            SMALLINT,
         p_nom_help          CHAR(200),
         p_ies_lista         SMALLINT,
         p_ies_impressao     CHAR(01),
      #  p_versao            CHAR(17),
         p_versao            CHAR(18),
         p_ind               SMALLINT,
         i                   SMALLINT,
         pa_curr, sc_curr    SMALLINT,
         p_ies_cons          SMALLINT,
         p_primeira_vez      SMALLINT,
         p_last_row          SMALLINT,
         g_ies_ambiente      CHAR(01),
         p_caminho           CHAR(080),
         p_den_item          LIKE item.den_item_reduz,
         p_msg               char(300)

  DEFINE p_tela              RECORD
                               cod_empresa      LIKE empresa.cod_empresa,
                               prz_entr1        LIKE ped_itens.prz_entrega,    
                               prz_entr2        LIKE ped_itens.prz_entrega    
                             END RECORD 

  DEFINE p_relat         RECORD 
           cod_item          LIKE ped_itens.cod_item,
           den_item_reduz    LIKE item.den_item_reduz,     
           qtd_estoq_seg     LIKE item_man.qtd_estoq_seg,
           qtd_pedido        LIKE ped_itens.qtd_pecas_solic,
           qtd_estoque       LIKE estoque.qtd_liberada,
           qtd_planejado     LIKE pl_it_me.qtd_plano,        
           qtd_necessaria    LIKE estoque.qtd_liberada,       
           dat_entrega       LIKE ped_itens.prz_entrega
                        END RECORD 

END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
  SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT 
  LET p_versao="pol0188-10.02.01"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0188.iem") RETURNING p_nom_help
  LET p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help   ,
      NEXT KEY control-f,
      PREVIOUS KEY control-b


  CALL log001_acessa_usuario("ESPEC999","")
     RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
     CALL pol0188_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0188_controle()
#--------------------------#
 CALL log006_exibe_teclas("01",p_versao)
 INITIALIZE p_nom_tela TO NULL
 CALL log130_procura_caminho("pol0188") RETURNING p_nom_tela
 LET  p_nom_tela = p_nom_tela CLIPPED 
 OPEN WINDOW w_pol0188 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 MENU "OPCAO"

      COMMAND "Listar" "Lista relatorio. "
      HELP 000 
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0188","CO")  THEN
          CALL pol0188_consulta()
      END IF
      COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0188_sobre() 

      COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 000
      MESSAGE ""
      EXIT MENU
 END MENU
 CLOSE WINDOW w_pol0188
 END FUNCTION

#-----------------------#
FUNCTION pol0188_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#---------------------------------------#
 FUNCTION pol0188_consulta()
#---------------------------------------#
 DEFINE where_clause, sql_stmt CHAR(500),
        p_cod_item             LIKE mov_est_fis.cod_item

 INITIALIZE p_tela.*   TO NULL 
 CALL log006_exibe_teclas("02 07",p_versao)
 CURRENT WINDOW IS w_pol0188 
 CLEAR FORM
 LET p_tela.cod_empresa = p_cod_empresa
 DISPLAY BY NAME p_tela.cod_empresa
 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

    AFTER FIELD prz_entr1   
       IF p_tela.prz_entr1   IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD prz_entr1  
       END IF

    AFTER FIELD prz_entr2   
       IF p_tela.prz_entr2 IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD prz_entr2   
       ELSE
          IF p_tela.prz_entr1   > p_tela.prz_entr2   THEN
             ERROR "Data De nao pode ser maior que Data ate"
             NEXT FIELD prz_entr1  
          END IF 
       END IF
    
END INPUT
IF int_flag <> 0 THEN
   ERROR "Funcao Cancelada"
   INITIALIZE p_tela.* TO NULL 
   RETURN
END IF
CURRENT WINDOW IS w_pol0188 
IF log028_saida_relat(17,40) IS NOT NULL THEN 
    MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
    IF p_ies_impressao = "S" THEN
       IF g_ies_ambiente = "U" THEN
          START REPORT pol0188_relat TO PIPE p_nom_arquivo
       ELSE
          CALL log150_procura_caminho ('LST') RETURNING p_caminho
          LET p_caminho = p_caminho CLIPPED, 'pol0188.tmp'
          START REPORT pol0188_relat  TO p_caminho     
       END IF
    ELSE
       START REPORT pol0188_relat TO p_nom_arquivo
    END IF
  END IF

LET p_cont = 0 
LET p_ind = 1
LET p_qtd_total = 0
LET p_numero = 0 
LET p_ies_lista = TRUE
DECLARE cq_pedido CURSOR FOR
  SELECT    b.cod_item,
            den_item_reduz,
           SUM(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio),
            prz_entrega     
    FROM pedidos a, ped_itens b, item c
    WHERE a.cod_empresa = b.cod_empresa 
      AND a.num_pedido = b.num_pedido 
      AND b.cod_empresa = c.cod_empresa 
      AND b.cod_item = c.cod_item 
      AND a.cod_empresa = p_cod_empresa 
      AND a.ies_sit_pedido <> "9"
      AND b.prz_entrega >= p_tela.prz_entr1 
      AND b.prz_entrega <= p_tela.prz_entr2 
      AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)>0
  GROUP BY 1,2,4
  ORDER BY 1,4
 
 FOREACH cq_pedido INTO p_relat.cod_item,p_relat.den_item_reduz,
                        p_relat.qtd_pedido,p_relat.dat_entrega
   SELECT qtd_liberada
     INTO p_relat.qtd_estoque 
     FROM estoque 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_item = p_relat.cod_item

   IF sqlca.sqlcode <> 0 THEN
      LET p_relat.qtd_estoque = 0
   END IF 

   SELECT qtd_plano
     INTO p_relat.qtd_planejado
     FROM pl_it_me
    WHERE mes_ref = month(p_tela.prz_entr1)
      AND ano_ref = year(p_tela.prz_entr2)
      AND cod_item= p_relat.cod_item       
      AND cod_empresa = p_cod_empresa 

   IF sqlca.sqlcode <> 0 THEN
      LET p_relat.qtd_planejado = 0
   END IF
  
   SELECT qtd_estoq_seg  
     INTO p_relat.qtd_estoq_seg     
     FROM item_man
    WHERE cod_item= p_relat.cod_item       
      AND cod_empresa = p_cod_empresa 

   IF sqlca.sqlcode <> 0 THEN
      LET p_relat.qtd_estoq_seg = 0
   END IF

   OUTPUT TO REPORT pol0188_relat(p_relat.*)                              

 END FOREACH   
 FINISH REPORT pol0188_relat

 IF p_ies_lista THEN
    IF  p_ies_impressao = "S" THEN
        MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                 ATTRIBUTE(REVERSE)
        IF g_ies_ambiente = "W" THEN
           LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
           RUN comando
        END IF
    ELSE
        MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo, " " ATTRIBUTE(REVERSE)
    END IF
 ELSE
     MESSAGE ""
     ERROR " Nao existem dados para serem listados. "
 END IF

END FUNCTION


#----------------------------#
 REPORT pol0188_relat(p_relat)                              
#----------------------------# 
  DEFINE p_relat         RECORD 
           cod_item          LIKE ped_itens.cod_item,
           den_item_reduz    LIKE item.den_item_reduz,  
           qtd_estoq_seg     LIKE item_man.qtd_estoq_seg,
           qtd_pedido        LIKE ped_itens.qtd_pecas_solic,
           qtd_estoque       LIKE estoque.qtd_liberada,
           qtd_planejado     LIKE pl_it_me.qtd_plano,        
           qtd_necessaria    LIKE estoque.qtd_liberada,       
           dat_entrega       LIKE ped_itens.prz_entrega
                        END RECORD 

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE LENGTH  88
 ORDER  EXTERNAL BY p_relat.cod_item     
{
XXXXXXXXXXXXXXXXXXXXXXXXXXXX
0        1         2         3         4         5         6         7 
12345678901234567890123456789012345678901234567890123456789012345678901234567890
pol0188                                        RELATORIO                                   FL. ##&
TIPO : TRANSFERENCIA                                         EXTRAIDO EM DD/MM/YY AS HH.MM.SS HRS.
REFERENCIA: ATENDIMENTO : DATA : ##/##/####  HORA : ##:##
            FATURAMENTO : DATA : ##/##/####  HORA : ##:##:##
 
                                                       QUANTIDADE           DATA        DATA
NUM OP    ITEM  DENOMINACAO          NUM NF  PEDIDO     PRODUZIDA   PLACA   ATENDIMENT  EMISSAO NF
-------  -----  -------------------  ------  ------  ------------  -------  ----------  ----------
XXXXXXX  XXXXX  XXXXXXXXXXXXXXXXXXX  XXXXXX  ######  X,XX&.&&&&&&  XXXXXXX  DD/MM/YYYY  DD/MM/YYYY
                                       TOTAL.:  XX,XXX,XX&.&&&&&&    
}

FORMAT

PAGE HEADER  
  
    PRINT COLUMN 001, "pol0188",
          COLUMN 030, "EXTRAIDO EM ",TODAY USING "DD/MM/YY"," AS ",TIME," HRS.",
          COLUMN 092, "FL. ", PAGENO USING "##&"
    PRINT COLUMN 001, "RELATORIO DA POSICAO DA CARTEIRA DE PEDIDO REF: ",p_tela.prz_entr1,  
          COLUMN 070, "ATE : ",p_tela.prz_entr2    
    SKIP  1 LINE
    PRINT COLUMN 001, "CODIGO           DESCRICAO             EST. MINIMO       CARTEIRA        ESTOQUE      PLANEJADO    NECESSIDADE   DT.ENTREGA"   
    PRINT COLUMN 001, "---------------  ------------------  -------------  -------------  -------------  -------------  -------------   ----------"


ON  EVERY ROW
    PRINT COLUMN 001, p_relat.cod_item,                           
          COLUMN 018, p_relat.den_item_reduz,
          COLUMN 053, p_relat.qtd_pedido  USING "#,###,###,##&",
          COLUMN 114, p_relat.dat_entrega USING "DD/MM/YYYY" 

    AFTER GROUP OF p_relat.cod_item    
       SKIP 1 LINE 
       LET p_qtd_total = GROUP SUM(p_relat.qtd_pedido) 
       LET p_relat.qtd_necessaria = p_relat.qtd_estoque - p_qtd_total - p_relat.qtd_planejado - p_relat.qtd_estoq_seg
       IF p_relat.qtd_necessaria > 0 THEN
          LET p_relat.qtd_necessaria = 0 
       END IF
       PRINT COLUMN 018, "TOTAL.:",
             COLUMN 038, p_relat.qtd_estoq_seg USING "#,###,###,##&",
             COLUMN 053, GROUP SUM(p_relat.qtd_pedido) USING "#,###,###,##&",
             COLUMN 068, p_relat.qtd_estoque USING "#,###,###,##&",
             COLUMN 083, p_relat.qtd_planejado USING "#,###,###,##&",
             COLUMN 098, p_relat.qtd_necessaria USING "#,###,###,##&"
       SKIP 1 LINE 
   
ON  LAST ROW
    LET p_last_row = TRUE

PAGE TRAILER
    IF  p_last_row THEN
        LET p_last_row = FALSE
    ELSE
    END IF

END REPORT
