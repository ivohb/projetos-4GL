#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: POL1294                                                 #
# OBJETIVO: RANK FORNECEDOR X ENTRADA DE APARAS POR PERIODO         #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 12/08/15                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
           p_den_empresa        LIKE empresa.den_empresa,
           p_user               LIKE usuario.nom_usuario,
           comando              CHAR(80),
           p_retorno            SMALLINT,
           p_status             SMALLINT,
           p_ies_impressao      CHAR(01),
           g_ies_ambiente       CHAR(01),
           p_comprime           CHAR(01),
           p_descomprime        CHAR(01),
           p_6lpp               CHAR(100),
           p_8lpp               CHAR(100),
           p_count              SMALLINT,
           p_versao             CHAR(18),
           p_nom_arquivo        CHAR(100),
           p_nom_tela           CHAR(200),
           p_ies_cons           SMALLINT,
           p_caminho            CHAR(080),
           p_sql                CHAR(2000),
           p_msg                CHAR(500),
           p_last_row           SMALLINT,
           p_index              SMALLINT,
           s_index              SMALLINT,
           p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
           p_peso_total_dia     DECIMAL(10,3),
           p_peso_balanca_dia   DECIMAL(10,3),
           p_peso_difer_dia     DECIMAL(10,3),
           p_peso_total_geral   DECIMAL(10,3),
           p_peso_balanca_geral DECIMAL(10,3),
           p_peso_difer_geral   DECIMAL(10,3),
           p_peso_balanca       DECIMAL(10,3),
           p_valor_total_dia    DECIMAL(10,2),
           p_valor_total_geral  DECIMAL(10,2),
           p_grupo          CHAR(1)

   DEFINE p_tela                RECORD 
          data_inicio_periodo   LIKE nf_sup.dat_emis_nf, 
          data_fim_periodo      LIKE nf_sup.dat_emis_nf
   END RECORD
   
   DEFINE p_lista RECORD
          num_aviso_rec         LIKE aviso_rec.num_aviso_rec,
          dat_inclusao          LIKE aviso_rec.dat_inclusao_seq,
          dat_emis_nf           LIKE nf_sup.dat_emis_nf,
          num_nf                LIKE nf_sup.num_nf,
          cod_fornecedor        LIKE fornecedor.cod_fornecedor,
          nom_fornecedor        LIKE fornecedor.raz_social,
          nom_transpor          LIKE clientes.nom_cliente,
          num_placa             LIKE transportador_placa_885.num_placa,
          peso_nota             LIKE aviso_rec.qtd_recebida,
          cod_item              LIKE aviso_rec.cod_item,
          pre_unit              LIKE aviso_rec.pre_unit_nf,
          pre_total             LIKE aviso_rec.val_liquido_item,
          peso_balanca          LIKE aviso_rec.qtd_recebida,
          peso_diferenca        LIKE aviso_rec.qtd_recebida,
          cod_uni_feder         LIKE cidades.cod_uni_feder,
          grupo                 CHAR(1)
   END RECORD

END GLOBALS

MAIN
    CALL log0180_conecta_usuario()
    WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 300 
    WHENEVER ANY ERROR STOP
    DEFER INTERRUPT
 	    LET p_versao = "POL1294-10.02.01"
    OPTIONS
        NEXT KEY control-f,
        INSERT KEY control-i,
        DELETE KEY control-e,
        PREVIOUS KEY control-b
 
    CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
    {LET p_cod_empresa = '02'; LET p_user = 'admlog'; LET p_status = 0}
    
    IF p_status = 0  THEN
        CALL pol1294_menu()
    END IF
 
END MAIN

#----------------------#
 FUNCTION pol1294_menu()
#----------------------#

    CALL log006_exibe_teclas("01",p_versao)
    INITIALIZE p_nom_tela TO NULL
    CALL log130_procura_caminho("pol1294") RETURNING p_nom_tela
    LET p_nom_tela = p_nom_tela CLIPPED
    OPEN WINDOW w_pol1294 AT 2,2 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

    DISPLAY p_cod_empresa TO cod_empresa

    MENU "OPCAO"
        COMMAND "Informar" "Informar Parâmetros p/ consulta"
            CALL pol1294_informar() RETURNING p_status
            IF p_status THEN
                MESSAGE "Parâmetros informados com sucesso !!!"
                LET p_ies_cons = TRUE
                NEXT OPTION "Listar"
            ELSE
                ERROR "Operação Cancelada !!!"
                NEXT OPTION "Fim"
            END IF
        COMMAND "Listar" "Listagem de carga e frete"
            IF pol1294_listagem() THEN
                MESSAGE "Processando a Extracao do Relatorio..." 
            ELSE
            #  	ERROR "Informar Parametros para Impressao"
            END IF
        COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
            CALL pol1294_sobre()
        COMMAND KEY ("!")
            PROMPT "Digite o comando : " FOR comando
            RUN comando
            PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
            DATABASE logix
         COMMAND "Fim" "Retorna ao menu anterior."
             EXIT MENU
    END MENU
    CLOSE WINDOW w_pol1294

END FUNCTION

