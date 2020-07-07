#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: POL0409                                               #
# MODULOS.: POL0409                                               #
# OBJETIVO: DIGITACAO DA SOLICITACAO DE FATURAMENTO               #
# AUTOR   : POLO INFORMATICA                                      #
# DATA    : 15/12/2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

   DEFINE 
          p_ordem_montag_lote RECORD LIKE ordem_montag_lote.*,
          p_ordem_montag_mest RECORD LIKE ordem_montag_mest.*,
          p_ordem_montag_item RECORD LIKE ordem_montag_item.*,
      #   p_om_lacre_marfrig  RECORD LIKE om_lacre_marfrig.*,
          p_pedidos           RECORD LIKE pedidos.*,
          p_par_vdp           RECORD LIKE par_vdp.*,
          p_query             CHAR(600),
          p_num_pedido       INTEGER,
          p_qtd_volume       INTEGER,
          l_qtd_padr_embal   INTEGER,
          p_cod_cliente      CHAR(15),
          p_cod_uni_feder    CHAR(02),
          p_cod_estado       CHAR(02),
          p_nom_transpor     CHAR(36),
          p_ies_sit_lote      CHAR(1),               
          p_tip_err           CHAR(1),               
          p_num_om            INTEGER,
          p_den_texto         CHAR(40),
          p_ind_om            INTEGER,
          p_num_transac       INTEGER,
          p_cod_empresa       LIKE empresa.cod_empresa,
          p_user              LIKE usuario.nom_usuario,
          p_usuario           LIKE usuario.nom_usuario,
          p_cod_cidade        LIKE clientes.cod_cidade,
          p_status            SMALLINT,
          p_last_row          SMALLINT,
          p_den_empresa       CHAR(36),
          p_ies_impressao     CHAR(01),
          p_nom_usuario       LIKE usuario.nom_usuario,
          p_den_via_transp    LIKE via_transporte.den_via_transporte,
          p_den_transpor      LIKE transport.den_transpor,
          p_num_solicit       decimal(4,0),
          p_dat_refer         date,
          p_cod_transpor      CHAR(15),
          p_num_placa         char(7),
          p_cod_tip_carteira  LIKE tipo_carteira.cod_tip_carteira,
          p_cod_entrega       LIKE entregas.cod_entrega,
          p_ies_cons          SMALLINT,
          pa_curr             SMALLINT,
          sc_curr             SMALLINT,
          p_ind               SMALLINT,
          p_prim_item_eh_wis  SMALLINT,
          p_prim_item_eh_wms  SMALLINT,
          p_val_frete         LIKE nf_solicit.val_frete,
          p_cod_embal         LIKE fat_solic_embal.embalagem,
          p_qtd_embal         LIKE fat_solic_embal.qtd_embalagem,
		      x_cod_transpor      LIKE ordem_montag_lote.cod_transpor,
          p_val_seguro        decimal(15,2),
          p_pes_tot_bruto     decimal(15,2),
          p_pes_tot_liquido   decimal(15,2),
          p_Comprime          CHAR(01),
          p_descomprime       CHAR(01),
          p_6lpp              CHAR(100),
          p_8lpp              CHAR(100),
          p_index             SMALLINT,
          s_index             SMALLINT

   DEFINE p_relat              RECORD
					solicitacao_fatura   INTEGER,
					lote_ord_montag      INTEGER,
					transportadora       CHAR(15),
					placa_veiculo        CHAR(07),
					texto_1              SMALLINT,
					texto_2              SMALLINT,
					texto_3              SMALLINT,
					num_om               DECIMAL(6,0),
					qtd_volume_om        DECIMAL(15,3),
					embalagem            CHAR(03),
					qtd_embalagem        DECIMAL(9,2)
   END RECORD
   
   DEFINE p_embal_1            CHAR(03),
          p_embal_2            CHAR(03),
          p_embal_3            CHAR(03),
          p_embal_4            CHAR(03),
          p_embal_5            CHAR(03),
          p_qtd_embal_1        DECIMAL(9,2),
          p_qtd_embal_2        DECIMAL(9,2),
          p_qtd_embal_3        DECIMAL(9,2),
          p_qtd_embal_4        DECIMAL(9,2),
          p_qtd_embal_5        DECIMAL(9,2),
          p_trans_solic_fatura LIKE fat_solic_mestre.trans_solic_fatura,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_vezes              SMALLINT 
          
             

   DEFINE t1_nf_solicit       ARRAY[200] OF RECORD
          num_om              INTEGER,
          num_volume          decimal(7,0),
          cod_embal_1         char(3),           #código do pallet
          qtd_embal_1         char(6),      #quantidade de peças por pallet
          cod_embal_2         char(3),
          qtd_embal_2         char(6),
          cod_embal_3         char(3),
          qtd_embal_3         char(6),
          cod_embal_4         char(3),
          qtd_embal_4         char(6),
          cod_embal_5         char(3),
          qtd_embal_5         char(6),
          num_sequencia       INTEGER
   END RECORD

   DEFINE t_transp            ARRAY[200] OF RECORD
          cod_transpor        LIKE ordem_montag_lote.cod_transpor,
          num_placa           LIKE ordem_montag_lote.num_placa    
   END RECORD

   DEFINE t1_frete_seguro     ARRAY[200] OF RECORD
          num_solicit         INTEGER,
          num_sequencia       INTEGER,
          val_frete           decimal(15,2),
          val_seguro          decimal(15,2),
          pes_tot_liquido     decimal(15,2),
          pes_tot_bruto       decimal(15,2)
   END RECORD

   DEFINE t2_qtd_embal        ARRAY[500] OF RECORD
          cod_embal           CHAR(03),
          qtd_embal           DECIMAL(7,2)
   END RECORD

   DEFINE t_ordens            ARRAY[200] OF RECORD
          num_om              LIKE ordem_montag_mest.num_om,
          seq_ent             INTEGER
   END RECORD

   DEFINE t_om_item           ARRAY[100] OF RECORD
          cod_item            LIKE ordem_montag_item.cod_item,
          den_item_reduz      LIKE item.den_item_reduz,
          qtd_reservada       LIKE ordem_montag_item.qtd_reservada,
          pes_total_item      LIKE ordem_montag_item.pes_total_item
   END RECORD

   DEFINE p_nom_arquivo       CHAR(100),
          p_msg               CHAR(500),
          g_ies_ambiente      CHAR(01),
          p_comando           CHAR(080),
          p_caminho           CHAR(080),
          p_nom_tela          CHAR(080),
          p_help              CHAR(080),
          p_cancel            INTEGER,
          comando             CHAR(080)

   DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

   DEFINE p_nf_solicit        RECORD 
					cod_empresa          CHAR(2),
					num_solicit          DECIMAL(4,0),
					dat_refer            DATE,
					cod_via_transporte   decimal(2,0),
					cod_entrega          decimal(4,0),
					cod_mercado          char(2),
					cod_local_embarque   decimal(3,0),
					ies_mod_embarque     decimal(2,0),
					ies_tip_solicit      char(1),
					ies_lotes_geral      char(1),
					cod_tip_carteira     char(2),
					num_lote_om          decimal(6,0),
					num_om               decimal(6,0),
					num_controle         decimal(3,0),
					num_texto_1          decimal(3,0),
					num_texto_2          decimal(3,0),
					num_texto_3          decimal(3,0),
					val_frete            decimal(15,2),
					val_seguro           decimal(15,2),
					val_frete_ex         decimal(15,2),
					val_seguro_ex        decimal(15,2),
					pes_tot_bruto        decimal(13,4),
					ies_situacao         char(1),
					num_sequencia        SMALLINT,
					nom_usuario          char(8),
					cod_transpor         char(15),
					num_placa            char(7),
					cod_estado           CHAR(02),
					num_volume           decimal(7,0),
					cod_embal_1          char(3),
					qtd_embal_1          decimal(4,0),
					cod_embal_2          char(3),
					qtd_embal_2          decimal(4,0),
					cod_embal_3          char(3),
					qtd_embal_3          decimal(4,0),
					cod_embal_4          char(3),
					qtd_embal_4          decimal(4,0),
					cod_embal_5          char(3),
					qtd_embal_5          decimal(4,0),
					cod_cnd_pgto         decimal(3,0),
					pes_tot_liquido      decimal(13,4),
					qtd_dias_acr_dupl    decimal(3,0)   
   END RECORD

   DEFINE p_nf_solicitr        RECORD 
					cod_empresa          CHAR(2),
					num_solicit          DECIMAL(4,0),
					dat_refer            DATE,
					cod_via_transporte   decimal(2,0),
					cod_entrega          decimal(4,0),
					cod_mercado          char(2),
					cod_local_embarque   decimal(3,0),
					ies_mod_embarque     decimal(2,0),
					ies_tip_solicit      char(1),
					ies_lotes_geral      char(1),
					cod_tip_carteira     char(2),
					num_lote_om          decimal(6,0),
					num_om               decimal(6,0),
					num_controle         decimal(3,0),
					num_texto_1          decimal(3,0),
					num_texto_2          decimal(3,0),
					num_texto_3          decimal(3,0),
					val_frete            decimal(15,2),
					val_seguro           decimal(15,2),
					val_frete_ex         decimal(15,2),
					val_seguro_ex        decimal(15,2),
					pes_tot_bruto        decimal(13,4),
					ies_situacao         char(1),
					num_sequencia        SMALLINT,
					nom_usuario          char(8),
					cod_transpor         char(15),
					num_placa            char(7),
					cod_estado           CHAR(02),
					num_volume           decimal(7,0),
					cod_embal_1          char(3),
					qtd_embal_1          decimal(4,0),
					cod_embal_2          char(3),
					qtd_embal_2          decimal(4,0),
					cod_embal_3          char(3),
					qtd_embal_3          decimal(4,0),
					cod_embal_4          char(3),
					qtd_embal_4          decimal(4,0),
					cod_embal_5          char(3),
					qtd_embal_5          decimal(4,0),
					cod_cnd_pgto         decimal(3,0),
					pes_tot_liquido      decimal(13,4),
					qtd_dias_acr_dupl    decimal(3,0)   
   END RECORD
      
   
   DEFINE p_nser       LIKE vdp_num_docum.serie_docum,
          p_sser       LIKE vdp_num_docum.subserie_docum,
          p_espcie     LIKE vdp_num_docum.especie_docum,
          p_tip_docum  LIKE vdp_num_docum.tip_docum,
          p_tip_solic  LIKE vdp_num_docum.tip_solicitacao
        
END GLOBALS

DEFINE  p_contador               SMALLINT,
        p_count                  SMALLINT,
        p_controle               SMALLINT

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0409-10.02.30" 
   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()              
   SET LOCK MODE TO WAIT
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho CLIPPED
   OPTIONS
      HELP     FILE p_help ,
      INSERT   KEY  control-i,
      DELETE   KEY  control-e,
      NEXT     KEY  control-f,
      PREVIOUS KEY  control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      SELECT par_vdp.* INTO p_par_vdp.*
      FROM par_vdp
      WHERE par_vdp.cod_empresa = p_cod_empresa
      CALL pol0409_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0409_controle()
#--------------------------#

  CALL log006_exibe_teclas("01", p_versao)
  INITIALIZE p_nf_solicit.*,
             p_nf_solicitr.* TO NULL

  CALL log130_procura_caminho("POL0409") RETURNING p_nom_tela
  OPEN WINDOW w_pol0409 AT 2,02 WITH FORM p_nom_tela
     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


 SELECT UNIQUE tip_solicitacao,
			   serie_docum,  
               subserie_docum,
               especie_docum,  
               tip_docum
   INTO p_tip_solic,
        p_nser,
        p_sser,
        p_espcie,
        p_tip_docum
   FROM vdp_num_docum 
  WHERE  empresa = p_cod_empresa
    AND  tip_solicitacao='SOLPRDSV'
	  AND  serie_docum='1'  
  
  IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','vdp_num_docum:1')
     RETURN
  END IF
  
  
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui Solicitacao de Faturamento"
      HELP 0001
      MESSAGE ""
      CALL log085_transacao("BEGIN")
      CALL pol0409_digitacao_nf_solicit() RETURNING p_status
      IF p_status THEN
         CALL log085_transacao("COMMIT")
         LET p_msg = 'Solicitação gerada com sucesso!'
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_msg = 'Operação cancelada!'
      END IF
      CALL log0030_mensagem(p_msg,'excla')
    COMMAND "Modificar"  "Modifica Solicitacao de Faturamento selecionada"
      HELP 0002
      MESSAGE ""
      IF p_ies_cons THEN 
         CALL pol0409_modificacao_solicitacao()
      ELSE
        MESSAGE "Consulte Previamente para fazer a Modificacao" 
           ATTRIBUTE(REVERSE)
      # CALL log0030_mensagem("Consulte previamente para fazer a modificacao. "
      #                       ,"exclamation")
      END IF
    COMMAND "Excluir"  "Exclui Solicitacao de Faturamento selecionada"
      HELP 0003
      MESSAGE ""
      IF p_ies_cons THEN  
         CALL pol0409_exclusao_solicitacao() 
      ELSE
         MESSAGE "Consulte Previamente para fazer a Exclusao"
            ATTRIBUTE(REVERSE)
      END IF
    COMMAND "Consultar"  "Consulta tabela de Solicitacao de Faturamento"
      HELP 0004
      MESSAGE ""
         CALL pol0409_query_solicitacao()
         NEXT OPTION "Seguinte"
    COMMAND "Seguinte"   "Exibe item seguinte"
      HELP 0005
      MESSAGE ""
      CALL pol0409_paginacao("SEGUINTE")
    COMMAND "Anterior"   "Exibe item anterior"
      HELP 0006
      MESSAGE ""
      CALL pol0409_paginacao("ANTERIOR")
    COMMAND KEY ("T") "faTurar"  "Consistir e faturar a solicitação"
			HELP 0001
			CALL log120_procura_caminho("VDP0745") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0409
    COMMAND "Listar" "Listagem"
      CALL pol0409_listagem()
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0409_sobre()
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
    # DATABASE logix
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0409

END FUNCTION

#-----------------------#
FUNCTION pol0409_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------------#
 FUNCTION pol0409_digitacao_nf_solicit()
#--------------------------------------#
 
  LET p_nf_solicitr.* = p_nf_solicit.*
  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa
  LET p_num_transac = 0
 
  INITIALIZE p_nf_solicit.*,
             p_ordem_montag_lote.*,
             t1_nf_solicit,
             t_ordens,         
             t1_frete_seguro TO NULL
             
  IF pol0409_dados_mestre("INCLUSAO") THEN
     IF pol0409_dados_solicitacao("INCLUSAO") THEN
        IF pol0409_efetiva_inclusao("I") THEN
           LET p_ies_cons = FALSE
           RETURN TRUE
        END IF
     END IF
  END IF

  CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa

  RETURN FALSE

END FUNCTION

#--------------------------------------#
 FUNCTION pol0409_dados_mestre(p_funcao)
#--------------------------------------#

  DEFINE p_funcao  CHAR(12)

  CALL log006_exibe_teclas("01 02 03 07", p_versao)
  CURRENT WINDOW IS w_pol0409
  LET INT_FLAG = FALSE
  
  LET p_nf_solicit.cod_empresa        = p_cod_empresa
  LET p_nf_solicit.cod_entrega        = 0
  LET p_nf_solicit.cod_local_embarque = NULL
  LET p_nf_solicit.ies_mod_embarque   = NULL
  LET p_nf_solicit.cod_mercado        = NULL
  LET p_nf_solicit.val_frete          = 0
  LET p_nf_solicit.val_seguro         = 0
  LET p_nf_solicit.val_frete_ex       = 0
  LET p_nf_solicit.val_seguro_ex      = 0

  IF p_funcao <> "MODIFICACAO" THEN
      LET p_nf_solicit.dat_refer          = TODAY
      LET p_nf_solicit.num_lote_om        = 0
      LET p_nf_solicit.cod_via_transporte = 1
      LET p_nf_solicit.pes_tot_bruto      = 0
      LET p_nf_solicit.pes_tot_liquido    = 0  
  END IF
  
  INPUT BY NAME p_nf_solicit.num_solicit,
                p_nf_solicit.dat_refer,
                p_ordem_montag_lote.num_lote_om,
                p_nf_solicit.cod_transpor,
                p_nf_solicit.num_placa,
                p_nf_solicit.cod_estado,
                p_nf_solicit.cod_via_transporte,
                p_nf_solicit.pes_tot_liquido,
                p_nf_solicit.pes_tot_bruto,
                p_nf_solicit.num_texto_1,
                p_nf_solicit.num_texto_2,
                p_nf_solicit.num_texto_3 WITHOUT DEFAULTS

    BEFORE FIELD num_solicit

           IF p_funcao = "MODIFICACAO" THEN
              NEXT FIELD cod_transpor
           END IF

    AFTER  FIELD num_solicit
           IF p_nf_solicit.num_solicit IS NULL THEN
              ERROR 'Campo com preenchimento obrigat´rio1'
                NEXT FIELD num_solicit
           END IF
           
           IF   pol0409_verifica_num_solicit()
           THEN ERROR "Solicitacao Já Digitada - Use Modificacao"
                NEXT FIELD num_solicit
           END IF

    BEFORE FIELD dat_refer

           IF p_funcao = "MODIFICACAO" THEN
              NEXT FIELD cod_transpor
           END IF

    AFTER FIELD dat_refer
           IF pol0409_verifica_data() THEN
              IF   log004_confirm(10,32) THEN
              ELSE 
                 NEXT FIELD dat_refer
              END IF
           ELSE 
              IF p_nf_solicit.dat_refer <> TODAY THEN
                 ERROR "Data de referencia diferente da data corrente. Verifique parametros (VDP2330)"
                 IF p_par_vdp.par_vdp_txt[326] = "S" THEN
                    IF log004_confirm(10,32) THEN
                    ELSE 
                       NEXT FIELD dat_refer
                    END IF
                 ELSE 
                    NEXT FIELD dat_refer
                 END IF
              END IF
           END IF

    BEFORE FIELD num_lote_om

           IF p_funcao = "MODIFICACAO" THEN
              NEXT FIELD cod_transpor
           END IF

    AFTER FIELD num_lote_om  
               
          IF p_ordem_montag_lote.num_lote_om IS NULL THEN
             ERROR "O Campo Numero do Lote nao pode ser Nulo"
             NEXT FIELD num_lote_om           
          END IF

          IF NOT pol0409_verifica_lote() THEN
             IF p_msg IS NOT NULL THEN
                CALL log0030_mensagem(p_msg,'excla')
             END IF
             NEXT FIELD num_lote_om           
          END IF
 
          LET p_nf_solicit.num_lote_om = p_ordem_montag_lote.num_lote_om 
		  
		  CALL pol0409_le_transp() 
		   

    AFTER  FIELD cod_transpor
           
           IF p_nf_solicit.cod_transpor IS NOT NULL THEN
              IF NOT pol0409_verifica_transp() THEN
                 IF p_msg IS NOT NULL THEN
                    CALL log0030_mensagem(p_msg,'excla')
                 END IF
                 NEXT FIELD cod_transpor           
              END IF
           ELSE
              LET p_nom_transpor = NULL
           END IF
           
           DISPLAY p_nom_transpor TO nom_transpor
           LET p_nf_solicit.cod_estado = p_cod_estado
           DISPLAY p_cod_estado to cod_estado

    AFTER  FIELD cod_via_transporte
    
           IF p_nf_solicit.cod_via_transporte IS NOT NULL THEN
              IF  NOT pol0409_verifica_via_transporte() THEN
                 ERROR " Via de Transporte nao cadastrada "
                 NEXT FIELD cod_via_transporte
              END IF
           END IF
           
    AFTER  FIELD pes_tot_liquido
           
           IF p_nf_solicit.pes_tot_liquido IS NULL THEN
              LET p_nf_solicit.pes_tot_liquido = 0
           END IF
           
    AFTER  FIELD pes_tot_bruto
           
           IF p_nf_solicit.pes_tot_bruto IS NULL THEN
              LET p_nf_solicit.pes_tot_bruto = 0
           END IF

           IF p_nf_solicit.pes_tot_bruto <  p_nf_solicit.pes_tot_liquido THEN
                 ERROR " Peso bruto deve ser maior ou igual a peso liquido "
                 NEXT FIELD pes_tot_bruto
           END IF

    AFTER  FIELD num_texto_1 
           
           LET p_den_texto = NULL
           
           IF p_nf_solicit.num_texto_1 IS NOT NULL THEN
              IF NOT  pol0409_le_den_txt(p_nf_solicit.num_texto_1) THEN
                 CALL log0030_mensagem(p_msg,'excla')
                 NEXT FIELD num_texto_1
              END IF
           END IF
           
           DISPLAY p_den_texto TO den_texto_1

    AFTER  FIELD num_texto_2
           
           LET p_den_texto = NULL

           IF p_nf_solicit.num_texto_2 IS NOT NULL THEN
              IF NOT  pol0409_le_den_txt(p_nf_solicit.num_texto_2) THEN
                 CALL log0030_mensagem(p_msg,'excla')
                 NEXT FIELD num_texto_2
              END IF
           END IF
           
           DISPLAY p_den_texto TO den_texto_2

    AFTER  FIELD num_texto_3
           
           LET p_den_texto = NULL

           IF p_nf_solicit.num_texto_3 IS NOT NULL THEN
              IF NOT  pol0409_le_den_txt(p_nf_solicit.num_texto_3) THEN
                 CALL log0030_mensagem(p_msg,'excla')
                 NEXT FIELD num_texto_3
              END IF
           END IF
           
           DISPLAY p_den_texto TO den_texto_3

    ON KEY (control-z,f4)
           CALL pol0409_popup()

    ON KEY (control-w,f1)
           CALL pol0409_help()
           
  END INPUT
  
  IF INT_FLAG = 0 THEN
     LET p_num_solicit      = p_nf_solicit.num_solicit
     LET p_dat_refer        = p_nf_solicit.dat_refer
     LET p_cod_entrega      = p_nf_solicit.cod_entrega
     RETURN TRUE
  ELSE 
     RETURN FALSE
  END IF
  
END FUNCTION
#---------------------------#
FUNCTION pol0409_le_transp()
#---------------------------#
   
   DEFINE x_num_placa CHAR(07)
   
    INITIALIZE x_cod_transpor TO NULL
      
      DECLARE cq_le_transp CURSOR FOR
       SELECT cod_transpor,
              num_placa
         FROM ordem_montag_lote
        WHERE cod_empresa = p_cod_empresa
          AND num_lote_om = p_ordem_montag_lote.num_lote_om
      
   FOREACH cq_le_transp INTO x_cod_transpor, x_num_placa
		IF 	x_cod_transpor IS NOT NULL THEN
			EXIT FOREACH
		END IF
   END FOREACH
  
  	IF x_cod_transpor IS NOT NULL THEN
	   LET p_nf_solicit.cod_transpor = x_cod_transpor
	   DISPLAY p_nf_solicit.cod_transpor TO cod_transpor
	END IF

  IF x_num_placa IS NOT NULL THEN
	   LET p_nf_solicit.num_placa = x_num_placa
	   DISPLAY p_nf_solicit.num_placa TO num_placa
	END IF
    
END FUNCTION   
#---------------------------------#
FUNCTION pol0409_verifica_transp()
#---------------------------------#

   LET p_msg = NULL
   
   SELECT nom_cliente,
          cod_cidade
     INTO p_nom_transpor,
          p_cod_cidade
     FROM clientes
    WHERE cod_cliente = p_nf_solicit.cod_transpor
      #AND cod_tip_cli = '99'
      AND ies_situacao = "A"

   IF STATUS = 100 THEN
      LET p_msg = 'Transportadora não cadastrada ou inativa!'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Trasnportador')
         RETURN FALSE
      END IF
   END IF
   
   SELECT cod_uni_feder
     INTO p_cod_estado
     FROM cidades
    WHERE cod_cidade = p_cod_cidade

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','cidades')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   
         
     
#------------------------------------#
FUNCTION pol0409_le_den_txt(p_cod_txt)
#------------------------------------#

   DEFINE p_cod_txt CHAR(5)
   
   LET p_msg = NULL
   
   SELECT des_texto
     INTO p_den_texto
     FROM texto_nf
    WHERE cod_texto = p_cod_txt

   IF STATUS <> 0 THEN
      LET p_msg = 'Texto não pode ser localizado na tabela texto_nf!'
      RETURN FALSE
   END IF
   
   IF p_nf_solicit.num_texto_1 = p_nf_solicit.num_texto_2 OR
      p_nf_solicit.num_texto_1 = p_nf_solicit.num_texto_3 OR
      p_nf_solicit.num_texto_2 = p_nf_solicit.num_texto_3 THEN
      LET p_msg = 'Favor não repetir o código do texto!'
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION
               
#----------------------------------#
  FUNCTION pol0409_verifica_data()
#----------------------------------#

  DEFINE p_dat_ult_fat     DATE,
         p_num_solicit     INTEGER,
         p_nom_usuario     CHAR(08),
         p_dat_refer       DATE

  INITIALIZE p_dat_ult_fat,
             p_num_solicit,
             p_nom_usuario,
             p_dat_refer  TO NULL

   SELECT dat_ult_fat INTO p_dat_ult_fat
     FROM fat_numero
    WHERE cod_empresa = p_cod_empresa

   IF SQLCA.sqlcode = 0 THEN
      
      IF p_dat_ult_fat > p_nf_solicit.dat_refer THEN
         
         OPEN  WINDOW w_pol04091 at 10,30 WITH 5 rows, 35 columns
               ATTRIBUTE (BORDER, PROMPT LINE LAST)
               DISPLAY " Data de referencia menor que a" AT 01,01
               DISPLAY " data da ultima nota emitida. " at 02,01
               DISPLAY " Data da ultima nota ",p_dat_ult_fat using "dd/mm/yyyy" AT 03,01
               DISPLAY " " AT 04,01
               PROMPT " Tecle enter p/ continuar " FOR comando
               CLOSE WINDOW w_pol04091
               RETURN TRUE
      END IF
   ELSE
      RETURN FALSE
   END IF
   
   {DECLARE c_ver_data CURSOR WITH HOLD FOR
    SELECT usuario,
           MAX(solicitacao_fatura),
           MAX(dat_refer)
     INTO p_nom_usuario,
          p_num_solicit,
          p_dat_refer
     FROM fat_solic_mestre
     WHERE empresa = p_cod_empresa
       AND dat_refer <> p_nf_solicit.dat_refer
     GROUP BY usuario
    
   FOREACH c_ver_data
       IF p_num_solicit > 0 THEN
          OPEN  WINDOW w_pol04091 at 10,20 WITH 5 rows, 40 columns
                ATTRIBUTE (BORDER, PROMPT LINE LAST)
          DISPLAY " Data de referencia diferente que " AT 01,01
          DISPLAY " data de referencia da solicitacao " at 02,01
          DISPLAY p_num_solicit USING "####&",
                 " do usuario(a) ",p_nom_usuario," - ",
                 p_dat_refer USING "DD/MM/YYYY"  AT 03,01
          DISPLAY " " AT 04,01
          PROMPT " Tecle enter p/ continuar " FOR comando
          CLOSE WINDOW w_pol04091
          RETURN TRUE
       END IF
   END FOREACH}
    
   RETURN FALSE
    
