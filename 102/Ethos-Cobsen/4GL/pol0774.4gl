#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: pol0774                                                 #
# MODULOS.: pol0774 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: RELATORIO DE PEDIDO DE VENDAS                           #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 07/12/2004                                              #
#-------------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
          p_den_empresa   LIKE empresa.den_empresa,
          p_user          LIKE usuario.nom_usuario,
          p_status        SMALLINT,
          p_comprime      CHAR(01),
          p_descomprime   CHAR(01),
          comando         CHAR(80),
          p_nom_arquivo   CHAR(100),
          p_nom_tela      CHAR(200),
          p_den_item      CHAR(72), 
          p_count         SMALLINT,
          p_nom_help      CHAR(200),
          p_ies_lista     SMALLINT,
          p_ies_impressao CHAR(01),
          p_versao        CHAR(18),
          p_ies_cons      SMALLINT,
          g_ies_ambiente  CHAR(01),
          p_caminho       CHAR(080),
          p_msg           CHAR(500)

   DEFINE p_ped_ethos_edi_pe3 RECORD LIKE ped_ethos_edi_pe3.*,
          p_ped_ethos_edi_pe5 RECORD LIKE ped_ethos_edi_pe5.*,
          p_ped_ethos_edi_pe1 RECORD LIKE ped_ethos_edi_pe1.*,
          p_ped_ethos_edi_pe6 RECORD LIKE ped_ethos_edi_pe6.*,
          p_ped_ethos_edi_te1 RECORD LIKE ped_ethos_edi_te1.*,          
          p_pedidos           RECORD LIKE pedidos.*, 
          p_ped_itens         RECORD LIKE ped_itens.*
                                                   
   DEFINE p_tela RECORD
      cod_cliente         LIKE pedidos.cod_cliente,          
      nom_cliente         LIKE clientes.nom_cliente,
      dat_ini             LIKE pedidos.dat_pedido,
      dat_fim             LIKE pedidos.dat_pedido,
      cod_item            CHAR(15),
      ies_txt             CHAR(01)
   END RECORD 

   DEFINE p_relat RECORD 
      cod_cliente         LIKE pedidos.cod_cliente,          
      num_pedido          LIKE pedidos.num_pedido,
      nom_cliente         LIKE clientes.nom_cliente,
      num_pedido_cli      LIKE pedidos.num_pedido_cli,
      cod_item_cliente    LIKE cliente_item.cod_item_cliente,
      cod_item            LIKE ped_itens.cod_item,
      den_item_reduz      LIKE item.den_item_reduz,
      prz_entrega_ab      LIKE ped_itens.prz_entrega,
      prz_entrega_fe      LIKE ped_itens.prz_entrega,
      cod_acabamento      CHAR(10),
      cod_revisao         CHAR(04),
      qtd_item            LIKE ped_itens.qtd_pecas_solic,
      pre_unit            LIKE ped_itens.pre_unit,
      pre_total           LIKE ped_itens.pre_unit
   END RECORD 
   
   DEFINE p_temp RECORD 
      cod_cliente         CHAR(15),          
      num_pedido          DECIMAL(6,0),
      num_pedido_cli      CHAR(20),
      cod_item_cliente    CHAR(20),
      cod_item            CHAR(15),
      prz_entrega_ab      DATE,
      prz_entrega_fe      DATE,
      cod_acabamento      CHAR(10),
      cod_revisao         CHAR(04),
      qtd_item            DECIMAL(9,0),
      pre_unit            DECIMAL(15,2),
      pre_total           DECIMAL(15,2)
   END RECORD 

   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT 
   LET p_versao = "POL0774-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0774.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0774_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0774_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0774") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0774 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informa Parametros para Impressao"
         HELP 001 
         LET p_ies_cons = FALSE
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0774","IN")  THEN
            CALL pol0774_cria_temp()
            IF pol0774_entrada_dados() THEN
               NEXT OPTION "Listar"
            ELSE
               ERROR "Funcao Cancelada"
               NEXT OPTION "Fim"
            END IF 
         END IF 
      COMMAND "Listar" "Lista Relatorio de Pedidos"
         HELP 002
         LET p_count = 0
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0774","MO") THEN
            IF p_ies_cons THEN 
               IF log028_saida_relat(13,29) IS NOT NULL THEN
                  MESSAGE " Processando a Extracao do Relatorio..." 
                     ATTRIBUTE(REVERSE)
                  IF p_ies_impressao = "S" THEN
                     IF g_ies_ambiente = "U" THEN
                        START REPORT pol0774_relat TO PIPE p_nom_arquivo
                     ELSE
                        CALL log150_procura_caminho ('LST') RETURNING p_caminho
                        LET p_caminho = p_caminho CLIPPED, 'pol0774.tmp'
                        START REPORT pol0774_relat TO p_caminho
                     END IF
                  ELSE
                     START REPORT pol0774_relat TO p_nom_arquivo
                  END IF
                  CALL pol0774_carrega_temp()   
                  CALL pol0774_emite_relatorio()   
                  IF p_count = 0 THEN
                     ERROR "Nao Existem Dados para serem Listados" 
                  ELSE
                     ERROR "Relatorio Processado com Sucesso" 
                  END IF
                  FINISH REPORT pol0774_relat   
               ELSE
                  CONTINUE MENU
               END IF                                                     
               IF p_ies_impressao = "S" THEN
                  MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
                  IF g_ies_ambiente = "W" THEN
                     LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                   p_nom_arquivo
                     RUN comando
                  END IF
               ELSE
                  MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
               END IF                              
               NEXT OPTION "Fim"
            ELSE
               ERROR "Informar Previamente Parametros para Impressao"
               NEXT OPTION "Informar"
            END IF 
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0774_sobre()
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
   CLOSE WINDOW w_pol0774