#--------------------------#
FUNCTION pol1294_informar()
#--------------------------#
    INITIALIZE p_tela TO NULL
    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    
    INPUT BY NAME p_tela.*
        WITHOUT DEFAULTS     

        AFTER FIELD data_inicio_periodo    
            IF p_tela.data_inicio_periodo IS NULL THEN
                ERROR "Campo de Preenchimento Obrigatorio"
                NEXT FIELD data_inicio_periodo
            END IF
        			
        AFTER FIELD data_fim_periodo    
            IF p_tela.data_fim_periodo IS NULL THEN
                ERROR "Campo de Preenchimento Obrigatorio"
                NEXT FIELD data_fim_periodo
            ELSE
                IF p_tela.data_fim_periodo < p_tela.data_inicio_periodo THEN
            	    ERROR 'A data final deve ser maior que a data inicial!'
            	    NEXT FIELD data_inicio_periodo
                END IF
            END IF            
    END INPUT
 
    IF INT_FLAG = 0 THEN
        RETURN TRUE
    ELSE
        LET INT_FLAG = 0
        CLEAR FORM
        DISPLAY p_cod_empresa TO cod_empresa
    END IF
    
    RETURN FALSE
    
END FUNCTION

#--------------------------#
FUNCTION pol1294_listagem()
#--------------------------#
    
    IF NOT pol1294_escolhe_saida() THEN
        RETURN
    END IF

    IF NOT pol1294_le_den_empresa() THEN
        RETURN
    END IF

    LET p_comprime    = ascii 15
    LET p_descomprime = ascii 18
    LET p_6lpp        = ascii 27, "2"
    LET p_8lpp        = ascii 27, "0"

    LET p_count = 0
    LET p_sql = " SELECT nf.cod_fornecedor,",
                "        fo.raz_social,",
                "        ci.cod_uni_feder,",
                "        SUM(ar.qtd_recebida) peso_total_nf,",
                "        SUM(ar.val_liquido_item) val_total_nf,",
                "        SUM(ca.qtd_contagem) peso_balanca,",
                "        CASE WHEN ci.cod_uni_feder='RJ'", 
                "              AND nf.cod_fornecedor<>'033352881000169'",
                "             THEN '1'",
                "             WHEN ci.cod_uni_feder<>'RJ'",
                "             THEN '2'",
                "             ELSE '3'",
                "        END grupo",
                "   FROM nf_sup nf,",
                "        aviso_rec ar,",
                "        item it,",
                "        familia_insumo_885 fi,",
                "        fornecedor fo,",
                "        cont_aparas_885 ca,",
                "        cidades ci",
                "  WHERE nf.cod_empresa = '",p_cod_empresa,"'",
                "    AND nf.cod_empresa = ar.cod_empresa",
                "    AND nf.num_aviso_rec = ar.num_aviso_rec",
                "    AND ar.cod_item = it.cod_item",
                "    AND it.cod_empresa = nf.cod_empresa",
                "    AND fi.cod_empresa = nf.cod_empresa",
                "    AND fi.cod_familia=it.cod_familia",
                "    AND (fi.ies_apara='S')",
                "    AND nf.cod_fornecedor = fo.cod_fornecedor",
                "    AND ca.cod_empresa = ar.cod_empresa",
                "    AND ca.num_aviso_rec = ar.num_aviso_rec",
                "    AND fo.cod_cidade = ci.cod_cidade"
    IF p_tela.data_inicio_periodo IS NOT NULL THEN
        LET p_sql = p_sql CLIPPED, ' '," AND ar.dat_inclusao_seq >=  '",p_tela.data_inicio_periodo USING 'dd/mm/yyyy',"' "
    END IF
    
    IF p_tela.data_fim_periodo IS NOT NULL THEN
        LET p_sql = p_sql CLIPPED, ' '," AND ar.dat_inclusao_seq <=  '",p_tela.data_fim_periodo USING 'dd/mm/yyyy',"' "
    END IF

    LET p_sql = p_sql CLIPPED, " GROUP BY nf.cod_fornecedor,  fo.raz_social, ci.cod_uni_feder"
    LET p_sql = p_sql CLIPPED, " ORDER BY grupo, fo.raz_social"
    
    PREPARE var_query FROM p_sql   
    DECLARE cq_impressao CURSOR FOR var_query
    
    LET p_peso_total_geral = 0
    LET p_peso_balanca_geral = 0
    LET p_peso_difer_geral = 0

    LET p_valor_total_dia = 0
    LET p_valor_total_geral = 0
    
    LET p_peso_total_dia = 0
    LET p_peso_difer_dia = 0
    LET p_peso_balanca_dia  = 0
    
    LET p_grupo = NULL
    
    FOREACH cq_impressao
       INTO p_lista.cod_fornecedor,
            p_lista.nom_fornecedor,
            p_lista.cod_uni_feder,
            p_lista.peso_nota, 
            p_lista.pre_total,
            p_lista.peso_balanca,
            p_lista.grupo
        IF STATUS <> 0 THEN
            CALL log003_err_sql("SELECT", 'CURSOR: cq_impressao')
            RETURN
        END IF
        LET p_lista.peso_diferenca = p_lista.peso_balanca - p_lista.peso_nota
        
        LET p_peso_total_geral   = p_peso_total_geral   + p_lista.peso_nota
        LET p_peso_balanca_geral = p_peso_balanca_geral + p_lista.peso_balanca
        LET p_peso_difer_geral   = p_peso_difer_geral   + p_lista.peso_diferenca
        LET p_valor_total_geral  = p_valor_total_geral  + p_lista.pre_total
        
        OUTPUT TO REPORT pol1294_relat(p_lista.grupo)
        
        IF p_grupo = p_lista.grupo THEN
         	LET p_peso_total_dia = p_peso_total_dia + p_lista.peso_nota
        	LET p_peso_balanca_dia = p_peso_balanca_dia + p_lista.peso_balanca
        	LET p_peso_difer_dia = p_peso_difer_dia + p_lista.peso_diferenca
        	LET p_valor_total_dia = p_valor_total_dia + p_lista.pre_total
        ELSE
            LET p_grupo = p_lista.grupo 
            
        	LET p_peso_total_dia   = p_lista.peso_nota
        	LET p_peso_balanca_dia =  p_lista.peso_balanca
        	LET p_peso_difer_dia   = p_lista.peso_diferenca
        	LET p_valor_total_dia  = p_lista.pre_total

        END IF

        LET p_count = 1

    END FOREACH

    FINISH REPORT pol1294_relat

    IF p_count = 0 THEN
        ERROR "Não existem dados há serem listados !!!"
        RETURN FALSE
    ELSE
        IF p_ies_impressao = "S" THEN
            MESSAGE "Relatório impresso na impressora ", p_nom_arquivo
            CALL log0030_mensagem(p_msg, 'excla')
            IF g_ies_ambiente = "W" THEN
                LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
                RUN comando
            END IF
        ELSE
            MESSAGE "Relatório gravado no arquivo ", p_nom_arquivo
            CALL log0030_mensagem(p_msg, 'exclamation')
        END IF
        ERROR 'Relatório gerado com sucesso !!!'
    END IF

    RETURN