END FUNCTION

#-----------------------#
 FUNCTION pol0409_popup()
#-----------------------#
  DEFINE p_cod_via_transporte  LIKE nf_solicit.cod_via_transporte,
         p_cod_tip_carteira    LIKE nf_solicit.cod_tip_carteira,
         p_cod_entrega         LIKE nf_solicit.cod_entrega,
         p_cnd_pgto            LIKE nf_solicit.cod_cnd_pgto
  CASE
    WHEN infield(cod_transpor)
         LET  p_cod_transpor = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         IF   p_cod_transpor IS NOT NULL
         THEN LET p_nf_solicit.cod_transpor = p_cod_transpor
              DISPLAY p_nf_solicit.cod_transpor TO cod_transpor
         END IF
    WHEN infield(cod_via_transporte)
         CALL log009_popup(6,25,"VIA TRANSPORTE","via_transporte",
                          "cod_via_transporte","den_via_transporte",
                          "vdp2520","N","") RETURNING p_cod_via_transporte
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         IF   p_cod_via_transporte IS NOT NULL
         THEN LET p_nf_solicit.cod_via_transporte = p_cod_via_transporte
              DISPLAY BY NAME p_nf_solicit.cod_via_transporte
         END IF
    WHEN infield(num_texto_1)
          CALL log009_popup(6,25,"TEXTO NF","texto_nf",
                            "cod_texto","des_texto",
                            "vdp0390","N","") RETURNING p_nf_solicit.num_texto_1
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY p_nf_solicit.num_texto_1 TO num_texto_1
    WHEN infield(num_texto_2)
          CALL log009_popup(6,25,"TEXTO NF","texto_nf",
                            "cod_texto","des_texto",
                            "vdp0390","N","") RETURNING p_nf_solicit.num_texto_2
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY p_nf_solicit.num_texto_2 TO num_texto_2
    WHEN infield(num_texto_3)
          CALL log009_popup(6,25,"TEXTO NF","texto_nf",
                            "cod_texto","des_texto",
                            "vdp0390","N","") RETURNING p_nf_solicit.num_texto_3
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY p_nf_solicit.num_texto_3 TO num_texto_3
    WHEN infield(cod_embal_1)
         CALL log009_popup(6,25,"EMBALAGEM","embalagem",
                           "cod_embal","den_embal",
                           "vdp0300","N","") RETURNING t1_nf_solicit[pa_curr].cod_embal_1
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].cod_embal_1 TO s_nf_solicit[sc_curr].cod_embal_1
    WHEN infield(cod_embal_2)
       CALL log009_popup(6,25,"EMBALAGEM","embalagem",
                        "cod_embal","den_embal",
                         "vdp0300","N","") RETURNING t1_nf_solicit[pa_curr].cod_embal_2
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].cod_embal_2 TO s_nf_solicit[sc_curr].cod_embal_2
    WHEN infield(cod_embal_3)
       CALL log009_popup(6,25,"EMBALAGEM","embalagem",
                         "cod_embal","den_embal",
                         "vdp0300","N","") RETURNING t1_nf_solicit[pa_curr].cod_embal_3
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].cod_embal_3 TO s_nf_solicit[sc_curr].cod_embal_3
    WHEN infield(cod_embal_4)
         CALL log009_popup(6,25,"EMBALAGEM","embalagem",
                         "cod_embal","den_embal",
                         "vdp0300","N","") RETURNING t1_nf_solicit[pa_curr].cod_embal_4
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].cod_embal_4 TO s_nf_solicit[sc_curr].cod_embal_4
    WHEN infield(cod_embal_5)
         CALL log009_popup(6,25,"EMBALAGEM","embalagem",
                           "cod_embal","den_embal",
                          "vdp0300","N","") RETURNING t1_nf_solicit[pa_curr].cod_embal_5
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0409
         #CALL vdp710_delim_fields()
         DISPLAY t1_nf_solicit[pa_curr].cod_embal_5 TO s_nf_solicit[sc_curr].cod_embal_5
  END CASE
END FUNCTION

#---------------------#
 FUNCTION pol0409_help()
#---------------------#
  CASE
    WHEN infield(num_solicit)          CALL showhelp(3245)
    WHEN infield(dat_refer)            CALL showhelp(3238)
    WHEN infield(cod_via_transporte)   CALL showhelp(3246)
    WHEN infield(cod_transpor)         CALL showhelp(3247)
    WHEN infield(num_placa)            CALL showhelp(3248)
    WHEN infield(cod_tip_carteira)     CALL showhelp(3249)
    WHEN infield(cod_entrega)          CALL showhelp(3250)
    WHEN infield(num_om)               CALL showhelp(3251)
    WHEN infield(num_controle)         CALL showhelp(3252)
    WHEN infield(cod_cnd_pgto)         CALL showhelp(2185)
    WHEN infield(qtd_dias_acr_dupl)    CALL showhelp(5465)
    WHEN infield(num_texto_1)          CALL showhelp(3239)
    WHEN infield(num_texto_2)          CALL showhelp(3239)
    WHEN infield(num_texto_3)          CALL showhelp(3239)
    WHEN infield(num_volume)           CALL showhelp(3253)
    WHEN infield(cod_embal_1)          CALL showhelp(3254)
    WHEN infield(qtd_embal_1)          CALL showhelp(3255)
    WHEN infield(cod_embal_2)          CALL showhelp(3254)
    WHEN infield(qtd_embal_2)          CALL showhelp(3255)
    WHEN infield(cod_embal_3)          CALL showhelp(3254)
    WHEN infield(qtd_embal_3)          CALL showhelp(3255)
    WHEN infield(cod_embal_4)          CALL showhelp(3254)
    WHEN infield(qtd_embal_4)          CALL showhelp(3255)
    WHEN infield(cod_embal_5)          CALL showhelp(3254)
    WHEN infield(qtd_embal_5)          CALL showhelp(3255)
    WHEN infield(ies_frete_seguro)     CALL showhelp(3256)
    WHEN infield(val_frete)            CALL showhelp(3351)
    WHEN infield(val_seguro)           CALL showhelp(3352)
    WHEN infield(pes_tot_liquido)      CALL showhelp(5416)
    WHEN infield(pes_tot_bruto)        CALL showhelp(3353)
  END CASE
END FUNCTION

#--------------------------------------#
 FUNCTION pol0409_verifica_num_solicit()
#--------------------------------------#

 SELECT trans_solic_fatura
   FROM fat_solic_mestre
  WHERE empresa            = p_cod_empresa
    AND solicitacao_fatura = p_nf_solicit.num_solicit
    #AND usuario            = p_user

 IF SQLCA.SQLCODE = 0 THEN
    RETURN TRUE
 ELSE 
    RETURN FALSE
 END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION pol0409_verifica_via_transporte()
#-----------------------------------------#
  SELECT den_via_transporte INTO p_den_via_transp FROM via_transporte
   WHERE via_transporte.cod_via_transporte = p_nf_solicit.cod_via_transporte
  IF   sqlca.sqlcode = 0
  THEN DISPLAY p_den_via_transp TO den_via_transporte
       RETURN true
  ELSE RETURN false
  END IF
END FUNCTION

#-------------------------------#
 FUNCTION pol0409_verifica_lote()
#-------------------------------# 

   LET p_msg = NULL
   
   SELECT ies_sit_lote
     INTO p_ies_sit_lote
     FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = p_ordem_montag_lote.num_lote_om 

   IF STATUS = 100 THEN
      LET p_msg = 'Lote inexistente!'
      RETURN FALSE
   ELSE 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_lote')
         RETURN FALSE
      END IF
   END IF
   
   IF p_ies_sit_lote = 'O' THEN
      LET p_msg = 'Já existe solicitação para o lote informado!'
      RETURN FALSE
   END IF
   
   IF p_ies_sit_lote = 'F' THEN
      LET p_msg = 'Lote já faturado!'
      RETURN FALSE
   END IF

   SELECT COUNT(num_om)
     INTO p_count
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = p_ordem_montag_lote.num_lote_om
      AND ies_sit_om  = 'N'
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_montag_mest')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET p_msg = "Não há OM's para o lote informado!"
      RETURN FALSE
   END IF
   
   #Ivo 02/05/2011 ...
   
   DECLARE cq_om_mest CURSOR FOR
    SELECT num_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = p_ordem_montag_lote.num_lote_om
      AND ies_sit_om  = 'N'

   FOREACH cq_om_mest INTO p_num_om
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_montag_mest:cq_om_mest')
         RETURN FALSE
      END IF
   
      DECLARE cq_omitem CURSOR FOR
       SELECT num_pedido
         FROM ordem_montag_item
        WHERE cod_empresa = p_cod_empresa
          AND num_om      = p_num_om
          
      FOREACH cq_omitem INTO p_num_pedido
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ordem_montag_item:cq_omitem')
            RETURN FALSE
         END IF
         
         SELECT cod_cliente
           INTO p_cod_cliente
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_num_pedido

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','pedidos:cq_omitem')
            RETURN FALSE
         END IF
         
         SELECT a.cod_uni_feder
           INTO p_cod_uni_feder
           FROM cidades a,
                clientes b
          WHERE b.cod_cliente = p_cod_cliente
            AND b.cod_cidade  = a.cod_cidade
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','uf:cq_omitem')
            RETURN FALSE
         END IF
         
         EXIT FOREACH
      
      END FOREACH

      EXIT FOREACH
            
   END FOREACH

   #... Ivo 02/05/2011 - até aqui

   IF NOT pol0409_verif_estoque() THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE
   
   
END FUNCTION 

#---------------------------------------#
 FUNCTION pol0409_verifica_cod_transpor()
#---------------------------------------#
  SELECT den_transpor INTO p_den_transpor FROM transport
   WHERE transport.cod_transpor = p_nf_solicit.cod_transpor
  IF   sqlca.sqlcode = 0
  THEN DISPLAY p_den_transpor TO den_transpor
       RETURN true
  ELSE SELECT nom_cliente INTO p_den_transpor FROM clientes
        WHERE clientes.cod_cliente  = p_nf_solicit.cod_transpor
       DISPLAY p_den_transpor TO den_transpor
       IF   sqlca.sqlcode = 0
       THEN RETURN TRUE
       ELSE RETURN false
       END IF
  END IF
END FUNCTION

#---------------------------------------#
 FUNCTION pol0409_verifica_cod_tip_cart()
#---------------------------------------#
  SELECT * FROM tipo_carteira
   WHERE tipo_carteira.cod_tip_carteira = p_nf_solicit.cod_tip_carteira

  IF   sqlca.sqlcode = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF
END FUNCTION

#----------------------------------------#
 FUNCTION pol0409_verifica_cod_entrega()
#----------------------------------------#
  
  DEFINE p_den_entrega CHAR(30)
  
  SELECT den_entrega
    INTO p_den_entrega
    FROM entregas
   WHERE cod_entrega = p_nf_solicit.cod_entrega

  IF sqlca.sqlcode = 0 THEN
     DISPLAY p_den_entrega TO den_entrega
   RETURN TRUE
  ELSE RETURN FALSE
  END IF
  
END FUNCTION

#-----------------------------------------#
 FUNCTION pol0409_dados_solicitacao(p_oper)
