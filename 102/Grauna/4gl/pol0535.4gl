#-------------------------------------------------------------------#
# PROGRAMA: pol0535                                                 #
# MODULOS.: pol0535-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE REVISÕES - GRAUNA                           #
# AUTOR...: POLO INFORMATICA - Ana Paula                            #
# DATA....: 08/03/2007                                              #
# ALTERADO: 06/06/07 por Ana Paula - versao 08                      #
#           19/09/08 Ivo - Só permitir informar item pai e cadastrar#
#                          as mesmas revisões para todos os itens   #
#                         tipo P/F que estejam abaixo na estrutrura #
#						07/03/2009 -THIAGO -	Grava histórico caso ocorra alguma#
#																	Alteração, inclusão ou exclusão de#
#                                 revisão   												#
#						09/03/2009-thiago- Tela para exibir o historico        	#
#						14/04/2009-Manuel- A pedido do Paulo Rocha da Grauna o 	#
#                              programa deve permitir digitar itens #
#                              beneficiados também(versão 05.10.10  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_cons           SMALLINT,
          p_ies_cons1           SMALLINT,
          p_caminho            CHAR(080),
          p_status             SMALLINT,
          p_status1             SMALLINT,
          p_count              SMALLINT,
          p_retorno            SMALLINT,          
          p_index              SMALLINT,
          p_ind                SMALLINT,
          s_index              SMALLINT,
          p_houve_erro         SMALLINT,
          p_cont_mod					 SMALLINT,
          p_data_padrao        DATE,
          sql_stmt             CHAR(300), 
          sql_stmt1             CHAR(500), 
          where_clause         CHAR(300),  
					 p_testa 						SMALLINT  
   DEFINE p_cod_item           LIKE item.cod_item,
          p_cod_compon         LIKE item.cod_item,
          p_den_item           LIKE item.den_item,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_explodiu           CHAR(01),
          p_tipo_dados         CHAR(03),
          p_den_dados          CHAR(50),
          p_rev_processo       CHAR(30),
          p_data_rev           DATE,
          p_hora_rev           DATETIME HOUR TO SECOND,
          p_situacao_rev       CHAR(01),
          p_revisao            CHAR(01),
          p_data_revisao       CHAR(01),    
          p_hora_revisao       CHAR(01),
          p_situacao           CHAR(01),
          p_liberacao_rev      CHAR(01),
          p_cod_item1          CHAR(15),
          p_cod_item2          CHAR(15),
          p_msg                CHAR(500)

   DEFINE pr_revisao           ARRAY[200] OF RECORD
          tipo_dados           LIKE revisao_1040.tipo_dados,
          den_dados            LIKE par_revisao_1040.den_dados, 
          rev_processo         LIKE revisao_1040.rev_processo,
          data_rev             LIKE revisao_1040.data_rev,
          hora_rev             LIKE revisao_1040.hora_rev,
          situacao_rev         LIKE revisao_1040.situacao_rev,
          liberacao_rev        LIKE revisao_1040.liberacao_rev
      END RECORD

   DEFINE p_revisao_1040     RECORD LIKE revisao_1040.*

   DEFINE p_tela            RECORD
          cod_item          LIKE item.cod_item
   END RECORD

   DEFINE pr_compon            ARRAY[1000] OF RECORD
          cod_item             LIKE revisao_1040.cod_item,
          tipo_dados           LIKE revisao_1040.tipo_dados,
          rev_processo         LIKE revisao_1040.rev_processo,
          data_rev             LIKE revisao_1040.data_rev,
          hora_rev             LIKE revisao_1040.hora_rev,
          situacao_rev         LIKE revisao_1040.situacao_rev,
          liberacao_rev        LIKE revisao_1040.liberacao_rev
   END RECORD

   DEFINE pr_copia          ARRAY[100] OF RECORD
          tipo_dados        LIKE revisao_1040.tipo_dados,
          rev_processo      LIKE revisao_1040.rev_processo,
          data_rev          LIKE revisao_1040.data_rev,
          hora_rev          LIKE revisao_1040.hora_rev,
          situacao_rev      LIKE revisao_1040.situacao_rev,
          liberacao_rev     LIKE revisao_1040.liberacao_rev
          END RECORD
          
   
          
  #----COPIAR PARA COMPARAR---#
   DEFINE l_m_cod_item			LIKE item.cod_item,
   				
   				l_num_sequencia    LIKE revisao_hist_1040.num_sequencia,    
					l_dat_hor_alter		 LIKE revisao_hist_1040.dat_hor_alter,
					l_usuario					 LIKE revisao_hist_1040.usuario
   
   DEFINE pr_modifica          ARRAY[200] OF RECORD
          tipo_dados           LIKE revisao_1040.tipo_dados,
          den_dados            LIKE par_revisao_1040.den_dados, 
          rev_processo         LIKE revisao_1040.rev_processo,
          data_rev             LIKE revisao_1040.data_rev,
          hora_rev             LIKE revisao_1040.hora_rev,
          situacao_rev         LIKE revisao_1040.situacao_rev,
          liberacao_rev        LIKE revisao_1040.liberacao_rev
      END RECORD
      
    DEFINE 	pr_consul						RECORD
    				
    				cod_item  							LIKE 	item.cod_item,
    				cod_operacao						LIKE 	revisao_hist_1040.cod_operacao,
    				usuario									LIKE	revisao_hist_1040.usuario,
    				data_ini								LIKE	revisao_hist_1040.data_rev,
    				data_fin								LIKE	revisao_hist_1040.data_rev
    				
    	END RECORD 
    	
   DEFINE pr_hist 		RECORD  	LIKE   revisao_hist_1040.*
   DEFINE pr_hist1 		RECORD  	LIKE   revisao_hist_1040.*
   DEFINE pr_inserir 	ARRAY[1000] OF RECORD 			LIKE  revisao_hist_1040.*
   
    DEFINE pr_before_row         RECORD
          tipo_dados           LIKE revisao_1040.tipo_dados,
          den_dados            LIKE par_revisao_1040.den_dados, 
          rev_processo         LIKE revisao_1040.rev_processo,
          data_rev             LIKE revisao_1040.data_rev,
          hora_rev             LIKE revisao_1040.hora_rev,
          situacao_rev         LIKE revisao_1040.situacao_rev,
          liberacao_rev        LIKE revisao_1040.liberacao_rev
      END RECORD
   
   
    

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol0535-05.10.15"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0535.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0535_controle()
   END IF
