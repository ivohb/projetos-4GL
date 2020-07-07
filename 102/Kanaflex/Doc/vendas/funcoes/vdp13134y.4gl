###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP13134                                              #
# OBJETIVO:  EPL DE PEDIDOS ON LINE                               #
# AUTOR...: LUCIANA NAOMI KANEKO                                  #
# DATA....: 12/09/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix
GLOBALS
  DEFINE g_ies_grafico       SMALLINT

END GLOBALS

   DEFINE m_empresa         LIKE empresa.cod_empresa
   DEFINE sql_stmt          CHAR(3000)
   DEFINE where_clause      CHAR(1500)

  DEFINE m_user                    LIKE usuarios.cod_usuario,
         m_comando                 CHAR(080),
         m_pedido                  LIKE pedido_dig_mest.num_pedido,
         m_nom_tela                CHAR(80),
         m_versao_funcao           CHAR(18),
         m_status                  SMALLINT,
         m_sc_curr                 SMALLINT,
         m_curr                    SMALLINT

  DEFINE ma_pedido_dig_item        ARRAY[500]  OF  RECORD
         parametro_dat            LIKE pedido_dig_item.prz_entrega
                       END RECORD

  DEFINE m_linha_produto      LIKE ped_info_compl.parametro_texto,
         m_ies_txt_exped          CHAR(001)   #E# - 469670


#-----------------------------------------------------------------#
FUNCTION vdp13134y_before_field_cod_cliente()
#-----------------------------------------------------------------#
  DEFINE l_ind               SMALLINT

  LET m_empresa            = LOG_getVar("empresa")

  INITIALIZE m_linha_produto TO NULL
  LET m_ies_txt_exped = 'N'

  FOR l_ind = 1 TO 500
      INITIALIZE ma_pedido_dig_item[l_ind].parametro_dat TO NULL
  END FOR

  INPUT m_linha_produto WITHOUT DEFAULTS FROM linha_produto

  AFTER  FIELD linha_produto
         IF  m_linha_produto IS NULL OR
             m_linha_produto = ' '   THEN
             CALL log0030_mensagem(" Obrigatório informar linha de produto ","excl")
             NEXT FIELD linha_produto
         END IF

  END INPUT

RETURN TRUE
END FUNCTION

#-----------------------------------------------------------------#
FUNCTION vdp13134y_after_field_m_ies_incl_txt()
#-----------------------------------------------------------------#
  LET m_empresa            = LOG_getVar("empresa")

  INPUT m_ies_txt_exped WITHOUT DEFAULTS FROM ies_txt_exped

  AFTER  FIELD ies_txt_exped
       IF  m_ies_txt_exped IS NOT NULL THEN
           IF  m_ies_txt_exped = "S" THEN
               IF  NOT vdpy154_digita_texto_exped(0,'CONSULTA') THEN
                   LET m_ies_txt_exped = "N"
                   DISPLAY m_ies_txt_exped TO ies_txt_exped
               END IF
           END IF
       END IF

  END INPUT

RETURN TRUE
END FUNCTION

#-----------------------------------------------------------------#
FUNCTION vdp13134y_before_open_window_item()
#-----------------------------------------------------------------#
  LET m_empresa            = LOG_getVar("empresa")
  LET m_nom_tela           = LOG_getVar("nom_tela")


  CALL log130_procura_caminho("vdp41342y") RETURNING m_nom_tela  #os TDQPX4

      CALL LOG_setVar("nom_tela",m_nom_tela)
      #EPL Nome da tela
      #EPL TIPO: char(80)

RETURN TRUE
END FUNCTION

#------------------------------------#
FUNCTION vdp13134y_before_inclusao_pedido()
#------------------------------------#

 CALL vdpy154_cria_w_ped_inf_cpl() # TABELA COPIA DA PED_INFO_COMPL
                                   # PARA GRAVACAO DA OSERVACAO DE EXPEDICAO.


RETURN TRUE

END FUNCTION


