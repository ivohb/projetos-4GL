#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: pol0990                                               #
# MODULOS.: pol0990 - LOG0010 - LOG0030 - LOG0040 - LOG0050       #
#           LOG0060 - LOG1200 - LOG1300 - LOG1400                 #
# OBJETIVO: relatorio entraga kanban                              #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_cod_cliente          LIKE pedidos.cod_cliente,
         p_cod_cnd_pgto         LIKE pedidos.cod_cnd_pgto,
         p_cnd_pgto_list        LIKE ped_cond_pgto_list.cod_cnd_pgto,
         p_ies_preco            LIKE pedidos.ies_preco,
         p_num_list_preco       LIKE pedidos.num_list_preco,
         p_num_versao_lista     LIKE pedidos.num_versao_lista,
         p_num_nff_ult          LIKE pedidos_qfp.num_nff_ult,
         p_dat_emissao          LIKE nf_mestre.dat_emissao,
         p_dat_emis_ult         LIKE nf_mestre.dat_emissao,
         p_qtd_embarcado        LIKE nf_item.qtd_item,
         p_qtd_estoque          LIKE estoque.qtd_liberada,
         p_qtd_prod             LIKE estoque.qtd_liberada,
         p_qtd_tot_ent          LIKE estoque.qtd_liberada,
         p_qtd_saldo_ped        LIKE ped_itens.qtd_pecas_solic,
         p_pre_unit             LIKE list_preco_item.pre_unit,
         p_qtd_pecas_cancel     LIKE ped_itens.qtd_pecas_cancel,
         p_cod_item_cliente     LIKE cliente_item.cod_item_cliente,
         p_num_pedido_ant       LIKE ped_itens_fct_547.num_pedido,
         p_identif              LIKE pedidos_edi_pe1.identif_prog_atual,  
         p_num_om_ini           LIKE ordem_montag_mest.num_om,
         p_num_om_fim           LIKE ordem_montag_mest.num_om,
         p_release              CHAR(40),
         p_saldo                DECIMAL(10,3),
         p_den_empresa          CHAR(36),
         p_count                INTEGER,
         p_erro                 CHAR(01),
         g_ies_ambiente         CHAR(01),
         p_qtd_variacao         DECIMAL(07,0),
         p_status               SMALLINT,
         p_last_row             SMALLINT,
         p_ind                  SMALLINT,
         p_ies_cons             SMALLINT,
         p_comprime             CHAR(01), 
         p_descomprime          CHAR(01),
         p_msg                  CHAR(500)

  DEFINE t_ped_itens_fct_547  ARRAY[500] OF RECORD
         num_pedido_cli     CHAR(15),
         num_pedido         LIKE ped_itens_fct_547.num_pedido,      
         cod_item           LIKE ped_itens_fct_547.cod_item,      
         qtd_solic          LIKE ped_itens.qtd_pecas_atend,
         dat_abertura       LIKE ped_itens.prz_entrega,
         prz_entrega        LIKE ped_itens.prz_entrega
                         END RECORD

  DEFINE p_tela   RECORD
         cod_empresa   CHAR(02), 
         dat_de     LIKE ped_itens.prz_entrega,
         dat_ate    LIKE ped_itens.prz_entrega
                 END RECORD
                                 
  DEFINE p_ped_itens_fct_547   RECORD LIKE ped_itens_fct_547.*,
         p_ped_itens           RECORD LIKE ped_itens.*

   DEFINE p_relat RECORD 
          num_pedido_cli     CHAR(15),
          num_pedido         DECIMAL(6,0),       
          cod_item           CHAR(15), 
          den_item           CHAR(15), 
          cod_item_cliente   CHAR(12), 
          dat_fatur          DATE,   
          qtd_solic          DECIMAL(10,3),
          dat_abertura       DATE,
          prz_entrega        DATE,
          val_unit           DECIMAL(15,2),
          ies_semana         CHAR(3)
   END RECORD 

   DEFINE p_wped_lst_547 RECORD
          num_ped_cli        CHAR(15),
          num_pedido         DECIMAL(6,0),
          cod_item           CHAR(15),
          qtd_saldo          DECIMAL(10,3),
          prz_entrega        DATE,
          ship_date          DATE    
   END RECORD 


  DEFINE p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         p_ok                   CHAR(001),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_prog_inex            CHAR(001),
         p_help                 CHAR(080),
         p_count_ped            INTEGER,
         p_cancel               INTEGER
  DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  LET p_versao = "POL0990-10.02.02" #Favor nao alterar esta linha (SUPORTE)
  WHENEVER ANY ERROR CONTINUE
  CALL log1400_isolation()             
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho CLIPPED
  OPTIONS
    HELP FILE p_help,
    PREVIOUS KEY control-b,
    NEXT     KEY control-f

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN 
    CALL pol0990_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0990_controle()
#--------------------------#

  INITIALIZE p_ped_itens_fct_547.*, p_ped_itens.* TO NULL
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("pol0990") RETURNING p_nom_tela 
  OPEN WINDOW w_pol0990 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Informar"    "Consulta Programacao do cliente"
      HELP 0004
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","pol0990","CO") THEN
         CALL pol0990_cria_tmp()    
         CALL pol0990_informa_datas()
         CALL pol0990_consulta_ped_itens_fct_547()
         MESSAGE "                 "
         NEXT OPTION "Listar"
      END IF
    COMMAND "Listar" "Lista Relatorio de Pedidos"
       HELP 002
       LET p_count = 0
       MESSAGE ""
       IF p_ies_cons THEN 
          IF log028_saida_relat(13,29) IS NOT NULL THEN
             MESSAGE " Processando a Extracao do Relatorio..." 
                ATTRIBUTE(REVERSE)
             IF p_ies_impressao = "S" THEN
                IF g_ies_ambiente = "U" THEN
                   START REPORT pol0990_relat TO PIPE p_nom_arquivo
                ELSE
                   CALL log150_procura_caminho ('LST') RETURNING p_caminho
                   LET p_caminho = p_caminho CLIPPED, 'pol0990.tmp'
                   START REPORT pol0990_relat TO p_caminho
                END IF
             ELSE
                START REPORT pol0990_relat TO p_nom_arquivo
             END IF
             CALL pol0990_emite_relatorio()   
             IF p_count = 0 THEN
                ERROR "Nao Existem Dados para serem Listados" 
             ELSE
                ERROR "Relatorio Processado com Sucesso" 
             END IF
             FINISH REPORT pol0990_relat   
          ELSE
             CONTINUE MENU
          END IF                                                     
          IF p_ies_impressao = "S" THEN
             MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                ATTRIBUTE(REVERSE)
             IF g_ies_ambiente = "W" THEN
                LET p_comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                              p_nom_arquivo
                RUN p_comando
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
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0990_sobre()      
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix
    COMMAND "Fim" "Retorna ao Menu Anterior"
      HELP 0008
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0990
END FUNCTION

#--------------------------#
 FUNCTION pol0990_cria_tmp()
#--------------------------#

  DELETE FROM wped_lst_547;

END FUNCTION

#--------------------------------#
 FUNCTION pol0990_informa_datas()
#--------------------------------#
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0990
   CLEAR FORM
   
   INITIALIZE p_tela TO NULL

   DISPLAY p_cod_empresa TO cod_empresa
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD dat_de
         IF p_tela.dat_de IS NULL THEN
            ERROR 'Informe Data inicio !!!'
            NEXT FIELD dat_de
         END IF    

      BEFORE FIELD dat_ate
         LET p_tela.dat_ate = p_tela.dat_de
         DISPLAY p_tela.dat_ate TO dat_ate  

      AFTER FIELD dat_ate
         IF p_tela.dat_ate IS NULL THEN
            ERROR 'Informe Data final !!!'
            NEXT FIELD dat_ate
         END IF 
     
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   ELSE
      LET p_ies_cons = FALSE
      DISPLAY '' TO dat_de
      DISPLAY '' TO dat_ate
   END IF
END FUNCTION

#--------------------------------------------#
 FUNCTION pol0990_consulta_ped_itens_fct_547()
#--------------------------------------------#
DEFINE l_num_ped_cli    LIKE pedidos.num_pedido_cli  

  LET p_ind = 1
  DECLARE cq_cons CURSOR FOR 
    SELECT * 
      FROM ped_itens_fct_547
     WHERE cod_empresa = p_cod_empresa
       AND prz_entrega >= p_tela.dat_de
       AND prz_entrega <= p_tela.dat_ate 
       AND (qtd_solic - qtd_romaneio)>0 
     ORDER BY prz_entrega, cod_item 
  FOREACH cq_cons INTO p_ped_itens_fct_547.*
    LET t_ped_itens_fct_547[p_ind].num_pedido       =   p_ped_itens_fct_547.num_pedido
    LET t_ped_itens_fct_547[p_ind].cod_item         =   p_ped_itens_fct_547.cod_item
    LET t_ped_itens_fct_547[p_ind].qtd_solic        =   (p_ped_itens_fct_547.qtd_solic - p_ped_itens_fct_547.qtd_romaneio)
    LET t_ped_itens_fct_547[p_ind].dat_abertura     =   p_ped_itens_fct_547.prz_entrega - 2 
    LET t_ped_itens_fct_547[p_ind].prz_entrega      =   p_ped_itens_fct_547.prz_entrega

    SELECT num_pedido_cli
      INTO l_num_ped_cli    
      FROM pedidos
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_ped_itens_fct_547.num_pedido 

    LET t_ped_itens_fct_547[p_ind].num_pedido_cli     =   l_num_ped_cli
  
    LET p_ind = p_ind + 1

    LET p_wped_lst_547.num_ped_cli      =   l_num_ped_cli
    LET p_wped_lst_547.num_pedido       =   p_ped_itens_fct_547.num_pedido
    LET p_wped_lst_547.cod_item         =   p_ped_itens_fct_547.cod_item
    LET p_wped_lst_547.qtd_saldo        =   (p_ped_itens_fct_547.qtd_solic - p_ped_itens_fct_547.qtd_romaneio)
    LET p_wped_lst_547.prz_entrega      =   p_ped_itens_fct_547.prz_entrega - 2 
    LET p_wped_lst_547.ship_date        =   p_ped_itens_fct_547.prz_entrega

    INSERT INTO wped_lst_547 VALUES (p_wped_lst_547.*)   

  END FOREACH 