#-----------------------------------------#

   DEFINE p_oper CHAR(11)
   DEFINE l_num_om LIKE nf_solicit.num_om

   LET p_nom_usuario = NULL

   IF p_oper = "INCLUSAO" THEN
      CALL pol0409_le_oms("I")
   END IF

   MESSAGE 'Ctrl_O -> Itens da Ordem de Montagem!'
   LET INT_FLAG = FALSE
   
   INPUT ARRAY t1_nf_solicit WITHOUT DEFAULTS FROM s_nf_solicit.*
   ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)

      BEFORE ROW
         LET pa_curr  = ARR_CURR()
         LET sc_curr  = SCR_LINE()   
   
    AFTER  FIELD cod_embal_1
       
       IF t1_nf_solicit[pa_curr].cod_embal_1 IS NULL THEN
          LET t1_nf_solicit[pa_curr].qtd_embal_1 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].qtd_embal_1
       ELSE 
          IF NOT pol0409_le_embalagem(t1_nf_solicit[pa_curr].cod_embal_1) THEN
             CALL log0030_mensagem(p_msg,'excla')
             NEXT FIELD cod_embal_1
          END IF
          IF t1_nf_solicit[pa_curr].cod_embal_1 = t1_nf_solicit[pa_curr].cod_embal_2 OR
             t1_nf_solicit[pa_curr].cod_embal_1 = t1_nf_solicit[pa_curr].cod_embal_3 OR   
             t1_nf_solicit[pa_curr].cod_embal_1 = t1_nf_solicit[pa_curr].cod_embal_4 OR
             t1_nf_solicit[pa_curr].cod_embal_1 = t1_nf_solicit[pa_curr].cod_embal_5 THEN
             ERROR 'Código já informado!'
             NEXT FIELD cod_embal_1
          END IF
       END IF

    AFTER FIELD qtd_embal_1
       
       IF t1_nf_solicit[pa_curr].qtd_embal_1 IS NULL THEN
          LET t1_nf_solicit[pa_curr].cod_embal_1 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].cod_embal_1
       ELSE
          IF t1_nf_solicit[pa_curr].cod_embal_1 IS NULL THEN
             NEXT FIELD cod_embal_1
          END IF
       END IF

    AFTER  FIELD cod_embal_2
       
       IF t1_nf_solicit[pa_curr].cod_embal_2 IS NULL THEN
          LET t1_nf_solicit[pa_curr].qtd_embal_2 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].qtd_embal_2
       ELSE 
          IF NOT pol0409_le_embalagem(t1_nf_solicit[pa_curr].cod_embal_2) THEN
             CALL log0030_mensagem(p_msg,'excla')
             NEXT FIELD cod_embal_2
          END IF
          IF t1_nf_solicit[pa_curr].cod_embal_2 = t1_nf_solicit[pa_curr].cod_embal_1 OR
             t1_nf_solicit[pa_curr].cod_embal_2 = t1_nf_solicit[pa_curr].cod_embal_3 OR   
             t1_nf_solicit[pa_curr].cod_embal_2 = t1_nf_solicit[pa_curr].cod_embal_4 OR
             t1_nf_solicit[pa_curr].cod_embal_2 = t1_nf_solicit[pa_curr].cod_embal_5 THEN
             ERROR 'Código já informado!'
             NEXT FIELD cod_embal_2
          END IF
       END IF

    AFTER FIELD qtd_embal_2
       
       IF t1_nf_solicit[pa_curr].qtd_embal_2 IS NULL THEN
          LET t1_nf_solicit[pa_curr].cod_embal_2 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].cod_embal_2
       ELSE
          IF t1_nf_solicit[pa_curr].cod_embal_2 IS NULL THEN
             NEXT FIELD cod_embal_2
          END IF
       END IF

    AFTER  FIELD cod_embal_3
       
       IF t1_nf_solicit[pa_curr].cod_embal_3 IS NULL THEN
          LET t1_nf_solicit[pa_curr].qtd_embal_3 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].qtd_embal_3
          
       ELSE 
          IF NOT pol0409_le_embalagem(t1_nf_solicit[pa_curr].cod_embal_3) THEN
             
             CALL log0030_mensagem(p_msg,'excla')
             NEXT FIELD cod_embal_3
          END IF
          IF t1_nf_solicit[pa_curr].cod_embal_3 = t1_nf_solicit[pa_curr].cod_embal_1 OR
             t1_nf_solicit[pa_curr].cod_embal_3 = t1_nf_solicit[pa_curr].cod_embal_2 OR   
             t1_nf_solicit[pa_curr].cod_embal_3 = t1_nf_solicit[pa_curr].cod_embal_4 OR
             t1_nf_solicit[pa_curr].cod_embal_3 = t1_nf_solicit[pa_curr].cod_embal_5 THEN
             ERROR 'Código já informado!'
             NEXT FIELD cod_embal_3
          END IF
       END IF

    AFTER FIELD qtd_embal_3
       
       IF t1_nf_solicit[pa_curr].qtd_embal_3 IS NULL THEN
          LET t1_nf_solicit[pa_curr].cod_embal_3 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].cod_embal_3
       ELSE
          IF t1_nf_solicit[pa_curr].cod_embal_3 IS NULL THEN
             NEXT FIELD cod_embal_3
          END IF
       END IF

    AFTER  FIELD cod_embal_4
       
       IF t1_nf_solicit[pa_curr].cod_embal_4 IS NULL THEN
          LET t1_nf_solicit[pa_curr].qtd_embal_4 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].qtd_embal_4
          
       ELSE 
          IF NOT pol0409_le_embalagem(t1_nf_solicit[pa_curr].cod_embal_4) THEN
             
             CALL log0030_mensagem(p_msg,'excla')
             NEXT FIELD cod_embal_4
          END IF
          IF t1_nf_solicit[pa_curr].cod_embal_4 = t1_nf_solicit[pa_curr].cod_embal_1 OR
             t1_nf_solicit[pa_curr].cod_embal_4 = t1_nf_solicit[pa_curr].cod_embal_2 OR   
             t1_nf_solicit[pa_curr].cod_embal_4 = t1_nf_solicit[pa_curr].cod_embal_3 OR
             t1_nf_solicit[pa_curr].cod_embal_4 = t1_nf_solicit[pa_curr].cod_embal_5 THEN
             ERROR 'Código já informado!'
             NEXT FIELD cod_embal_4
          END IF
       END IF

    AFTER FIELD qtd_embal_4
       
       IF t1_nf_solicit[pa_curr].qtd_embal_4 IS NULL THEN
          LET t1_nf_solicit[pa_curr].cod_embal_4 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].cod_embal_4
       ELSE
          IF t1_nf_solicit[pa_curr].cod_embal_4 IS NULL THEN
             NEXT FIELD cod_embal_4
          END IF
       END IF

    AFTER  FIELD cod_embal_5
       
       IF t1_nf_solicit[pa_curr].cod_embal_5 IS NULL THEN
          LET t1_nf_solicit[pa_curr].qtd_embal_5 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].qtd_embal_5
          
       ELSE 
          IF NOT pol0409_le_embalagem(t1_nf_solicit[pa_curr].cod_embal_5) THEN
             
             CALL log0030_mensagem(p_msg,'excla')
             NEXT FIELD cod_embal_5
          END IF
          IF t1_nf_solicit[pa_curr].cod_embal_5 = t1_nf_solicit[pa_curr].cod_embal_1 OR
             t1_nf_solicit[pa_curr].cod_embal_5 = t1_nf_solicit[pa_curr].cod_embal_2 OR   
             t1_nf_solicit[pa_curr].cod_embal_5 = t1_nf_solicit[pa_curr].cod_embal_3 OR
             t1_nf_solicit[pa_curr].cod_embal_5 = t1_nf_solicit[pa_curr].cod_embal_4 THEN
             ERROR 'Código já informado!'
             NEXT FIELD cod_embal_5
          END IF
       END IF

    AFTER FIELD qtd_embal_5
       
       IF t1_nf_solicit[pa_curr].qtd_embal_5 IS NULL THEN
          LET t1_nf_solicit[pa_curr].cod_embal_5 = NULL
          DISPLAY '' TO s_nf_solicit[sc_curr].cod_embal_5
       ELSE
          IF t1_nf_solicit[pa_curr].cod_embal_5 IS NULL THEN
             NEXT FIELD cod_embal_5
          END IF
       END IF

    ON KEY (control-z,f4)
           CALL pol0409_popup()
    ON KEY (control-o)
           CALL pol0409_exibe_item(t1_nf_solicit[pa_curr].num_om)

  END INPUT
  IF INT_FLAG = 0
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF 

END FUNCTION

#---------------------------#
FUNCTION pol0409_le_oms(p_op)
#---------------------------#

   DEFINE p_op CHAR(01)
   
      INITIALIZE t1_nf_solicit TO NULL
      
      DECLARE cq_ordem CURSOR FOR
       SELECT num_om     
         FROM ordem_montag_mest
        WHERE cod_empresa = p_cod_empresa
          AND num_lote_om = p_ordem_montag_lote.num_lote_om
          AND ies_sit_om  = "N"
        ORDER BY num_om

      LET p_ind = 1
      
      FOREACH cq_ordem INTO p_ordem_montag_mest.num_om

         LET t1_nf_solicit[p_ind].num_om  = p_ordem_montag_mest.num_om
         
         IF p_op = 'I' THEN
            LET p_count = 1
         ELSE  
            LET p_count = 1
         END IF
         
         IF p_op = 'I' THEN
            LET p_query = 
                "SELECT cod_embal_int, qtd_embal_int FROM ordem_montag_embal ",
                " WHERE cod_empresa = '",p_cod_empresa,"' ",
                "   AND num_om      = '",p_ordem_montag_mest.num_om,"' "
         ELSE
            LET p_query =
                "SELECT embalagem, qtd_embalagem FROM fat_solic_embal ",
                "WHERE trans_solic_fatura = '",p_num_transac,"' ",
                "  AND ord_montag         = '",p_ordem_montag_mest.num_om,"' "
         END IF
            
         
         PREPARE var_query FROM p_query   
         DECLARE cq_cod_emb CURSOR FOR var_query

         FOREACH cq_cod_emb INTO p_cod_embal, p_qtd_embal
         
            IF p_cod_embal > 0 THEN
               IF p_count = 1 THEN
                  LET t1_nf_solicit[p_ind].cod_embal_1 = p_cod_embal
                  LET t1_nf_solicit[p_ind].qtd_embal_1 = p_qtd_embal
               ELSE
                  IF p_count = 2 THEN
                     LET t1_nf_solicit[p_ind].cod_embal_2 = p_cod_embal
                     LET t1_nf_solicit[p_ind].qtd_embal_2 = p_qtd_embal
                  ELSE
                     IF p_count = 3 THEN
                        LET t1_nf_solicit[p_ind].cod_embal_3 = p_cod_embal
                        LET t1_nf_solicit[p_ind].qtd_embal_3 = p_qtd_embal
                     ELSE
                        IF p_count = 4 THEN
                           LET t1_nf_solicit[p_ind].cod_embal_4 = p_cod_embal
                           LET t1_nf_solicit[p_ind].qtd_embal_4 = p_qtd_embal
                        ELSE
                           LET t1_nf_solicit[p_ind].cod_embal_5 = p_cod_embal
                           LET t1_nf_solicit[p_ind].qtd_embal_5 = p_qtd_embal
                        END IF
                     END IF
                  END IF
               END IF
            END IF
                        
            LET p_count = p_count + 1
                  
         END FOREACH

         {SELECT SUM(qtd_volume_item)
           INTO p_qtd_volume
           FROM ordem_montag_item
          WHERE cod_empresa = p_cod_empresa
            AND num_om    = p_ordem_montag_mest.num_om
            
         IF p_qtd_volume IS NULL THEN
            LET p_qtd_volume = 0
         END IF}
         
         LET t1_nf_solicit[p_ind].num_volume = NULL
         LET t1_nf_solicit[p_ind].num_sequencia = p_ind
         
         LET p_ind = p_ind + 1

      END FOREACH

      LET p_count = p_ind - 1
      
      CALL SET_COUNT(p_ind - 1)
      
END FUNCTION

#----------------------------------------#
FUNCTION pol0409_le_embalagem(p_cod_embal)
#----------------------------------------#
   
   DEFINE p_cod_embal LIKE embalagem.cod_embal
   
   SELECT den_embal
     FROM embalagem
    WHERE cod_embal = p_cod_embal
              
   IF STATUS <> 0 THEN
      LET p_msg = 'Código não localizado na tabela embalagem!'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION



#------------------------------------------#
# FUNCTION pol04090_verifica_integracao_wis()
#------------------------------------------#
# DEFINE  l_sucesso_sql       SMALLINT,
#         l_ies_item_wis      SMALLINT,
#         l_num_om            LIKE ordem_montag_item.num_om,
#         l_cod_item          LIKE ordem_montag_item.cod_item#

# INITIALIZE l_cod_item TO NULL
# LET l_num_om = t1_nf_solicit[p_ind].num_om#

# IF l_num_om IS NULL THEN
#   RETURN TRUE
# END IF


#IF p_prim_item_eh_wis IS NULL THEN {Primeira Chamada a funcao}

#   SELECT MAX(cod_item) INTO l_cod_item
#     FROM ordem_montag_item
#    WHERE cod_empresa = p_cod_empresa
#      AND num_om      = l_num_om

#   IF l_cod_item IS NULL
#   THEN
#     CALL log003_err_sql("SELECAO","ORDEM_MONTAG_ITEM")
#     RETURN FALSE
#   END IF

###    CALL vdp3188_item_sob_controle_wis(p_cod_empresa,l_cod_item)
###         RETURNING l_sucesso_sql, l_ies_item_wis              

###   IF l_sucesso_sql THEN
###     IF l_ies_item_wis THEN
###        SELECT * FROM wis_merc_env_cli      {Verifica se OM foi enviada ao WIS}
###         WHERE cod_empresa       = p_cod_empresa
###           AND num_om            = l_num_om
###           AND dat_processamento IS NOT NULL
###           AND cod_erro          IS NULL

###       IF SQLCA.SQLCODE <> 0 THEN
###         ERROR "OM ",l_num_om," nao cadastrada na tabela WIS_MERC_ENV_CLI"
#         RETURN FALSE
#       END IF
#       LET p_prim_item_eh_wis = TRUE
#     ELSE
#       LET p_prim_item_eh_wis = FALSE
#     END IF
#     RETURN TRUE
#   ELSE
#     RETURN FALSE
#   END IF
# END IF


# SELECT MAX(cod_item) INTO l_cod_item
#   FROM ordem_montag_item
#  WHERE cod_empresa = p_cod_empresa
#    AND num_om      = l_num_om#

# IF l_cod_item IS NULL
# THEN
#   CALL log003_err_sql("SELECAO","ORDEM_MONTAG_ITEM")
#   RETURN FALSE
# END IF

### CALL vdp3188_item_sob_controle_wis(p_cod_empresa,l_cod_item)
###      RETURNING l_sucesso_sql, l_ies_item_wis                


