#-------------------------------------------------------------------#
# PROGRAMA: POL0251                                                 #
# OBJETIVO: TRANSFERENCIA DE ADIANTAMENTO                           #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_nom_for_nf        LIKE fornecedor.raz_social,
         cod_for_nf          LIKE fornecedor.cod_fornecedor,
         p_nom_for_ad        LIKE fornecedor.raz_social,
         p_cod_for_ad        LIKE fornecedor.cod_fornecedor,
         p_num_ad_nf_orig    LIKE adiant.num_ad_nf_orig,
         p_ser_nf            LIKE adiant.ser_nf,
         p_ssr_nf            LIKE adiant.ssr_nf, 
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tela          CHAR(080),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_msg               CHAR(100),
         p_last_row          SMALLINT,
         p_den_item_reduz    LIKE item.den_item_reduz 

  DEFINE p_adiant            RECORD LIKE adiant.*,    
         p_fornecedor        RECORD LIKE fornecedor.*
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  DEFER INTERRUPT
  LET p_versao = "pol0251-10.02.01"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0251.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("ESPEC999","")
    RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN
     CALL esp001_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION esp001_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tela TO NULL
  CALL log130_procura_caminho("pol0251") RETURNING p_nom_tela
  LET  p_nom_tela = p_nom_tela CLIPPED 
  OPEN WINDOW w_pol0251 AT 2,4 WITH FORM p_nom_tela 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE ""
       LET int_flag = 0
       IF  log005_seguranca(p_user,"CAP","POL0251","CO") THEN
           IF esp001_entrada_dados("CONSULTA") THEN
              NEXT OPTION "Modificar"
           ELSE
              ERROR "Consulta	Cancelada"
           END IF 
       END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_num_ad_nf_orig IS NOT NULL THEN
           IF  log005_seguranca(p_user,"CAP","POL0251","MO") THEN
               IF esp001_entrada_dados("MODIFICACAO") THEN
                  CALL esp001_modificacao()
               ELSE
                  ERROR "Alteracao Cancelada"
               END IF
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL esp0251_sobre() 
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0251
END FUNCTION

#-----------------------#
FUNCTION esp0251_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#---------------------------------------#
 FUNCTION esp001_entrada_dados(p_funcao)
#---------------------------------------#
  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0251

  INPUT BY NAME p_num_ad_nf_orig,
                p_ser_nf,
                p_ssr_nf,
                cod_for_nf   WITHOUT DEFAULTS  


    BEFORE FIELD p_num_ad_nf_orig
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD cod_for_nf
      END IF

    AFTER FIELD p_num_ad_nf_orig
      IF p_num_ad_nf_orig IS NULL THEN
         ERROR "O campo NUM. AD nao pode ser nulo."
         NEXT FIELD p_num_ad_nf_orig  
      END IF

    AFTER FIELD p_ser_nf
      IF p_ser_nf IS NULL THEN
         ERROR "O campo SERIE nao pode ser nulo."
         NEXT FIELD p_ser_nf    
      END IF 

    AFTER FIELD p_ssr_nf
      IF p_ssr_nf IS NULL THEN
         ERROR "O campo SUB SERIE nao pode ser nulo."
         NEXT FIELD p_ssr_nf
      ELSE
         SELECT * 
           INTO p_adiant.*
           FROM adiant
          WHERE cod_empresa = p_cod_empresa
            AND num_ad_nf_orig = p_num_ad_nf_orig
            AND ser_nf = p_ser_nf
            AND ssr_nf = p_ssr_nf
          IF sqlca.sqlcode <> 0 THEN
             ERROR "Adiantamento nao cadastrado"
             NEXT FIELD p_num_ad_nf_orig
          ELSE
             LET p_cod_for_ad = p_adiant.cod_fornecedor
             SELECT raz_social
               INTO p_nom_for_ad
               FROM fornecedor
              WHERE cod_fornecedor = p_cod_for_ad

              DISPLAY p_cod_for_ad TO cod_for_ad
              DISPLAY p_nom_for_ad TO nom_for_ad
              DISPLAY p_adiant.val_adiant TO val_adiant

              EXIT INPUT
          END IF 
       END IF 

    AFTER FIELD cod_for_nf
      IF cod_for_nf IS NULL THEN
         ERROR "O campo FORNECEDOR nao pode ser nulo."         
         NEXT FIELD cod_for_nf  
      ELSE
         SELECT raz_social
           INTO p_nom_for_nf
           FROM fornecedor
          WHERE cod_fornecedor = cod_for_nf

          DISPLAY p_nom_for_nf TO nom_for_nf

      END IF   

   ON KEY (control-z)
        CALL pol0251_popup()

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0251
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION

#----------------------------------#
 FUNCTION esp001_modificacao()
#----------------------------------#
  
    LET p_adiant.tex_observ_adiant = "FOR. SUBS. DE ",p_cod_for_ad," P/ ",cod_for_nf     

    UPDATE adiant SET cod_fornecedor = cod_for_nf,
                      tex_observ_adiant = p_adiant.tex_observ_adiant 
     WHERE cod_empresa = p_cod_empresa 
       AND num_ad_nf_orig = p_num_ad_nf_orig
       AND ser_nf = p_ser_nf
       AND ssr_nf = p_ssr_nf
     IF sqlca.sqlcode = 0 THEN
        UPDATE mov_adiant SET cod_fornecedor = cod_for_nf
         WHERE cod_empresa = p_cod_empresa 
           AND num_ad_nf_orig = p_num_ad_nf_orig
           AND ser_nf = p_ser_nf
           AND ssr_nf = p_ssr_nf
        IF sqlca.sqlcode = 0 THEN
           UPDATE ad_mestre SET cod_fornecedor = cod_for_nf
            WHERE cod_empresa = p_cod_empresa 
              AND num_ad = p_num_ad_nf_orig
           IF sqlca.sqlcode = 0 THEN 
              
              CALL pol0251_atu_ap(p_num_ad_nf_orig, cod_for_nf)
              
           
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("MODIFICACAO","AP")
              ELSE
                 MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
              END IF
           ELSE
              CALL log003_err_sql("MODIFICACAO","AD_MESTRE")
           END IF
        ELSE
           CALL log003_err_sql("MODIFICACAO","MOV_ADIANT")
        END IF
     ELSE
        CALL log003_err_sql("MODIFICACAO","ADIANT")
     END IF

END FUNCTION

#-------------------------------------------#
FUNCTION pol0251_atu_ap(p_num_ad, p_cod_for)
#-------------------------------------------#
  
  DEFINE p_num_ad  INTEGER,
         p_num_ap  INTEGER,
         p_cod_for CHAR(15)

  DECLARE cq_ad_ap CURSOR FOR                      
   SELECT num_ap                                               
     FROM ad_ap                                                
    WHERE cod_empresa = p_cod_empresa                          
      AND num_ad = p_num_ad
                                  
  FOREACH cq_ad_ap INTO p_num_ap   
                              
     IF STATUS <> 0 THEN                                       
        CALL log003_err_sql('FOREACH','cq_ad_ap')   
        EXIT FOREACH
     END IF           
                                                               
     UPDATE ap SET cod_fornecedor = p_cod_for                    
      WHERE cod_empresa = p_cod_empresa                           
        AND num_ap = p_num_ap     
     
     IF STATUS <> 0 THEN
        CALL log003_err_sql('UPDATE','AP')
        EXIT FOREACH
     END IF
  
  END FOREACH

END FUNCTION                        

#-----------------------#
 FUNCTION pol0251_popup()
#-----------------------#
  DEFINE p_cod_fornecedor     LIKE fornecedor.cod_fornecedor
  
  CASE

     WHEN infield(cod_for_nf)
       # LET p_cod_fornecedor = sup162_popup_fornecedor()

       CURRENT WINDOW IS w_pol0251   
       LET  cod_for_nf = p_cod_fornecedor
       DISPLAY cod_for_nf TO cod_for_nf

  END CASE

END FUNCTION
#------------------------------ FIM DE PROGRAMA -------------------------------#