END FUNCTION


#---------------------------------#
 FUNCTION pol0990_emite_relatorio()
#---------------------------------#
 DEFINE l_num_seq        LIKE ped_itens.num_sequencia,
        l_ent_ant        LIKE ped_itens.prz_entrega,
        l_ent_sant       LIKE ped_itens.prz_entrega,
        l_dia_sem_ant    INTEGER,
        l_dia_sem_sant   INTEGER,
        l_dat_rom        LIKE ped_itens.prz_entrega,
        l_dia_sem_atu    INTEGER,
        l_dia_sem_rom    INTEGER,        
        l_qtd_dias       INTEGER
 
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa 

   DECLARE cq_rel CURSOR FOR
   SELECT *
     FROM wped_lst_547
    ORDER BY prz_entrega,cod_item
 
   FOREACH cq_rel INTO p_wped_lst_547.*

       SELECT WEEKDAY(prz_entrega)
         INTO l_dia_sem_atu
         FROM ped_itens_fct_547
        WHERE num_pedido = p_wped_lst_547.num_pedido 
          AND prz_entrega = p_wped_lst_547.ship_date
   
       LET p_relat.num_pedido_cli   =  p_wped_lst_547.num_ped_cli 
       LET p_relat.num_pedido       =  p_wped_lst_547.num_pedido  
       LET p_relat.cod_item         =  p_wped_lst_547.cod_item    
       LET p_relat.qtd_solic        =  p_wped_lst_547.qtd_saldo   
       LET p_relat.dat_abertura     =  p_wped_lst_547.prz_entrega 
       LET p_relat.prz_entrega      =  p_wped_lst_547.ship_date   
   
      SELECT den_item_reduz
        INTO p_relat.den_item
      FROM item
      WHERE cod_item    = p_relat.cod_item  
        AND cod_empresa = p_cod_empresa 

      SELECT cod_item_cliente
        INTO p_relat.cod_item_cliente
        FROM item_kanban_547
      WHERE cod_item    = p_relat.cod_item  
        AND cod_empresa = p_cod_empresa 

      SELECT MAX(num_sequencia) 
        INTO l_num_seq
        FROM ped_itens 
       WHERE cod_empresa =  p_cod_empresa
         AND num_pedido  =  p_wped_lst_547.num_pedido
         AND prz_entrega <= p_wped_lst_547.prz_entrega

      SELECT pre_unit 
        INTO p_relat.val_unit
        FROM ped_itens 
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_wped_lst_547.num_pedido 
         AND num_sequencia = l_num_seq

      IF p_relat.val_unit IS NULL THEN 
         LET  p_relat.val_unit = 0 
      END IF 

      SELECT MAX(dat_emissao), 
             WEEKDAY(MAX(dat_emissao)) 
        INTO l_ent_ant,
             l_dia_sem_ant 
        FROM nf_mestre a,
             nf_item b
       WHERE a.cod_empresa = p_cod_empresa
         AND b.num_pedido  = p_wped_lst_547.num_pedido
         AND a.cod_empresa = b.cod_empresa
         AND a.num_nff = b.num_nff

     SELECT MAX(prz_entrega),
            WEEKDAY(MAX(prz_entrega))  
       INTO l_ent_sant,
            l_dia_sem_sant
       FROM ped_itens_fct_547
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido  = p_wped_lst_547.num_pedido
##        AND dat_alteracao IS NULL 
        AND prz_entrega < p_wped_lst_547.prz_entrega

    IF  l_ent_sant > l_ent_ant  THEN 
        LET l_ent_ant =    l_ent_sant
        LET l_dia_sem_ant = l_dia_sem_sant 
    END IF 