# IF l_sucesso_sql THEN
#   IF l_ies_item_wis THEN                  {Item ocorrencia atual array eh WIS?}
#     IF p_prim_item_eh_wis THEN            {Primeiro item da array eh WIS?}
#       SELECT * FROM wis_merc_env_cli      {Verifica se OM foi enviada ao WIS}
#        WHERE cod_empresa       = p_cod_empresa
#          AND num_om            = l_num_om
#          AND dat_processamento IS NOT NULL
#          AND cod_erro          IS NULL

#       IF SQLCA.SQLCODE <> 0 THEN
#         ERROR "OM ",l_num_om," nao cadastrada na tabela WIS_MERC_ENV_CLI"
#         RETURN FALSE
#       END IF
#     ELSE                                  {Primeiro item da array nao eh WIS}
#       ERROR "OM ",l_num_om," nao deve pertencer ao WIS"
#       RETURN FALSE
#     END IF
#   ELSE                                    {Item ocorrencia atual array nao eh WIS}
#     IF p_prim_item_eh_wis THEN            {Primeiro item da array eh WIS}
#       ERROR "OM ",l_num_om," deve pertencer ao WIS."
#       RETURN FALSE
#     END IF
#   END IF
# ELSE
#   RETURN FALSE
# END IF

# RETURN TRUE
#END FUNCTION

#------------------------------------------------------------------#
#-- OS 118709 - Integracao LOGIX-ERP <<-->> LOGIX-WMS -------------}
#------------------------------------------------------------------#
# FUNCTION pol04090_verifica_integracao_wms()
#------------------------------------------#
# DEFINE  l_sucesso_sql       SMALLINT,
#         l_ies_item_wms      SMALLINT,
#         l_ies_om_recebida   SMALLINT,
#         l_num_om            LIKE ordem_montag_item.num_om,
#         l_cod_item          LIKE ordem_montag_item.cod_item

# INITIALIZE l_cod_item TO NULL
# LET l_num_om = t1_nf_solicit[p_ind].num_om

# IF l_num_om IS NULL THEN
#   RETURN TRUE
# END IF

# IF p_prim_item_eh_wms IS NULL THEN {Primeira Chamada a funcao}

#   SELECT MAX(cod_item) INTO l_cod_item
#     FROM ordem_montag_item
#    WHERE cod_empresa = p_cod_empresa
#      AND num_om      = l_num_om

#   IF l_cod_item IS NULL
#   THEN
#     CALL log003_err_sql("SELECAO","ORDEM_MONTAG_ITEM")
#     RETURN FALSE
#   END IF

#   CALL wms0004_item_sob_controle_wms(p_cod_empresa,l_cod_item)
#        RETURNING l_sucesso_sql, l_ies_item_wms               

#   IF l_sucesso_sql THEN
#     IF l_ies_item_wms THEN

#       CALL wms0004_om_recebida_do_wms(p_cod_empresa, l_num_om)
#            RETURNING l_sucesso_sql, l_ies_om_recebida            

#       IF l_sucesso_sql AND l_ies_om_recebida THEN
#       ELSE
#         ERROR "OM ",l_num_om," nao foi separada pelo LOGIX-WMS"
#         RETURN FALSE
#       END IF

#       LET p_prim_item_eh_wms = TRUE

#     ELSE
#       LET p_prim_item_eh_wms = FALSE
#     END IF

# #    RETURN TRUE
#   ELSE
#     RETURN FALSE
#   END IF
# END IF#


# SELECT MAX(cod_item) INTO l_cod_item
#   FROM ordem_montag_item
#  WHERE cod_empresa = p_cod_empresa
#    AND num_om      = l_num_om#

# IF l_cod_item IS NULL
# THEN
#   CALL log003_err_sql("SELECAO","ORDEM_MONTAG_ITEM")
#   RETURN FALSE
# END IF

# CALL wms0004_item_sob_controle_wms(p_cod_empresa,l_cod_item)
#      RETURNING l_sucesso_sql, l_ies_item_wms         


# IF l_sucesso_sql THEN
#   IF l_ies_item_wms THEN                  {Item ocorrencia atual array eh WIS?}
#      IF p_prim_item_eh_wms THEN            {Primeiro item da array eh WIS?}
#         CALL wms0004_om_recebida_do_wms(p_cod_empresa, l_num_om)
#         RETURNING l_sucesso_sql, l_ies_om_recebida              

#         IF l_sucesso_sql AND l_ies_om_recebida THEN
#         ELSE 
#         ERROR "OM ",l_num_om," nao foi separada pelo LOGIX-WMS"
#         RETURN FALSE
#       END IF
#     ELSE                                  {Primeiro item da array nao eh WIS}
#       ERROR "OM ",l_num_om," nao deve estar sob a abrangencia do LOGIX-WMS"
#       RETURN FALSE
#     END IF
#   ELSE                                    {Item ocorrencia atual array nao eh WIS}
#     IF p_prim_item_eh_wms THEN            {Primeiro item da array eh WIS}
#       ERROR "OM ",l_num_om," deve estar sob a abrangencia do LOGIX-WMS"
#       RETURN FALSE
#     END IF
#   END IF
# ELSE
#   RETURN FALSE
# END IF

# RETURN TRUE
#END FUNCTION

#---------------------------------------#
 FUNCTION pol0409_verifica_om_bloqueada()
#---------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "B"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#---------------------------------------#
 FUNCTION pol0409_verifica_om_embalagem()
#---------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "E"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#------------------------------------#
 FUNCTION pol0409_verifica_om_vendas()
#------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "V"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#------------------------------------#
 FUNCTION pol0409_verifica_om_fiscal()
#------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "I"

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION


#--------------------------------------#
 FUNCTION pol0409_verifica_om_faturada()
#--------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "F"

    IF sqlca.sqlcode = 0
    THEN RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#---------------------------------------#
 FUNCTION pol0409_verifica_om_cancelada()
#---------------------------------------#
    SELECT * FROM  ordem_montag_mest
     WHERE  ordem_montag_mest.cod_empresa = p_cod_empresa   AND
            ordem_montag_mest.num_om = t1_nf_solicit[pa_curr].num_om
       AND  ordem_montag_mest.ies_sit_om = "C"

    IF sqlca.sqlcode = 0
    THEN RETURN FALSE
    ELSE RETURN TRUE
    END IF
 END FUNCTION

#---------------------------------------------------#
 FUNCTION pol0409_frete_seguro(p_num_seq,p_num_solic)
#---------------------------------------------------#
  DEFINE p_num_solic LIKE nf_solicit.num_solicit,
         p_num_seq   LIKE nf_solicit.num_sequencia

  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol04091") RETURNING p_nom_tela
  OPEN WINDOW w_pol04091 AT 5,30 WITH FORM p_nom_tela
     ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  CURRENT WINDOW IS w_pol04091
  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_pol04091
  IF   t1_frete_seguro[p_num_seq].val_frete > 0
  THEN LET p_val_frete = t1_frete_seguro[p_num_seq].val_frete
  ELSE LET p_val_frete = 0
  END IF
  IF   t1_frete_seguro[p_num_seq].val_seguro > 0
  THEN LET p_val_seguro = t1_frete_seguro[p_num_seq].val_seguro
  ELSE LET p_val_seguro = 0
  END IF
  IF   t1_frete_seguro[p_num_seq].pes_tot_bruto > 0
  THEN LET p_pes_tot_bruto = t1_frete_seguro[p_num_seq].pes_tot_bruto
  ELSE LET p_pes_tot_bruto = 0
  END IF
  IF   t1_frete_seguro[p_num_seq].pes_tot_liquido > 0
  THEN LET p_pes_tot_liquido = t1_frete_seguro[p_num_seq].pes_tot_liquido
  ELSE LET p_pes_tot_liquido = 0
  END IF
  DISPLAY p_val_frete   TO val_frete
  DISPLAY p_val_seguro  TO val_seguro
  DISPLAY p_pes_tot_bruto TO pes_tot_bruto
  DISPLAY p_pes_tot_liquido TO pes_tot_liquido
  DISPLAY p_cod_empresa TO cod_empresa
  DISPLAY p_num_seq     TO num_sequencia
  DISPLAY p_num_solic   TO num_solicit
  LET INT_FLAG = FALSE

    INPUT p_val_frete,
          p_val_seguro,
          p_pes_tot_liquido,
          p_pes_tot_bruto WITHOUT DEFAULTS
     FROM val_frete,
          val_seguro,
          pes_tot_liquido,
          pes_tot_bruto

     AFTER FIELD pes_tot_bruto
        IF p_pes_tot_bruto < p_pes_tot_liquido THEN
           ERROR "Peso bruto nao pode ser menor que o peso liquido. "
           NEXT FIELD pes_tot_bruto
        END IF

     ON KEY (control-w,f1)
        CALL pol0409_help()
     END INPUT
CALL log006_exibe_teclas("01", p_versao)

CURRENT WINDOW IS w_pol04091
CLOSE WINDOW w_pol04091
CURRENT WINDOW IS w_pol0409
END FUNCTION

#--------------------------------#
 FUNCTION pol0409_om_ja_digitada()
#--------------------------------#

  DEFINE p_subs    INTEGER
  LET p_subs = 0

  FOR p_subs = 1 TO (pa_curr - 1)
      IF t1_nf_solicit[p_subs].num_om  = t1_nf_solicit[pa_curr].num_om
      THEN RETURN TRUE
      END IF
  END FOR
  
  SELECT usuario 
    INTO p_nom_usuario 
    FROM fat_solic_mestre a,
         fat_solic_fatura b
   WHERE a.empresa        = p_cod_empresa
     AND b.trans_solic_fatura = a.trans_solic_fatura
     AND b.ord_montag         = t1_nf_solicit[pa_curr].num_om
     #AND a.usuario           <> p_user
     
  IF sqlca.sqlcode = 0 THEN

     LET p_msg = 'OM:', t1_nf_solicit[pa_curr].num_om,' já possui\n',
                 'solicitação p/ usuário ',p_nom_usuario,'\n'
     CALL log0030_mensagem(p_msg,'excla')

     RETURN TRUE
  END IF

  SELECT usuario 
    INTO p_nom_usuario 
    FROM fat_solic_mestre a,
         fat_solic_fatura b
   WHERE a.empresa        = p_cod_empresa
     AND b.trans_solic_fatura = a.trans_solic_fatura
     AND b.ord_montag         = t1_nf_solicit[pa_curr].num_om
     AND a.solicitacao_fatura <> p_nf_solicit.num_solicit     
     #AND a.usuario            = p_user
     
  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  END IF
  
  
  RETURN FALSE
  
END FUNCTION

#-----------------------#
FUNCTION pol0409_le_uf()
#-----------------------#

 DEFINE p_ordem  INTEGER,
        p_pedido INTEGER,
        p_cliente CHAR(15)
        

 DECLARE cq_le_om CURSOR FOR
  SELECT num_om
    FROM ordem_montag_mest
   WHERE cod_empresa = p_cod_empresa
     AND num_lote_om = p_nf_solicit.num_lote_om
 FOREACH cq_le_om INTO p_ordem
    IF STATUS <> 0 THEN
       CALL log003_err_sql('LENDO', 'cq_le_om')
       EXIT FOREACH
    END IF
    DECLARE cq_le_ped CURSOR FOR
     SELECT num_pedido
       FROM ordem_montag_item
      WHERE cod_empresa = p_cod_empresa
        AND num_om = p_ordem
    FOREACH cq_le_ped INTO p_pedido
       IF STATUS <> 0 THEN
          CALL log003_err_sql('LENDO', 'cq_le_om')
          EXIT FOREACH
       END IF
       SELECT cod_cliente
         INTO p_cliente
         FROM pedidos
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido  = p_pedido
       IF STATUS <> 0 THEN
          CALL log003_err_sql('LENDO', 'pedidos:cq_le_om')
          EXIT FOREACH
       END IF
       SELECT a.cod_uni_feder
         INTO p_cod_uni_feder
         FROM cidades a,
              clientes b
        WHERE b.cod_cliente = p_cliente
          AND b.cod_cidade  = a.cod_cidade
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','cidades:cq_le_om')
          LET p_cod_uni_feder = NULL
       END IF
       EXIT FOREACH
    END FOREACH
    EXIT FOREACH
 END FOREACH

END FUNCTION
#--------------------------------------#
 FUNCTION pol0409_efetiva_inclusao(p_op)
