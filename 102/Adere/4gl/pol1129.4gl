#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX - PW1                                  #
# PROGRAMA: pol1129                                                 #    
# CLIENTE : ADERE                                                   #                                       
# OBJETIVO: CADASTRO PEÇAS SIMETRICA                                #
# AUTOR...: POLO INFORMATICA - MANUEL                               #
# DATA....: 24/02/2012                                              #
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
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
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
          p_opcao              CHAR(01)
          
   DEFINE p_cod_operac         LIKE ord_oper.cod_operac,
          p_cod_arranjo        LIKE ord_oper.cod_arranjo,
          p_cod_recur          LIKE recurso.cod_recur,
          m_cod_operac         LIKE ord_oper.cod_operac,
          m_cod_recur          LIKE recurso.cod_recur,
          p_num_ordem          INTEGER,
          p_ies_situa          CHAR(01),
          p_cod_item           CHAR(15),
          p_den_item           CHAR(18),
          p_id_registro        INTEGER,
          p_id_registroa       INTEGER,
          m_id_registro        INTEGER
          
   DEFINE p_conjuga RECORD LIKE conjuga_ops_912.*

   DEFINE p_tela      RECORD
    id_registro 			LIKE conjuga_ops_912.id_registro,
    qtd_ciclos_peca   LIKE conjuga_ops_912.qtd_ciclos_peca,
	  dat_inclusao 			LIKE conjuga_ops_912.dat_inclusao,
    hor_inclusao 			LIKE conjuga_ops_912.hor_inclusao,
    nom_usuario   		LIKE conjuga_ops_912.nom_usuario 
   END RECORD 
    
   DEFINE pr_ops        ARRAY[10] OF RECORD
    num_seq     		    LIKE conjuga_ops_912.num_seq,
	  num_ordem 				  LIKE conjuga_ops_912.num_ordem,
    num_seq_operac 	  	LIKE conjuga_ops_912.num_seq_operac,
    qtd_pecas_ciclo    	LIKE conjuga_ops_912.qtd_pecas_ciclo,
	  cod_item     			  LIKE item.cod_item,
	  den_item          	LIKE item.den_item_reduz
   END RECORD

   DEFINE p_consulta  RECORD
    id_registro 			LIKE conjuga_ops_912.id_registro,
	  dat_inclusao 			LIKE conjuga_ops_912.dat_inclusao,
    nom_usuario   		LIKE conjuga_ops_912.nom_usuario, 
    num_ordem         LIKE ordens.num_ordem
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1129-10.02.06"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1129_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1129_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1129") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1129 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1129_envia_hist() then
      RETURN
   END IF
   
   MESSAGE ''
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1129_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1129_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancelada !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1129_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1129_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1129_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1129_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1129_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1129_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1129

END FUNCTION

#-----------------------#
 FUNCTION pol1129_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa \n\n",
               " LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1129_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1129_inclusao()
#--------------------------#

   call pol1129_limpa_tela()
   INITIALIZE p_tela, pr_ops TO NULL
   LET p_opcao = 'I'
   LET p_tela.dat_inclusao = today
   LET p_tela.hor_inclusao = time
   LET p_tela.nom_usuario = p_user
   LET p_tela.id_registro = 0
   
   IF pol1129_edita_cabec() THEN      
      IF pol1129_edita_itens() THEN      
         IF pol1129_grava_dados() THEN                                                     
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1129_edita_cabec()
#-----------------------------#
   
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD qtd_ciclos_peca

      IF p_tela.qtd_ciclos_peca IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD qtd_ciclos_peca   
      END IF
                                       
   END INPUT 

   IF INT_FLAG THEN
      call pol1129_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1129_edita_itens()