END FUNCTION

#-------------------------------#
FUNCTION pol1294_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1294.tmp"
         START REPORT pol1294_relat TO p_caminho
      ELSE
         START REPORT pol1294_relat TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1294_le_den_empresa()
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

#-----------------------------------#
REPORT pol1294_relat(p_grupo)
#-----------------------------------#

   DEFINE p_grupo CHAR(1)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63

   FORMAT

      PAGE HEADER

         PRINT COLUMN 002,  p_den_empresa,
               COLUMN 092, "PAG. ", PAGENO USING "####&"

         PRINT COLUMN 002, "pol1294",
               COLUMN 013, "RANK FORNECEDOR X ENTRADA DE APARAS POR PERIODO ",
               COLUMN 072, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME 
               
         PRINT COLUMN 002, "PERIODO DE: ", p_tela.data_inicio_periodo, " A ", p_tela.data_fim_periodo
         PRINT
      
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, "NOME FORNECEDOR             TOTAL KG           TOTAL KG           DIFERENCA          VAL. APARAS    "
         PRINT COLUMN 002, "                            PESO BAL           PESO N.F                                    N.F      "
         PRINT
         
      BEFORE GROUP OF p_grupo
         SKIP TO TOP OF PAGE
         
      ON EVERY ROW
         PRINT COLUMN 002, p_lista.nom_fornecedor[1,25],
               COLUMN 029, p_lista.peso_balanca USING "###,###,###,##&",
               COLUMN 048, p_lista.peso_nota USING "###,###,###,##&",
               COLUMN 067, p_lista.peso_diferenca USING "###,###,###,##&",
               COLUMN 086, p_lista.pre_total USING "###,###,##&.&&"               
      AFTER GROUP OF p_grupo
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, "SUB - TOTAL",
               COLUMN 029, p_peso_balanca_dia USING "###,###,###,##&",
               COLUMN 048, p_peso_total_dia USING "###,###,###,##&",
               COLUMN 067, p_peso_difer_dia USING "###,###,###,##&",
               COLUMN 086, p_valor_total_dia USING "###,###,##&.&&"
         PRINT
         
      ON LAST ROW
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, "TOTAL GERAL",
               COLUMN 029, p_peso_balanca_geral USING "###,###,###,##&",
               COLUMN 048, p_peso_total_geral USING "###,###,###,##&",
               COLUMN 067, p_peso_difer_geral USING "###,###,###,##&",
               COLUMN 086, p_valor_total_geral USING "###,###,##&.&&"
         PRINT
         
         PRINT COLUMN 030, " * * * ULTIMA FOLHA * * * "
END REPORT


#-----------------------#
FUNCTION pol1294_sobre()
#-----------------------#

    LET p_msg = p_versao CLIPPED,"\n","\n",
                " LOGIX 10.02 ","\n","\n",
                " Home page: www.aceex.com.br ","\n","\n",
                " (0xx11) 4991-6667 ","\n","\n"

    CALL log0030_mensagem(p_msg,'excla')

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#