#--------------------------------------#

  DEFINE p_num_lote_om LIKE ordem_montag_mest.num_lote_om,
         p_op          CHAR(01)

   IF p_op = 'M' THEN
   
      DELETE FROM fat_solic_mestre
       WHERE trans_solic_fatura = p_num_transac
     
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("EXCLUSAO", "fat_solic_mestre")
         RETURN FALSE
      END IF
   
      DELETE FROM fat_solic_fatura
       WHERE trans_solic_fatura = p_num_transac
     
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("EXCLUSAO", "fat_solic_fatura")
         RETURN FALSE
      END IF
   
      DELETE FROM fat_solic_embal
       WHERE trans_solic_fatura = p_num_transac
     
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("EXCLUSAO", "fat_solic_embal")
         RETURN FALSE
      END IF
      
      CALL pol0409_le_uf()
   END IF
  
   LET p_count = 0

  IF NOT pol0409_insere_mestre() THEN
     RETURN FALSE
  END IF

  IF NOT pol0409_insere_fatura() THEN
     RETURN FALSE
  END IF
  
  FOR pa_curr = 1 TO 200
      
      IF t1_nf_solicit[pa_curr].num_om IS NOT NULL THEN
         
         IF t1_nf_solicit[pa_curr].cod_embal_1 IS NOT NULL AND  
            t1_nf_solicit[pa_curr].qtd_embal_1 IS NOT NULL THEN                              
            INSERT INTO fat_solic_embal                                     
             VALUES(p_num_transac,                                          
                    t1_nf_solicit[pa_curr].num_om,                                    
                    p_nf_solicit.num_lote_om,                               
                    t1_nf_solicit[pa_curr].cod_embal_1,                               
                    t1_nf_solicit[pa_curr].qtd_embal_1)                               
            IF STATUS <> 0 THEN                                             
               CALL log003_err_sql("INCLUSAO", "fat_solic_embal:1")         
               RETURN FALSE                                                 
            END IF                                                          
         END IF                                                             
                                                                            
         IF t1_nf_solicit[pa_curr].cod_embal_2 IS NOT NULL AND  
            t1_nf_solicit[pa_curr].qtd_embal_2 IS NOT NULL THEN                              
            INSERT INTO fat_solic_embal                                     
             VALUES(p_num_transac,                                          
                    t1_nf_solicit[pa_curr].num_om,                                    
                    p_nf_solicit.num_lote_om,                               
                    t1_nf_solicit[pa_curr].cod_embal_2,                               
                    t1_nf_solicit[pa_curr].qtd_embal_2)                               
            IF STATUS <> 0 THEN                                             
               CALL log003_err_sql("INCLUSAO", "fat_solic_embal:2")         
               RETURN FALSE                                                 
            END IF                                                          
         END IF                                                             
                                                                            
         IF t1_nf_solicit[pa_curr].cod_embal_3 IS NOT NULL AND  
            t1_nf_solicit[pa_curr].qtd_embal_3 IS NOT NULL THEN                              
            INSERT INTO fat_solic_embal                                     
             VALUES(p_num_transac,                                          
                    t1_nf_solicit[pa_curr].num_om,                                    
                    p_nf_solicit.num_lote_om,                               
                    t1_nf_solicit[pa_curr].cod_embal_3,                               
                    t1_nf_solicit[pa_curr].qtd_embal_3)                               
            IF STATUS <> 0 THEN                                             
               CALL log003_err_sql("INCLUSAO", "fat_solic_embal:3")         
               RETURN FALSE                                                 
            END IF                                                          
         END IF                                                             
                                                                            
         IF t1_nf_solicit[pa_curr].cod_embal_4 IS NOT NULL AND  
            t1_nf_solicit[pa_curr].qtd_embal_4 IS NOT NULL THEN                              
            INSERT INTO fat_solic_embal                                     
             VALUES(p_num_transac,                                          
                    t1_nf_solicit[pa_curr].num_om,                                    
                    p_nf_solicit.num_lote_om,                               
                    t1_nf_solicit[pa_curr].cod_embal_4,                               
                    t1_nf_solicit[pa_curr].qtd_embal_4)                               
            IF STATUS <> 0 THEN                                             
               CALL log003_err_sql("INCLUSAO", "fat_solic_embal:4")         
               RETURN FALSE                                                 
            END IF                                                          
         END IF                                                             
                                                                            
         IF t1_nf_solicit[pa_curr].cod_embal_5 IS NOT NULL AND  
            t1_nf_solicit[pa_curr].qtd_embal_5 IS NOT NULL THEN                              
            INSERT INTO fat_solic_embal                                     
             VALUES(p_num_transac,                                          
                    t1_nf_solicit[pa_curr].num_om,                                    
                    p_nf_solicit.num_lote_om,                               
                    t1_nf_solicit[pa_curr].cod_embal_5,                               
                    t1_nf_solicit[pa_curr].qtd_embal_5)                               
            IF STATUS <> 0 THEN                                             
               CALL log003_err_sql("INCLUSAO", "fat_solic_embal:5")         
               RETURN FALSE                                                 
            END IF                                                          
         END IF                                                             

      END IF

  END FOR
  
  SELECT COUNT(trans_solic_fatura)
    INTO p_count
    FROM fat_solic_embal
   WHERE trans_solic_fatura = p_num_transac

  IF STATUS <> 0 THEN                                             
     CALL log003_err_sql("LENDO", "fat_solic_embal")         
     RETURN FALSE                                                 
  END IF                                                          
  
  IF p_count = 0 THEN
     CALL log0030_mensagem('Solicitação sem embalagem não é permitido!','excla')
     RETURN FALSE
  END IF
        
  RETURN TRUE
  
END FUNCTION

#------------------------------#
FUNCTION pol0409_insere_mestre()
#------------------------------#

   LET p_num_transac = 0
   LET p_nf_solicit.ies_situacao = "C"
   LET p_nf_solicit.cod_tip_carteira = NULL
   LET p_nf_solicit.ies_tip_solicit    = "L"
   LET p_nf_solicit.ies_lotes_geral    = "N"
   LET p_nf_solicit.num_volume = t1_nf_solicit[1].num_volume

   INSERT INTO fat_solic_mestre 
      VALUES (p_num_transac,
              p_cod_empresa,
              p_tip_solic,
              p_nser,
              p_sser,
              p_espcie,
              p_nf_solicit.num_solicit,
              p_user,
              '',                             #incrição estadual
              p_nf_solicit.dat_refer,
              p_nf_solicit.ies_tip_solicit,
              p_nf_solicit.ies_lotes_geral,
              p_nf_solicit.cod_tip_carteira,
              p_nf_solicit.ies_situacao)   
              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_solic_mestre')
      RETURN FALSE
   END IF
   
   LET p_num_transac = SQLCA.SQLERRD[2]

   
   RETURN TRUE

END FUNCTION

#------------------------------#         
FUNCTION pol0409_insere_fatura()
#------------------------------#         

   DEFINE p_cod_pais LIKE uni_feder.cod_pais
   
   #Ivo 02/05/2011 ...
   
   DEFINE p_mercado          LIKE fat_solic_fatura.mercado,         
          p_modo_embarque    LIKE fat_solic_fatura.modo_embarque,   
          p_local_embarque   LIKE fat_solic_fatura.local_embarque,  
          p_cidade_embarque  LIKE fat_solic_fatura.cidade_embarque, 
          p_dat_hor_embarque LIKE fat_solic_fatura.dat_hor_embarque,
          p_local_despacho   INTEGER

   
   LET p_mercado = ' '
   LET p_modo_embarque = ' '
   LET p_local_embarque =  ' '
   LET p_cidade_embarque = ' '
   LET p_dat_hor_embarque = ' '
   
   SELECT cod_pais
     INTO p_cod_pais
     FROM uni_feder
    WHERE cod_uni_feder = p_cod_uni_feder
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','uni_feder')
      LET p_cod_pais = '001'
   END IF
    
   IF p_cod_pais <> '001' THEN
   
      SELECT parametro_texto
        INTO p_cidade_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = p_num_pedido                                  
         AND ped_info_compl.campo   = 'CIDADE_EMBARQUE'                     

      SELECT parametro_dat
        INTO p_dat_hor_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = p_num_pedido                                  
         AND ped_info_compl.campo   = 'DAT_HOR_EMBARQUE'                     

      SELECT parametro_texto
        INTO p_local_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = p_num_pedido                                  
         AND ped_info_compl.campo   = 'LOCAL_EMBARQUE'                     

      SELECT parametro_texto
        INTO p_mercado
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = p_num_pedido                                  
         AND ped_info_compl.campo   = 'MERCADO'                     


      SELECT parametro_texto
        INTO p_modo_embarque
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = p_num_pedido                                  
         AND ped_info_compl.campo   = 'MODO_EMBARQUE'                     

      SELECT parametro_texto
        INTO p_local_despacho
        FROM ped_info_compl                                            
       WHERE ped_info_compl.empresa = p_cod_empresa                                 
         AND ped_info_compl.pedido  = p_num_pedido                                  
         AND ped_info_compl.campo   = 'LOCAL_DESPACHO'                     

   END IF

   #... Ivo 02/05/2011 - até aqui

   INSERT INTO fat_solic_fatura (
      trans_solic_fatura,
      ord_montag,        
      lote_ord_montag,   
      seq_solic_fatura,  
      controle,          
      texto_1,           
      texto_2,           
      texto_3,           
      via_transporte,    
      transportadora,    
      placa_veiculo,     
      estado_placa_veic, 
      val_frete,         
      val_seguro,        
      peso_liquido,      
      peso_bruto,        
      primeiro_volume,   
      volume_cubico,     
      mercado,           
      local_embarque,    
      modo_embarque,
      dat_hor_embarque,
      cidade_embarque,
      local_despacho)
    VALUES(p_num_transac,
           0,  #p_nf_solicit.num_om,
           p_nf_solicit.num_lote_om,
           1,  #sequencia
           1,  #controle
           p_nf_solicit.num_texto_1,
           p_nf_solicit.num_texto_2,
           p_nf_solicit.num_texto_3,
           p_nf_solicit.cod_via_transporte,
           p_nf_solicit.cod_transpor,
           p_nf_solicit.num_placa,
           p_nf_solicit.cod_estado,         
           p_nf_solicit.val_frete,
           p_nf_solicit.val_seguro,
           p_nf_solicit.pes_tot_liquido,
           p_nf_solicit.pes_tot_bruto,
           p_nf_solicit.num_volume,                              
           0,
           p_mercado,           
           p_local_embarque,
           p_modo_embarque,
           p_dat_hor_embarque,
           p_cidade_embarque,
           p_local_despacho)   
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO", "fat_solic_fatura")
      RETURN FALSE
   END IF
   
   SELECT empresa
     FROM fat_exp_nf
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_num_transac
   
   IF STATUS = 0 THEN
      DELETE FROM fat_exp_nf
       WHERE empresa = p_cod_empresa
         AND trans_nota_fiscal = p_num_transac
   END IF
   
   INSERT INTO fat_exp_nf (
    empresa,
    trans_nota_fiscal, 
    modo_embarq,     
    local_embarq,    
    dat_hor_embarq,
    mercado,     
    cidade_embarque,
    local_despacho)
   VALUES (p_cod_empresa,
           p_num_transac,
           p_modo_embarque,    
           p_local_embarque,   
           p_dat_hor_embarque, 
           p_mercado,         
           p_cidade_embarque,
           p_local_despacho)  
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSAO", "fat_exp_nf")
      RETURN FALSE
   END IF
       
   RETURN TRUE

END FUNCTION


#-----------------------------------------#
 FUNCTION pol0409_modificacao_solicitacao()
#-----------------------------------------#

 LET p_nf_solicitr.* = p_nf_solicit.*
 LET p_num_solicit = p_nf_solicit.num_solicit
 
 
      IF   pol0409_dados_mestre("MODIFICACAO") THEN
           IF   pol0409_dados_solicitacao("MODIFICACAO") THEN
                IF log004_confirm(7,43) THEN
                   CALL log085_transacao("BEGIN")
                   IF pol0409_efetiva_inclusao("M") THEN
                      CALL log085_transacao("COMMIT")
                      MESSAGE " Modificacao efetuada com sucesso " ATTRIBUTE(REVERSE)
                   ELSE 
                      CALL log085_transacao("ROLLBACK")
                      MESSAGE " Operação cancelada " ATTRIBUTE(REVERSE)
                   END IF
                END IF
           ELSE
              LET p_nf_solicit.* = p_nf_solicitr.*
              CALL pol0409_exibe_dados_solicitacao()
              ERROR " Modificacao Cancelada "
              RETURN
           END IF
      ELSE 
         LET p_nf_solicit.* = p_nf_solicitr.*
         CALL pol0409_exibe_dados_solicitacao()
         ERROR " Modificacao Cancelada "
         RETURN
      END IF
      
 
 END FUNCTION

#--------------------------------------#
 FUNCTION pol0409_exclusao_solicitacao()
#--------------------------------------#
  LET p_nf_solicitr.* = p_nf_solicit.*

  SELECT trans_solic_fatura
    INTO p_num_transac
    FROM fat_solic_mestre
   WHERE empresa = p_cod_empresa
     AND solicitacao_fatura = p_nf_solicit.num_solicit
     #AND usuario = p_user

  IF SQLCA.sqlcode = 0 THEN
     IF log004_confirm(7,43) THEN
        CALL log085_transacao("BIGIN")
        IF NOT pol409_deleta_solic() THEN
           CALL log085_transacao("ROLLBACK")
        END IF
        CALL log085_transacao("COMMIT")
        ERROR " Operação efetuada com sucesso "
        CLEAR FORM
        DISPLAY p_cod_empresa TO cod_empresa
     ELSE 
        ERROR " Exclusao Cancelada "
     END IF
  ELSE 
     ERROR " Nao Existem Dados para a Chave Informada "
  END IF
  
END FUNCTION