#------------------------------#     
  
   INPUT ARRAY pr_ops
      WITHOUT DEFAULTS FROM sr_ops.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

         FOR p_ind = 1 TO ARR_COUNT()  
             display p_ind to sr_ops[p_ind].num_seq
         End For                                                                     
      
      AFTER FIELD num_ordem
        
         IF pr_ops[p_index].num_ordem IS NULL then
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN                       
            Else
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD num_ordem
            End if
         Else
            let p_num_ordem = pr_ops[p_index].num_ordem           
                                                                  
            select ies_situa,                                     
                   cod_item                                       
              into p_ies_situa,                                   
                   p_cod_item                                     
              from ordens                                         
             where cod_empresa = p_cod_empresa                    
               and num_ordem   = p_num_ordem                      
                                                                  
            IF STATUS = 100 THEN                                  
               Error 'Ordem inexistente !!!'                      
               NEXT FIELD num_ordem                                                                           
            Else                                                  
               If status <> 0 then                                
                  CALL log003_err_sql('lendo','ordens')           
                  RETURN FALSE                                    
               End if                                                                                           
            END IF                                                                                              
                                                                  
            IF p_ies_situa MATCHES "[34]" THEN                                                               
            Else                                                  
               Error 'Informe uma ordem aberta ou liberada !!!'                                                             
               NEXT FIELD num_ordem                               
            End if                                                
                                                                  
            call pol1129_le_item()                                
            display p_cod_item to sr_ops[s_index].cod_item        
            display p_den_item to sr_ops[s_index].den_item        
         End if
         
         
      AFTER FIELD num_seq_operac
         IF pr_ops[p_index].num_seq_operac IS NULL or
            pr_ops[p_index].num_seq_operac = 0 then
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD num_seq_operac
         END IF

         SELECT cod_operac,
           from ord_oper
          where cod_empresa    = p_cod_empresa
            and num_ordem      = p_num_ordem
            and num_seq_operac = pr_ops[p_index].num_seq_operac

         IF STATUS = 100 THEN                                                                                 
            Error 'Sequencia de operação não prevista para a ordem !!!'
            NEXT FIELD num_seq_operac
         Else
            If status <> 0 then
               CALL log003_err_sql('lendo','ord_oper')                                                            
               RETURN FALSE                                                                                     
            End if
         END IF                                                                                              
  
         FOR p_ind = 1 TO ARR_COUNT()                                                                        
            IF p_ind <> p_index THEN                                                                            
               IF pr_ops[p_ind].num_ordem = pr_ops[p_index].num_ordem THEN    
                  IF pr_ops[p_ind].num_seq_operac = pr_ops[p_index].num_seq_operac THEN    
                     ERROR "Ordem/operação já informadas na conjugação corrente !!!"                                               
                     NEXT FIELD num_seq_operac   
                  END IF                                                                      
               END IF                                                                                           
            END IF                                                                                              
         END FOR                                                                                                
         
         select id_registro
           into m_id_registro
           from conjuga_ops_912                                                                                                      
          where cod_empresa    = p_cod_empresa
            and num_ordem      = p_num_ordem
            and num_seq_operac = pr_ops[p_index].num_seq_operac 
           
         IF STATUS = 0 THEN   
            If m_id_registro <> p_tela.id_registro then                                                                             
               Error 'Ordem/operação já informadas em outra conjugação !!!'
               NEXT FIELD num_seq_operac
            End if
         Else
            If status <> 100 then
               CALL log003_err_sql('lendo','conjuga_ops_912')                                                            
               RETURN FALSE                                                                                     
            End if
         END IF                                                                                              
           
      AFTER FIELD qtd_pecas_ciclo
         IF pr_ops[p_index].qtd_pecas_ciclo IS NULL or
            pr_ops[p_index].qtd_pecas_ciclo = 0 then
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD qtd_pecas_ciclo
         END IF
      
      AFTER ROW
         IF NOT INT_FLAG THEN                                    
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN                       
            ELSE                     
               IF pr_ops[p_index].num_ordem IS NULL THEN   
                  NEXT FIELD num_ordem                             
               END IF                                           
               IF pr_ops[p_index].num_seq_operac IS NULL THEN   
                  NEXT FIELD num_seq_operac                         
               END IF                                           
               IF pr_ops[p_index].qtd_pecas_ciclo IS NULL THEN   
                  NEXT FIELD qtd_pecas_ciclo                         
               END IF                                           
            END IF                                              
         END IF                                                 

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            
            IF pr_ops[1].num_ordem IS NULL THEN
               ERROR 'Informe pelo menos uma ordem!!!'
               NEXT FIELD num_seq_operac 
            END IF
            
            CALL pol1129_le_ord_oper(
               pr_ops[1].num_ordem, pr_ops[1].num_seq_operac) RETURNING p_status  
            
            IF NOT p_status THEN
               RETURN FALSE
            END IF
            
            {IF p_cod_recur IS NULL THEN
               LET p_msg = 'Recurso da operação da\n',
                           '1ª ordem não cadastrado!!!'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD num_seq_operac 
            END IF}
            
            LET m_cod_operac = p_cod_operac
            LET m_cod_recur  = p_cod_recur
            LET p_count = 0
            
            FOR p_ind = 2 TO ARR_COUNT()  
               IF pr_ops[p_ind].num_ordem IS NOT NULL THEN
                  CALL pol1129_le_ord_oper(
                     pr_ops[p_ind].num_ordem, pr_ops[p_ind].num_seq_operac) RETURNING p_status  
                  IF NOT p_status THEN
                     RETURN FALSE
                  END IF
                  {IF p_cod_recur IS NULL THEN
                     LET p_msg = 'Recurso da operação da\n',
                                 'OP ',pr_ops[p_ind].num_ordem, ' não cadastrado!!!'
                     CALL log0030_mensagem(p_msg,'excla')
                     LET p_count = p_count + 1
                  END IF}
                  IF p_cod_operac <> m_cod_operac THEN
                     LET p_msg = 'Operação da OP ',pr_ops[p_ind].num_ordem, '\n',
                                 'diferente da operação da 1ª ordem.'
                     CALL log0030_mensagem(p_msg,'excla')
                     LET p_count = p_count + 1
                  END IF
                  {IF p_cod_recur <> m_cod_recur THEN
                     LET p_msg = 'Recurso da operação da OP ',pr_ops[p_ind].num_ordem, '\n',
                                 'diferente do recurso da 1ª ordem.'
                     CALL log0030_mensagem(p_msg,'excla')
                     LET p_count = p_count + 1
                  END IF}
               END IF
            END FOR         
                                                                                                   
            IF p_count > 0 THEN
               NEXT FIELD num_seq_operac 
            END IF
            
         END IF
                  
         ON KEY (control-z)
            CALL pol1129_popup()
                 
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      IF p_opcao = 'I' THEN
         call pol1129_limpa_tela()
      ELSE
         CALL pol1129_carrega_itens() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
         
