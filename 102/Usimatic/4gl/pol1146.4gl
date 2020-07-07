#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1146                                                 #
# OBJETIVO: DEMANDA DE PEDIDOS                                      #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 11/04/12                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          p_num_pedido         DECIMAL(6,0),
          p_num_docum          CHAR(10),
          p_prz_entrega        DATE,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
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
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
  
   DEFINE p_tela              RECORD
          dat_ini             DATE,
          dat_fim             DATE
   END RECORD


DEFINE p_demanda            RECORD
    cod_empresa char(2),  
    num_docum char(10),   
    cod_item char(15),    
    cod_grade_1 char(15), 
    cod_grade_2 char(15), 
    cod_grade_3 char(15), 
    cod_grade_4 char(15), 
    cod_grade_5 char(15), 
    prz_entrega date,     
    qtd_saldo decimal(15,3), 
    empresa_necessidade char(2),
    dat_pedido date,
    pedido decimal(6,0),
    seq_item_pedido decimal(5,0),
    sit_demanda char(1),
    origem char(1),
    texto_demanda char(4000),
    docum_origem char(30)
END RECORD
                
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1146-12.00.07"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol1146_menu()
   END IF
END MAIN

#-----------------------#
 FUNCTION pol1146_menu()#
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1146") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1146 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros p/ o processamento"
         CALL pol1146_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso !!!'
            LET p_ies_cons = TRUE
            NEXT OPTION "Processar"
         ELSE
            ERROR 'Operação cancelada !!!'
            LET p_ies_cons = FALSE
         END IF 
      COMMAND "Processar" "Processa a geração da demanda p/ MRP"
         IF p_ies_cons THEN
            IF pol1146_processar() THEN
               ERROR 'Operação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancela !!!'
            END IF 
            LET p_ies_cons = FALSE
            NEXT OPTION "Fim" 
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION "Informar"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1146_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1146

END FUNCTION

#------------------------#
 FUNCTION pol1146_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
 FUNCTION pol1146_informar()#
#---------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG =  FALSE
   
   INPUT BY NAME p_tela.*  WITHOUT DEFAULTS  

      AFTER INPUT
         IF INT_FLAG = 0 THEN

            IF p_tela.dat_ini IS NULL THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD dat_ini 
            END IF

            IF p_tela.dat_fim IS NULL THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD dat_fim
            END IF
         
            IF p_tela.dat_fim < p_tela.dat_ini THEN 
               ERROR 'Data final nao pode ser menor que inicial.'
               NEXT FIELD dat_fim
            END IF

         END IF

   END INPUT

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1146_processar()#
#---------------------------#

   IF NOT log004_confirm(19,41) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1146_gera_demanda() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1146_gera_demanda()#
#------------------------------#

   DEFINE p_dat_txt    char(10),
          p_dia        INTEGER,
          l_situacao   CHAR(01),
          l_origem     CHAR(01),
          p_id         INTEGER
          
      
   DECLARE cq_dem CURSOR WITH HOLD FOR
    SELECT pedido,
           num_docum, 
           prz_entrega,
           rowid
      FROM mrp_dem_grade
     WHERE cod_empresa = p_cod_empresa
       AND prz_entrega >= p_tela.dat_ini
       AND prz_entrega <= p_tela.dat_fim
     ORDER BY prz_entrega

   FOREACH cq_dem INTO p_demanda.pedido,
      p_demanda.num_docum, p_demanda.prz_entrega,  p_id

      IF STATUS <> 0 then
         CALL log003_err_sql('Lendo','mrp_dem_grade:cq_dem')
         RETURN FALSE
      END IF
      
      IF p_demanda.pedido = '0' OR p_demanda.pedido IS NULL THEN
         LET p_demanda.num_docum = 'PREVISAO'
         LET p_dat_txt = p_demanda.prz_entrega
         LET p_dia = p_dat_txt[1,2]
      
         IF p_dia = pol1146_ultimo_do_mes(p_dat_txt) then
            let p_dat_txt = '01',p_dat_txt[3,10]
            let p_demanda.prz_entrega = p_dat_txt
         END IF

         UPDATE mrp_dem_grade
            SET num_docum = p_demanda.num_docum,
                prz_entrega = p_demanda.prz_entrega
          WHERE rowid = p_id
       
         IF STATUS <> 0 then
            CALL log003_err_sql('update','mrp_dem_grade')
            RETURN FALSE
         END IF      

      END IF
                  
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1146_ultimo_do_mes(p_data)#
#-------------------------------------#

   DEFINE p_data       CHAR(10),
          p_mes        INTEGER,
          p_ano        INTEGER,
          p_resto      INTEGER,
          p_ultimo_dia INTEGER    
          
   let p_mes = p_data[4,5]
   
   if p_mes = 4 or p_mes = 6 or p_mes = 9 or p_mes = 11 then
      let p_ultimo_dia = 30
   else
      if p_mes = 2 then
         let p_ano = p_data[7,10]
         let p_resto = p_ano MOD 4
         if p_resto = 0 then
            let p_ultimo_dia = 29
         else
            let p_ultimo_dia = 28
         end if
      else
         let p_ultimo_dia = 31
      end if
   end if
   
   RETURN (p_ultimo_dia)

END FUNCTION

   
#-----------------------------#
FUNCTION pol1146_pega_pedido()
#-----------------------------#

   DEFINE p_carac CHAR(01),
          p_numpedido CHAR(6),
          p_numseq    CHAR(3),
          p_ind       INTEGER

   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
   
   FOR p_ind = p_ind + 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   LET p_num_pedido  = p_numpedido
   LET p_num_seq = p_numseq
   
END FUNCTION

   