#----------------------------#
FUNCTION pol409_deleta_solic()
#----------------------------# 
          
   DELETE FROM fat_solic_mestre
    WHERE empresa = p_cod_empresa
      AND trans_solic_fatura = p_num_transac
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_mestre')
      RETURN FALSE
   END IF
      
   DELETE FROM fat_solic_fatura
    WHERE trans_solic_fatura = p_num_transac
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_fatura')
      RETURN FALSE
   END IF

   DELETE FROM fat_solic_embal
    WHERE trans_solic_fatura = p_num_transac
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','fat_solic_embal')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol0409_query_solicitacao()
#-----------------------------------#

 DEFINE where_clause, sql_stmt  CHAR(600)
 
 DEFINE p_cons         RECORD
    num_solicit        INTEGER, 
    dat_refer          DATE, 
    cod_tip_carteira   CHAR(02),
    num_lote_om        INTEGER
 END RECORD    

 LET p_nf_solicitr.* = p_nf_solicit.*
 INITIALIZE p_nf_solicit.*, p_cons TO NULL
 CLEAR FORM
 DISPLAY p_cod_empresa TO nf_solicit.cod_empresa
 LET INT_FLAG = FALSE
 
  INPUT BY NAME 
     p_cons.num_solicit,
     p_cons.dat_refer,
     p_cons.num_lote_om WITHOUT DEFAULTS

     BEFORE FIELD num_solicit
   
     AFTER FIELD num_solicit
   
  END INPUT

 IF INT_FLAG <> 0 THEN 
    LET INT_FLAG = 0
    ERROR " Consulta Cancelada "
    LET p_nf_solicit.* = p_nf_solicitr.*
    IF p_ies_cons THEN
       CALL pol0409_exibe_dados_solicitacao()
    END IF
    RETURN
 END IF

 LET sql_stmt = 
    "SELECT UNIQUE a.solicitacao_fatura ",
    "  FROM fat_solic_mestre a, fat_solic_fatura b ", 
    "   WHERE a.empresa = '",p_cod_empresa,"' ",
    #"     AND a.usuario = '",p_user,"' ",
    "     AND b.trans_solic_fatura = a.trans_solic_fatura "
 
 IF p_cons.num_solicit IS NOT NULL THEN
    LET sql_stmt = sql_stmt CLIPPED, " AND a.solicitacao_fatura = '",p_cons.num_solicit,"' "
 END IF
 
 IF p_cons.dat_refer IS NOT NULL THEN
    LET sql_stmt = sql_stmt CLIPPED, " AND a.dat_refer = '",p_cons.dat_refer,"' "
 END IF
  
 IF p_cons.num_lote_om IS NOT NULL THEN
    LET sql_stmt = sql_stmt CLIPPED, " AND b.lote_ord_montag = '",p_cons.num_lote_om,"' "
 END IF

 PREPARE var_query FROM sql_stmt
 DECLARE cq_solicitacao2 SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_solicitacao2
 FETCH cq_solicitacao2 INTO p_nf_solicit.num_solicit

 IF SQLCA.SQLCODE = NOTFOUND THEN
    MESSAGE "Argumentos de Pesquisa nao Encontrados" ATTRIBUTE(REVERSE)
    LET p_ies_cons = FALSE
    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa

 ELSE
    LET p_ies_cons = TRUE
    CALL pol0409_exibe_dados_solicitacao()
 END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION pol0409_exibe_dados_solicitacao()
#-----------------------------------------#

   SELECT UNIQUE 
          a.dat_refer, 
          b.via_transporte, 
          b.lote_ord_montag,
          a.tip_docum,
          a.serie_fatura,
          a.subserie_fatura,
          a.especie_fatura,
          a.tip_solicitacao,
          a.trans_solic_fatura,
          a.lote_geral,
          b.transportadora,
          b.placa_veiculo,
          b.estado_placa_veic,
          b.peso_liquido,
          b.peso_bruto,
          b.texto_1,
          b.texto_2,
          b.texto_3,
          b.lote_ord_montag
     INTO p_nf_solicit.dat_refer, 
          p_nf_solicit.cod_via_transporte,
          p_ordem_montag_lote.num_lote_om,
          p_tip_solic,
          p_nser,
          p_sser,
          p_espcie,
          p_nf_solicit.ies_tip_solicit,
          p_num_transac,
          p_nf_solicit.ies_lotes_geral,
          p_nf_solicit.cod_transpor,
          p_nf_solicit.num_placa,
          p_nf_solicit.cod_estado,
          p_nf_solicit.pes_tot_liquido,
          p_nf_solicit.pes_tot_bruto,
          p_nf_solicit.num_texto_1,
          p_nf_solicit.num_texto_2,
          p_nf_solicit.num_texto_3,
          p_nf_solicit.num_lote_om
    FROM fat_solic_mestre a,
         fat_solic_fatura b
   WHERE a.empresa            = p_cod_empresa
     #AND a.usuario            = p_user
     AND A.solicitacao_fatura = p_nf_solicit.num_solicit
     AND b.trans_solic_fatura = a.trans_solic_fatura

    
 CLEAR FORM
 DISPLAY p_cod_empresa TO cod_empresa

 DISPLAY p_nf_solicit.num_solicit TO num_solicit
 DISPLAY p_nf_solicit.dat_refer TO dat_refer
 DISPLAY p_nf_solicit.cod_via_transporte TO cod_via_transporte
 DISPLAY p_ordem_montag_lote.num_lote_om TO num_lote_om 

 IF pol0409_verifica_via_transporte() THEN
 END IF  
 
 IF p_nf_solicit.cod_transpor IS NOT NULL THEN
    CALL pol0409_verifica_transp() RETURNING p_status
    DISPLAY p_nom_transpor TO nom_transpor
 END IF
 
 DISPLAY p_nf_solicit.cod_transpor     TO cod_transpor
 DISPLAY p_nf_solicit.num_placa        TO num_placa
 DISPLAY p_nf_solicit.cod_estado       TO cod_estado
 DISPLAY p_nf_solicit.pes_tot_liquido  TO pes_tot_liquido
 DISPLAY p_nf_solicit.pes_tot_bruto    TO pes_tot_bruto
 DISPLAY p_nf_solicit.num_texto_1      TO num_texto_1
 DISPLAY p_nf_solicit.num_texto_2      TO num_texto_2
 DISPLAY p_nf_solicit.num_texto_3      TO num_texto_3
 
 IF p_nf_solicit.num_texto_1 IS NOT NULL THEN
    CALL pol0409_le_den_txt(p_nf_solicit.num_texto_1) RETURNING p_status
    DISPLAY p_den_texto TO den_texto_1
 END IF

 IF p_nf_solicit.num_texto_2 IS NOT NULL THEN
    CALL pol0409_le_den_txt(p_nf_solicit.num_texto_2) RETURNING p_status
    DISPLAY p_den_texto TO den_texto_2
 END IF

 IF p_nf_solicit.num_texto_3 IS NOT NULL THEN
    CALL pol0409_le_den_txt(p_nf_solicit.num_texto_3) RETURNING p_status
    DISPLAY p_den_texto TO den_texto_3
 END IF
 
 LET p_num_solicit = p_nf_solicit.num_solicit

 CALL pol0409_le_oms("C")

 IF p_count > 6 THEN
    DISPLAY ARRAY t1_nf_solicit TO s_nf_solicit.*
 ELSE 
    LET INT_FLAG = FALSE
    INPUT ARRAY t1_nf_solicit WITHOUT DEFAULTS FROM s_nf_solicit.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
 END IF
 
 LET INT_FLAG = 0

END FUNCTION

#-----------------------------------#
 FUNCTION pol0409_paginacao(p_funcao)
#-----------------------------------#

 DEFINE p_funcao CHAR(20)
 IF p_ies_cons THEN 
    WHILE TRUE
       LET p_nf_solicitr.* = p_nf_solicit.*
       CASE
          WHEN p_funcao = "SEGUINTE"
               FETCH NEXT     cq_solicitacao2 INTO p_nf_solicit.num_solicit
          WHEN p_funcao = "ANTERIOR"
               FETCH PREVIOUS cq_solicitacao2 INTO p_nf_solicit.num_solicit
       END CASE
       IF SQLCA.SQLCODE = NOTFOUND THEN 
          ERROR " Nao Existem mais Itens nesta Direcao "
          LET p_nf_solicit.* = p_nf_solicitr.*
          EXIT WHILE
       END IF

       SELECT COUNT(dat_refer)
         INTO p_count
         FROM fat_solic_mestre
        WHERE empresa = p_cod_empresa
          AND solicitacao_fatura = p_nf_solicit.num_solicit
          #AND usuario = p_user
      
       IF p_count > 0 THEN  
          CALL pol0409_exibe_dados_solicitacao()
          EXIT WHILE
       END IF
       
    END WHILE
 ELSE 
    ERROR " Nao Existe Nenhuma Consulta Ativa "
 END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0409_den_empresa()
#-----------------------------#

 SELECT den_empresa INTO p_den_empresa
 FROM empresa
 WHERE cod_empresa = p_cod_empresa

END FUNCTION

#----------------------------------#
 FUNCTION pol0409_tabula_qtd_embal()
#----------------------------------#

   DEFINE l_om_embal      RECORD LIKE ordem_montag_embal.*
   DEFINE l_qtd_embal_int DEC(7,2)
   DEFINE l_qtd_embal_ext DEC(7,2)
   DEFINE l_qtd_embal     DEC(5,0)
   DEFINE p_dep           SMALLINT

   FOR p_ind = 1 TO 500
      LET t2_qtd_embal[p_ind].cod_embal = NULL
      LET t2_qtd_embal[p_ind].qtd_embal = NULL
   END FOR

   DECLARE cq_ordem_item CURSOR FOR
   SELECT num_pedido
   FROM ordem_montag_item
   WHERE cod_empresa = p_cod_empresa
     AND num_om = t1_nf_solicit[p_count].num_om

   FOREACH cq_ordem_item INTO p_ordem_montag_item.num_pedido
      EXIT FOREACH
   END FOREACH

   SELECT cod_tip_venda,
          cod_cliente
      INTO p_pedidos.cod_tip_venda,
           p_pedidos.cod_cliente
   FROM pedidos
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido = p_ordem_montag_item.num_pedido

   DECLARE cq_om_embal CURSOR FOR
   SELECT a.cod_embal,
         (b.qtd_reservada / a.qtd_padr_embal)
   FROM embal_itaesbra a, ordem_montag_item b
   WHERE a.cod_empresa = b.cod_empresa
     AND b.cod_empresa = p_cod_empresa
     AND a.cod_cliente = p_pedidos.cod_cliente
     AND a.cod_tip_venda = p_pedidos.cod_tip_venda 
     AND a.cod_item = b.cod_item
     AND b.num_om = t1_nf_solicit[p_count].num_om

{    AND cod_item IN (SELECT cod_item from ordem_montag_item 
                      WHERE embal_itaesbra.cod_empresa = 
                            ordem_montag_item.cod_empresa 
                      AND embal_itaesbra.cod_item = ordem_montag_item.cod_item 
                      AND ordem_montag_item.cod_empresa = p_cod_empresa 
                      AND num_om = t1_nf_solicit[p_count].num_om)    }
#  ORDER BY cod_item
 
{
   DECLARE cq_om_embal CURSOR FOR
#  SELECT * INTO l_om_embal.* FROM ordem_montag_embal
   SELECT * FROM ordem_montag_embal
   WHERE ordem_montag_embal.cod_empresa = p_cod_empresa
#    AND ordem_montag_embal.num_om = t1_nf_solicit[pa_curr].num_om
     AND ordem_montag_embal.num_om = t1_nf_solicit[p_count].num_om
   ORDER BY cod_item   
}

   LET p_dep = 0
#  FOREACH cq_om_embal INTO l_om_embal.*
   FOREACH cq_om_embal INTO l_om_embal.cod_embal_int,
                        #   l_om_embal.qtd_embal_int,
                            l_qtd_embal_int,
                            l_om_embal.cod_embal_ext,
                        #   l_om_embal.qtd_embal_ext
                            l_qtd_embal_ext

      IF l_om_embal.cod_embal_int <> "   " AND
         l_om_embal.cod_embal_int > "0" THEN 
         FOR p_ind = 1 TO p_dep
            IF t2_qtd_embal[p_ind].cod_embal = l_om_embal.cod_embal_int THEN 
               LET t2_qtd_embal[p_ind].qtd_embal = t2_qtd_embal[p_ind].qtd_embal
                                                #  + l_om_embal.qtd_embal_int
                                                   + l_qtd_embal_int
               EXIT FOR
            END IF
         END FOR
         IF p_ind < 6 THEN 
            IF p_ind > p_dep THEN 
               LET p_dep = p_ind
               LET t2_qtd_embal[p_ind].cod_embal = l_om_embal.cod_embal_int
            #  LET t2_qtd_embal[p_ind].qtd_embal = l_om_embal.qtd_embal_int
               LET t2_qtd_embal[p_ind].qtd_embal = l_qtd_embal_int
            END IF
         ELSE 
            INITIALIZE t2_qtd_embal TO NULL  #para contemplar quando
                                             #tem mais de 5 embal.
                                             #para o vdp0570 calcu-
                                             #lar correto.
            RETURN
         END IF
      END IF

      IF l_om_embal.cod_embal_ext <> "   " AND
         l_om_embal.cod_embal_ext > "0" THEN 
         FOR p_ind = 1 TO p_dep
            IF t2_qtd_embal[p_ind].cod_embal = l_om_embal.cod_embal_ext THEN 
               LET t2_qtd_embal[p_ind].qtd_embal = t2_qtd_embal[p_ind].qtd_embal
                                                #  + l_om_embal.qtd_embal_ext
                                                   + l_qtd_embal_ext
               EXIT FOR
            END IF
         END FOR
         IF p_ind < 6 THEN 
            IF p_ind > p_dep THEN 
               LET p_dep = p_ind
               LET t2_qtd_embal[p_ind].cod_embal = l_om_embal.cod_embal_ext
            #  LET t2_qtd_embal[p_ind].qtd_embal = l_om_embal.qtd_embal_ext
               LET t2_qtd_embal[p_ind].qtd_embal = l_qtd_embal_ext
            END IF
         ELSE 
            INITIALIZE t2_qtd_embal TO NULL
            RETURN
         END IF
      END IF

   END FOREACH

   FOR p_ind = 1 TO 5
      LET l_qtd_embal = t2_qtd_embal[p_ind].qtd_embal
      IF t2_qtd_embal[p_ind].qtd_embal > l_qtd_embal THEN
         LET t2_qtd_embal[p_ind].qtd_embal = l_qtd_embal + 1
      END IF    
   END FOR