END FUNCTION

#---------------------------#
FUNCTION pol0774_cria_temp()
#---------------------------#

WHENEVER ANY ERROR CONTINUE

   CREATE TEMP TABLE tpol0774
     (cod_cliente         CHAR(15),          
      num_pedido          DECIMAL(6,0),
      num_pedido_cli      CHAR(20),
      cod_item_cliente    CHAR(20),
      cod_item            CHAR(15),
      prz_entrega_ab      DATE,
      prz_entrega_fe      DATE,
      cod_acabamento      CHAR(10),
      cod_revisao         CHAR(04),
      qtd_item            DECIMAL(9,0),
      pre_unit            DECIMAL(15,2),
      pre_total           DECIMAL(15,2))

   CREATE INDEX ix_tpol0774 ON tpol0774 (num_pedido)
 
 DELETE FROM tpol0774

END FUNCTION


#-------------------------------#
 FUNCTION pol0774_entrada_dados()
#-------------------------------#

   INITIALIZE p_tela.* TO NULL
   DISPLAY p_cod_empresa TO cod_empresa

   INPUT BY NAME p_tela.* 
      WITHOUT DEFAULTS

      AFTER FIELD cod_cliente   
      IF p_tela.cod_cliente IS NULL THEN
         ERROR "Campo de preenchimento obrigatorio"
         NEXT FIELD cod_cliente
      ELSE
         SELECT nom_cliente
            INTO p_tela.nom_cliente
         FROM clientes        
         WHERE cod_cliente = p_tela.cod_cliente
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cliente
         END IF
         DISPLAY BY NAME p_tela.nom_cliente
      END IF

      AFTER FIELD dat_ini    
      IF p_tela.dat_ini IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_ini       
      END IF 

      AFTER FIELD dat_fim   
      IF p_tela.dat_fim IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD dat_fim
      ELSE
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR "Data Inicial nao pode ser maior que data Final"
            NEXT FIELD dat_ini
         END IF 
         IF p_tela.dat_fim - p_tela.dat_ini > 720 THEN 
            ERROR "Periodo nao pode ser maior que 720 Dias"
            NEXT FIELD dat_ini
         END IF 
      END IF 

      AFTER FIELD cod_item   
         IF p_tela.cod_item IS NOT NULL THEN
            SELECT den_item
              INTO p_den_item
              FROM item     
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_tela.cod_item 
            IF SQLCA.sqlcode <> 0 THEN 
               ERROR 'ITEM NAO CADASTRADO ', SQLCA.sqlcode
               NEXT FIELD cod_item
            END IF                
         END IF             

      AFTER FIELD ies_txt   
         IF p_tela.ies_txt <> 'S'  AND
            p_tela.ies_txt <> 'N'  THEN
            ERROR 'INFORMR (S) OU (N)'
            NEXT FIELD ies_txt
         END IF 

   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      RETURN FALSE 
   END IF

END FUNCTION 

#-------------------------------#
 FUNCTION pol0774_carrega_temp()