END MAIN
  
#--------------------------#
 FUNCTION pol0535_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0535") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0535 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0535_incluir() RETURNING p_status
         IF p_status THEN
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         LET p_ies_cons = FALSE   
       
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0535_modificar() RETURNING p_status
            IF p_status THEN
               MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
                  ATTRIBUTE(REVERSE)
                  IF NOT pol0535_grava_hist() THEN
                  	ERROR "Erro ao gravar historico !!!"
                  END IF 
            ELSE
               MESSAGE "Operação Cancelada !!!"
                  ATTRIBUTE (REVERSE)
            END IF
          ELSE
            ERROR "Execute Previamente a Consulta !!!"
          END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF p_tela.cod_item IS NULL THEN
               ERROR "Não há dados na tela a serem excluídos !!!"
            ELSE
                CALL pol0535_excluir() RETURNING p_status
               IF p_status THEN
                  MESSAGE "Exclusão de Dados Efetuada c/ Sucesso !!!"
                     ATTRIBUTE(REVERSE)
               ELSE
                  MESSAGE "Operação Cancelada !!!"
                     ATTRIBUTE(REVERSE)
               END IF      
            END IF
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0535_consultar()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0535_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0535_paginacao("ANTERIOR")
      COMMAND KEY ("P") "comPonentes" "Exibe os componentes do item"
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0535_mostra_compon()
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND KEY ("H") "Histórico" "Consulta e exibe historico das revisões"
         MESSAGE ""
         LET INT_FLAG = 0
        
            CALL pol0535_controle_hist()
         

     COMMAND KEY ("O") "cOpia" "Copia Revisoes."
         HELP 007
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0535_copia_rev() THEN
            CALL pol0535_grava_copia()
         END IF

         IF p_status THEN
            MESSAGE "Copia de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         LET p_ies_cons = FALSE   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol0535_sobre()

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0535

END FUNCTION

#-----------------------#
 FUNCTION pol0535_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Conversão para 10.02.00\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
 FUNCTION pol0535_incluir()
#--------------------------#
	
   LET p_retorno = FALSE

   IF pol0535_aceita_chave() THEN
      IF pol0535_aceita_itens() THEN
         CALL pol0535_coleta_itens()
      END IF
   END IF
   
   RETURN(p_retorno)
   
   END FUNCTION

#--------------------------#
FUNCTION pol0535_modificar()
#--------------------------#
	 INITIALIZE pr_inserir TO NULL
	 LET p_cont_mod = 1
	 
	 
	 

   LET p_retorno = FALSE
	 		
   IF pol0535_aceita_itens() THEN
   		
      CALL pol0535_coleta_itens()
   ELSE
      CALL pol0535_exibe_tipos()
      
      
   END IF
	 
   RETURN(p_retorno)
   
END FUNCTION

#------------------------------#
FUNCTION pol0535_aceita_chave()
#------------------------------#

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0535
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_tela.cod_item,
              p_den_item TO NULL
  
   INPUT BY NAME p_tela.cod_item WITHOUT DEFAULTS  

      AFTER FIELD cod_item
      IF p_tela.cod_item IS NULL THEN
         ERROR "Campo com Preenchimento Obrigatório !!!"
         NEXT FIELD cod_item
      END IF
     
      SELECT COUNT(cod_item)
        INTO p_count
        FROM revisao_1040
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_tela.cod_item
          
      IF p_count > 0 THEN 
         ERROR 'Item já possui revisões! Utilize Modificar'
         NEXT FIELD cod_item
      END IF
      
      SELECT den_item,
             ies_tip_item
        INTO p_den_item,
             p_ies_tip_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_tela.cod_item
 
      IF SQLCA.sqlcode = NOTFOUND THEN
         ERROR "Item nao cadastrado na Tabela ITEM !!!"  
         NEXT FIELD cod_item
      END IF

      DISPLAY p_den_item TO den_item

      IF p_ies_tip_item MATCHES '[PFB]' THEN
      ELSE
         ERROR "Informe um item final/produzido/Beneficiado"  
         NEXT FIELD cod_item
      END IF

      SELECT COUNT(cod_item_pai)
        INTO p_count
        FROM estrutura
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_compon = p_tela.cod_item

      IF p_count > 0 THEN 
         ERROR 'Esse item é um componente de outros itens'
         NEXT FIELD cod_item
      END IF

      ON KEY (control-z)
         CALL pol0535_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

   RETURN(p_retorno)

END FUNCTION 

#-----------------------------#
FUNCTION pol0535_aceita_itens()
#-----------------------------#

   INITIALIZE pr_revisao TO NULL
   
   DECLARE cq_revisao CURSOR FOR 
    SELECT tipo_dados,
           rev_processo,
           data_rev,
           hora_rev,
           situacao_rev,
           liberacao_rev
      FROM revisao_1040
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_tela.cod_item
     ORDER BY 1
       
   LET p_index = 1
   
    FOREACH cq_revisao INTO pr_revisao[p_index].tipo_dados,    
                            pr_revisao[p_index].rev_processo,
                            pr_revisao[p_index].data_rev,
                            pr_revisao[p_index].hora_rev,
                            pr_revisao[p_index].situacao_rev,
                            pr_revisao[p_index].liberacao_rev
 
      INITIALIZE pr_revisao[p_index].den_dados TO NULL
      
      SELECT den_dados
        INTO pr_revisao[p_index].den_dados
        FROM par_revisao_1040
       WHERE cod_empresa = p_cod_empresa
         AND tipo_dados  = pr_revisao[p_index].tipo_dados
         
      LET p_index = p_index + 1

	    IF p_index > 200 THEN
         EXIT FOREACH
      END IF

   END FOREACH
   
   LET p_data_padrao = "01/01/1900"
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_revisao
      WITHOUT DEFAULTS FROM sr_revisao.*
      
      BEFORE DELETE
   			CALL pol0535_guarda("E")

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         LET pr_before_row.* = pr_revisao[p_index].*
         LET p_testa = 0
         
      BEFORE FIELD tipo_dados
         LET p_tipo_dados = pr_revisao[p_index].tipo_dados
         
      AFTER FIELD tipo_dados
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_revisao[p_index].tipo_dados IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_revisao[p_index].tipo_dados = p_tipo_dados
               NEXT FIELD tipo_dados
            END IF
         END IF

         IF pr_revisao[p_index].tipo_dados IS NOT NULL THEN
            IF pol0535_repetiu_cod() THEN
               ERROR "Tipo Dados ",pr_revisao[p_index].tipo_dados," já Agrupada !!!"
               LET pr_revisao[p_index].tipo_dados = p_tipo_dados
               NEXT FIELD tipo_dados
            ELSE
               SELECT den_dados,
                      revisao,
                      data_revisao,
                      hora_revisao,
                      situacao
                 INTO pr_revisao[p_index].den_dados,
                      p_revisao,
                      p_data_revisao,
                      p_hora_revisao,
                      p_situacao
                 FROM par_revisao_1040
                WHERE cod_empresa = p_cod_empresa
                  AND tipo_dados  = pr_revisao[p_index].tipo_dados

                IF STATUS = 0 THEN
                   DISPLAY pr_revisao[p_index].den_dados TO
                           sr_revisao[s_index].den_dados
                   IF FIELD_TOUCHED(tipo_dados) THEN	{<----------------alterado---------------}
											LET p_testa = 1
										END IF
                 ELSE
                    ERROR "Tipo de Dados nao Cadastrado no LOGIX !!!"
                    NEXT FIELD tipo_dados
                 END IF
            END IF
         END IF
					
         AFTER FIELD rev_processo
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_revisao[p_index].rev_processo IS NULL AND
               p_revisao = "S" THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_revisao[p_index].rev_processo = p_rev_processo
               NEXT FIELD rev_processo
            END IF
         END IF
         IF pr_revisao[p_index].rev_processo IS NOT NULL THEN
            IF pol0535_repetiu_cod() THEN
               ERROR "Revisao Processo ",pr_revisao[p_index].rev_processo," já Agrupada !!!"
               LET pr_revisao[p_index].rev_processo = p_rev_processo
               NEXT FIELD rev_processo
            END IF
         END IF
         
        IF FIELD_TOUCHED(rev_processo) THEN	{<----------------alterado---------------}
					LET p_testa = 1
				END IF
        
         AFTER FIELD data_rev
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_revisao[p_index].data_rev IS NULL AND
               p_data_revisao = "S" THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_revisao[p_index].data_rev = p_data_rev
               NEXT FIELD data_rev
            END IF
         END IF
         IF pr_revisao[p_index].data_rev IS NOT NULL THEN
            IF pr_revisao[p_index].data_rev >= p_data_padrao THEN
               IF pol0535_repetiu_cod() THEN
                  ERROR "Data Revisao ",pr_revisao[p_index].data_rev," já Agrupada !!!"
                  LET pr_revisao[p_index].data_rev = p_data_rev
                  NEXT FIELD data_rev
               END IF
            ELSE
               ERROR "Data Invalida !!!"
               NEXT FIELD data_rev
            END IF
         END IF
         
         IF FIELD_TOUCHED(data_rev) THEN	{<----------------alterado---------------}
					LET p_testa = 1
				 END IF
         
         AFTER FIELD hora_rev
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_revisao[p_index].hora_rev IS NULL AND
               p_hora_revisao = "S" THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_revisao[p_index].hora_rev = p_hora_rev
               NEXT FIELD hora_rev
            END IF
         END IF
         IF pr_revisao[p_index].hora_rev IS NOT NULL THEN
            IF pol0535_repetiu_cod() THEN
               ERROR "Hora Revisao ",pr_revisao[p_index].hora_rev," já Agrupada !!!"
               LET pr_revisao[p_index].hora_rev = p_hora_rev
               NEXT FIELD hora_rev
            END IF
         END IF
         
        IF FIELD_TOUCHED(hora_rev) THEN	{<----------------alterado---------------}
					LET p_testa = 1
				END IF

      AFTER FIELD situacao_rev
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_revisao[p_index].situacao_rev IS NULL AND
               p_situacao = "S" THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET pr_revisao[p_index].situacao_rev = p_situacao_rev
               NEXT FIELD situacao_rev
            END IF
         END IF
         IF pr_revisao[p_index].situacao_rev IS NOT NULL THEN
            IF pol0535_repetiu_cod() THEN
               ERROR "Situacao ",pr_revisao[p_index].situacao_rev," já Agrupada !!!"
               LET pr_revisao[p_index].situacao_rev = p_situacao_rev
               NEXT FIELD situacao_rev
            END IF
         END IF
         
         IF FIELD_TOUCHED(situacao_rev) THEN 	{<----------------alterado---------------}
					LET p_testa = 1
				END IF
         
 
      AFTER FIELD liberacao_rev
      IF pr_revisao[p_index].liberacao_rev IS NULL OR      
         pr_revisao[p_index].liberacao_rev = ' ' THEN
         IF INT_FLAG = 0 THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD liberacao_rev
         END IF
      ELSE
         IF pr_revisao[p_index].liberacao_rev <> 'S' AND 
            pr_revisao[p_index].liberacao_rev <> 'N' THEN
            ERROR 'Valor inválido. Informe (S)-Sim ou (N)-Não'
            NEXT FIELD liberacao_rev
         END IF
      END IF
      
      IF FIELD_TOUCHED(liberacao_rev) THEN       {<----------------alterado---------------}
					LET p_testa = 1
				END IF

      ON KEY (control-z)
         CALL pol0535_popup()
     AFTER ROW
     	IF p_testa = 1 THEN
     		CALL pol0535_guarda("A")
     	END IF 
       
     AFTER INSERT 
     		CALL pol0535_guarda("I")
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE
   ELSE
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF   
   RETURN(p_retorno)
   {comemntando as modificações07/03/2009: Inseri um before DELETE, para que ele verifique se for deletar algum
   item ele copiar esse item para dentro de um array, para poder gravar no Historico passando como parametro 
   o caracter "E", o mesmo ocorre com a função AFTER INSERT depois de inserir ele pega os item que foi inserido 
   joga para um outro array que sera gravado na table de historico, ja a quando um item e alterado foi usado uma
   variavel p_testa e a função FIELD_TOUCHED AFTER ROW eo BEFORE ROW o after row vai ter a seguint funçao, armazenar os dados da linha
   caso ela for alterada seja possivel gravar esses dados a funcçao FIELD_TOUCHEDse essa função retornar um valor 
   verdadeiro  quer dizer alteraram  algum valor dos campos   e vai atribuir um valor para variavel 
   p_testa depois qdo for mudar de linha vou verificar se a varivel p_testa tem algm valor se estiver mando esses Dados
   para o array para ser gravado na tabela de historico}
   
END FUNCTION

#-------------------------------#
FUNCTION pol0535_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_revisao[p_ind].tipo_dados = pr_revisao[p_index].tipo_dados THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0535_coleta_itens()
#-----------------------------#


   
   IF NOT pol0535_explode_estrutura() THEN
      RETURN
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol0535_grava_itens() THEN
     CALL log085_transacao("ROLLBACK")
   ELSE
     CALL log085_transacao("COMMIT")
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0535_grava_itens()
#-----------------------------#


   
   DECLARE cq_tmp CURSOR FOR
    SELECT cod_item
      FROM item_tmp_1040

   FOREACH cq_tmp INTO p_cod_item

      DELETE FROM revisao_1040
       WHERE cod_empresa  = p_cod_empresa
         AND cod_item     = p_cod_item
         
      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql('Deletando','revisao_1040')
         RETURN FALSE
      END IF
   
      FOR p_ind = 1 TO ARR_COUNT()
      
          IF pr_revisao[p_ind].tipo_dados IS NOT NULL THEN

             INSERT INTO revisao_1040
             VALUES(p_cod_empresa,
                    p_cod_item,
                    pr_revisao[p_ind].tipo_dados,
                    pr_revisao[p_ind].rev_processo,
                    pr_revisao[p_ind].data_rev,
                    pr_revisao[p_ind].hora_rev,
                    pr_revisao[p_ind].situacao_rev,
                    pr_revisao[p_ind].liberacao_rev)
          
             IF sqlca.sqlcode <> 0 THEN 
                CALL log003_err_sql('Deletando','revisao_1040')
                RETURN FALSE
             END IF
          END IF
          
      END FOR
      
   END FOREACH

   LET p_retorno = TRUE
   
   RETURN TRUE
      
END FUNCTION

#------------------------#
FUNCTION pol0535_excluir()
#------------------------#

   LET p_retorno = FALSE

   IF log004_confirm(18,35) THEN
   		CALL pol0535_copia_grava_excluido()
   		
      CALL log085_transacao("BEGIN")
			
      DELETE FROM revisao_1040
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_tela.cod_item
          
      IF STATUS = 0 THEN 
         CALL log085_transacao("COMMIT")
         
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         INITIALIZE p_tela.cod_item TO NULL
      ELSE
         CALL log003_err_sql("DELEÇÃO","revisao_1040")
      END IF
   END IF
   RETURN(p_retorno)
   
END FUNCTION

#----------------------------#
 FUNCTION pol0535_consultar()
#----------------------------#

   LET p_cod_item = p_revisao_1040.cod_item

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause 
      ON revisao_1040.cod_item

      ON KEY(control-z)
         CALL pol0535_popup()
   
   END CONSTRUCT
         
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0535
            
   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0
      LET p_tela.cod_item = p_cod_item
      CALL pol0535_exibe_item()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = 
    "SELECT cod_item FROM revisao_1040 ",
    " WHERE cod_empresa = '", p_cod_empresa,"' ",
    "  AND ", where_clause CLIPPED,
    #"  AND cod_item not in (select cod_item_compon from estrutura where cod_empresa = '", p_cod_empresa,"')",
    " ORDER BY cod_item"

                   
   PREPARE var_queri FROM sql_stmt
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_tela.*
   
   IF SQLCA.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE
      CALL pol0535_exibe_item()
   END IF
   
END FUNCTION

#------------------------------#
 FUNCTION pol0535_exibe_item()
#------------------------------#

   DISPLAY BY NAME p_tela.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_item TO NULL
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_tela.cod_item
   
   DISPLAY p_den_item TO den_item

   CALL pol0535_exibe_tipos()
   
   END FUNCTION
  
  #---------------------------------#
    FUNCTION pol0535_exibe_tipos()
  #---------------------------------#

	  DECLARE cq_revisao1 CURSOR FOR 
    SELECT tipo_dados,
           rev_processo,
           data_rev,
           hora_rev,
           situacao_rev,
           liberacao_rev
      FROM revisao_1040
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_tela.cod_item
     ORDER BY 1
     
   LET p_index = 1
   
   FOREACH cq_revisao1 INTO pr_revisao[p_index].tipo_dados,
                            pr_revisao[p_index].rev_processo,
                            pr_revisao[p_index].data_rev,
                            pr_revisao[p_index].hora_rev,
                            pr_revisao[p_index].situacao_rev,
                            pr_revisao[p_index].liberacao_rev
                            
     INITIALIZE pr_revisao[p_index].den_dados TO NULL
      
      SELECT den_dados
        INTO pr_revisao[p_index].den_dados
        FROM par_revisao_1040
       WHERE cod_empresa = p_cod_empresa
         AND tipo_dados  = pr_revisao[p_index].tipo_dados
                  
      LET p_index = p_index + 1

   END FOREACH
   
   LET p_index = p_index -1 
   
   CALL SET_COUNT(p_index)

   IF p_index > 5 THEN
      LET p_ies_cons = TRUE 
      DISPLAY ARRAY pr_revisao TO sr_revisao.*
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
   ELSE
      INPUT ARRAY pr_revisao WITHOUT DEFAULTS FROM sr_revisao.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION 