END FUNCTION 

#--------------------------------#
 FUNCTION pol0409_exibe_item(p_om)
#--------------------------------#

   DEFINE p_om LIKE ordem_montag_item.num_om,
          p_i  SMALLINT   

   CALL log006_exibe_teclas("01", p_versao)
   INITIALIZE t_om_item TO NULL

   CALL log130_procura_caminho("POL04093") RETURNING p_nom_tela
   OPEN WINDOW w_pol04093 AT 3,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa 

   DECLARE cq_om_item CURSOR FOR
   SELECT cod_item,
          qtd_reservada,
          pes_total_item
   FROM ordem_montag_item   
   WHERE cod_empresa = p_cod_empresa
     AND num_om = p_om                        

   LET p_i = 1
   FOREACH cq_om_item INTO t_om_item[p_i].cod_item,
                           t_om_item[p_i].qtd_reservada,
                           t_om_item[p_i].pes_total_item

      SELECT den_item_reduz
         INTO t_om_item[p_i].den_item_reduz
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = t_om_item[p_i].cod_item

      LET p_i = p_i + 1

   END FOREACH 

   LET p_i = p_i - 1
   CALL SET_COUNT(p_i)

   IF p_i > 0 THEN
      DISPLAY ARRAY t_om_item TO s_om_item.* 
      END DISPLAY 
   END IF

   CLOSE WINDOW w_pol04093
   CURRENT WINDOW IS w_pol0409

END FUNCTION

#------------------------------#
 FUNCTION pol0409_exibe_transp()
#------------------------------#

   DEFINE l_r CHAR(1)

   CALL log006_exibe_teclas("01", p_versao)
   INITIALIZE p_nom_tela TO NULL

   CALL log130_procura_caminho("POL04094") RETURNING p_nom_tela
   OPEN WINDOW w_pol04094 AT 4,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, FORM LINE FIRST, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY t_transp[pa_curr].* TO s_transp[1].*

   PROMPT "Digite Enter p/ Retornar" FOR l_r

   CLOSE WINDOW w_pol04094
   CURRENT WINDOW IS w_pol0409

END FUNCTION

#--------------------------#
 FUNCTION pol0409_listagem()
#--------------------------#     

   IF NOT pol0409_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol0409_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_index = 1
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT solicitacao_fatura,
           trans_solic_fatura
      FROM fat_solic_mestre
     WHERE empresa = p_cod_empresa
       #AND usuario = p_user
     ORDER BY solicitacao_fatura
   
   FOREACH cq_impressao 
      INTO p_relat.solicitacao_fatura,
           p_trans_solic_fatura

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_solic_mestre:cq_impressao')
         RETURN FALSE
      END IF      
      
      SELECT lote_ord_montag,
             transportadora,
             placa_veiculo,
             texto_1,
             texto_2,
             texto_3
        INTO p_relat.lote_ord_montag,
             p_relat.transportadora,
             p_relat.placa_veiculo,
             p_relat.texto_1,
             p_relat.texto_2,
             p_relat.texto_3
        FROM fat_solic_fatura
       WHERE trans_solic_fatura = p_trans_solic_fatura
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_solic_fatura')
         RETURN FALSE
      END IF
      
      SELECT nom_cliente
        INTO p_nom_cliente
        FROM clientes
       WHERE cod_cliente = p_relat.transportadora
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','clientes')
         RETURN FALSE
      END IF
      
      DECLARE cq_impressao_2 CURSOR FOR
      
       SELECT num_om,
              qtd_volume_om
         FROM ordem_montag_mest
        WHERE cod_empresa = p_cod_empresa
          AND num_lote_om = p_relat.lote_ord_montag
        ORDER BY num_om
          
      FOREACH cq_impressao_2
         INTO p_relat.num_om,
              p_relat.qtd_volume_om
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ordem_montag_mest:cq_impressao_2')
            RETURN FALSE
         END IF
         
         LET p_vezes       = 0
         LET p_embal_1     = NULL 
         LET p_embal_2     = NULL
         LET p_embal_3     = NULL
         LET p_embal_4     = NULL
         LET p_embal_5     = NULL
         LET p_qtd_embal_1 = NULL
         LET p_qtd_embal_2 = NULL
         LET p_qtd_embal_3 = NULL
         LET p_qtd_embal_4 = NULL
         LET p_qtd_embal_5 = NULL
         
         DECLARE cq_impressao_3 CURSOR FOR
          
          SELECT embalagem,
                 qtd_embalagem
            FROM fat_solic_embal
           WHERE trans_solic_fatura = p_trans_solic_fatura
             AND lote_ord_montag    = p_relat.lote_ord_montag
             AND ord_montag         = p_relat.num_om
             
         FOREACH cq_impressao_3
            INTO p_relat.embalagem,
                 p_relat.qtd_embalagem
                  
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','fat_solic_embal:cq_impressao_3')
               RETURN FALSE
            END IF
             
            LET p_vezes = p_vezes + 1
            
            CASE p_vezes
             
               WHEN 1
                LET p_embal_1     = p_relat.embalagem
                LET p_qtd_embal_1 = p_relat.qtd_embalagem
                 
               WHEN 2
                LET p_embal_2     = p_relat.embalagem
                LET p_qtd_embal_2 = p_relat.qtd_embalagem
                 
               WHEN 3
                LET p_embal_3     = p_relat.embalagem
                LET p_qtd_embal_3 = p_relat.qtd_embalagem
                 
               WHEN 4
                LET p_embal_4     = p_relat.embalagem
                LET p_qtd_embal_4 = p_relat.qtd_embalagem
                 
               WHEN 5
                LET p_embal_5     = p_relat.embalagem
                LET p_qtd_embal_5 = p_relat.qtd_embalagem
                
               OTHERWISE
                EXIT FOREACH 
                 
            END CASE
             
         END FOREACH 
         
         OUTPUT TO REPORT pol0409_relat(p_relat.solicitacao_fatura)
         
         LET p_count = 1
 
      END FOREACH 
       
   END FOREACH  
               
   FINISH REPORT pol0409_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol0409_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0409.tmp"
         START REPORT pol0409_relat TO p_caminho
      ELSE
         START REPORT pol0409_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol0409_le_empresa()
#---------------------------#

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

#-----------------------------------------#
 REPORT pol0409_relat(p_solicitacao_fatura)
#-----------------------------------------#
  
  DEFINE p_solicitacao_fatura LIKE fat_solic_mestre.trans_solic_fatura
  
  OUTPUT LEFT   MARGIN 0
         TOP    MARGIN 0
         BOTTOM MARGIN 1
         PAGE   LENGTH 66
     
     ORDER EXTERNAL BY p_solicitacao_fatura
     
  FORMAT
     
     FIRST PAGE HEADER
         
        PRINT COLUMN 001, p_den_empresa, p_comprime,
              COLUMN 090, "PAG.: ", PAGENO USING "####&" 
              
        PRINT COLUMN 001, "pol0409",
              COLUMN 029, "SOLICITACAO DE FATURAMENTO",
              COLUMN 070, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
        PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------"
        PRINT
         
     PAGE HEADER

        PRINT COLUMN 001, p_den_empresa, p_comprime,
              COLUMN 090, "PAG.: ", PAGENO USING "####&" 
               
        PRINT COLUMN 001, "pol0409",
              COLUMN 029, "SOLICITACAO DE FATURAMENTO",
              COLUMN 072, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
        PRINT COLUMN 001, "---------------------------------------------------------------------------------------------------"
        PRINT
        
        PRINT COLUMN 001, '                       |------------------------------- EMBALAGENS -------------------------------|'
        PRINT COLUMN 001, 'Num.OM      Volume     |Cod Quantidade Cod Quantidade Cod Quantidade Cod Quantidade Cod Quantidade|'
        PRINT COLUMN 001, '------ ----------------|--- ---------- --- ---------- --- ---------- --- ---------- --- ----------|'
        
     BEFORE GROUP OF p_solicitacao_fatura
        
        SKIP 2 LINES 
        PRINT COLUMN 007, 'Solicitacao: ', p_relat.solicitacao_fatura USING '##########', '      Lote: ', p_relat.lote_ord_montag USING '##########'
        PRINT COLUMN 004, 'Transportadora: ', p_relat.Transportadora, ' ', p_nom_cliente, ' Placa: ', p_relat.placa_veiculo
        PRINT COLUMN 012, 'Textos: ', p_relat.texto_1, ' ', p_relat.texto_2, ' ', p_relat.texto_3
        PRINT 
        PRINT COLUMN 001, '                       |------------------------------- EMBALAGENS -------------------------------|'
        PRINT COLUMN 001, 'Num.OM      Volume     |Cod Quantidade Cod Quantidade Cod Quantidade Cod Quantidade Cod Quantidade|'
        PRINT COLUMN 001, '------ ----------------|--- ---------- --- ---------- --- ---------- --- ---------- --- ----------|'
     
     ON EVERY ROW

        PRINT COLUMN 001,  p_relat.num_om             USING "######", 
              COLUMN 008,  p_relat.qtd_volume_om      USING "###########&.&&&", 
              COLUMN 024,  '|', p_embal_1, 
              COLUMN 029,  p_qtd_embal_1              USING "######&.&&", 
              COLUMN 040,  p_embal_2, 
              COLUMN 044,  p_qtd_embal_2              USING "######&.&&", 
              COLUMN 055,  p_embal_3, 
              COLUMN 059,  p_qtd_embal_3              USING "######&.&&", 
              COLUMN 070,  p_embal_4, 
              COLUMN 074,  p_qtd_embal_4              USING "######&.&&",
              COLUMN 085,  p_embal_5, 
              COLUMN 089,  p_qtd_embal_5              USING "######&.&&", '|'


     ON LAST ROW
        LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF

END REPORT

#-------------------------------#
FUNCTION pol0409_verif_estoque()
#-------------------------------#
   
   define p_num_om integer,
          p_num_reserva integer,
          p_cod_item char(15),
          p_cod_local CHAR(10),
          p_qtd_item  decimal(10,2),
          p_num_lote CHAR(15),
          p_qtd_saldo decimal(10,2),
          p_sem_saldo SMALLINT
   
   let p_sem_saldo = false
   
   DECLARE cq_est cursor for
    SELECT num_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = p_ordem_montag_lote.num_lote_om
      AND ies_sit_om  = 'N'

   FOREACH cq_est into p_num_om
      
      if status <> 0 then
         call log003_err_sql('Lendo','ordem_montag_mest:cq_est')
         RETURN false
      end if
      
      DECLARE cq_omg cursor for
       select num_reserva
         from ordem_montag_grade 
        WHERE cod_empresa = p_cod_empresa 
          and num_om = p_num_om
      FOREACH cq_omg into p_num_reserva

         if status <> 0 then
            call log003_err_sql('Lendo','ordem_montag_mest:cq_est')
            RETURN false
         end if
         
         select cod_item,
                cod_local,
                num_lote,
                qtd_reservada
           into p_cod_item,
                p_cod_local,
                p_num_lote,
                p_qtd_item
           from estoque_loc_reser 
          where cod_empresa = p_cod_empresa
            and num_reserva = p_num_reserva

         if status <> 0 then
             call log003_err_sql('Lendo','estoque_loc_reser:cq_omg')
            RETURN false
         end if
         
         if p_num_lote is null then  
            select sum(qtd_saldo)
              into p_qtd_saldo
              from estoque_lote 
             where cod_empresa = p_cod_empresa
               and cod_item = p_cod_item 
               and cod_local = p_cod_local 
               and ies_situa_qtd in ('L','E')
               and num_lote is null
         else
            select sum(qtd_saldo)
              into p_qtd_saldo
              from estoque_lote 
             where cod_empresa = p_cod_empresa
               and cod_item = p_cod_item 
               and cod_local = p_cod_local 
               and ies_situa_qtd in ('L','E')
               and num_lote = p_num_lote
         end if
         
         if status <> 0 then
             call log003_err_sql('Lendo','estoque_lote:cq_omg')
            RETURN false
         end if

         if p_qtd_saldo is null then
            let p_qtd_saldo = 0
         end if
         
         if p_qtd_saldo < p_qtd_item then
            let p_msg = 'OM:', p_num_om,'\n',
                        'Item:', p_cod_item,'\n',
                        'Reserva:', p_num_reserva,'\n',
                        'Qtd reservada:', p_qtd_item, '\n',
                        'Qtd saldo:', p_qtd_saldo, '\n'
            call log0030_mensagem(p_msg,'excla')
            let p_sem_saldo = true
         end if
         
      end FOREACH
   
   end FOREACH
   
   let p_msg = null
   
   if p_sem_saldo then
      error 'Por falta de saldo, esse lote/om não podera ser faturado!'
      RETURN false
   end if
   
   RETURN true

end FUNCTION
   
        
#------------------------------- FIM DE PROGRAMA BL------------------------------#

{
15/08/2012 - Ivo
- Liberação, para digitação, em todos os campos referentes aos códigos e quantidades de embalagens