END FUNCTION

#----------------------------------------#
FUNCTION pol1129_le_ord_oper(p_op, p_seq)
#----------------------------------------#

   DEFINE p_op  like ord_oper.num_ordem,
          p_seq like ord_oper.num_seq_operac,
          p_achou char(01)
          
   SELECT cod_operac,
          cod_arranjo
     INTO p_cod_operac,
          p_cod_arranjo
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
      AND num_ordem      = p_op
      AND num_seq_operac = p_seq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ord_oper')
      RETURN FALSE
   END IF
{
   LET p_achou = 'N'
   
   DECLARE cq_recurso CURSOR FOR
    SELECT a.cod_recur
      FROM rec_arranjo a, recurso b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_arranjo = p_cod_arranjo
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_recur   = a.cod_recur
       AND b.ies_tip_recur = '2'

   FOREACH cq_recurso INTO p_cod_recur
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','recurso')
         RETURN FALSE
      END IF

      LET p_achou = 'S'
      EXIT FOREACH
   
   END FOREACH
   
   IF p_achou = 'N' THEN
      LET p_cod_recur = NULL
   END IF
}
   RETURN TRUE
   
END FUNCTION

      
   

#------------------------#
FUNCTION pol1129_le_item()
#------------------------#

   select den_item_reduz
     into p_den_item
     from item
    where cod_empresa = p_cod_empresa
      and cod_item    = p_cod_item

   if STATUS <> 0 then
      RETURN p_den_item = ''
   end if

end FUNCTION

#-----------------------#
 FUNCTION pol1129_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
   
      WHEN INFIELD(num_seq_operac)
         LET p_codigo = pol1129_le_operacao()
         CLOSE WINDOW w_pol11291
         IF p_codigo IS NOT NULL THEN
            LET pr_ops[p_index].num_seq_operac = p_codigo
            DISPLAY p_codigo TO sr_ops[s_index].num_seq_operac
         END IF
   
   END CASE

END FUNCTION 

#-----------------------------#
 FUNCTION pol1129_le_operacao()
#-----------------------------#

   DEFINE pr_operacs  ARRAY[20] OF RECORD
          cod_operac      LIKE operacao.cod_operac,
          num_seq_operac  LIKE ord_oper.num_seq_operac,
          den_operac      LIKE operacao.den_operac
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11291") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11291 AT 5,16 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_operacs CURSOR FOR
    SELECT a.cod_operac,
           a.num_seq_operac,
           b.den_operac
      FROM ord_oper a, operacao b
     where a.cod_empresa = p_cod_empresa
       and a.num_ordem   = p_num_ordem
       and b.cod_empresa = a.cod_empresa
       and b.cod_operac  = a.cod_operac
     ORDER BY a.num_seq_operac

   FOREACH cq_operacs
      INTO pr_operacs[p_ind].cod_operac,   
           pr_operacs[p_ind].num_seq_operac,   
           pr_operacs[p_ind].den_operac   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','operações:cq_operacs')
         RETURN ''
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 20 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
   
   If p_ind = 1 then
      LET p_msg = 'Ordem sem as operaçoes correspondentes !!!'
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN ''
   End if
        
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_operacs TO sr_operacs.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol11291
   
   IF NOT INT_FLAG THEN
      RETURN pr_operacs[p_ind].num_seq_operac
   ELSE
      RETURN ""
   END IF
   
END FUNCTION


#-----------------------------#
 FUNCTION pol1129_grava_dados()
#-----------------------------#
   
   CALL log085_transacao("BEGIN")
   
   If p_opcao = 'I' then  
      SELECT max(id_registro)
        into p_id_registro
        FROM conjuga_ops_912
       where cod_empresa = p_cod_empresa
      
      if STATUS <> 0 then
         call log003_err_sql('Lendo','conjuga_ops_912')
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      end If
      
      if p_id_registro is null then
         let p_id_registro = 1
      else
         let p_id_registro = p_id_registro + 1
      end if
      
      let p_tela.id_registro = p_id_registro
      display p_tela.id_registro to id_registro
   else
      DELETE FROM conjuga_ops_912
       WHERE cod_empresa = p_cod_empresa
         and id_registro = p_tela.id_registro
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Deletando", "conjuga_ops_912")
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF 
   End if
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_ops[p_ind].num_ordem IS NOT NULL THEN
          
		       INSERT INTO conjuga_ops_912
		       VALUES (p_cod_empresa,
		               p_tela.id_registro,
		               p_ind,
		               pr_ops[p_ind].num_ordem,
		               pr_ops[p_ind].num_seq_operac,
		               p_tela.qtd_ciclos_peca,
		               pr_ops[p_ind].qtd_pecas_ciclo,
		               p_tela.dat_inclusao,
		               p_tela.hor_inclusao,
		               p_tela.nom_usuario)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "conjuga_ops_912")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#--------------------------#
FUNCTION pol1129_consulta()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11292") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11292 AT 8,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_id_registroa = p_id_registro

   If NOT pol1129_aceita_param() then
      Call pol1129_cancela_consulta()
      RETURN FALSE
   End if

   If NOT pol1129_achou_dados() then
      Call pol1129_cancela_consulta()
      RETURN FALSE
   End if

   IF not pol1129_exibe_dados() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1129_cancela_consulta()