{-- 
 INITIALIZE l_dat_rom TO NULL

      SELECT MAX(dat_romaneio),
             WEEKDAY(MAX(dat_romaneio)) 
        INTO l_dat_rom,
             l_dia_sem_rom
        FROM ped_itens_fct_547
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_wped_lst_547.num_pedido

      IF l_dat_rom IS NOT NULL THEN 
         LET l_ent_ant = l_dat_rom
         LET l_dia_sem_ant = l_dia_sem_rom
      END IF    
}
      LET p_relat.dat_fatur = l_ent_ant
      
      IF l_dia_sem_atu <= l_dia_sem_ant THEN
         LET p_relat.ies_semana = '   '
      ELSE
         LET l_qtd_dias = p_wped_lst_547.ship_date - l_ent_ant
         
         IF l_qtd_dias < 7 THEN 
            LET p_relat.ies_semana = '***' 
         ELSE
            LET p_relat.ies_semana = '   '
         END IF     
      END IF 
      
      OUTPUT TO REPORT pol0990_relat(p_relat.*) 
      LET p_count = p_count + 1

   END FOREACH

END FUNCTION

#----------------------------#
 REPORT pol0990_relat(p_relat)                              
#----------------------------# 

   DEFINE p_relat RECORD 
          num_pedido_cli     CHAR(15),
          num_pedido         DECIMAL(6,0),       
          cod_item           CHAR(15), 
          den_item           CHAR(15),
          cod_item_cliente   CHAR(12),
          dat_fatur          DATE,       
          qtd_solic          DECIMAL(10,3),
          dat_abertura       DATE,
          prz_entrega        DATE,
          val_unit           DECIMAL(15,2),
          ies_semana         CHAR(03)
   END RECORD 
   

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3

   ORDER EXTERNAL BY p_relat.prz_entrega,p_relat.cod_item 
 
   FORMAT
{                                                                         PEDIDO
XXXXXXXXXXXXXXXXXXXXXXXXXXXX                                       TRANSFERENCIA
0        1         2         3         4         5         6         7         8         9         10        11        12        13
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
                                      
ETHOS METALURGICA                                   RELATORIO GATILHO DE ENTREGA - KANBAN                         PAG.: ###&
pol0990                                         PERIODO : DD/MM/AAAA ATE DD/MM/AAAA                               DATA:  DD/MM/YY 
-----------------------------------------------------------------------------------------------------------------------------------
   Ped Cli      PEDIDO Item            Descricao        Cod.It Cli.   Ult.Fatura           Preço  Qtde  Dat. Abert  Ship Date  Sem
-----------------------------------------------------------------------------------------------------------------------------------
xxxxxxxxxxxxxx  999999 xxxxxxxxxxxxxxx xxxxxxxxxxxxxxx  xxxxxxxxxxxx  dd/mm/aaaa        99999.99  9999  dd/mm/aaaa  dd/mm/aaaa ***
0        1         2         3         4         5         6         7         8         9         10        11        12        13
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
}

      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 053, "RELATORIO GATILHO DE ENTREGA - KANBAN",
               COLUMN 115, "PAG.:  ", PAGENO USING "###&"
         PRINT COLUMN 001, "POL0990",
               COLUMN 049, "PERIODO : ", p_tela.dat_de," ATE ",p_tela.dat_ate,
               COLUMN 115, "DATA: ", TODAY USING "DD/MM/YY"
         PRINT COLUMN 001, "*---------------------------------------",
                           "----------------------------------------",
                           "----------------------------------------",
                           "----------*"
                           
         PRINT COLUMN 004, "Ped Cli",
               COLUMN 017, "Pedido",
               COLUMN 024, "Item",
               COLUMN 040, "Descricao",
               COLUMN 057, "Cod.It Cli.",
               COLUMN 071, "Ship anter",
               COLUMN 090, "Preco",
               COLUMN 097, "Qtde",
               COLUMN 103, "Dat. Abert",
               COLUMN 115, "Ship Date",
               COLUMN 126, "Sem"
         PRINT COLUMN 001, "---------------------------------------",
                           "---------------------------------------",
                           "---------------------------------------",
                           "--------------"

      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_pedido_cli[1,14], 
               COLUMN 017, p_relat.num_pedido USING "&&&&&&", 
               COLUMN 024, p_relat.cod_item, 
               COLUMN 040, p_relat.den_item, 
               COLUMN 057, p_relat.cod_item_cliente,
               COLUMN 071, p_relat.dat_fatur,
               COLUMN 087, p_relat.val_unit USING "####&.&&",
               COLUMN 097, p_relat.qtd_solic USING "###&", 
               COLUMN 103, p_relat.dat_abertura, 
               COLUMN 115, p_relat.prz_entrega,
               COLUMN 126, p_relat.ies_semana 
         
         PRINT COLUMN 001, "---------------------------------------",
                           "---------------------------------------",
                           "---------------------------------------",
                           "--------------"
END REPORT

#-----------------------#
 FUNCTION pol0990_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#------------------------------ FIM DE PROGRAMA -------------------------------#