#-------------------------------#
DEFINE l_num_ped_ant    LIKE pedidos.num_pedido,
       l_qtd_saldo      DECIMAL(9,0),
       l_num_seq        INTEGER,
       l_pre_unit       LIKE ped_itens.pre_unit,
       l_count          INTEGER
       
   LET l_num_ped_ant = 0     

   DECLARE cq_pedidos CURSOR FOR
   SELECT b.*,c.*
   FROM ped_ethos_edi_pe3 b, ped_ethos_edi_pe5 c
   WHERE b.cod_empresa = c.cod_empresa
     AND b.num_pedido  = c.num_pedido 
     AND b.num_sequencia = c.num_sequencia
     AND b.cod_empresa   = p_cod_empresa
  ORDER BY b.num_pedido   
 
   FOREACH cq_pedidos INTO p_ped_ethos_edi_pe3.*,p_ped_ethos_edi_pe5.*

      IF l_num_ped_ant <> p_ped_ethos_edi_pe3.num_pedido THEN
      
         SELECT *  
           INTO p_pedidos.*
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa 
            AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
             
          IF p_pedidos.cod_cliente <> p_tela.cod_cliente THEN 
             CONTINUE FOREACH
          END IF    
          
          SELECT *
            INTO p_ped_ethos_edi_pe6.*
            FROM ped_ethos_edi_pe6
           WHERE cod_empresa = p_cod_empresa 
             AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
          IF SQLCA.sqlcode <> 0 THEN 
             INITIALIZE p_ped_ethos_edi_pe6.alter_tecnica,
                        p_ped_ethos_edi_pe6.cod_material TO NULL 
          END IF

          SELECT *
            INTO p_ped_ethos_edi_pe1.*
            FROM ped_ethos_edi_pe1
           WHERE cod_empresa = p_cod_empresa 
             AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido

          LET l_count = 0
          
