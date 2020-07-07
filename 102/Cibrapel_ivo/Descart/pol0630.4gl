
DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),
          p_msg                CHAR(300),
          p_num_ordem          integer,
          p_dat_txt            char(10),
          p_num_op             char(10),
          p_num_transac_orig   integer,
          p_cod_local          char(15)
          
   DEFINE p_dat_fecha_ult_man  datetime year to day,
          p_dat_fecha_ult_sup  datetime year to day,
          p_dat_baixa          datetime year to day,
          p_dat_atual          datetime year to second,
          p_cod_oper_insp      CHAR(04),
          p_cod_emp_ofic       char(02),
          p_cod_emp_ger        char(02),
          p_num_transac        integer,
          p_dat_consumo        date,
          p_dat_prod           date,
          p_num_docum          char(15),
          p_criticou           SMALLINT,
          p_cod_operacao       char(04),
          p_num_conta          char(25)
   
   DEFINE p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*
   
   DEFINE p_aparas        RECORD 
          cod_item        char(15),
          num_lote        char(15),
          qtd_movto       decimal(10,3),
          num_nf          integer,
          dat_movto       datetime year to day,
          estatus         integer
   END RECORD

   DEFINE p_tela          RECORD 
          cod_operacao    char(04),
          den_operacao    char(30)
   END RECORD
    

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "pol0630-05.10.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0630.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0630_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0630_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0630") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0630 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
      
   if p_cod_empresa = 'O2' or p_cod_empresa = '02' then
   else
      let p_cod_empresa = '02'
   end if
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Processar" "Inicia o processamento"
         IF log004_confirm(18,35) THEN      
            call pol0630_processa() RETURNING p_status
            IF p_status THEN
               ERROR "Operação Efetuada c/ Sucesso !!!"
            ELSE
               ERROR "Operação Cancelada !!!"
               CALL log0030_mensagem(p_msg,'excla')
            end if
         else
            error "Operação cancelada!"
         END IF      
      COMMAND "Consultar" "Consulta lotes criticados"
         call pol0630_consulta() RETURNING p_status
         CLOSE WINDOW w_pol06301
         if p_status then
            ERROR 'Consulta efetuada com sucesso!'
         else
            ERROR 'Operação cancelada!'
         end if
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
   CLOSE WINDOW w_pol0630

END FUNCTION


#--------------------------#
FUNCTION pol0630_informar()
#--------------------------#

   let p_ies_cons = false
   let INT_FLAG = false
   
   SELECT cod_estoque_sp    
     INTO p_tela.cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
     let p_msg = 'Erro ', status, ' Lendo par_pcp'
     CALL log0030_mensagem(p_msg,'excla')
     RETURN FALSE
   END IF

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
   
      AFTER FIELD cod_operacao
         IF p_tela.cod_operacao IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_operacao   
         END IF

         select den_operacao
           into p_tela.den_operacao 
           from estoque_operac
          where cod_empresa  = p_cod_empresa
            and cod_operacao = p_tela.cod_operacao
            and ies_tipo     = 'S'

         IF STATUS = 100 THEN
            error 'Operação enexistente ou não é de saída!'
            NEXT FIELD cod_operacao   
         else
            if status <> 0 then
               let p_msg = 'Erro ', status, ' Lendo estoque_operac'
               CALL log0030_mensagem(p_msg,'excla')
               RETURN FALSE
            end if
         END IF

   END INPUT 


   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   let p_ies_cons = true
   
   RETURN TRUE

END FUNCTION

                    
#----------------------------#
FUNCTION pol0630_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
   ELSE
      IF STATUS <> 100 THEN
         let p_msg = 'Erro ', status, ' Lendo empresas_885'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            let p_msg = 'Erro ', status, ' Lendo empresas_885'
            CALL log0030_mensagem(p_msg,'excla')
            RETURN FALSE
         END IF
      END IF
   END IF
   
   LET p_cod_empresa = p_cod_emp_ofic 
   
   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_emp_ofic
           
   IF STATUS <> 0 THEN 
      let p_msg = 'Erro ', status, ' Lendo par_estoque'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF 

   SELECT cod_operac_estoq_l
     INTO p_cod_oper_insp
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
      
   IF STATUS <> 0 THEN
      let p_msg = 'Erro ', status, ' Lendo par_sup'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   RETURN TRUE 

END FUNCTION

#--------------------------#
function pol0630_processa()
#--------------------------#

   if not pol0630_le_empresa() then
      return false
   end if
   
   let p_num_ordem = 0
   
   declare cq_proces CURSOR WITH HOLD FOR
    select coditem,
           codlote,
           saldologix,
           nf_datamovto                                                         s
      from aparas_esp_885
     where estatus = 0
   
   foreach cq_proces into
      p_aparas.cod_item,
      p_aparas.num_lote,
      p_aparas.qtd_movto,
      p_aparas.dat_movto
   
      if status <> 0 then
         let p_msg = 'Erro ', status, ' Lendo aparas_esp_885'
         return false
      end if
      
      delete from aparas_erro_885
       where coditem = p_aparas.cod_item
         and codlote = p_aparas.num_lote

      if status <> 0 then
         let p_msg = 'Erro ', status, ' Deletando aparas_erro_885'
         return false
      end if
      
      let p_cod_empresa = p_cod_emp_ofic
      Let p_aparas.estatus = 1
      let p_dat_consumo = p_aparas.dat_movto    
      let p_dat_txt = p_aparas.dat_movto
      let p_num_op = p_dat_txt[1,4], p_dat_txt[6,7]
      let p_num_ordem = p_num_op
      
      select cod_local_estoq
        into p_cod_local
        from item
       where cod_empresa = p_cod_empresa
         and cod_item    = p_aparas.cod_item

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS DA TAB ITEM'  
         RETURN FALSE
      end if
      
      select *   
        into p_estoque_lote_ender.*
        from estoque_lote_ender    
       where cod_empresa = p_cod_empresa
         and cod_item    = p_aparas.cod_item
         and num_lote    = p_aparas.num_lote
         and cod_local   = p_cod_local
   
      If status = 100 then
         LET p_msg = 'Lote inexistente no logix'
         IF NOT pol0630_grava_erro() THEN
            RETURN FALSE
         END IF
      else      
         IF STATUS = 0 THEN
            if not pol0630_consiste_consu() then
               RETURN false
            end if
         else
            LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS DA TAB ESTOQUE_LOTE_ENDER'  
            RETURN FALSE
         end if
      end if
     
      CALL log085_transacao("BEGIN")  

      IF p_criticou then
      else
         if not pol0630_baixa_item() then
            CALL log085_transacao("ROLLBACK")  
            RETURN false
         end if
      end if
      
      if not pol0630_atu_aparas_esp() then     
         CALL log085_transacao("ROLLBACK")                                                      
         RETURN false                                                                              
      end if                                                                                       

      CALL log085_transacao("COMMIT")  
      
   end foreach
 
   RETURN true

END FUNCTION

#-------------------------------#
FUNCTION pol0630_consiste_consu()
#-------------------------------#
   
   let p_dat_baixa = p_aparas.dat_movto
   
   IF p_dat_baixa <= p_dat_fecha_ult_man THEN
      LET p_msg = 'Data de consumo com manufatura fechada!'
      IF NOT pol0630_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
                     
   IF p_dat_baixa <= p_dat_fecha_ult_sup THEN
      ERROR 'Data de consumo com suprimento fechado!'
      IF NOT pol0630_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
{   
   SELECT MAX(num_transac)
     INTO p_num_transac
     FROM estoque_trans
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_aparas.cod_item
      AND num_docum     = p_num_docum
      AND num_lote_dest = p_aparas.num_lote
      AND ies_tip_movto = 'N'
      AND cod_operacao  = p_cod_oper_insp
      
   IF p_num_transac IS NULL THEN
      LET p_msg = 'ITEM/LOTE SEM MOVIMENTO DE ENTRADA NO LOGIX'
      IF NOT pol0630_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT dat_movto
        INTO p_dat_prod
        FROM estoque_trans
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
        
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DATA DE ENTRADA DO LOTE'  
         RETURN FALSE
      ELSE
         IF p_dat_prod > p_dat_consumo THEN
            LET p_msg = 'DATA DO CONSUMO < DATA DE ENTRADA NO LOGIX'
            IF NOT pol0630_grava_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF 
   end if
}        
   RETURN TRUE

END FUNCTION


#-----------------------------#
 FUNCTION pol0630_grava_erro()
#-----------------------------#

   LET p_criticou = TRUE
   Let p_aparas.estatus = 3

   INSERT INTO aparas_erro_885
      VALUES (p_aparas.cod_item,
              p_aparas.num_lote,   
              p_aparas.dat_movto,
              p_msg)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA BAIXA_ERRO_885'
      RETURN FALSE
   END IF                                           
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0630_atu_aparas_esp()
#-------------------------------#

   update aparas_esp_885
      set estatus = p_aparas.estatus
    where coditem = p_aparas.cod_item
      and codlote = p_aparas.num_lote

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS DA TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   end if

   RETURN true

END FUNCTION



#-----------------------------#
FUNCTION pol0630_baixa_item()
#-----------------------------#

   if not pol0630_atu_estoque() then                                                         
      RETURN false                                                                              
   end if                                                                                       

   if not pol0630_insere_movimento() then                                                         
      RETURN false                                                                              
   end if                                                                                       
                                                                                                
   RETURN TRUE

END FUNCTION            

#-----------------------------#
function pol0630_atu_estoque()
#-----------------------------#
   
   define p_qtd_liberada  like estoque.qtd_liberada,
          p_qtd_rejeitada like estoque.qtd_rejeitada,
          p_qtd_lib_excep like estoque.qtd_lib_excep
                    
   select qtd_liberada,
          qtd_rejeitada,
          qtd_lib_excep
     into p_qtd_liberada,
          p_qtd_rejeitada,
          p_qtd_lib_excep
     from estoque
    where cod_empresa = p_cod_empresa
      and cod_item    = p_aparas.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS DA TAB ESTOQUE'  
      RETURN FALSE
   end if
      
   if p_estoque_lote_ender.ies_situa_qtd = 'L' then    
      let p_qtd_liberada = p_qtd_liberada - p_estoque_lote_ender.qtd_saldo
   else
      if p_estoque_lote_ender.ies_situa_qtd = 'R' then    
         let p_qtd_rejeitada = p_qtd_rejeitada - p_estoque_lote_ender.qtd_saldo
      else
         let p_qtd_lib_excep = p_qtd_lib_excep - p_estoque_lote_ender.qtd_saldo
      end if
   end if
   
   if p_qtd_liberada < 0 then
      let p_qtd_liberada = 0
   end if
   
   if p_qtd_rejeitada < 0 then
      let p_qtd_rejeitada = 0
   end if

   if p_qtd_lib_excep < 0 then
      let p_qtd_lib_excep = 0
   end if
   
   update estoque
      set qtd_liberada = p_qtd_liberada,
          qtd_rejeitada = p_qtd_rejeitada,  
          qtd_lib_excep = p_qtd_lib_excep
    where cod_empresa = p_cod_empresa
      and cod_item    = p_aparas.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE'  
      RETURN FALSE
   end if      
   
   delete from estoque_lote   
    where cod_empresa = p_cod_empresa
      and cod_item    = p_aparas.cod_item
      and num_lote    = p_aparas.num_lote
      and cod_local   = p_cod_local

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE'  
      RETURN FALSE
   end if      

   delete from estoque_lote_ender    
    where cod_empresa = p_cod_empresa
      and cod_item    = p_aparas.cod_item
      and num_lote    = p_aparas.num_lote
      and cod_local   = p_cod_local

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   end if      
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
function pol0630_insere_movimento()
#----------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01)
   
   INITIALIZE p_estoque_trans.* TO NULL

   SELECT cod_estoque_sp    
     INTO p_cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB PAR_PCP'  
     RETURN FALSE
   END IF
   
   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO tab estoque_operac'
     RETURN FALSE
   END IF

   IF p_ies_com_detalhe = 'S' THEN 
      SELECT num_conta_debito 
        INTO p_num_conta
        FROM estoque_operac_ct
       WHERE cod_empresa  = p_cod_empresa
         AND cod_operacao = p_cod_operacao
      IF STATUS <> 0 THEN
        LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB estoque_operac_ct'
        RETURN FALSE
      END IF
   ELSE
      LET p_num_conta = NULL
   END IF
      
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_aparas.cod_item
   LET p_estoque_trans.dat_movto          = p_aparas.dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_aparas.dat_movto
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.ies_tip_movto      = "N"
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "POL0977"
   LET p_estoque_trans.num_docum          = p_num_ordem
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.qtd_movto          = p_estoque_lote_ender.qtd_saldo
   LET p_estoque_trans.ies_sit_est_orig   = p_estoque_lote_ender.ies_situa_qtd
   LET p_estoque_trans.ies_sit_est_dest   = NULL
   LET p_estoque_trans.cod_local_est_orig = p_estoque_lote_ender.cod_local
   LET p_estoque_trans.cod_local_est_dest = NULL
   LET p_estoque_trans.num_lote_orig      = p_estoque_lote_ender.num_lote
   LET p_estoque_trans.num_lote_dest      = NULL

   IF NOT pol0977_grava_trans() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0977_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0977_grava_trans()
#----------------------------#

    INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS'  
     RETURN FALSE
   END IF

   LET p_num_transac_orig = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0977_ins_est_trans_end()
#------------------------------------#

   let p_dat_atual = current

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.num_transac      = p_num_transac_orig
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = ' '
   LET p_estoque_trans_end.tex_reservado    = " "

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS_END'  
     RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, p_num_transac_orig, p_user, p_dat_atual,'POL0977')

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_AUDITORIA'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0630_consulta()
#--------------------------#

   DEFINE p_query    char(600), 
          p_where    char(600),
          p_cod_item char(15),
          p_num_lote char(15)
          
   DEFINE pr_critica       ARRAY[5000] OF RECORD
          cod_item          char(15),
          num_lote          char(15),
          mensagem          char(70)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol06301") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol06301 AT 5,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_index = 1
   
   CONSTRUCT BY NAME p_where ON 
      aparas_esp_885.coditem,
      aparas_esp_885.codlote
      
   IF INT_FLAG THEN
      RETURN false
   END IF

   LET p_query = 
      "SELECT coditem, codlote",
      "  FROM aparas_esp_885 ",
      " WHERE ", p_where CLIPPED,
      "   AND estatus = 3 ",
      " ORDER BY coditem, codlote"

   PREPARE var_cons FROM p_query   
   DECLARE cq_cons  SCROLL CURSOR WITH HOLD FOR var_cons

   FOREACH cq_cons INTO p_cod_item, p_num_lote

      IF STATUS <> 0 THEN
         let p_msg = 'Erro ', status, ' Lendo aparas_esp_885:cq_cons'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF

      declare cq_erros cursor for
       select mensagem
         from aparas_erro_885
        where coditem = p_cod_item
          and codlote = p_num_lote
      FOREACH cq_erros into
         pr_critica[p_index].mensagem

         IF STATUS <> 0 THEN
            let p_msg = 'Erro ', status, ' Lendo aparas_erro_885:cq_erros'
            CALL log0030_mensagem(p_msg,'excla')
            RETURN FALSE
         END IF
         
         let pr_critica[p_index].cod_item = p_cod_item
         let pr_critica[p_index].num_lote = p_num_lote
       
         LET p_index = p_index + 1
      
         IF p_index > 5000 THEN
            LET p_msg = 'Limite de linhas da grade ultrapassado!'
            CALL log0030_mensagem(p_msg,'excla')
            EXIT FOREACH
         END IF
      END FOREACH
           
   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Nenhum registro foi encontrado, para os parâmetros informados!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_critica TO sr_critica.*
         
   RETURN TRUE
      
END FUNCTION

