#-----------------------------------------#
# PROGRAMA: pol0818                       #
# OBJETIVO: CONSULTA NF CONSOLIDADA       #
#-----------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_nota_mest_peso_885          RECORD LIKE nota_mest_peso_885.*,
          p_nota_itens_peso_885         RECORD LIKE nota_itens_peso_885.*,
          p_empresas_885        RECORD LIKE empresas_885.*,
          p_cod_empresa      LIKE empresa.cod_empresa,
          p_cod_emp_aux      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_nom_cliente      LIKE clientes.nom_cliente,
          p_den_nat_oper     LIKE nat_operacao.den_nat_oper,
          p_den_cnd_pgto     LIKE cond_pgto.den_cnd_pgto,
          p_cod_nat_oper     LIKE nat_operacao.cod_nat_oper,
          p_cod_cnd_pgto     LIKE cond_pgto.cod_cnd_pgto,
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
          p_den_item         LIKE item.den_item,
          p_data_ent         DATE,
          p_cod_unid_med     LIKE item.cod_unid_med,
          p_msg              CHAR(100)

   DEFINE t_nota_itens_peso_885 ARRAY[500] OF RECORD
      cod_item       LIKE nota_itens_peso_885.cod_item,
      qtd_item       LIKE nota_itens_peso_885.qtd_item,        
      pre_unit_qtd   LIKE nota_itens_peso_885.pre_unit_qtd,       
      peso_item      LIKE nota_itens_peso_885.peso_item,        
      pre_unit_peso  LIKE nota_itens_peso_885.pre_unit_peso,       
      pre_total      DECIMAL(15,2),
      den_item       LIKE item.den_item        
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

MAIN
   LET p_versao = "POL0818-10.02.00" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0818_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0818_controle()
#--------------------------#

   INITIALIZE p_nota_mest_peso_885.*, 
              p_nota_itens_peso_885.* TO NULL

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0818") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0818 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE p_empresas_885.* TO NULL
       
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Pedido"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0818","CO") THEN 
            CALL pol0818_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Total"
            END IF
         END IF
       COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0818_sobre()
       COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0818

END FUNCTION

#--------------------------#
 FUNCTION pol0818_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0818

   LET p_nota_mest_peso_885.num_nff = NULL 
   
   IF pol0818_entrada_dados() THEN
      CALL pol0818_exibe_dados()
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_nota_mest_peso_885.num_nff = NULL 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0818_entrada_dados()
#-------------------------------#
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0818

   LET INT_FLAG = FALSE  
   INPUT BY NAME p_nota_mest_peso_885.num_nff
      WITHOUT DEFAULTS  

      AFTER FIELD num_nff     
      IF p_nota_mest_peso_885.num_nff IS NOT NULL THEN
         SELECT * 
           INTO p_empresas_885.*		
           FROM empresas_885 
          WHERE cod_emp_gerencial = p_cod_empresa
         IF SQLCA.sqlcode <> 0 THEN  
            ERROR 'Empresa nao parametrizada para consulta'
            NEXT FIELD num_nff
         END IF 
         
         SELECT * INTO p_nota_mest_peso_885.*
         FROM nota_mest_peso_885                  
         WHERE cod_empresa = p_empresas_885.cod_emp_oficial
           AND num_nff = p_nota_mest_peso_885.num_nff
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Nota fiscal - Inexixtente" 
            NEXT FIELD num_nff       
         END IF
      ELSE 
         ERROR "O Campo Numero da Nota nao pode ser Nulo"
         NEXT FIELD num_nff       
      END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0818
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#------------------------------#
 FUNCTION pol0818_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_nota_mest_peso_885.num_nff
   DISPLAY BY NAME p_nota_mest_peso_885.cod_cliente 
   DISPLAY BY NAME p_nota_mest_peso_885.val_tot_merc 
   DISPLAY BY NAME p_nota_mest_peso_885.val_tot_nff 
   DISPLAY BY NAME p_nota_mest_peso_885.dat_emissao
   DISPLAY BY NAME p_nota_mest_peso_885.ies_situacao
  
   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_nota_mest_peso_885.cod_cliente
  
   SELECT cod_nat_oper,
          cod_cnd_pgto
     INTO p_cod_nat_oper,
          p_cod_cnd_pgto       
     FROM nf_mestre 
    WHERE cod_empresa = p_empresas_885.cod_emp_oficial
      AND num_nff     = p_nota_mest_peso_885.num_nff      

   SELECT den_nat_oper
     INTO p_den_nat_oper
     FROM nat_operacao
    WHERE cod_nat_oper = p_cod_nat_oper

   SELECT den_cnd_pgto
     INTO p_den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_cod_cnd_pgto
      
   DISPLAY p_cod_nat_oper TO cod_nat_oper
   DISPLAY p_cod_cnd_pgto TO cod_cnd_pgto
   DISPLAY p_nom_cliente  TO nom_cliente
   DISPLAY p_den_cnd_pgto TO den_cnd_pgto
   DISPLAY p_den_nat_oper TO den_nat_oper  

   INITIALIZE t_nota_itens_peso_885 TO NULL
   
   DECLARE c_nti885 CURSOR FOR
   SELECT *
     FROM nota_itens_peso_885
    WHERE cod_empresa = p_empresas_885.cod_emp_oficial
      AND num_nff = p_nota_mest_peso_885.num_nff

   LET p_i = 1
   FOREACH c_nti885 INTO p_nota_itens_peso_885.*

      LET t_nota_itens_peso_885[p_i].cod_item      = p_nota_itens_peso_885.cod_item
      LET t_nota_itens_peso_885[p_i].pre_unit_qtd  = p_nota_itens_peso_885.pre_unit_qtd
      LET t_nota_itens_peso_885[p_i].qtd_item      = p_nota_itens_peso_885.qtd_item
      LET t_nota_itens_peso_885[p_i].peso_item     = p_nota_itens_peso_885.peso_item
      LET t_nota_itens_peso_885[p_i].pre_unit_peso = p_nota_itens_peso_885.pre_unit_peso
      LET t_nota_itens_peso_885[p_i].pre_total = t_nota_itens_peso_885[p_i].qtd_item * t_nota_itens_peso_885[p_i].pre_unit_qtd

      SELECT den_item
         INTO t_nota_itens_peso_885[p_i].den_item
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_nota_itens_peso_885.cod_item

      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_nota_itens_peso_885 TO s_nota_itens_peso_885.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0818_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION