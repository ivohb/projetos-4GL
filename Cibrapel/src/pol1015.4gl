#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1015                                                 #
# OBJETIVO: EXPORTAÇÃO DE TEXTO DO CLIENTE PARA O TRIM              #
# DATA....: 12/02/10                                                #
# CONVERSÃO 10.02: 16/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_chave              CHAR(700),
          p_ponto              CHAR(01)
                 
   DEFINE p_cliente            LIKE vdp_cliente_texto.cliente, 
          p_sequencia_texto    LIKE vdp_cliente_texto.sequencia_texto,
          p_texto              LIKE vdp_cliente_texto.texto,
          p_data_hora          DATETIME YEAR TO SECOND, #LIKE cli_txt_erro_885.data_hora,
          p_mensagem           CHAR(100) #LIKE cli_txt_erro_885.mensagem
                    
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1015-10.02.00  "
   CALL func002_versao_prg(p_versao)

   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1015_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol1015_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1015") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1015 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   DELETE FROM cli_txt_erro_885
   
   CALL pol1015_processar()
   
   CALL pol1015_deletar()   
      
   CLOSE WINDOW w_pol1015

END FUNCTION

#---------------------------#
 FUNCTION pol1015_processar()
#---------------------------#
   
   MESSAGE "Aguarde! Processando..."
   LET p_ponto = 1 
   
   DECLARE cq_processa CURSOR FOR 
   
   SELECT cliente,
          sequencia_texto,
          texto
     FROM vdp_cliente_texto
    
   FOREACH cq_processa INTO 
           p_cliente,
           p_sequencia_texto,
           p_texto
      
      IF STATUS <> 0 THEN 
         LET p_data_hora = CURRENT 
         LET p_mensagem  = "Erro: ", STATUS, "  Lendo", "  vdp_cliente_texto"
         CALL pol1015_grava_erro()
         CONTINUE FOREACH 
      END IF
      
      SELECT cliente,
             sequencia_texto,
             texto
        FROM cliente_texto_885 
       WHERE cliente         = p_cliente
         AND sequencia_texto = p_sequencia_texto
             
      IF STATUS = 100 THEN 
         IF NOT pol1015_insere_dados() THEN 
            CONTINUE FOREACH 
         END IF 
      ELSE 
         IF STATUS <> 0 THEN 
            LET p_data_hora = CURRENT 
            LET p_mensagem  = "Erro: ", STATUS, "  Lendo", "  cliente_texto_885"
            CALL pol1015_grava_erro()
            CONTINUE FOREACH
         ELSE 
            IF NOT pol1015_atualiza_dados() THEN 
               CONTINUE FOREACH 
            END IF 
         END IF 
      END IF 
      
      IF p_ponto = 1 THEN
         MESSAGE "Aguarde! Processando."
         LET p_ponto = 2 
      ELSE
         IF p_ponto = 2 THEN
            MESSAGE "Aguarde! Processando.."
            LET p_ponto = 3
         ELSE
            MESSAGE "Aguarde! Processando..."
            LET p_ponto = 1
         END IF 
      END IF 
      
   END FOREACH 
      
   RETURN 
   
END FUNCTION 
      
#------------------------------#
 FUNCTION pol1015_insere_dados()
#------------------------------#

   INSERT INTO cliente_texto_885
      VALUES (p_cliente, p_sequencia_texto, p_texto)
      
   IF STATUS <> 0 THEN 
      LET p_data_hora = CURRENT 
      LET p_mensagem  = "Erro: ", STATUS, "  Inserindo", "  cliente_texto_885"
      CALL pol1015_grava_erro()
      RETURN FALSE 
   END IF 
   
   RETURN TRUE 
   
END FUNCTION 

#--------------------------------#
 FUNCTION pol1015_atualiza_dados()
#--------------------------------#  

   UPDATE cliente_texto_885
      SET texto = p_texto
    WHERE cliente         = p_cliente
      AND sequencia_texto = p_sequencia_texto
          
    IF STATUS <> 0 THEN 
       LET p_data_hora = CURRENT 
       LET p_mensagem  = "Erro: ", STATUS, "  Modificando", "  cliente_texto_885"
       CALL pol1015_grava_erro()
    END IF 
    
    RETURN TRUE 
    
END FUNCTION  

#----------------------------#
 FUNCTION pol1015_grava_erro()
#----------------------------#
   
   INSERT INTO cli_txt_erro_885
      VALUES (p_data_hora, p_mensagem)
   
   RETURN 
   
END FUNCTION 

#-------------------------#
 FUNCTION pol1015_deletar()
#-------------------------#
   
   DECLARE cq_deleta CURSOR FOR 
   
   SELECT cliente,
          sequencia_texto
     FROM cliente_texto_885
   FOREACH cq_deleta INTO 
           p_cliente,
           p_sequencia_texto
           
      IF STATUS <> 0 THEN 
         LET p_data_hora = CURRENT 
         LET p_mensagem  = "Erro: ", STATUS, "  Lendo", "  cliente_texto_885"
         CALL pol1015_grava_erro()
         CONTINUE FOREACH 
      END IF
      
      SELECT cliente,
             sequencia_texto
        FROM vdp_cliente_texto 
       WHERE cliente         = p_cliente
         AND sequencia_texto = p_sequencia_texto
             
      IF STATUS = 100 THEN 
         IF NOT pol1015_deleta_texto() THEN 
            CONTINUE FOREACH 
         END IF 
      ELSE 
         IF STATUS <> 0 THEN 
            LET p_data_hora = CURRENT 
            LET p_mensagem  = "Erro: ", STATUS, "  Lendo", "  vdp_cliente_texto"
            CALL pol1015_grava_erro()
         END IF 
      END IF 
      
   END FOREACH  
   
   RETURN 
   
END FUNCTION 

#------------------------------#
 FUNCTION pol1015_deleta_texto()
#------------------------------#

   DELETE FROM cliente_texto_885
    WHERE cliente         = p_cliente
      AND sequencia_texto = p_sequencia_texto
      
   IF STATUS <> 0 THEN 
      LET p_data_hora = CURRENT 
      LET p_mensagem  = "Erro: ", STATUS, "  Deletando", "  cliente_texto_885"
      CALL pol1015_grava_erro()
      RETURN FALSE 
   END IF 
   
   RETURN TRUE  
   
END FUNCTION 
                
#-------------------------------- FIM DE PROGRAMA -----------------------------#