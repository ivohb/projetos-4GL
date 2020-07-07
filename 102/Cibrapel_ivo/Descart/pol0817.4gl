#-----------------------------------------#
# PROGRAMA: pol0817                       #
#-----------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_apont_trim_885    RECORD LIKE apont_trim_885.*,
          p_apont_trim_885e   RECORD LIKE apont_trim_885.*,
          p_empresas_885     RECORD LIKE empresas_885.*,
          p_cod_empresa      LIKE empresa.cod_empresa,
          p_cod_emp_aux      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_den_cidade       LIKE cidades.den_cidade,
          p_ies_cons         SMALLINT,
          p_last_row         SMALLINT,
          p_conta            SMALLINT,
          p_cont             SMALLINT,
          pa_curr            SMALLINT,
          sc_curr            SMALLINT,
          p_status           SMALLINT,
          p_funcao           CHAR(15),
          p_houve_erro       SMALLINT, 
          p_comando          CHAR(80),
          p_caminho          CHAR(80),
          p_help             CHAR(80),
          p_cancel           INTEGER,
          p_nom_tela         CHAR(80),
          p_mensag           CHAR(200),
          w_i                SMALLINT,
          p_i                SMALLINT, 
          p_cod_unid_med     LIKE item.cod_unid_med

   DEFINE t_apon_itens ARRAY[500] OF RECORD
          numsequencia  LIKE apont_trim_885.numsequencia,
          num_ordem     DECIMAL(6,0),           
          coditem       LIKE apont_trim_885.coditem,       
          codmaquina    LIKE apont_trim_885.codmaquina,    
          qtdprod       LIKE apont_trim_885.qtdprod,       
          tipmovto      LIKE apont_trim_885.tipmovto,      
          largura       LIKE apont_trim_885.largura,       
          diametro      LIKE apont_trim_885.diametro,      
          comprimento   LIKE apont_trim_885.comprimento,   
          tubete        LIKE apont_trim_885.tubete,        
          num_lote      LIKE apont_trim_885.num_lote,      
          consumorefugo LIKE apont_trim_885.consumorefugo
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

MAIN
   LET p_versao = "POL0817-05.10.01" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0817_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0817_controle()
#--------------------------#

   INITIALIZE p_apont_trim_885.* TO NULL

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0817") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0817 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Pedido"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0817","CO") THEN 
            CALL pol0817_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Total"
            END IF
         END IF

       COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0817

END FUNCTION

#--------------------------#
 FUNCTION pol0817_consulta()
#--------------------------#
 
   CLEAR FORM
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0817
 
   SELECT *
     INTO p_empresas_885.*
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
   IF SQLCA.sqlcode <> 0 THEN   
      SELECT *
        INTO p_empresas_885.*
        FROM empresas_885
       WHERE cod_emp_gerencial = p_cod_empresa
   END IF 
    
   LET p_apont_trim_885.numordem = NULL 
   LET p_apont_trim_885.numpedido = NULL 
   
   IF pol0817_entrada_dados() THEN
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_apont_trim_885.numordem = NULL 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0817_entrada_dados()
#-------------------------------#
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0817

   LET INT_FLAG = FALSE  
   INPUT BY NAME p_apont_trim_885.numordem,
                 p_apont_trim_885.numpedido
      WITHOUT DEFAULTS  

      AFTER FIELD numordem     
      IF p_apont_trim_885.numordem IS NOT NULL THEN
         SELECT MAX(numpedido)
           INTO p_apont_trim_885.numpedido
           FROM apont_trim_885                  
          WHERE codempresa = p_empresas_885.cod_emp_gerencial
            AND numordem = p_apont_trim_885.numordem
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Ordem inexixtente" 
            NEXT FIELD numordem  
         ELSE
            CALL pol0817_monta_dados_ordem()
         END IF
      END IF 

      AFTER FIELD numpedido     
      IF p_apont_trim_885.numpedido IS NOT NULL THEN
         SELECT MAX(numordem)
           INTO p_apont_trim_885.numordem
           FROM apont_trim_885                  
          WHERE codempresa = p_empresas_885.cod_emp_gerencial
            AND numpedido = p_apont_trim_885.numpedido
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Pedido inexixtente" 
            NEXT FIELD numopedido       
         ELSE
            CALL pol0817_monta_dados_pedido()
         END IF
      ELSE
         IF p_apont_trim_885.numordem IS NULL THEN   
            ERROR 'Informe a Ordem ou o Pedido'
            NEXT FIELD numordem
         END IF    
      END IF 

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0817
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#------------------------------------#
 FUNCTION pol0817_monta_dados_ordem()