#---------------------------------#

   IF p_ies_cons THEN 
      LET p_id_registro = p_id_registroa
      CALL pol1129_exibe_dados() RETURNING p_status
   END IF    

End FUNCTION


#-----------------------------#
FUNCTION pol1129_aceita_param()
#-----------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE p_consulta to null
   
   INPUT BY NAME p_consulta.* WITHOUT DEFAULTS

      AFTER FIELD id_registro

      IF p_consulta.id_registro IS not NULL THEN 
         SELECT count(id_registro)
           into p_count
           from conjuga_ops_912
          where cod_empresa = p_cod_empresa
            and id_registro = p_consulta.id_registro
         
         if p_count = 0 then
            ERROR 'Conjugação inexistente !!!'
            NEXT FIELD id_registro   
         end if
         EXIT INPUT
      Else
         LET p_consulta.id_registro = 0
      END IF

      AFTER FIELD num_ordem

      IF p_consulta.num_ordem IS not NULL THEN 
         SELECT count(num_ordem)
           into p_count
           from conjuga_ops_912
          where cod_empresa = p_cod_empresa
            and num_ordem = p_consulta.num_ordem
         
         if p_count = 0 then
            ERROR 'Ordem sem conjugação !!!'
            NEXT FIELD num_ordem   
         end if
         EXIT INPUT
      END IF
                                       
   END INPUT 

   CLOSE WINDOW w_pol11292

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE   

End FUNCTION

#-----------------------------#
FUNCTION pol1129_achou_dados()
#-----------------------------#

   DEFINE p_query CHAR(600)
   
   LET p_query = 
   "SELECT DISTINCT id_registro FROM conjuga_ops_912 ",
   " WHERE cod_empresa  = '",p_cod_empresa,"' "
   
   IF p_consulta.id_registro > 0  THEN
      LET p_query = p_query CLIPPED, "   AND id_registro = '",p_consulta.id_registro,"' "
   END IF   

   IF p_consulta.dat_inclusao IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND dat_inclusao = '",p_consulta.dat_inclusao,"' "
   END IF

   IF p_consulta.nom_usuario IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND nom_usuario LIKE '","%",p_consulta.nom_usuario CLIPPED,"%","' "
   END IF

   IF p_consulta.num_ordem IS NOT NULL THEN
      LET p_query = p_query CLIPPED, "   AND num_ordem = '",p_consulta.num_ordem,"' "
   END IF   
   
   LET p_query = p_query CLIPPED, " ORDER BY id_registro "
        
   PREPARE var_query FROM p_query   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro

   IF STATUS = NOTFOUND THEN
      LET p_msg = "Argumentos de pesquisa\n",
                  "não encontrados !!!\n"
      CALL log0030_mensagem(p_msg,"exclamation")
      LET p_ies_cons = FALSE
   Else
      LET p_ies_cons = TRUE
   End if
       
   RETURN p_ies_cons

End FUNCTION

#------------------------------#
 FUNCTION pol1129_exibe_dados()