#-----------------------------------#
 FUNCTION pol0535_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_item = p_tela.cod_item
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                            p_tela.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                            p_tela.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_tela.cod_item = p_cod_item
            EXIT WHILE
         END IF

         IF p_tela.cod_item = p_cod_item THEN
            CONTINUE WHILE
         END IF

         SELECT COUNT(cod_item)
           INTO p_count
           FROM revisao_1040
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_tela.cod_item
            
         IF p_count > 0 THEN
            CALL pol0535_exibe_item()
            EXIT WHILE 
         END IF

      END WHILE
                  
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0535_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0535
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
         
      WHEN INFIELD (tipo_dados)
         CALL log009_popup(8,25,"TIPO DE DADOS","par_revisao_1040",
              "tipo_dados","den_dados","","S","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0535
         IF p_codigo IS NOT NULL THEN
           LET pr_revisao[p_index].tipo_dados = p_codigo
           DISPLAY p_codigo TO sr_revisao[s_index].tipo_dados
         END IF
         
    
     WHEN INFIELD(cod_item3)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05353
         IF p_codigo IS NOT NULL THEN
           SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item  = p_codigo
           DISPLAY p_den_item TO den_item3			
           DISPLAY p_codigo TO cod_item3
         END IF 
         
         
   END CASE

END FUNCTION

#---------------------------#
FUNCTION pol0535_copia_rev()
#---------------------------#

   DEFINE cod_item1   LIKE item.cod_item,
          cod_item2   LIKE item.cod_item
          
   CALL log006_exibe_teclas("01 02 07",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol05351") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05351 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INPUT BY NAME cod_item1,
                 cod_item2  WITHOUT DEFAULTS  

      AFTER FIELD cod_item1
      IF cod_item1 IS NULL THEN
         ERROR "Campo com Preenchimento Obrigatório !!!"
         NEXT FIELD cod_item1
      END IF

      LET p_cod_item1 = cod_item1
      SELECT UNIQUE cod_item
        FROM revisao_1040
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item1
         
      IF SQLCA.sqlcode = NOTFOUND THEN
         ERROR "Item nao cadastrado na Tabela REVISAO_1040 !!!"  
         NEXT FIELD cod_item1
      ELSE
         SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item1
    
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Item nao cadastrado na Tabela ITEM !!!"  
            NEXT FIELD cod_item1
         ELSE
            DISPLAY p_den_item TO den_item1
         END IF
      END IF   
 
      AFTER FIELD cod_item2
      IF cod_item2 IS NULL THEN
         ERROR "Campo com Preenchimento Obrigatório !!!"
         NEXT FIELD cod_item2
      END IF
      LET p_cod_item2 = cod_item2
      
      SELECT UNIQUE cod_item
        FROM revisao_1040
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item2

      IF SQLCA.sqlcode = NOTFOUND THEN
         SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item2
 
         IF SQLCA.sqlcode = NOTFOUND THEN
            ERROR "Item nao cadastrado na Tabela ITEM !!!"  
            NEXT FIELD cod_item2
         ELSE
            DISPLAY p_den_item TO den_item2
         END IF
      ELSE
         ERROR "Item ja cadastrado na Tabela REVISAO_1040 !!!"  
         NEXT FIELD cod_item2
      END IF
     
      ON KEY (control-z)
         CALL pol0535_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
   
      CLOSE WINDOW w_pol05351
      CURRENT WINDOW IS w_pol0535
{      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa}
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

   RETURN(p_retorno)

END FUNCTION

#-----------------------------#
FUNCTION pol0535_grava_copia()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 
  
   CALL log085_transacao("BEGIN")

   CALL pol0535_cria_tabela_temporaria()

   DECLARE cq_copia CURSOR FOR 
    SELECT tipo_dados,
           rev_processo,
           data_rev,
           hora_rev,
           situacao_rev,
           liberacao_rev
      FROM revisao_1040
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item1
     ORDER BY 1
       
    LET p_ind = 1
   
   FOREACH cq_copia INTO pr_copia[p_ind].tipo_dados,    
                         pr_copia[p_ind].rev_processo,
                         pr_copia[p_ind].data_rev,
                         pr_copia[p_ind].hora_rev,
                         pr_copia[p_ind].situacao_rev,
                         pr_copia[p_ind].liberacao_rev

      INSERT INTO copia_revisao
         VALUES (p_cod_empresa,
                 p_cod_item2,
                 pr_copia[p_ind].tipo_dados,    
                 pr_copia[p_ind].rev_processo,
                 pr_copia[p_ind].data_rev,
                 pr_copia[p_ind].hora_rev,
                 pr_copia[p_ind].situacao_rev,
                 pr_copia[p_ind].liberacao_rev)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INSERÇÃO","TABELA-COPIA_REVISAO")
      END IF

      LET p_index = p_index + 1
      IF p_index > 100 THEN
         EXIT FOREACH
      END IF

   END FOREACH

   IF log004_confirm(18,35) THEN
      CALL log085_transacao("BEGIN")

      INSERT INTO revisao_1040
      SELECT *
        FROM copia_revisao
       WHERE cod_empresa = p_cod_empresa
   
      DELETE FROM copia_revisao

      IF STATUS = 0 THEN 
         CALL log085_transacao("COMMIT")
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
         CALL log003_err_sql("COPIA","revisao_1040")
      END IF
   END IF

END FUNCTION

#---------------------------------------#
FUNCTION pol0535_cria_tabela_temporaria()
#---------------------------------------#

   CALL log085_transacao("BEGIN") 

   DROP TABLE copia_revisao;
   CREATE TEMP TABLE copia_revisao
     (
      cod_empresa     CHAR(02),
      cod_item        CHAR(15),
      tipo_dados      CHAR(03),
      rev_processo    CHAR(30),
      data_rev        DATE,
      hora_rev        DATETIME HOUR TO SECOND,
      situcao_rev     CHAR(01),
      liberacao_rev   CHAR(01) 
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-COPIA_REVISAO")
   END IF

   CALL log085_transacao("COMMIT") 
 
END FUNCTION

#----------------------------------#
FUNCTION pol0535_explode_estrutura()
#----------------------------------#

   IF NOT pol0535_cria_tab_item() THEN
      RETURN FALSE
   END IF

   LET p_cod_compon = p_tela.cod_item
   LET p_explodiu = 'N'

   IF NOT pol0535_insere_item() THEN
      RETURN FALSE
   END IF

   WHILE TRUE
    
    SELECT COUNT(cod_item)
      INTO p_count
      FROM item_tmp_1040
     WHERE explodiu = 'N'
     
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','item_tmp_1040')
       RETURN FALSE
    END IF
    
    IF p_count = 0 THEN
       EXIT WHILE
    END IF
    
    DECLARE cq_exp CURSOR FOR
     SELECT cod_item
       FROM item_tmp_1040
      WHERE explodiu = 'N'
    
    FOREACH cq_exp INTO p_cod_item
    
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','item_tmp_1040:cq_exp')
          RETURN FALSE
       END IF
       
       UPDATE item_tmp_1040
          SET explodiu = 'S'
        WHERE cod_item = p_cod_item

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Atualizando','item_tmp_1040:cq_exp')
          RETURN FALSE
       END IF
       
        DECLARE cq_est CURSOR FOR
        SELECT a.cod_item_compon
          FROM estrutura a,
               item b
         WHERE a.cod_empresa  = p_cod_empresa
           AND a.cod_item_pai = p_cod_item       
           AND b.cod_empresa  = a.cod_empresa
           AND b.cod_item     = a.cod_item_compon
           AND b.ies_tip_item <> 'C'
           AND a.cod_item_compon[1,2] <> '30'
             
       FOREACH cq_est INTO p_cod_compon

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Lendo','estrutura')
             RETURN FALSE
          END IF

          LET p_explodiu = 'N'
          
          IF NOT pol0535_insere_item() THEN
             RETURN FALSE
          END IF
         
       END FOREACH
   
    END FOREACH
   
   END WHILE
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0535_cria_tab_item()
#-------------------------------#

   DROP TABLE item_tmp_1040

   CREATE TABLE item_tmp_1040(
      cod_item       CHAR(15),
      explodiu       CHAR(01)
    );
         
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","item_tmp_1040")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0535_insere_item()
#-----------------------------#

   INSERT INTO item_tmp_1040
      VALUES(p_cod_compon, p_explodiu)

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("Iserindo","item_tmp_1040")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0535_mostra_compon()
#-------------------------------#

   IF NOT pol0535_explode_estrutura() THEN
      ERROR 'Operação cancelada'
      RETURN
   END IF

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol05352") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol05352 AT 8,8 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET p_ind = 1
   INITIALIZE pr_compon TO NULL

   DECLARE cq_compon CURSOR FOR
    SELECT cod_item
      FROM item_tmp_1040

   FOREACH cq_compon INTO p_cod_compon

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_compon')
         EXIT FOREACH
      END IF
      
      DECLARE cq_itens CURSOR FOR
       SELECT cod_item,
              tipo_dados,
              rev_processo,
              data_rev,
              hora_rev,
              situacao_rev,
              liberacao_rev
          FROM revisao_1040 
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_cod_compon
         ORDER BY cod_item
   
      FOREACH cq_itens INTO pr_compon[p_ind].*

         LET p_ind = p_ind + 1
         
         IF p_ind > 1000 THEN
            ERROR 'Limite de Linhas Ultrapassado !!!'
            EXIT FOREACH
         END IF
      
      END FOREACH
   
   END FOREACH

   IF p_ind > 1 THEN   
      CALL SET_COUNT(p_ind - 1)
      DISPLAY ARRAY pr_compon TO sr_compon.*
   END IF
   
   CLOSE WINDOW w_pol05352
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0535_copia_grava_excluido() {<-----AO EXCLUIR TODOS OS ITENS ELE COPIA E GRAVA NO BANCO----THIAGO--}
#-------------------------------------#
DEFINE p_index1 	SMALLINT

		LET l_m_cod_item = p_cod_item


DECLARE cq_exclui CURSOR FOR 
						SELECT  tipo_dados,
									rev_processo, 
									data_rev,
									hora_rev,
									situacao_rev,
	  							liberacao_rev
	  			FROM 		revisao_1040
	  			WHERE		cod_empresa = p_cod_empresa
	  				AND		cod_item = p_tela.cod_item
		
		LET l_dat_hor_alter= CURRENT
		LET l_usuario = p_user
		LET p_index1 = 1
					SELECT 	MAX(num_sequencia)
							INTO 		l_num_sequencia
							FROM 		revisao_hist_1040
		IF l_num_sequencia IS NULL THEN
			LET l_num_sequencia = 0
		END IF
							
	FOREACH cq_exclui INTO 	pr_modifica[p_index1].tipo_dados,
													pr_modifica[p_index1].rev_processo, 
													pr_modifica[p_index1].data_rev,
													pr_modifica[p_index1].hora_rev,
													pr_modifica[p_index1].situacao_rev,
					  							pr_modifica[p_index1].liberacao_rev
					  							
					LET  l_num_sequencia = l_num_sequencia + 1
      
          INSERT INTO revisao_hist_1040 VALUES
								(p_cod_empresa,l_num_sequencia,p_tela.cod_item,
								pr_modifica[p_index1].tipo_dados,pr_modifica[p_index1].rev_processo,
								pr_modifica[p_index1].data_rev,pr_modifica[p_index1].hora_rev,
								pr_modifica[p_index1].situacao_rev,pr_modifica[p_index1].liberacao_rev,
								"E",l_dat_hor_alter,l_usuario)
          
             IF sqlca.sqlcode <> 0 THEN 
                CALL log003_err_sql('Incluir','revisao_hist_1040')
                RETURN FALSE
             END IF
    				
    				LET    p_index1 = p_index1 + 1
    
          
      END FOREACH
{Ao deletear um item todas as suas revisões serão gravadas }
END FUNCTION
#--------------------------------#
FUNCTION pol0535_guarda(cod_oper)
#--------------------------------#
DEFINE cod_oper CHAR(1)
		
		IF cod_oper = "A" THEN 
				LET pr_inserir[p_cont_mod].cod_operacao 	= cod_oper
				LET pr_inserir[p_cont_mod].cod_item 			= p_tela.cod_item
				LET pr_inserir[p_cont_mod].cod_empresa 		= p_cod_empresa
				LET pr_inserir[p_cont_mod].tipo_dados 		= pr_before_row.tipo_dados
				LET pr_inserir[p_cont_mod].rev_processo 	= pr_before_row.rev_processo
				LET pr_inserir[p_cont_mod].data_rev 			= pr_before_row.data_rev
				LET pr_inserir[p_cont_mod].hora_rev 			= pr_before_row.hora_rev
				LET pr_inserir[p_cont_mod].situacao_rev 	= pr_before_row.situacao_rev
				LET pr_inserir[p_cont_mod].liberacao_rev 	= pr_before_row.liberacao_rev
				LET pr_inserir[p_cont_mod].dat_hor_alter	= CURRENT
				LET pr_inserir[p_cont_mod].usuario				= p_user
		ELSE
				LET pr_inserir[p_cont_mod].cod_operacao 	= cod_oper
				LET pr_inserir[p_cont_mod].cod_item 			= p_tela.cod_item
				LET pr_inserir[p_cont_mod].cod_empresa 		= p_cod_empresa
				LET pr_inserir[p_cont_mod].tipo_dados 		= pr_revisao[p_index].tipo_dados
				LET pr_inserir[p_cont_mod].rev_processo 	= pr_revisao[p_index].rev_processo
				LET pr_inserir[p_cont_mod].data_rev 			= pr_revisao[p_index].data_rev
				LET pr_inserir[p_cont_mod].hora_rev 			= pr_revisao[p_index].hora_rev
				LET pr_inserir[p_cont_mod].situacao_rev 	= pr_revisao[p_index].situacao_rev
				LET pr_inserir[p_cont_mod].liberacao_rev 	= pr_revisao[p_index].liberacao_rev
				LET pr_inserir[p_cont_mod].dat_hor_alter	= CURRENT
				LET pr_inserir[p_cont_mod].usuario				= p_user
		END IF
		LET p_cont_mod = p_cont_mod + 1
END FUNCTION

#--------------------------------#
FUNCTION pol0535_grava_hist()
#--------------------------------#
DEFINE contador,seq		SMALLINT

CALL log085_transacao("BEGIN")
SELECT MAX(num_sequencia)
INTO seq
FROM revisao_hist_1040
IF seq IS NULL THEN
	LET seq = 0
END IF

LET seq = seq + 1
	FOR contador = 1  TO p_cont_mod 
		LET pr_inserir[contador].num_sequencia = seq
		IF pr_inserir[contador].tipo_dados IS NOT NULL THEN
			INSERT INTO revisao_hist_1040 VALUES(pr_inserir[contador].*)
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("INSERIR","revisao_hist_1040")
				CALL log085_transacao("ROLLBACK")
				RETURN FALSE
			END IF
			LET seq = seq+1
		END IF 
	END FOR
CALL log085_transacao("COMMIT")
RETURN TRUE 

END FUNCTION


#--------------------------------#
FUNCTION pol0535_consulta_hist()
#--------------------------------#
DEFINE b,c,d	CHAR(100)

	DISPLAY p_cod_empresa TO cod_empresa
	CALL pol0535_entrada_par()
	LET pr_hist1.* = pr_hist.*
  
  IF pr_consul.usuario IS NOT NULL THEN
  	LET b = " AND usuario= ","'",pr_consul.usuario CLIPPED,"'"
  END IF 
  
  IF pr_consul.cod_item IS NOT NULL THEN
  	LET c =" AND cod_item =","'",pr_consul.cod_item CLIPPED,"'"
  END IF 
  
  IF pr_consul.cod_operacao IS NOT NULL THEN
  	LET d =" AND cod_operacao =","'",pr_consul.cod_operacao CLIPPED,"'"
  END IF 
	
   LET sql_stmt1 =" SELECT * FROM revisao_hist_1040",
									" WHERE cod_empresa = ",p_cod_empresa,
									" AND cast(To_Char(dat_hor_alter,'%d')||'/'||To_Char(dat_hor_alter,'%m')||'/'||To_Char(dat_hor_alter,'%Y') as date) >='",pr_consul.data_ini,"' ",
									"AND cast(To_Char(dat_hor_alter,'%d')||'/'||To_Char(dat_hor_alter,'%m')||'/'||To_Char(dat_hor_alter,'%Y') as date) <='", pr_consul.data_fin,"' ",
									b CLIPPED,c CLIPPED,d CLIPPED,
									"ORDER BY 3,1,2"
   PREPARE var_quer FROM sql_stmt1   
   DECLARE cq_consulta_hist SCROLL CURSOR WITH HOLD FOR var_quer
   OPEN cq_consulta_hist
   FETCH cq_consulta_hist INTO pr_hist.*
   
   
   IF SQLCA.SQLCODE <>0 THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons1 = FALSE
   ELSE 
      LET p_ies_cons1 = TRUE
      CALL pol0535_exibe_hist()
   END IF
END FUNCTION

#-----------------------------------#
 FUNCTION pol0535_pag(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons1 THEN
       WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta_hist INTO pr_hist.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta_hist INTO pr_hist.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET pr_hist.* = pr_hist1.* 
            EXIT WHILE
         END IF

         SELECT COUNT(cod_item)
           INTO p_count
           FROM revisao_hist_1040
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = pr_hist.cod_item
            
         IF p_count > 0 THEN
            CALL pol0535_exibe_hist()
            EXIT WHILE 
         END IF 
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF
END FUNCTION

#-----------------------------------#
 FUNCTION pol0535_exibe_hist()
#-----------------------------------#
DEFINE l_den_item		LIKE item.den_item,
			 l_den_dados 	LIKE par_revisao_1040.den_dados,
			 l_data_hora CHAR(20) 
			 
	DISPLAY pr_hist.cod_item 			TO cod_item
	SELECT den_item
	INTO l_den_item
	FROM item
	WHERE cod_empresa = p_cod_empresa
	AND cod_item    = pr_hist.cod_item
	{AQUI VAI COLOCAR A DATA NA ORDEM DD-MM-AAAA PARA APRESENTAR PARA O USUÁRIO}
	 SELECT To_Char(dat_hor_alter,'%d')||'/'||To_Char(dat_hor_alter,'%m')||'/'||To_Char(dat_hor_alter,'%Y')||' '||To_Char(dat_hor_alter,'%H')||':'||To_Char(dat_hor_alter,'%M')||':'||To_Char(dat_hor_alter,'%S')
   INTO l_data_hora
   FROM revisao_hist_1040
   WHERE num_sequencia = pr_hist.num_sequencia
   AND cod_empresa = p_cod_empresa
   
	
	DISPLAY l_den_item 						TO den_item
	DISPLAY pr_hist.cod_operacao 	TO cod_operacao
	DISPLAY pr_hist.usuario 			TO usuario
	DISPLAY l_data_hora 					TO dat_hor_alter
	DISPLAY pr_hist.num_sequencia TO num_sequencia
	DISPLAY pr_hist.tipo_dados 		TO tipo_dados
	
	SELECT den_dados
	INTO l_den_dados
	FROM par_revisao_1040
	WHERE cod_empresa = p_cod_empresa
	AND tipo_dados  = pr_hist.tipo_dados 
	
	DISPLAY l_den_dados 					TO den_dados
	DISPLAY pr_hist.rev_processo 	TO rev_processo
	DISPLAY pr_hist.data_rev 			TO data_rev
	DISPLAY pr_hist.hora_rev 			TO hora_rev
	DISPLAY pr_hist.situacao_rev 	TO situacao_rev
	DISPLAY pr_hist.liberacao_rev TO liberacao_rev
END FUNCTION

#-------------------------------#
 FUNCTION pol0535_controle_hist()
#-------------------------------#
	CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol05353") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol05353 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 001
         MESSAGE "" 
         LET INT_FLAG = 0
         
         	CALL pol0535_consulta_hist()
		      IF p_retorno THEN
		         IF p_ies_cons1 THEN
		            NEXT OPTION "Seguinte" 
		         END IF
		     	ELSE
		     		ERROR"Consulta Cancelada!!!"
		     	END IF
		     
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0535_pag("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0535_pag("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 004
         MESSAGE ""
         EXIT MENU
      	
   END MENU
   CLOSE WINDOW w_pol05353

END FUNCTION
#-----------------------------#
FUNCTION pol0535_entrada_par()
#-----------------------------#
DEFINE l_den LIKE item.den_item
CLEAR FORM  
DISPLAY p_cod_empresa TO cod_empresa        
   
	 INITIALIZE pr_consul TO NULL
  	LET pr_consul.data_ini = "01/01/1900"
	LET pr_consul.data_fin = CURRENT
   
INPUT BY NAME pr_consul.* WITHOUT DEFAULTS
	
	AFTER FIELD cod_item
		IF pr_consul.cod_item IS NOT NULL THEN
			SELECT den_item
			INTO l_den
			FROM item
			WHERE cod_empresa = p_cod_empresa
			AND cod_item = pr_consul.cod_item
			IF SQLCA.SQLCODE <> 0 THEN
				ERROR"Item não cadastrado!!"
				NEXT FIELD cod_item
			ELSE
				DISPLAY l_den TO den_item
			END IF
		END IF
		
		AFTER FIELD cod_operacao
			IF pr_consul.cod_operacao IS NOT NULL THEN
				IF pr_consul.cod_operacao = "I" OR pr_consul.cod_operacao = "E" OR pr_consul.cod_operacao = "A" THEN
				ELSE
					ERROR"Valor invalido!!!'I'- inlclusão 'E'- excluir 'A'- alterar!!"
					NEXT FIELD cod_operacao
				END IF
			END IF
			
		AFTER FIELD usuario
			IF pr_consul.usuario IS NOT NULL THEN
				select cod_usuario from usuario_empresa
				where cod_usuario = pr_consul.usuario
				and cod_empresa = p_cod_empresa
				
				IF SQLCA.SQLCODE <> 0 THEN
					ERROR"Usuario não cadastrado!!!"
					NEXT FIELD usuario
				END IF
			END IF 
			
	AFTER FIELD data_ini
			IF pr_consul.data_ini IS NULL THEN
				ERROR"Campo de Preenchimento Obrigatorio"
			END IF
			
	AFTER FIELD data_fin
			IF pr_consul.data_fin IS NULL THEN
				ERROR"Campo de Preenchimento Obrigatorio"
			ELSE 
				IF pr_consul.data_fin< pr_consul.data_ini THEN
					ERROR "Campo Data final tem que sar maior ou igual ao Campo Data inicial"
				END IF
			END IF
	ON KEY(control-z)
			CALL pol0535_popup_hist()
END INPUT

	IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE 
   ELSE
   		INITIALIZE pr_consul TO NULL
      CLEAR FORM
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0535_popup_hist()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05353
         
         IF p_codigo IS NOT NULL THEN
           SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item  = p_codigo
            LET pr_consul.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
           DISPLAY p_den_item TO den_item			
         END IF 
         
     WHEN INFIELD (usuario)
         CALL log009_popup(8,25,"Usuario","usuario_empresa",
              "cod_usuario","cod_usuario","","S","")
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol05353
         IF p_codigo IS NOT NULL THEN
           LET pr_consul.usuario = p_codigo
           DISPLAY p_codigo TO usuario
         END IF
         
         
   END CASE

END FUNCTION




#-------------------------------- FIM DE PROGRAMA -----------------------------#