#------------------------------------#

   DISPLAY BY NAME p_apont_trim_885.codempresa
   DISPLAY BY NAME p_apont_trim_885.numordem
   DISPLAY BY NAME p_apont_trim_885.numpedido

   INITIALIZE t_apon_itens TO NULL
   
   DECLARE c_apon_ord CURSOR FOR
   SELECT *
     FROM apont_trim_885
    WHERE codempresa = p_empresas_885.cod_emp_gerencial
      AND numordem = p_apont_trim_885.numordem
    ORDER BY numsequencia 

   LET p_i = 1
   FOREACH c_apon_ord INTO p_apont_trim_885.*

      LET t_apon_itens[p_i].numsequencia  = p_apont_trim_885.numsequencia     
      LET t_apon_itens[p_i].num_ordem     = p_apont_trim_885.numordem  
      LET t_apon_itens[p_i].coditem       = p_apont_trim_885.coditem      
      LET t_apon_itens[p_i].codmaquina    = p_apont_trim_885.codmaquina  
      LET t_apon_itens[p_i].qtdprod       = p_apont_trim_885.qtdprod  
      LET t_apon_itens[p_i].tipmovto      = p_apont_trim_885.tipmovto  
      LET t_apon_itens[p_i].largura       = p_apont_trim_885.largura    
      LET t_apon_itens[p_i].diametro      = p_apont_trim_885.diametro   
      LET t_apon_itens[p_i].tubete        = p_apont_trim_885.tubete     
      LET t_apon_itens[p_i].comprimento   = p_apont_trim_885.comprimento
      LET t_apon_itens[p_i].num_lote      = p_apont_trim_885.num_lote  
      LET t_apon_itens[p_i].consumorefugo = p_apont_trim_885.consumorefugo 

      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_apon_itens TO s_apon_itens.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0817_monta_dados_pedido()
#------------------------------------#

   DISPLAY BY NAME p_apont_trim_885.codempresa
   DISPLAY BY NAME p_apont_trim_885.numordem
   DISPLAY BY NAME p_apont_trim_885.numpedido

   INITIALIZE t_apon_itens TO NULL
   
   DECLARE c_apon_ped CURSOR FOR
   SELECT *
     FROM apont_trim_885
    WHERE codempresa = p_empresas_885.cod_emp_gerencial
      AND numpedido = p_apont_trim_885.numpedido
    ORDER BY numsequencia 

   LET p_i = 1
   FOREACH c_apon_ped INTO p_apont_trim_885.*

      LET t_apon_itens[p_i].numsequencia  = p_apont_trim_885.numsequencia
      LET t_apon_itens[p_i].num_ordem     = p_apont_trim_885.numordem  
      LET t_apon_itens[p_i].coditem       = p_apont_trim_885.coditem      
      LET t_apon_itens[p_i].codmaquina    = p_apont_trim_885.codmaquina  
      LET t_apon_itens[p_i].qtdprod       = p_apont_trim_885.qtdprod  
      LET t_apon_itens[p_i].tipmovto      = p_apont_trim_885.tipmovto  
      LET t_apon_itens[p_i].largura       = p_apont_trim_885.largura    
      LET t_apon_itens[p_i].diametro      = p_apont_trim_885.diametro   
      LET t_apon_itens[p_i].tubete        = p_apont_trim_885.tubete     
      LET t_apon_itens[p_i].comprimento   = p_apont_trim_885.comprimento
      LET t_apon_itens[p_i].num_lote      = p_apont_trim_885.num_lote  
      LET t_apon_itens[p_i].consumorefugo = p_apont_trim_885.consumorefugo 

      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_apon_itens TO s_apon_itens.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION