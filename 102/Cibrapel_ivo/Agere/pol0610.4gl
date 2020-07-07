#-------------------------------------------------------------------#
# OBJETIVO: RELATÓRIO DE MANUTENÇÃO                                 #
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
          P_comprime           CHAR(01),
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
          p_ies_info           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_cod_tipo           char(01),
          p_custo_total        decimal(10,2),
          p_den_total          char(45),
          p_quebra             INTEGER,
          p_tot_cust           decimal(11,2),
          p_tot_tipo           decimal(12,2),
          p_tot_ger            decimal(13,2)
          
   define p_cod_item           LIKE aviso_rec.cod_item,       
          p_pre_unit           LIKE aviso_rec.pre_unit_nf, 
          p_num_oc             LIKE aviso_rec.num_oc,
          p_qtd_recebida       LIKE aviso_rec.qtd_recebida,   
          p_den_item           LIKE item.den_item,
          p_num_seq            LIKE aviso_rec.num_seq,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_num_docum          LIKE estoque_trans.num_docum,
          p_num_conta          LIKE estoque_trans.num_conta,
          p_gru_ctr_estoq      LIKE item.gru_ctr_estoq,
          p_cod_familia        LIKE item.cod_familia,
          p_num_reserva        LIKE estoque_loc_reser.num_reserva,
          p_cod_uni_funcio     LIKE estoque_loc_reser.cod_uni_funcio,
          p_fat_conversao      like ordem_sup.fat_conver_unid,
          p_cod_cent_cust      like cad_cc.cod_cent_cust,
          p_nom_cent_cust      like cad_cc.nom_cent_cust
                       
   DEFINE p_tela               RECORD 
          dat_inicial          DATE,
          dat_final            DATE
   END RECORD  

   DEFINE p_relat              RECORD 
          cod_tipo             char(01),
          cod_item             char(15),
          den_item             char(40),
          cod_cent_cust        decimal(4,0),
          nom_cent_cust        char(40),
          qtd_movto            decimal(10,3),
          pre_unit             decimal(10,2),
          custo_total          decimal(11,2)
   END RECORD  
   
END GLOBALS

   DEFINE sql_stmt             CHAR(600)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0610-05.10.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
     RETURNING p_status, p_cod_empresa, p_user    
    
   IF p_status = 0 THEN
      CALL pol0610_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol0610_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0610") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0610 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0610_le_empresa() THEN
      RETURN
   END IF

   CALL pol0610_limpa_tela()

   IF NOT pol0610_cria_tab_tmp() THEN
      RETURN
   END IF
      
   LET p_ies_info = FALSE  
   
   MENU "OPCAO"
      COMMAND "Informar" "Informe parâmetros para listados."
         CALL pol0610_Informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso!!!'
            LET p_ies_info = TRUE
            NEXT OPTION "Listar" 
         ELSE
            LET p_ies_info = FALSE
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Listar" "Listar do relatório de manutenção"
         IF p_ies_info THEN
            if pol0610_listar() then
               error 'Operação efetuada com sucesso!'
            else
               error 'Opração cancelada!'
            end if
         ELSE
            ERROR "Informe primeiro os parâmetros!!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa."
         CALL pol0610_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0610

END FUNCTION

#-----------------------#
FUNCTION pol0610_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
    
#----------------------------#
FUNCTION pol0610_le_empresa()
#----------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   RETURN TRUE 

END FUNCTION
  
#----------------------------#
 FUNCTION pol0610_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
      
#-----------------------------#
FUNCTION pol0610_cria_tab_tmp()
#-----------------------------#

   DROP TABLE w_pol0610_885
   
   CREATE  TABLE w_pol0610_885
     (       
      cod_tipo        CHAR(01),
      cod_cent_cust   DECIMAL(4,0),
      nom_cent_cust   CHAR(50),
      cod_item        CHAR(15),
      qtd_movto       DECIMAL(10,3),
      pre_unit        DECIMAL(17,6)
     );
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("criando","w_pol0610_885")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#--------------------------#
 FUNCTION pol0610_Informar()