#-----------------------------------------------------------------#
FUNCTION vdp13134y_after_insert_vendor_pedido()
#-----------------------------------------------------------------#

  LET m_empresa            = LOG_getVar("empresa")
  LET m_pedido             = LOG_getVar("pedido")

     IF  NOT vdpy154_grava_txt_obs_exped(m_pedido) THEN
         RETURN FALSE
     END IF

  FOR m_curr = 1 TO  500
    IF ma_pedido_dig_item[m_curr].parametro_dat IS NOT NULL AND
       ma_pedido_dig_item[m_curr].parametro_dat <> '31/12/1899' THEN
       WHENEVER ERROR CONTINUE
       INSERT INTO vdp_ped_item_compl (empresa,
                                       pedido ,
                                       sequencia_pedido,
                                       campo ,
                                       parametro_dat)
                            VALUES ( m_empresa,
                                     m_pedido,
                                     m_curr,
                                     'data_cliente',
                                     ma_pedido_dig_item[m_curr].parametro_dat)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INCLUSAO","vdp_ped_item_compl")
           RETURN FALSE
        END IF
    ELSE
       EXIT FOR
    END IF
  END FOR

RETURN TRUE
END FUNCTION


#-----------------------------------------------------------------#
FUNCTION vdp13134y_before_field_auxiliar()
#-----------------------------------------------------------------#
  DEFINE l_prz_entrega      LIKE pedido_dig_item.prz_entrega

  LET m_empresa            = LOG_getVar("empresa")
  LET m_pedido             = LOG_getVar("pedido")
  LET l_prz_entrega        = LOG_getVar("prz_entrega")
  LET m_curr               = LOG_getVar("arr_curr")
  LET m_sc_curr            = LOG_getVar("scr_line")

#   IF ma_pedido_dig_item[m_curr].parametro_dat IS NULL OR
#      ma_pedido_dig_item[m_curr].parametro_dat = '31/12/1899' THEN
#      LET ma_pedido_dig_item[m_curr].parametro_dat = l_prz_entrega
#   END IF

   INPUT ma_pedido_dig_item[m_curr].parametro_dat WITHOUT DEFAULTS
    FROM s_pedido_dig_item[m_sc_curr].parametro_dat

     BEFORE FIELD parametro_dat
        IF ma_pedido_dig_item[m_curr].parametro_dat IS NULL OR
           ma_pedido_dig_item[m_curr].parametro_dat = '31/12/1899' THEN
           LET ma_pedido_dig_item[m_curr].parametro_dat = l_prz_entrega
        END IF

        DISPLAY ma_pedido_dig_item[m_curr].parametro_dat TO s_pedido_dig_item[m_sc_curr].parametro_dat

     AFTER FIELD parametro_dat
        IF ma_pedido_dig_item[m_curr].parametro_dat < TODAY THEN
           CALL log0030_mensagem( " DATA menor que a data corrente","excl")
           NEXT FIELD parametro_dat
        END IF
   END INPUT

RETURN TRUE
END FUNCTION


#------------------------------------#
FUNCTION vdp13134y_ativa_zoom(l_ativa)
#------------------------------------#
 DEFINE l_ativa SMALLINT
 IF l_ativa THEN
    IF g_ies_grafico THEN
       #Ativação do botão de zoom no ambiente gráfico
       --# CALL fgl_dialog_setkeylabel('control-z','Zoom')
    ELSE
       #Apresentação fixa no canto superior direito da tela
       DISPLAY "( Zoom )" AT 3,60
    END IF
 ELSE
    IF g_ies_grafico THEN
       #Desativação do botão de zoom no ambiente gráfico
       --# CALL fgl_dialog_setkeylabel('control-z',NULL)
    ELSE
       #Retirar texto fixo de zoom no canto superior direito da tela
       DISPLAY "--------" AT 3,60
    END IF
 END IF
 END FUNCTION

#-------------------------------#
 FUNCTION vdp13134y_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp13134y.4gl $|$Revision: 3 $|$Date: 05/10/11 15:04 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION
