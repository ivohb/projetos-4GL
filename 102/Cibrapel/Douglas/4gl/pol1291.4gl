#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: POL1291                                                 #
# OBJETIVO: MAPA DE CARGA E FRETE                                   #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 03/08/15                                                #
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
           p_sql                CHAR(950),
           p_msg                CHAR(500),
           p_last_row           SMALLINT,
           p_index              SMALLINT,
           s_index              SMALLINT,
           p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
           p_val_total_geral    DECIMAL(12,2),
           p_val_aparas         DECIMAL(12,2),
           p_val_aparas_sst     DECIMAL(12,2),
           p_val_bobinas        DECIMAL(12,2),
           p_val_bobinas_sst    DECIMAL(12,2),
           p_val_canudo         DECIMAL(12,2),
           p_val_canudo_sst     DECIMAL(12,2),
           p_val_frete_total    DECIMAL(12,2),
           p_peso_total_geral   DECIMAL(10,3),
           p_peso_aparas        DECIMAL(10,3),
           p_peso_bobinas       DECIMAL(10,3),
           p_peso_canudos       DECIMAL(10,3),
           p_val_total_rpa      DECIMAL(10,3),
           p_val_total_rnt      DECIMAL(10,3)

   DEFINE p_tela                RECORD 
          cod_transpor          LIKE clientes.cod_cliente,
          nom_transpor          LIKE clientes.nom_cliente,
          num_placa             LIKE transportador_placa_885.num_placa,
          tara_minima           LIKE transportador_placa_885.tara_minima,
          data_inicio_periodo   DATE,
          data_fim_periodo      DATE
   END RECORD
   
   DEFINE p_lista RECORD
          dat_emis_nf           LIKE nf_sup.dat_emis_nf,
          cod_fornecedor        LIKE fornecedor.cod_fornecedor,
          nom_fornecedor        LIKE fornecedor.raz_social,
          cod_familia           LIKE item.cod_familia,
          den_material          CHAR(20),
          num_nf                LIKE nf_sup.num_nf,
          val_nf                LIKE nf_sup.val_tot_nf_c,
          val_unit              LIKE nf_sup.val_tot_nf_c,
          val_frete             LIKE nf_sup.val_tot_nf_c,
          peso_nota             LIKE aviso_rec.qtd_recebida,
          num_aviso_rec         LIKE aviso_rec.num_aviso_rec,
          num_placa             LIKE transportador_placa_885.num_placa
   END RECORD
   
   DEFINE p_familia_insumo_885 RECORD
          ies_apara             LIKE familia_insumo_885.ies_apara, 
          ies_bobina            LIKE familia_insumo_885.ies_bobina, 
          ies_canudo            LIKE familia_insumo_885.ies_canudo
   END RECORD

END GLOBALS

MAIN
    CALL log0180_conecta_usuario()
    WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 300 
    WHENEVER ANY ERROR STOP
    DEFER INTERRUPT
 	    LET p_versao = "pol1291-10.02.01"
    OPTIONS
        NEXT KEY control-f,
        INSERT KEY control-i,
        DELETE KEY control-e,
        PREVIOUS KEY control-b
 
    CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
    {LET p_cod_empresa = '01'; LET p_user = 'admlog'; LET p_status = 0}
    
    IF p_status = 0  THEN
        CALL pol1291_menu()
    END IF
 
END MAIN

#----------------------#
 FUNCTION pol1291_menu()
#----------------------#

    CALL log006_exibe_teclas("01",p_versao)
    INITIALIZE p_nom_tela TO NULL
    CALL log130_procura_caminho("pol1291") RETURNING p_nom_tela
    LET p_nom_tela = p_nom_tela CLIPPED
    OPEN WINDOW w_pol1291 AT 2,2 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

    DISPLAY p_cod_empresa TO cod_empresa

    MENU "OPCAO"
        COMMAND "Informar" "Informar Parâmetros p/ consulta"
            CALL pol1291_informar() RETURNING p_status
            IF p_status THEN
                MESSAGE "Parâmetros informados com sucesso !!!"
                LET p_ies_cons = TRUE
                NEXT OPTION "Listar"
            ELSE
                ERROR "Operação Cancelada !!!"
                NEXT OPTION "Fim"
            END IF
        COMMAND "Listar" "Listagem de carga e frete"
            IF pol1291_listagem() THEN
                MESSAGE "Processando a Extracao do Relatorio..." 
            END IF
        COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
            CALL pol1291_sobre()
        COMMAND KEY ("!")
            PROMPT "Digite o comando : " FOR comando
            RUN comando
            PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
            DATABASE logix
         COMMAND "Fim" "Retorna ao menu anterior."
             EXIT MENU
    END MENU
    CLOSE WINDOW w_pol1291

END FUNCTION

#--------------------------#
FUNCTION pol1291_informar()
#--------------------------#
    INITIALIZE p_tela TO NULL
    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    
    INPUT BY NAME p_tela.*
        WITHOUT DEFAULTS     
        
        AFTER FIELD cod_transpor
            IF p_tela.cod_transpor IS NULL THEN
                ERROR "Campo de Preenchimento Obrigatorio"
                NEXT FIELD cod_transpor
            END IF
        	IF p_tela.cod_transpor IS NOT NULL THEN
        	    SELECT COUNT(cod_transpor)
                  INTO p_count
                  FROM fornec_tara_minima_885
                 WHERE cod_transpor   = p_tela.cod_transpor

                IF STATUS <> 0 THEN
                    CALL log003_err_sql("Lendo","fornec_tara_minima_885")
                    RETURN FALSE
                END IF
                IF p_count = 0 THEN
                    ERROR 'Transportador não Localizado.'
                    RETURN FALSE
                END IF
      
                SELECT nom_cliente
                  INTO p_tela.nom_transpor
                  FROM clientes
                 WHERE cod_cliente = p_tela.cod_transpor
                IF STATUS = 100 THEN
                    ERROR 'Transportador não Localizado.'
                    NEXT FIELD cod_transpor
                ELSE
                    IF STATUS <> 0 THEN
                        CALL log003_err_sql('SELECT','fornec_tara_minima_885')
                        RETURN FALSE
                    END IF
                END IF
                DISPLAY p_tela.nom_transpor TO nom_transpor
             END IF
             
        AFTER FIELD num_placa
            IF p_tela.num_placa IS NULL THEN
                ERROR "Campo de Preenchimento Obrigatorio"
                NEXT FIELD num_placa
            END IF
            IF p_tela.num_placa IS NOT NULL THEN
                SELECT tara_minima
                  INTO p_tela.tara_minima
                  FROM transportador_placa_885
                 WHERE cod_transpor = p_tela.cod_transpor
                   AND num_placa    = p_tela.num_placa
                       
                IF STATUS = 100 THEN
                    ERROR 'Placa não localizada.'
                    NEXT FIELD num_placa
                ELSE
                    IF STATUS <> 0 THEN
                        CALL log003_err_sql('SELECT','transportador_placa_885')
                        RETURN FALSE
                    END IF
                END IF
                DISPLAY p_tela.tara_minima TO tara_minima
             END IF
             
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
                         
        ON KEY (control-z)
            CALL pol1291_popup()
            
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

#-----------------------#
FUNCTION pol1291_popup()
#-----------------------#
    DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1291
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_transpor = p_codigo CLIPPED
            DISPLAY p_tela.cod_transpor TO cod_transpor
         END IF
  
      WHEN INFIELD(num_placa)
         CALL pol1291_popup_placa() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1291
         IF p_codigo IS NOT NULL THEN
            LET p_tela.num_placa = p_codigo CLIPPED
            DISPLAY p_tela.num_placa TO num_placa
         END IF
    END CASE

END FUNCTION

#-----------------------------#
FUNCTION pol1291_popup_placa()#
#-----------------------------#
    DEFINE l_index SMALLINT
    DEFINE pr_placas ARRAY[100] OF RECORD 	
           cod_transpor LIKE clientes.cod_cliente,
           nom_transpor LIKE clientes.nom_cliente,
           num_placa    LIKE transportador_placa_885.num_placa
    END RECORD
    
    CALL log006_exibe_teclas("01",p_versao)
    INITIALIZE p_nom_tela TO NULL
    CALL log130_procura_caminho("pol12911") RETURNING p_nom_tela
    LET p_nom_tela = p_nom_tela CLIPPED
    OPEN WINDOW w_pol12911 AT 2,16 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    DISPLAY p_cod_empresa TO cod_empresa
    
    LET l_index = 1
    
    DECLARE cq_placa CURSOR FOR 
    SELECT tp.cod_transpor,  
           cl.nom_cliente, 
           tp.num_placa
      FROM transportador_placa_885 tp, 
           clientes cl
     WHERE tp.cod_transpor = cl.cod_cliente
       AND tp.cod_transpor = p_tela.cod_transpor
     ORDER BY 1,2,3
 
    FOREACH cq_placa INTO pr_placas[l_index].*
        LET l_index = l_index + 1
        
        IF l_index > 100 THEN
            LET p_msg = 'Limite de grade ultrapassado !!!'
            CALL log0030_mensagem(p_msg,'exclamation')
            EXIT FOREACH
        END IF
                
    END FOREACH

    CALL SET_COUNT(l_index -1)

    DISPLAY ARRAY pr_placas TO sr_placas.* 
    
    LET p_index = ARR_CURR()
    LET s_index = SCR_LINE()

    CLOSE WINDOW w_pol12911

    IF INT_FLAG = 0 THEN
        RETURN pr_placas[p_index].num_placa
    ELSE
        LET INT_FLAG = 0
        RETURN FALSE
    END IF