#--------------------------#
      
   CALL pol0610_limpa_tela()
   
   INITIALIZE p_tela TO NULL
   
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
   
   AFTER FIELD dat_inicial
      IF p_tela.dat_inicial IS NULL THEN
         ERROR "Campo com prenchimento obrigatório !!!"
         NEXT FIELD dat_inicial
      END IF

      NEXT FIELD dat_final
      
   AFTER FIELD dat_final
      IF p_tela.dat_final IS NULL THEN
         ERROR "Campo com prenchimento obrigatório !!!"
         NEXT FIELD dat_final
      END IF
      
      IF p_tela.dat_inicial > p_tela.dat_final THEN
         ERROR "A data inicial do periodo não pode ser maior que a data final do periodo !!!"
         NEXT FIELD dat_inicial
      ELSE
         IF p_tela.dat_final - p_tela.dat_inicial > 365 THEN
            ERROR "O periodo para listagem não pode ser maior que 365 dias !!!"
            NEXT FIELD dat_inicial
         END IF 
      END IF 

   END INPUT 
    
  IF INT_FLAG THEN
     CALL pol0610_limpa_tela()
     RETURN FALSE
  END IF
   
  RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0610_inicializa_relat()
#----------------------------------#
      
   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF

   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED
         START REPORT pol0610_relat TO p_caminho
      ELSE
         START REPORT pol0610_relat TO p_nom_arquivo
      END IF
   END IF
    
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'Empresa')
      RETURN FALSE
   END IF 

END FUNCTION

#--------------------------------#
FUNCTION pol0610_finaliza_relat()
#--------------------------------#

   FINISH REPORT pol0610_relat

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
         RUN comando
      END IF
      LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
      CALL log0030_mensagem(p_msg, 'excla')
   ELSE
      LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      CALL log0030_mensagem(p_msg, 'excla')
   END IF
     
END FUNCTION 

#------------------------#                                                          
 FUNCTION pol0610_Listar()
#------------------------#

   DELETE FROM w_pol0610_885
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletanto','w_pol0610_885')
      RETURN FALSE
   END IF
   
   let p_count = 0
   
   if not pol0610_carrega_dados() then
      return false
   end if   
   
   if p_count = 0 then
      let p_msg = 'Não existem dados a serem listados!'
      call log0030_mensagem(p_msg,'excla')
      return false
   end if
   
   CALL pol0610_inicializa_relat()
   CALL pol0610_imprime()
   CALL pol0610_finaliza_relat()
 
    return true
    
end function

#------------------------------#
function pol0610_carrega_dados()
#------------------------------#

   message 'Aguarde!... Processando.'
    
   let p_pre_unit = 0
   let p_cod_tipo = '1'

   declare cq_trans cursor for
    select e.cod_item,
           e.qtd_movto,
           e.num_docum,
           e.num_conta,
           i.cod_familia
      from estoque_trans e, item i
     where e.cod_empresa = p_cod_empresa
       and e.cod_operacao = 'REQ' 
       and e.dat_movto   >= p_tela.dat_inicial
       and e.dat_movto   <= p_tela.dat_final  
       and i.cod_empresa  = e.cod_empresa
       and i.cod_item     = e.cod_item
       and i.gru_ctr_estoq>= 25
       and i.gru_ctr_estoq not in (30,35)
   
   FOREACH cq_trans into
      p_cod_item,
      p_qtd_movto,
      p_num_docum,
      p_num_conta,
      p_cod_familia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','estoque_trans')
         return false
      END IF
      
      ERROR 'Item: ' , p_cod_item
      
      let p_cod_cent_cust = p_num_conta[1,4]  
      
{      let p_num_reserva = p_num_docum
      
      select cod_uni_funcio
        into p_cod_uni_funcio
        from estoque_loc_reser
       where cod_empresa = p_cod_empresa
         and num_reserva = p_num_reserva
      
      if status <> 0 then
         CALL log003_err_sql('lendo','estoque_loc_reser')
         return false
      end if
      
      select cod_centro_custo
        into p_cod_cent_cust
        from uni_funcional
       where cod_empresa    = p_cod_empresa
         and cod_uni_funcio = p_cod_uni_funcio
         and dat_validade_ini <= p_tela.dat_inicial
         and dat_validade_fim >= p_tela.dat_final
      
      if status <> 0 then
         CALL log003_err_sql('lendo','uni_funcional')
         return false
      end if   
}      
      if not pol0610_le_cad_cc() then
         return false
      end if

      if not pol0610_le_preco() then
         return false
      end if      
	  
      if not pol0610_ins_temp() then
         return false
      end if      

   end foreach               
   
   let p_cod_tipo = '2'
   let p_cod_cent_cust = 0
   let p_nom_cent_cust = 'MATERIAL DIRETO'

   declare cq_direto cursor for
    select a.cod_item,
           a.qtd_recebida,
           a.pre_unit_nf
      from aviso_rec a, item i
     where a.cod_empresa = p_cod_empresa
       and a.dat_inclusao_seq >= p_tela.dat_inicial
       and a.dat_inclusao_seq <= p_tela.dat_final
       and a.cod_item = i.cod_item
       and a.cod_empresa = i.cod_empresa
       and i.cod_familia = '275'

   foreach cq_direto into p_cod_item, p_qtd_movto, p_pre_unit       

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','serviços')
         return false
      END IF
      
      if not pol0610_ins_temp() then
         return false
      end if      

   end foreach          
   
   let p_cod_tipo = '3'        
   let p_nom_cent_cust = 'SERVICOS'
   let p_qtd_movto = 1
   
   declare cq_serv cursor for
    select a.cod_item,
           a.pre_unit_nf
      from aviso_rec a, item i
     where a.cod_empresa = p_cod_empresa
       and a.dat_inclusao_seq >= p_tela.dat_inicial
       and a.dat_inclusao_seq <= p_tela.dat_final
       and a.cod_item = i.cod_item
       and a.cod_empresa = i.cod_empresa
       and i.gru_ctr_estoq = 70  

   foreach cq_serv into p_cod_item, p_pre_unit       

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','serviços')
         return false
      END IF
      
      if not pol0610_ins_temp() then
         return false
      end if      

   end foreach                  
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
function pol0610_le_preco()
#--------------------------#
   
   define p_achou smallint
                                                                                              
   select distinct pre_unit
     into p_pre_unit
     from w_pol0610_885
    where cod_item = p_cod_item
   
   if status = 0 then
      return true
   else
      if status <> 100 then
         CALL log003_err_sql('lendo','w_pol0610_885:preco')
         return false
      end if
   end if
         
   let p_achou = false
   
   declare cq_preco cursor for
    select pre_unit_nf,
           num_oc,
           dat_inclusao_seq
      from aviso_rec
     where cod_empresa = p_cod_empresa
       and cod_item    = p_cod_item
       and dat_inclusao_seq <= p_tela.dat_final  
     order by dat_inclusao_seq desc

   foreach cq_preco into p_pre_unit, p_num_oc  

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','aviso_rec:preco')
         return false
      END IF         
      
      let p_achou = true     
      exit foreach 
      
   end foreach
   
   if not p_achou then
      let p_pre_unit = 0
      return true
   end if        
   
   select fat_conver_unid
     into p_fat_conversao
     from ordem_sup
    where cod_empresa = p_cod_empresa
      and num_oc      = p_num_oc
      and ies_versao_atual = 'S'
   
   if status = 100 then
      let p_fat_conversao = 1
   else
      if status <> 0 then
         CALL log003_err_sql('lendo','ordem_sup:fat conversão')
         return false
      end if
   end if 
   
   let p_pre_unit = p_pre_unit / p_fat_conversao
   
   return true

end function

#--------------------------#
function pol0610_ins_temp()
#--------------------------#

   insert into w_pol0610_885 values(  
      p_cod_tipo,    
      p_cod_cent_cust,
      p_nom_cent_cust,
      p_cod_item,
      p_qtd_movto,
      p_pre_unit)
      
   if status <> 0 then
      CALL log003_err_sql('Inserindo','w_pol0610_885')
      return false
   end if               
   
   let p_count = 1
   
   return true
         
end function      

#---------------------------#
FUNCTION pol0610_le_cad_cc()
#---------------------------#

   select nom_cent_cust 
     into p_nom_cent_cust
     from cad_cc
    where cod_empresa   = p_cod_empresa
      and cod_cent_Cust = p_cod_cent_cust     

   if status <> 0 then
      error p_cod_cent_cust
      CALL log003_err_sql('Lendo','cad_cc')
      return false
   end if    

   RETURN TRUE

end FUNCTION