{          SELECT COUNT(*)
             INTO l_count 
          FROM cliente_item
          WHERE cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente   
            AND cod_cliente_matriz = "1"
            
          IF l_count = 1 THEN
             SELECT cod_item 
               INTO p_ped_ethos_edi_pe1.cod_item
               FROM cliente_item
              WHERE cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente   
                AND cod_cliente_matriz = "1"
          ELSE
             SELECT cod_item 
                INTO p_ped_ethos_edi_pe1.cod_item
             FROM cliente_item
             WHERE cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente   
               AND cod_item not like "%A"
               AND cod_cliente_matriz = "1"
          END IF 
}

           SELECT MAX(cod_item)
             INTO p_ped_ethos_edi_pe1.cod_item
             FROM ped_itens 
            WHERE cod_empresa = p_cod_empresa 
              AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido 
           
           IF p_tela.cod_item IS NOT NULL THEN
              IF p_ped_ethos_edi_pe1.cod_item <> p_tela.cod_item THEN 
                 CONTINUE FOREACH
              END IF    
           END IF 
            
           SELECT MAX(num_sequencia)
             INTO l_num_seq
             FROM ped_itens 
            WHERE cod_empresa = p_cod_empresa 
              AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido 

           IF l_num_seq > 0 THEN 
              SELECT pre_unit 
                INTO l_pre_unit 
                FROM ped_itens
               WHERE cod_empresa   = p_cod_empresa
                 AND num_pedido    = p_ped_ethos_edi_pe3.num_pedido 
                 AND num_sequencia = l_num_seq  
           ELSE
              SELECT pre_unit 
                INTO l_pre_unit
                FROM desc_preco_item 
               WHERE cod_empresa = p_cod_empresa 
                 AND cod_item    = p_ped_ethos_edi_pe1.cod_item
                 AND num_list_preco = 1
           END IF    
           IF l_pre_unit IS NULL THEN
              LET l_pre_unit = 0 
           END IF    
          
           LET l_num_ped_ant =   p_ped_ethos_edi_pe3.num_pedido    
      END IF 
      
      IF p_ped_ethos_edi_pe5.dat_entrega_1 IS NOT NULL THEN
        
         SELECT cod_item,(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio),
                pre_unit
           INTO p_ped_itens.cod_item,l_qtd_saldo,l_pre_unit
           FROM ped_itens
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
            AND prz_entrega = p_ped_ethos_edi_pe5.dat_entrega_1
         IF SQLCA.sqlcode <> 0 THEN 
            LET p_temp.qtd_item         = p_ped_ethos_edi_pe3.qtd_entrega_1
         ELSE
            LET p_temp.qtd_item         = l_qtd_saldo
         END IF    
         
         LET p_temp.cod_cliente      = p_pedidos.cod_cliente 
         LET p_temp.num_pedido       = p_pedidos.num_pedido
         LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
         LET p_temp.prz_entrega_ab   = p_ped_ethos_edi_pe5.dat_entrega_1
         LET p_temp.prz_entrega_fe   = p_ped_ethos_edi_pe3.dat_entrega_1
         LET p_temp.cod_acabamento   = p_ped_ethos_edi_pe6.cod_material
         LET p_temp.cod_revisao      = p_ped_ethos_edi_pe6.alter_tecnica
         LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
         LET p_temp.cod_item         = p_ped_ethos_edi_pe1.cod_item
         LET p_temp.pre_unit         = l_pre_unit
         LET p_temp.pre_total        = (l_pre_unit * p_temp.qtd_item)
         
         IF p_ped_ethos_edi_pe5.dat_entrega_1 >= p_tela.dat_ini AND 
            p_ped_ethos_edi_pe5.dat_entrega_1 <= p_tela.dat_fim THEN 
            IF p_ped_ethos_edi_pe5.identif_programa_1 <> "1" THEN
               INSERT INTO tpol0774 VALUES (p_temp.*)                        
            END IF 
         END IF    
      END IF    

      IF p_ped_ethos_edi_pe5.dat_entrega_2 IS NOT NULL THEN
        
        SELECT cod_item,(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
          INTO p_ped_itens.cod_item,l_qtd_saldo
          FROM ped_itens
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
           AND prz_entrega = p_ped_ethos_edi_pe5.dat_entrega_2
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_temp.qtd_item         = p_ped_ethos_edi_pe3.qtd_entrega_1
        ELSE
           LET p_temp.qtd_item         = l_qtd_saldo
        END IF    
        LET p_temp.cod_cliente      = p_pedidos.cod_cliente 
        LET p_temp.num_pedido       = p_pedidos.num_pedido
        LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
        LET p_temp.prz_entrega_ab   = p_ped_ethos_edi_pe5.dat_entrega_2
        LET p_temp.prz_entrega_fe   = p_ped_ethos_edi_pe3.dat_entrega_2
        LET p_temp.cod_acabamento   = p_ped_ethos_edi_pe6.cod_material
        LET p_temp.cod_revisao      = p_ped_ethos_edi_pe6.alter_tecnica
        LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
        LET p_temp.cod_item         = p_ped_ethos_edi_pe1.cod_item
        LET p_temp.pre_unit         = l_pre_unit
        LET p_temp.pre_total        = (l_pre_unit * p_temp.qtd_item)
        
        IF p_ped_ethos_edi_pe5.dat_entrega_2 >= p_tela.dat_ini AND 
           p_ped_ethos_edi_pe5.dat_entrega_2 <= p_tela.dat_fim THEN 
           IF p_ped_ethos_edi_pe5.identif_programa_2 <> "1" THEN
              INSERT INTO tpol0774 VALUES (p_temp.*)                        
           END IF 
        END IF    
      END IF    

      IF p_ped_ethos_edi_pe5.dat_entrega_3 IS NOT NULL THEN

        SELECT cod_item,(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
          INTO p_ped_itens.cod_item,l_qtd_saldo
          FROM ped_itens
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
           AND prz_entrega = p_ped_ethos_edi_pe5.dat_entrega_3
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_temp.qtd_item      = p_ped_ethos_edi_pe3.qtd_entrega_1
        ELSE
           LET p_temp.qtd_item      = l_qtd_saldo
        END IF    
        
        LET p_temp.cod_cliente      = p_pedidos.cod_cliente 
        LET p_temp.num_pedido       = p_pedidos.num_pedido
        LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
        LET p_temp.prz_entrega_ab   = p_ped_ethos_edi_pe5.dat_entrega_3
        LET p_temp.prz_entrega_fe   = p_ped_ethos_edi_pe3.dat_entrega_3
        LET p_temp.cod_acabamento   = p_ped_ethos_edi_pe6.cod_material
        LET p_temp.cod_revisao      = p_ped_ethos_edi_pe6.alter_tecnica
        LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
        LET p_temp.cod_item         = p_ped_ethos_edi_pe1.cod_item
        LET p_temp.pre_unit         = l_pre_unit
        LET p_temp.pre_total        = (l_pre_unit * p_temp.qtd_item)
        IF p_ped_ethos_edi_pe5.dat_entrega_3 >= p_tela.dat_ini AND 
           p_ped_ethos_edi_pe5.dat_entrega_3 <= p_tela.dat_fim THEN 
           IF p_ped_ethos_edi_pe5.identif_programa_3 <> "1" THEN
              INSERT INTO tpol0774 VALUES (p_temp.*)                        
           END IF 
        END IF    
      END IF    

      IF p_ped_ethos_edi_pe5.dat_entrega_4 IS NOT NULL THEN

        SELECT cod_item,(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
          INTO p_ped_itens.cod_item,l_qtd_saldo
          FROM ped_itens
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
           AND prz_entrega = p_ped_ethos_edi_pe5.dat_entrega_4
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_temp.qtd_item         = p_ped_ethos_edi_pe3.qtd_entrega_1
        ELSE
           LET p_temp.qtd_item         = l_qtd_saldo
        END IF    
        LET p_temp.cod_cliente      = p_pedidos.cod_cliente 
        LET p_temp.num_pedido       = p_pedidos.num_pedido
        LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
        LET p_temp.prz_entrega_ab   = p_ped_ethos_edi_pe5.dat_entrega_4
        LET p_temp.prz_entrega_fe   = p_ped_ethos_edi_pe3.dat_entrega_4
        LET p_temp.cod_acabamento   = p_ped_ethos_edi_pe6.cod_material
        LET p_temp.cod_revisao      = p_ped_ethos_edi_pe6.alter_tecnica
        LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
        LET p_temp.cod_item         = p_ped_ethos_edi_pe1.cod_item
        LET p_temp.pre_unit         = l_pre_unit
        LET p_temp.pre_total        = (l_pre_unit * p_temp.qtd_item)
        IF p_ped_ethos_edi_pe5.dat_entrega_4 >= p_tela.dat_ini AND 
           p_ped_ethos_edi_pe5.dat_entrega_4 <= p_tela.dat_fim THEN 
           IF p_ped_ethos_edi_pe5.identif_programa_4 <> "1" THEN
              INSERT INTO tpol0774 VALUES (p_temp.*)                        
           END IF 
        END IF    
      END IF    

      IF p_ped_ethos_edi_pe5.dat_entrega_5 IS NOT NULL THEN

        SELECT cod_item,(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
          INTO p_ped_itens.cod_item,l_qtd_saldo
          FROM ped_itens
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
           AND prz_entrega = p_ped_ethos_edi_pe5.dat_entrega_5
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_temp.qtd_item         = p_ped_ethos_edi_pe3.qtd_entrega_1
        ELSE
           LET p_temp.qtd_item         = l_qtd_saldo
        END IF    
        LET p_temp.cod_cliente      = p_pedidos.cod_cliente 
        LET p_temp.num_pedido       = p_pedidos.num_pedido
        LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
        LET p_temp.prz_entrega_ab   = p_ped_ethos_edi_pe5.dat_entrega_5
        LET p_temp.prz_entrega_fe   = p_ped_ethos_edi_pe3.dat_entrega_5
        LET p_temp.cod_acabamento   = p_ped_ethos_edi_pe6.cod_material
        LET p_temp.cod_revisao      = p_ped_ethos_edi_pe6.alter_tecnica
        LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
        LET p_temp.cod_item         = p_ped_ethos_edi_pe1.cod_item
        LET p_temp.pre_unit         = l_pre_unit
        LET p_temp.pre_total        = (l_pre_unit * p_temp.qtd_item)
        IF p_ped_ethos_edi_pe5.dat_entrega_5 >= p_tela.dat_ini AND 
           p_ped_ethos_edi_pe5.dat_entrega_5 <= p_tela.dat_fim THEN 
           IF p_ped_ethos_edi_pe5.identif_programa_5 <> "1" THEN
              INSERT INTO tpol0774 VALUES (p_temp.*)                        
           END IF 
        END IF    
      END IF    

      IF p_ped_ethos_edi_pe5.dat_entrega_6 IS NOT NULL THEN

        SELECT cod_item,(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
          INTO p_ped_itens.cod_item,l_qtd_saldo
          FROM ped_itens
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
           AND prz_entrega = p_ped_ethos_edi_pe5.dat_entrega_6
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_temp.qtd_item         = p_ped_ethos_edi_pe3.qtd_entrega_1
        ELSE
           LET p_temp.qtd_item         = l_qtd_saldo
        END IF    
        LET p_temp.cod_cliente      = p_pedidos.cod_cliente 
        LET p_temp.num_pedido       = p_pedidos.num_pedido
        LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
        LET p_temp.prz_entrega_ab   = p_ped_ethos_edi_pe5.dat_entrega_6
        LET p_temp.prz_entrega_fe   = p_ped_ethos_edi_pe3.dat_entrega_6
        LET p_temp.cod_acabamento   = p_ped_ethos_edi_pe6.cod_material
        LET p_temp.cod_revisao      = p_ped_ethos_edi_pe6.alter_tecnica
        LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
        LET p_temp.cod_item         = p_ped_ethos_edi_pe1.cod_item
        LET p_temp.pre_unit         = l_pre_unit
        LET p_temp.pre_total        = (l_pre_unit * p_temp.qtd_item)
        IF p_ped_ethos_edi_pe5.dat_entrega_6 >= p_tela.dat_ini AND 
           p_ped_ethos_edi_pe5.dat_entrega_6 <= p_tela.dat_fim THEN 
           IF p_ped_ethos_edi_pe5.identif_programa_6 <> "1" THEN
              INSERT INTO tpol0774 VALUES (p_temp.*)                        
           END IF 
        END IF    
      END IF    

      IF p_ped_ethos_edi_pe5.dat_entrega_7 IS NOT NULL THEN

        SELECT cod_item,(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
          INTO p_ped_itens.cod_item,l_qtd_saldo
          FROM ped_itens
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_ped_ethos_edi_pe3.num_pedido
           AND prz_entrega = p_ped_ethos_edi_pe5.dat_entrega_7
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_temp.qtd_item         = p_ped_ethos_edi_pe3.qtd_entrega_1
        ELSE
           LET p_temp.qtd_item         = l_qtd_saldo
        END IF    
        LET p_temp.cod_cliente      = p_pedidos.cod_cliente 
        LET p_temp.num_pedido       = p_pedidos.num_pedido
        LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
        LET p_temp.prz_entrega_ab   = p_ped_ethos_edi_pe5.dat_entrega_7
        LET p_temp.prz_entrega_fe   = p_ped_ethos_edi_pe3.dat_entrega_7
        LET p_temp.cod_acabamento   = p_ped_ethos_edi_pe6.cod_material
        LET p_temp.cod_revisao      = p_ped_ethos_edi_pe6.alter_tecnica
        LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
        LET p_temp.cod_item         = p_ped_ethos_edi_pe1.cod_item
        LET p_temp.pre_unit         = l_pre_unit
        LET p_temp.pre_total        = (l_pre_unit * p_temp.qtd_item)
        IF p_ped_ethos_edi_pe5.dat_entrega_7 >= p_tela.dat_ini AND 
           p_ped_ethos_edi_pe5.dat_entrega_7 <= p_tela.dat_fim THEN 
           IF p_ped_ethos_edi_pe5.identif_programa_7 <> "1" THEN
              INSERT INTO tpol0774 VALUES (p_temp.*)                        
           END IF 
        END IF    
      END IF    

   END FOREACH
{
   DECLARE cq_pedit CURSOR FOR
   SELECT a.*,b.*
   FROM ped_itens a, pedidos b
   WHERE a.cod_empresa = b.cod_empresa
     AND a.num_pedido  = b.num_pedido
     AND b.cod_cliente = "1" 
     AND a.cod_empresa = p_cod_empresa
     AND prz_entrega  >= p_tela.dat_ini 
     AND prz_entrega  <= p_tela.dat_fim
     AND (qtd_pecas_solic - qtd_pecas_cancel - qtd_pecas_atend - qtd_pecas_romaneio) > 0 
  ORDER BY b.num_pedido   
 
   FOREACH cq_pedit INTO p_ped_itens.*,p_pedidos.*
   
     SELECT COUNT(*)
       INTO l_count 
       FROM tpol0774
      WHERE num_pedido_cli = p_pedidos.num_pedido_cli
        AND prz_entrega_ab = p_ped_itens.prz_entrega
        AND cod_item       = p_ped_itens.cod_item 
     IF l_count > 0 THEN
        CONTINUE FOREACH
     END IF 

     SELECT COUNT(*)
        INTO l_count 
     FROM cliente_item
     WHERE cod_item_cliente = p_ped_itens.cod_item 
       AND cod_cliente_matriz = "1"
       
     IF l_count = 1 THEN
        SELECT cod_item_cliente 
          INTO p_temp.cod_item_cliente
          FROM cliente_item
         WHERE cod_item  = p_ped_itens.cod_item 
           AND cod_cliente_matriz = "1"
     ELSE
        SELECT cod_item_cliente 
          INTO p_temp.cod_item_cliente
          FROM cliente_item
         WHERE cod_item  = p_ped_itens.cod_item 
           AND cod_item NOT LIKE "%A"
           AND cod_cliente_matriz = "1"
     END IF 

     SELECT den_texto_2[9,12]
       INTO p_temp.cod_revisao 
       FROM ped_itens_texto
      WHERE cod_empresa   = p_cod_empresa
        AND num_pedido    = p_ped_itens.num_pedido
        AND num_sequencia = p_ped_itens.num_sequencia
     IF SQLCA.sqlcode <> 0 THEN
        LET p_temp.cod_revisao  = ""
     END IF 
     
     LET p_temp.cod_cliente      = p_pedidos.cod_cliente
     LET p_temp.num_pedido       = p_ped_itens.num_pedido
     LET p_temp.num_pedido_cli   = p_pedidos.num_pedido_cli
     LET p_temp.prz_entrega_ab   = p_ped_itens.prz_entrega
     LET p_temp.prz_entrega_fe   = p_ped_itens.prz_entrega
     LET p_temp.cod_acabamento   = ""
     LET p_temp.cod_item_cliente = p_ped_ethos_edi_pe1.cod_item_cliente
     LET p_temp.cod_item         = p_ped_itens.cod_item
     LET p_temp.pre_unit         = p_ped_itens.pre_unit
     LET p_temp.qtd_item         = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel - p_ped_itens.qtd_pecas_romaneio
     LET p_temp.pre_total        = (p_temp.pre_unit * p_temp.qtd_item)
     INSERT INTO tpol0774 VALUES (p_temp.*)                        
   END FOREACH         
}
END FUNCTION

#---------------------------------#
 FUNCTION pol0774_emite_relatorio()
#---------------------------------#

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   SELECT den_empresa   
      INTO p_den_empresa
   FROM empresa 
   WHERE cod_empresa = p_cod_empresa

   DECLARE cq_rel CURSOR FOR
   SELECT *
     FROM tpol0774
    ORDER BY prz_entrega_ab,cod_item
 
   FOREACH cq_rel INTO p_temp.*

      LET p_relat.cod_cliente        = p_temp.cod_cliente           
      LET p_relat.num_pedido         = p_temp.num_pedido 
      LET p_relat.num_pedido_cli     = p_temp.num_pedido_cli
      LET p_relat.cod_item_cliente   = p_temp.cod_item_cliente
      LET p_relat.cod_item           = p_temp.cod_item
      LET p_relat.prz_entrega_ab     = p_temp.prz_entrega_ab
      LET p_relat.prz_entrega_fe     = p_temp.prz_entrega_fe
#      SELECT den_acabamento 
#        INTO p_relat.cod_acabamento
#        FROM acab_cli_ethos
#       WHERE cod_empresa    = p_cod_empresa 
#         AND cod_cliente    = '1'
#         AND cod_acabamento =  p_temp.cod_acabamento
###      LET p_relat.cod_acabamento     = p_temp.cod_acabamento
#      IF SQLCA.sqlcode <> 0 THEN 
         LET p_relat.cod_acabamento     = p_temp.cod_acabamento
#      END IF    
      LET p_relat.cod_revisao        = p_temp.cod_revisao
      LET p_relat.qtd_item           = p_temp.qtd_item
      LET p_relat.pre_unit           = p_temp.pre_unit
      LET p_relat.pre_total          = p_temp.pre_total  


      SELECT nom_cliente
         INTO p_relat.nom_cliente
      FROM clientes
      WHERE cod_cliente = p_temp.cod_cliente  
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_relat.nom_cliente = NULL
      END IF
 
      SELECT den_item_reduz
         INTO p_relat.den_item_reduz
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_temp.cod_item 
      IF SQLCA.SQLCODE <> 0 THEN
         LET p_relat.den_item_reduz = NULL
      END IF

      OUTPUT TO REPORT pol0774_relat(p_relat.*) 
      LET p_count = p_count + 1

   END FOREACH

END FUNCTION

#----------------------------#
 REPORT pol0774_relat(p_relat)                              
#----------------------------# 

   DEFINE p_relat RECORD 
      cod_cliente         LIKE pedidos.cod_cliente,          
      num_pedido          LIKE pedidos.num_pedido,
      nom_cliente         LIKE clientes.nom_cliente,
      num_pedido_cli      LIKE pedidos.num_pedido_cli,
      cod_item_cliente    LIKE cliente_item.cod_item_cliente,
      cod_item            LIKE ped_itens.cod_item,
      den_item_reduz      LIKE item.den_item_reduz,
      prz_entrega_ab      LIKE ped_itens.prz_entrega,
      prz_entrega_fe      LIKE ped_itens.prz_entrega,
      cod_acabamento      CHAR(10),
      cod_revisao         CHAR(04),
      qtd_item            LIKE ped_itens.qtd_pecas_solic,
      pre_unit            LIKE ped_itens.pre_unit,
      pre_total           LIKE ped_itens.pre_unit
   END RECORD 
   
   DEFINE l_linha         CHAR(125)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_relat.prz_entrega_ab,p_relat.cod_item 
 
   FORMAT

      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 053, "RELATORIO PROGRAMACAO FUTURA",
               COLUMN 119, "PAG.:  ", PAGENO USING "######&"
         PRINT COLUMN 001, "POL0774",
               COLUMN 049, "PERIODO : ", p_tela.dat_ini," ATE ",p_tela.dat_fim,
               COLUMN 119, "DATA: ", TODAY USING "DD/MM/YY"
         PRINT COLUMN 001, "*---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------*"
         PRINT COLUMN 001, "Cliente    : ", p_relat.cod_cliente, " ",
                           p_relat.nom_cliente
         PRINT COLUMN 001, "+---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------+"
                           
         PRINT COLUMN 001, "   Ped Cli      ",
               COLUMN 017, "Pedido ",
               COLUMN 024, "      Item      ",
               COLUMN 040, "     Descricao     ",
               COLUMN 059, "DT Entrega ",
               COLUMN 070, "    Cod Prod     ",
               COLUMN 087, "Material   Rev. ",
               COLUMN 103, "  Qtde  ",
               COLUMN 111, "Pre Unit  ",
               COLUMN 121, "Pre Total  "
         PRINT COLUMN 001, "---------------------------------------",
                           "---------------------------------------",
                           "---------------------------------------",
                           "--------------"

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_pedido_cli[1,14], 
               COLUMN 017, p_relat.num_pedido USING "&&&&&&", 
               COLUMN 024, p_relat.cod_item, 
               COLUMN 040, p_relat.den_item_reduz, 
               COLUMN 059, p_relat.prz_entrega_ab, 
               COLUMN 070, p_relat.cod_item_cliente[1,16], 
               COLUMN 087, p_relat.cod_acabamento, 
               COLUMN 098, p_relat.cod_revisao, 
               COLUMN 103, p_relat.qtd_item USING "###&", 
               COLUMN 111, p_relat.pre_unit USING "##,##&.&&", 
               COLUMN 121, p_relat.pre_total USING "###,##&.&&" 
         
         IF p_tela.ies_txt = 'S'  THEN
            DECLARE cq_te1 CURSOR FOR 
              SELECT * 
                FROM ped_ethos_edi_te1 
               WHERE cod_empresa = p_cod_empresa 
                 AND num_pedido  = p_relat.num_pedido
            FOREACH cq_te1 INTO p_ped_ethos_edi_te1.*
              LET l_linha = p_ped_ethos_edi_te1.texto_1,' ',p_ped_ethos_edi_te1.texto_2,' ',p_ped_ethos_edi_te1.texto_3 
              PRINT COLUMN 001, l_linha
            END FOREACH              
         END IF 
            
         PRINT COLUMN 001, "---------------------------------------",
                           "---------------------------------------",
                           "---------------------------------------",
                           "--------------"

      ON LAST ROW 

         SKIP 1 LINE          
         PRINT COLUMN 001, "TOTAL GERAL: ",        
               COLUMN 118, sum(p_relat.pre_total) USING "##,###,##&.&&"

         PRINT COLUMN 001, p_descomprime

END REPORT

#-----------------------#
 FUNCTION pol0774_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------ FIM DE PROGRAMA -------------------------------#