#------------------------------#
   
   DECLARE cq_cabc CURSOR FOR
    SELECT id_registro,
           qtd_ciclos_peca,
           dat_inclusao,   
           hor_inclusao,   
           nom_usuario    
      FROM conjuga_ops_912
     WHERE cod_empresa = p_cod_empresa
       and id_registro = p_id_registro
   
   FOREACH cq_cabc 
      INTO p_tela.id_registro,    
           p_tela.qtd_ciclos_peca,
           p_tela.dat_inclusao,   
           p_tela.hor_inclusao,
           p_tela.nom_usuario
   
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('lendo','conjuga_ops_912:cq_cabc')
         RETURN FALSE 
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   DISPLAY BY NAME p_tela.*
   
   If NOT pol1129_carrega_itens() then
      RETURN FALSE
   End if
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1129_carrega_itens()
#------------------------------#
      
   INITIALIZE pr_ops TO NULL
   
   LET p_index = 1
   
   DECLARE cq_array CURSOR FOR
   
    SELECT num_seq,
           num_ordem,      
           num_seq_operac, 
           qtd_pecas_ciclo
      FROM conjuga_ops_912
     WHERE cod_empresa = p_cod_empresa
       and id_registro = p_id_registro
     ORDER BY num_seq
     
   FOREACH cq_array
      INTO pr_ops[p_index].num_seq,
           pr_ops[p_index].num_ordem,
           pr_ops[p_index].num_seq_operac,
           pr_ops[p_index].qtd_pecas_ciclo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "conjuga_ops_912:cq_array")
         RETURN FALSE
      END IF
      
      select cod_item                                       
        into p_cod_item                                     
        from ordens                                         
       where cod_empresa = p_cod_empresa                    
         and num_ordem   = pr_ops[p_index].num_ordem                      
                                                                  
      If status <> 0 then                                
         CALL log003_err_sql('lendo','ordens')           
         RETURN FALSE                                    
      END IF                                                                                              
            
      CALL pol1129_le_item()
      
      LET pr_ops[p_index].cod_item = p_cod_item
      LET pr_ops[p_index].den_item = p_den_item
      
      LET p_index = p_index + 1
      
      IF p_index > 20 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   
   IF p_index > 10 THEN
      DISPLAY ARRAY pr_ops TO sr_ops.*
   ELSE
      INPUT ARRAY pr_ops WITHOUT DEFAULTS FROM sr_ops.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
   
   RETURN TRUE
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol1129_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_id_registroa = p_id_registro

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_id_registro
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_id_registro
         
      END CASE

      IF STATUS = 0 THEN
         SELECT COUNT(id_registro)
           INTO p_count
           FROM conjuga_ops_912
          WHERE cod_empresa = p_cod_empresa
            and id_registro = p_id_registro
                        
         IF p_count > 0 THEN   
            CALL pol1129_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         ERROR "Não existem mais itens nesta direção !!!"
         LET p_id_registro = p_id_registroa
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1129_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT id_registro 
      FROM conjuga_ops_912  
     WHERE cod_empresa = p_cod_empresa
       and id_registro = p_id_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","evento_265")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1129_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   
   IF pol1129_prende_registro() THEN
    If pol1129_edita_cabec() then
      IF pol1129_edita_itens() THEN
         IF pol1129_grava_dados() THEN
            LET p_retorno = TRUE
         END IF
      END IF
    End if
    CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol1129_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1129_prende_registro() THEN
      DELETE FROM conjuga_ops_912
       WHERE cod_empresa = p_cod_empresa
         and id_registro = p_id_registro
    
      IF STATUS = 0 THEN
         LET p_retorno = TRUE                       
         Call pol1129_limpa_tela()
      Else
         CALL log003_err_sql("Deletando", "conjuga_ops_912")
      END IF 
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1129_listagem()
#--------------------------#     

   IF NOT pol1129_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1129_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM conjuga_ops_912
     WHERE cod_empresa = p_cod_empresa
  ORDER BY id_registro
  
   FOREACH cq_impressao INTO p_conjuga.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 

      select cod_item                                       
        into p_cod_item                                     
        from ordens                                         
       where cod_empresa = p_cod_empresa                    
         and num_ordem   = p_conjuga.num_ordem                      
                                                                  
      If status = 0 then                                
         call pol1129_le_item()
      Else
         let p_den_item = ''
      END IF                                                                                              
      
   OUTPUT TO REPORT pol1129_relat(p_conjuga.id_registro) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1129_relat   
   
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1129_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1129.tmp"
         START REPORT pol1129_relat TO p_caminho
      ELSE
         START REPORT pol1129_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1129_le_den_empresa()
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

#---------------------------------#
 REPORT pol1129_relat(p_conjugacao)
#---------------------------------#
    
   DEFINE p_conjugacao LIKE conjuga_ops_912.id_registro
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
   
   ORDER EXTERNAL BY p_conjugacao
         
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1129",
               COLUMN 013, "CONJUGACAO DE ORDENS DE PRODUCAO",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
               
      BEFORE GROUP OF p_conjugacao
         
         PRINT

         PRINT COLUMN 001, "Conjugacao:", 
               COLUMN 013, p_conjugacao USING "########",
               COLUMN 023, "Ciclo peca:",
               COLUMN 035, p_conjuga.qtd_ciclos_peca USING "##",
               COLUMN 039, "Inclusao:",
               COLUMN 049, p_conjuga.dat_inclusao USING "dd/mm/yy",
               COLUMN 058, p_conjuga.hor_inclusao,
               COLUMN 067, "Resp: ", p_conjuga.nom_usuario
         PRINT
         PRINT COLUMN 001, '     SEQ   ORDEM    SEQ OPER PECA CICLO      ITEM           DESCRICAO'
         PRINT COLUMN 001, '     --- ---------- -------- ---------- --------------- ------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 006, p_conjuga.num_seq         USING "###",
               COLUMN 010, p_conjuga.num_ordem       USING "##########",   
               COLUMN 021, p_conjuga.num_seq_operac  USING "########",
               COLUMN 030, p_conjuga.qtd_pecas_ciclo USING "##########", 
               COLUMN 041, p_cod_item,
               COLUMN 057, p_den_item

      AFTER GROUP OF p_conjugacao

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#----------------------------#
FUNCTION pol1129_envia_hist()
#----------------------------#

   DEFINE p_ies_move SMALLINT
   
   MESSAGE 'AGUARDE!... MOVENDO OPs ENCERRADAS/CANCELADAS P/ HISTÓRICO.'
   
   DECLARE cq_hist CURSOR WITH HOLD FOR
    SELECT DISTINCT id_registro
      FROM conjuga_ops_912
     WHERE cod_empresa = p_cod_empresa
     ORDER BY id_registro
  
  FOREACH cq_hist into p_id_registro
     
     IF STATUS <> 0 THEN 
        CALL log003_err_sql('Lendo','conjuga_ops_912:cq_hist')
        RETURN FALSE
     END IF
      
     LET p_ies_move = TRUE
       
     DECLARE cq_ops CURSOR FOR
      SELECT DISTINCT num_ordem
        FROM conjuga_ops_912
       WHERE cod_empresa = p_cod_empresa
         AND id_registro = p_id_registro

      FOREACH cq_ops INTO p_num_ordem
         
        IF STATUS <> 0 THEN 
           CALL log003_err_sql('Lendo','conjuga_ops_912:cq_ops')
           RETURN FALSE
        END IF
        
        SELECT ies_situa
          INTO p_ies_situa
          FROM ordens
         WHERE cod_empresa = p_cod_empresa
           AND num_ordem   = p_num_ordem

        IF STATUS <> 0 THEN 
           CALL log003_err_sql('Lendo','ordens:cq_ops')
           RETURN FALSE
        END IF
        
        IF p_ies_situa MATCHES '[59]' THEN
        ELSE
           LET p_ies_move = FALSE
           EXIT FOREACH
        END IF
     
     END FOREACH
     
     IF not p_ies_move THEN
        CONTINUE FOREACH
     END IF
  
     CALL log085_transacao("BEGIN")
     
     INSERT INTO conj_hist_ops_912
      SELECT * FROM conjuga_ops_912
      WHERE cod_empresa = p_cod_empresa
        AND id_registro = p_id_registro
     
     IF STATUS <> 0 THEN 
        CALL log003_err_sql('Inserindo','conj_hist_ops_912')
        CALL log085_transacao("ROLLBACK")
        RETURN FALSE
     END IF

     DELETE FROM conjuga_ops_912
      WHERE cod_empresa = p_cod_empresa
        AND id_registro = p_id_registro
        
     IF STATUS <> 0 THEN 
        CALL log003_err_sql('Deletando','conjuga_ops_912')
        CALL log085_transacao("ROLLBACK")
        RETURN FALSE
     END IF
     
     CALL log085_transacao("COMMIT")
     
  END FOREACH

END FUNCTION
     