#------------------------#
function pol0610_imprime()
#------------------------#

   let p_quebra   = 0
   let p_tot_tipo = 0
   let p_tot_ger  = 0
   
   declare cq_imprime cursor for
    select cod_tipo,
           nom_cent_cust,
           cod_item,
           pre_unit,
           sum(qtd_movto)
      from w_pol0610_885
     group by cod_tipo, nom_cent_cust, cod_item,  pre_unit
     order by cod_tipo, nom_cent_cust, cod_item      

   foreach cq_imprime INTO 
           p_relat.cod_tipo,
           p_relat.nom_cent_cust,
           p_relat.cod_item,
           p_relat.pre_unit,
           p_relat.qtd_movto
                 
      if status <> 0 then
         CALL log003_err_sql('Lendo','w_pol0610_885:cq_imprime')
         return 
      end if       
              
      LET p_relat.custo_total = p_relat.qtd_movto * p_relat.pre_unit
                    
      select den_item 
        into p_relat.den_item
        from item
       where cod_empresa = p_cod_empresa
         and cod_item    = p_relat.cod_item     

      if status <> 0 then
         CALL log003_err_sql('Lendo','Item')
         return 
      end if  
        
      OUTPUT TO REPORT pol0610_relat(p_relat.*)    

   end foreach
         
end function  

#-----------------------------#
 REPORT pol0610_relat(p_relat)
#-----------------------------#
  
   DEFINE p_relat              RECORD 
          cod_tipo             char(01),
          cod_item             char(15),
          den_item             char(40),
          cod_cent_cust        decimal(4,0),
          nom_cent_cust        char(40),
          qtd_movto            decimal(10,3),
          pre_unit             decimal(10,2),
          custo_total          decimal(11,2)
   END RECORD  
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 1
          BOTTOM MARGIN 2
          PAGE   LENGTH 66
          
  ORDER EXTERNAL BY p_relat.cod_tipo , p_relat.nom_cent_cust    
          
   FORMAT
      
      FIRST PAGE HEADER  
      
         PRINT COLUMN 001, p_den_empresa, p_comprime, 
               COLUMN 208, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol0610",
               COLUMN 044, "RELATORIO DE MANUTENCAO",
               COLUMN 070, p_tela.dat_inicial, " - ", p_tela.dat_final,
               COLUMN 100, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "     ITEM                    DESCRICAO                           CENTRO DE CUSTO                  QUANTIDADE CUSTO UNIT CUSTO TOTAL "
         PRINT COLUMN 001, "--------------- ---------------------------------------- ---------------------------------------- ---------- ---------- -----------"
         PRINT

      BEFORE GROUP OF p_relat.nom_cent_cust
         LET p_nom_cent_cust = p_relat.nom_cent_cust
                         
      ON EVERY ROW
         
         PRINT COLUMN 001, p_relat.cod_item,
               COLUMN 017, p_relat.den_item,
               COLUMN 058, p_relat.nom_cent_cust,
               COLUMN 099, p_relat.qtd_movto   USING '##,##&.&&&',
               COLUMN 110, p_relat.pre_unit    USING '###,##&.&&',
               COLUMN 121, p_relat.custo_total USING '####,##&.&&'
      
      AFTER GROUP OF p_relat.nom_cent_cust

         let p_tot_cust = GROUP SUM(p_relat.custo_total)
         let p_tot_tipo = p_tot_tipo + p_tot_cust
         
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------"
         PRINT COLUMN 017, 'TOTAL CENT CUSTO ',p_nom_cent_cust,
               COLUMN 121, p_tot_cust USING '####,##&.&&'
         PRINT

      AFTER GROUP OF p_relat.cod_tipo
         
         let p_quebra = p_quebra + 1
         
         if p_quebra = 1 then
            let p_den_total = 'TOTAL GERAL DO ALMOXARIFADO:' 
         else 
            if p_quebra = 2 then
               let p_den_total = 'TOTAL GERAL MATERIAL DE APLICACAO DIRETA:'
            else
               let p_den_total = 'TOTAL GERAL SERVIÇOS:'
            end if
         end if                  
         
         let p_tot_ger = p_tot_ger + p_tot_tipo
         
         PRINT COLUMN 017, p_den_total,
               COLUMN 121, p_tot_tipo USING '####,##&.&&'
         PRINT
         
         let p_tot_tipo = 0
                       
      ON LAST ROW

         PRINT COLUMN 017, 'T O T A L  G E R A L  D O  P E R I O D O:',
               COLUMN 120, p_tot_ger USING '##,###,##&.&&'
 
         LET p_last_row = TRUE

     PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 066, "* * * ULTIMA FOLHA * * *"
           LET p_last_row = FALSE
        ELSE 
           PRINT " "
        END IF
                                 
END REPORT
              