END FUNCTION

#--------------------------#
FUNCTION pol1291_listagem()
#--------------------------#
    
    LET p_val_total_geral  = 0
    LET p_val_aparas       = 0
    LET p_val_aparas_sst   = 0
    LET p_val_bobinas      = 0
    LET p_val_bobinas_sst  = 0
    LET p_val_canudo       = 0
    LET p_val_canudo_sst   = 0
    LET p_val_frete_total  = 0
    LET p_peso_total_geral = 0
    LET p_peso_aparas      = 0
    LET p_peso_bobinas     = 0
    LET p_peso_canudos     = 0

    IF NOT pol1291_escolhe_saida() THEN
        RETURN
    END IF

    IF NOT pol1291_le_den_empresa() THEN
        RETURN
    END IF

    LET p_comprime    = ascii 15
    LET p_descomprime = ascii 18
    LET p_6lpp        = ascii 27, "2"
    LET p_8lpp        = ascii 27, "0"

    LET p_count = 0
    LET p_sql = " SELECT tf.num_aviso_rec, tf.peso_balanca, tf.val_tonelada, tf.val_frete,",
                "        nf.num_nf, nf.dat_emis_nf, nf.val_tot_nf_c, nf.cod_fornecedor, ",
                "        fo.raz_social, tf.num_placa",
                "  FROM nf_x_tab_frete_885 tf, ",
                "       nf_sup nf,",
                "       fornecedor fo",
                " WHERE tf.cod_empresa = '",p_cod_empresa,"'",
                "   AND tf.cod_empresa = nf.cod_empresa",
                "   AND tf.num_aviso_rec = nf.num_aviso_rec",
                "   AND nf.cod_fornecedor = fo.cod_fornecedor" 
                
    IF p_tela.cod_transpor IS NOT NULL THEN
        LET p_sql = p_sql CLIPPED, " AND tf.cod_transpor = '",p_tela.cod_transpor,"' "
    END IF
    
    IF p_tela.num_placa IS NOT NULL THEN
        LET p_sql = p_sql CLIPPED, " AND tf.num_placa = '",p_tela.num_placa,"' "
    END IF 
    
    IF p_tela.data_inicio_periodo IS NOT NULL THEN
        LET p_sql = p_sql CLIPPED, ' '," AND nf.dat_emis_nf >=  '",p_tela.data_inicio_periodo,"' "
    END IF
    
    IF p_tela.data_fim_periodo IS NOT NULL THEN
        LET p_sql = p_sql CLIPPED, ' '," AND nf.dat_emis_nf <=  '",p_tela.data_fim_periodo,"' "
    END IF
    
    LET p_sql = p_sql CLIPPED, " ORDER BY tf.cod_empresa, tf.num_placa, nf.dat_emis_nf, nf.cod_fornecedor"
    
    PREPARE var_query FROM p_sql   
    DECLARE cq_impressao CURSOR FOR var_query

   FOREACH cq_impressao
       INTO p_lista.num_aviso_rec, p_lista.peso_nota, p_lista.val_unit, p_lista.val_frete, 
            p_lista.num_nf, p_lista.dat_emis_nf, p_lista.val_nf, p_lista.cod_fornecedor,
            p_lista.nom_fornecedor, p_lista.num_placa
            
        IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
            RETURN
        END IF
        
        LET p_peso_total_geral = p_peso_total_geral + p_lista.val_nf
        LET p_val_frete_total  = p_val_frete_total  + p_lista.val_frete

        SELECT cod_familia
          INTO p_lista.cod_familia
          FROM aviso_rec ar,
               item it
         WHERE num_aviso_rec = p_lista.num_aviso_rec
           AND ar.cod_item=it.cod_item
         GROUP BY it.cod_familia
        IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','aviso_rec')
            RETURN FALSE
        END IF
        
        SELECT ies_apara, ies_bobina, ies_canudo
           INTO p_familia_insumo_885.ies_apara, 
                p_familia_insumo_885.ies_bobina,
                p_familia_insumo_885.ies_canudo
           FROM familia_insumo_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_lista.cod_familia
        IF STATUS = 100 THEN
            ERROR "Fornecedor não localizado !!!"
            NEXT FIELD cod_fornecedor
        ELSE
            IF STATUS <> 0 THEN
                CALL log003_err_sql('lendo','familia_insumo_885')
                RETURN FALSE
            END IF
        END IF
        
        CASE 
            WHEN p_familia_insumo_885.ies_apara='S'
                 LET p_lista.den_material='APARAS'
                 LET p_peso_aparas = p_peso_aparas + p_lista.val_nf
            WHEN p_familia_insumo_885.ies_bobina='S'
                 LET p_lista.den_material='BOBINA'
                 LET p_peso_bobinas = p_peso_bobinas + p_lista.val_nf
            WHEN p_familia_insumo_885.ies_canudo='S'
                 LET p_lista.den_material='CANUDO'                 
                 LET p_peso_canudos = p_peso_canudos + p_lista.val_nf
        OTHERWISE
              LET p_lista.den_material=''
        END CASE 

        OUTPUT TO REPORT pol1291_relat(p_lista.num_placa)

        LET p_count = 1

    END FOREACH

    FINISH REPORT pol1291_relat

    IF p_count = 0 THEN
        ERROR "Não existem dados há serem listados !!!"
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
FUNCTION pol1291_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1291.tmp"
         START REPORT pol1291_relat TO p_caminho
      ELSE
         START REPORT pol1291_relat TO p_nom_arquivo
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1291_le_den_empresa()
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
REPORT pol1291_relat(p_num_placa)
#-----------------------------------#

   DEFINE p_num_placa LIKE transportador_placa_885.num_placa

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63

   FORMAT

      PAGE HEADER

         PRINT COLUMN 002,  p_den_empresa,
               COLUMN 090, "PAG. ", PAGENO USING "####&"

         PRINT COLUMN 002, "pol1291",
               COLUMN 013, "MAPA DE CARGA E FRETE - PLACA : ",p_num_placa,
               COLUMN 071, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME 
               
         PRINT COLUMN 002, "PERIODO DE: ", p_tela.data_inicio_periodo, " A ", p_tela.data_fim_periodo
         PRINT
      
      BEFORE GROUP OF p_num_placa
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, "DATA        FORNECEDOR      MATERIAL  DOCUMENTO  VAL.NF.      PESO NOTA    VAL.UNIT.    VAL.FRETE   "
      ON EVERY ROW
         PRINT COLUMN 002, p_lista.dat_emis_nf,
               COLUMN 014, p_lista.nom_fornecedor[1,15],
               COLUMN 030, p_lista.den_material[1,10],
               COLUMN 040, p_lista.num_nf USING "##########",
               COLUMN 051, p_lista.val_nf USING "########&.&&",
               COLUMN 064, p_lista.peso_nota USING "########&",
               COLUMN 077, p_lista.val_unit USING "########&.&&",
               COLUMN 090, p_lista.val_frete USING "########&.&&"

      AFTER GROUP OF p_num_placa
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, "TOTAL GERAL DESTE RELATORIO",
               COLUMN 064, p_peso_total_geral USING "########&"," KG",
               COLUMN 086, "R$",p_val_frete_total USING "###,###,##&.&&"
         PRINT
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, " TOTAL R.P.A. - Aparas  R$",
               COLUMN 064, p_peso_aparas USING "########&"," KG"
         PRINT COLUMN 002, "       S.S.T.           R$"
         PRINT
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, " TOTAL R.P.A. - Bobinas R$",
               COLUMN 064, p_peso_bobinas USING "########&"," KG"
         PRINT COLUMN 002, "       S.S.T.           R$"
         PRINT
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, " TOTAL R.P.A. - Canudos R$",
               COLUMN 064, p_peso_canudos USING "########&"," KG"
         PRINT COLUMN 002, "       S.S.T.           R$"
         PRINT
         PRINT COLUMN 002, "----------------------------------------------------------------------------------------------------"
         PRINT COLUMN 002, " RESUMO :",
               COLUMN 010, " TOTAL RPA:",
               COLUMN 020, p_val_total_rpa USING "###,###,##&.&&"
         PRINT COLUMN 010, " TOTAL RNT:",
               COLUMN 020, p_val_total_rnt USING "###,###,##&.&&"
         PRINT COLUMN 010, "-------------------"
         PRINT COLUMN 020, "R$",p_val_total_rpa+p_val_total_rnt USING "###,###,##&.&&"
         
      ON LAST ROW
         PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"

      PAGE TRAILER
         PRINT COLUMN 002, "-----------------------------------------------------------------------------------------"


END REPORT


#-----------------------#
FUNCTION pol1291_sobre()
#-----------------------#

    LET p_msg = p_versao CLIPPED,"\n","\n",
                " LOGIX 10.02 ","\n","\n",
                " Home page: www.aceex.com.br ","\n","\n",
                " (0xx11) 4991-6667 ","\n","\n"

    CALL log0030_mensagem(p_msg,'excla')

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#