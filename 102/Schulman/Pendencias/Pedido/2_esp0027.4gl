###PARSER-N�o remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: OMC - OPERACAO MOVIMENTO CARGA                        #
# PROGRAMA: esp0027                                               #
# OBJETIVO: IMPRESS�O DE ORDENS DE COLETA                         #
# AUTOR...: CLEITON PIOVEZAN                                      #
# DATA....: 24/02/2004                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
    DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
           p_user                 LIKE usuario.nom_usuario,
           p_status               SMALLINT

    DEFINE p_ies_impressao        CHAR(001),
           g_ies_ambiente         CHAR(001),
           p_nom_arquivo          CHAR(100),
           p_nom_arquivo_back     CHAR(100)

    DEFINE g_ies_grafico          SMALLINT

    DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

#MODULARES
    DEFINE where_clause                 CHAR(500) 
        , m_diretorio_pdf              CHAR(150)
        , m_diretorio_img              CHAR(150)
        
DEFINE ma_config_pdf                ARRAY[9999] OF RECORD
             linha                        CHAR(1000)
                                       END RECORD
                                       
                                       
           DEFINE m_ind                        INTEGER
        , m_nome_arquivo               CHAR(200)
        , m_date                       CHAR(10)
        , m_hora                       CHAR(08) 
        , m_linha, m_coluna            INTEGER
        
                                       
                             
    DEFINE m_comprime             CHAR(01),
           m_descomprime          CHAR(01),
           m_6lpp                 CHAR(02),
           m_reimpressao          SMALLINT

    DEFINE m_den_empresa          LIKE empresa.den_empresa

    DEFINE m_tem_dados            SMALLINT,
           m_reg_array            SMALLINT,
           m_consulta_ativa       SMALLINT

    DEFINE m_ma_curr              SMALLINT,
           m_sc_curr              SMALLINT

    DEFINE sql_stmt               CHAR(1000),
           m_last_row             SMALLINT

    DEFINE m_comando              CHAR(080)
    DEFINE m_caminho              CHAR(150)
    DEFINE m_caminho_help         CHAR(150),
           m_ser_coleta           CHAR(03)#717141 - Cesar

   DEFINE m_tot_formulario        INTEGER

    DEFINE mr_consulta            RECORD
             # serie_ordem_coleta     CHAR(03), #717141 - Cesar
              ordem_coleta_ini       LIKE omc_ordem_coleta.ordem_coleta
            #  ordem_coleta_fim       LIKE omc_ordem_coleta.ordem_coleta
            #  dat_coleta_ini         LIKE omc_ordem_coleta.dat_coleta,
            #  dat_coleta_fim         LIKE omc_ordem_coleta.dat_coleta,
            #  hor_coleta_ini         LIKE omc_ordem_coleta.hor_coleta,
           #   hor_coleta_fim         LIKE omc_ordem_coleta.hor_coleta,
           #   remetent               LIKE omc_ordem_coleta.remetent,
           #   nom_remetent           LIKE omc_emitente.nom_emitente,
           #   destinat               LIKE omc_ordem_coleta.remetent,
           #   nom_destinat           LIKE omc_emitente.nom_emitente
                                  END RECORD

    DEFINE mr_ordem_coleta        RECORD
              cod_barra_ordem        LIKE omc_ordem_coleta.ord_coleta_oficial,
              linh_ordem             LIKE omc_ordem_coleta.ord_coleta_oficial
                                  END RECORD

    DEFINE ma_ordem_coleta        ARRAY[3000] OF RECORD
              imprime                CHAR(01),
              ordem_coleta           LIKE omc_ordem_coleta.ordem_coleta,
              remetente              LIKE omc_ordem_coleta.remetent,
              destinata              LIKE omc_ordem_coleta.destinat,
              dat_coleta             LIKE omc_ordem_coleta.dat_coleta,
              hor_coleta             LIKE omc_ordem_coleta.hor_coleta
                                  END RECORD

    DEFINE m_parametro            SMALLINT #717141 - Cesar
#END MODULARES

MAIN
    CALL log0180_conecta_usuario()

    LET p_versao = 'esp0027-10.02.00p' #Favor nao alterar esta linha (SUPORTE)

    WHENEVER ERROR CONTINUE

    CALL log1400_isolation()
    SET LOCK MODE TO WAIT 120

    WHENEVER ERROR STOP

    DEFER INTERRUPT

    LET m_caminho_help = log140_procura_caminho('esp0027.iem')

    OPTIONS
        PREVIOUS KEY control-b,
        NEXT     KEY control-f,
        HELP     FILE m_caminho_help

    CALL log001_acessa_usuario('OMC','LOGGTC')
         RETURNING p_status, p_cod_empresa, p_user

    IF   p_status = 0
    THEN CALL esp0027_controle()
    END IF

END MAIN

#---------------------------#
 FUNCTION esp0027_controle()
#---------------------------#
 DEFINE l_arg1 INTEGER

 CALL log006_exibe_teclas('01',p_versao)
# LET m_ser_coleta = omc0875_busca_serie_docum(p_cod_empresa, '4', FALSE)

 LET m_consulta_ativa = FALSE
 INITIALIZE mr_consulta.*     TO NULL
 INITIALIZE mr_ordem_coleta.* TO NULL
 INITIALIZE ma_ordem_coleta   TO NULL
 INITIALIZE m_comando TO NULL

 LET m_parametro = FALSE #717141 - Cesar

 CALL log1300_procura_caminho('esp0027','') RETURNING m_comando
 OPEN WINDOW w_esp0027 AT 2,2 WITH FORM  m_comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 MENU 'OPCAO'
      #BEFORE MENU
      #       INITIALIZE l_arg1 TO NULL
      #       WHENEVER ERROR CONTINUE
      #        LET l_arg1 = arg_val(1)
      #       WHENEVER ERROR STOP
      #
      #       IF l_arg1 IS NOT NULL THEN
      #          LET m_parametro                    = TRUE #717141 - Cesar
      #          LET m_reimpressao                  = FALSE
      #          LET mr_consulta.ordem_coleta_ini   = l_arg1
      #          LET mr_consulta.ordem_coleta_fim   = l_arg1
      #          LET mr_consulta.dat_coleta_ini     = '01/01/1900'
      #          LET mr_consulta.dat_coleta_fim     = '31/12/3999'
      #          LET mr_consulta.hor_coleta_ini     = '00:00:00'
      #          LET mr_consulta.hor_coleta_fim     = '23:59:59'
      #          LET mr_consulta.serie_ordem_coleta = m_ser_coleta
      #          DISPLAY p_cod_empresa TO empresa
      #          DISPLAY BY NAME mr_consulta.*
      #
      #          IF omc0875_permite_escolha(p_cod_empresa, 4) = TRUE THEN
      #             CALL log006_exibe_teclas('01 09', p_versao)
      #             CURRENT WINDOW IS w_esp0027
      #             CALL esp0027_informar()
      #             LET m_parametro = FALSE #717141 - Cesar
      #          ELSE
      #             IF esp0027_prepara_consulta() THEN
      #                CALL log006_exibe_teclas('01 09', p_versao)
      #                CURRENT WINDOW IS w_esp0027
      #                IF esp0027_seleciona_dados_impressao() THEN
      #                   NEXT OPTION 'Processar'
      #                END IF
      #             END IF
      #          END IF
      #       END IF

      COMMAND 'Informar'   ' Informa par�metros para consulta.'
              HELP 009
              MESSAGE ''
              IF   log005_seguranca(p_user, 'OMC', 'esp0027', 'IN')
              THEN LET m_reimpressao = FALSE
                   IF   esp0027_informar()
                   THEN NEXT OPTION 'Processar'
                   END IF
              END IF

      COMMAND 'Processar' 'Processa impress�o.'
              HELP 010
              MESSAGE ''
              
                        CALL esp0027_processar()
                     
   

      COMMAND KEY ('!')
              PROMPT 'Digite o m_comando : ' FOR m_comando
              RUN m_comando
              PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando
              LET int_flag = 0

      COMMAND 'Fim'        'Retorna ao Menu Anterior'
              HELP 008
              EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

 END MENU

 CLOSE WINDOW w_esp0027

END FUNCTION

#--------------------------#
 FUNCTION esp0027_informar()
#--------------------------#
  CALL log006_exibe_teclas('01 02 07 08', p_versao)
  CURRENT WINDOW IS w_esp0027
  IF m_parametro = FALSE THEN #717141 - Cesar
     INITIALIZE mr_consulta.* TO NULL
  END IF
  INITIALIZE mr_ordem_coleta.* TO NULL
  INITIALIZE ma_ordem_coleta   TO NULL
  CLEAR FORM

  IF esp0027_entrada_dados('CONSULTA') THEN
  
  ELSE
     ERROR ' Consulta cancelada. '
     CLEAR FORM
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------#
 FUNCTION esp0027_entrada_dados(l_funcao)
#----------------------------------------#
 DEFINE l_funcao CHAR(015),
        l_ind     SMALLINT,
        l_erro    SMALLINT

 LET INT_FLAG = FALSE

 CALL log006_exibe_teclas("01 02", p_versao)
 CURRENT WINDOW IS w_esp0027

 DISPLAY p_cod_empresa TO empresa

  

 INPUT BY NAME mr_consulta.* WITHOUT DEFAULTS

 

 CALL log006_exibe_teclas('01', p_versao)
 CURRENT WINDOW IS w_esp0027

 IF INT_FLAG THEN
    LET INT_FLAG = FALSE
    RETURN FALSE
 ELSE
#    LET m_ser_coleta = mr_consulta.serie_ordem_coleta  #717141 - Cesar
    RETURN TRUE
 END IF

END FUNCTION

#-----------------------#
 FUNCTION esp0027_help()
#-----------------------#
 OPTIONS HELP FILE m_caminho_help

 CASE
     WHEN INFIELD(ordem_coleta_ini)     CALL SHOWHELP(101)
     WHEN INFIELD(ordem_coleta_fim)     CALL SHOWHELP(102)
     WHEN INFIELD(dat_coleta_ini)       CALL SHOWHELP(103)
     WHEN INFIELD(dat_coleta_fim)       CALL SHOWHELP(103)
     WHEN INFIELD(hor_coleta_ini)       CALL SHOWHELP(104)
     WHEN INFIELD(hor_coleta_fim)       CALL SHOWHELP(104)
     WHEN INFIELD(remetent)             CALL SHOWHELP(105)
     WHEN INFIELD(destinat)             CALL SHOWHELP(106)
     WHEN INFIELD(imprime)              CALL SHOWHELP(107)
     WHEN INFIELD(cod_barra_ordem)      CALL SHOWHELP(108)
     WHEN INFIELD(linh_ordem)           CALL SHOWHELP(109)
     WHEN INFIELD(serie_ordem_coleta)   CALL SHOWHELP(110)#717141 - Cesar

 END CASE

END FUNCTION
  

#---------------------------#
 FUNCTION esp0027_processar()
#---------------------------#
 DEFINE l_mensagem             CHAR(130),
        l_arquivo              SMALLINT,
        l_ind                  SMALLINT,
        l_ord_coleta_oficial   INTEGER

 DEFINE lr_relat               RECORD
           ordem_coleta           LIKE omc_ordem_coleta.ordem_coleta,
           ord_coleta_oficial     LIKE omc_ordem_coleta.ord_coleta_oficial,
           remetent         			   LIKE omc_ordem_coleta.remetent,
           nom_remetent     			   LIKE omc_emitente.nom_emitente,
           contato          			   LIKE omc_emitente.contato,
           telefone_1       			   LIKE omc_emitente.telefone_1,
           endereco         			   CHAR(072),
           bairro           			   LIKE omc_emitente.bairro,
           den_bairro       			   LIKE bairros.den_bairro,
           cidade           			   LIKE omc_emitente.cidade,
           den_cidade       			   LIKE cidades.den_cidade,
           num_cnpj_cpf     			   LIKE omc_emitente.num_cnpj_cpf,
           inscr_estadual   			   LIKE omc_emitente.inscricao_estadual,
           veiculo          			   LIKE omc_ordem_coleta.veiculo,
           veiculo_ntracionad     LIKE omc_ordem_coleta.veiculo_ntracionad,
           veic_ntrac_aux_1       LIKE omc_ordem_coleta.veic_ntrac_aux_1,
           veic_ntrac_aux_2       LIKE omc_ordem_coleta.veic_ntrac_aux_2,
           placa_veiculo          LIKE frt_veiculo.placa,
           placa_ntrac1           LIKE frt_veiculo.placa,
           placa_ntrac2           LIKE frt_veiculo.placa,
           placa_ntrac3           LIKE frt_veiculo.placa,
           motorista        			   LIKE omc_ordem_coleta.motorista,
           nom_motorista    			   LIKE frt_motorista.nom_motorista,
           cpf              			   LIKE frt_motorista.cpf,
           rg               			   LIKE frt_motr_compl.num_registro_geral,
           peso_item        			   LIKE omc_item_coleta.peso_item,
											destinat         			   LIKE omc_ordem_coleta.remetent,
											nom_destinat     			   LIKE omc_emitente.nom_emitente,
											cidade_destinat  			   LIKE omc_emitente.cidade,
											den_cid_dest     			   LIKE cidades.den_cidade,
											estado_destinat  			   LIKE cidades.cod_uni_feder,
           dat_coleta       			   LIKE omc_ordem_coleta.dat_coleta,
           dat_inclusao     			   LIKE omc_ordem_coleta.dat_inclusao,
           hor_inclusao     			   LIKE omc_ordem_coleta.hor_inclusao,
           hor_fim_atendto  			   LIKE omc_emitente.hor_fim_atendto,
           observacao       			   LIKE omc_ordem_coleta.observacao,
           qtd_item_1       			   LIKE omc_item_coleta.qtd_item,
           qtd_item_2       			   LIKE omc_item_coleta.qtd_item,
           qtd_item_3       			   LIKE omc_item_coleta.qtd_item,
           qtd_item_4       			   LIKE omc_item_coleta.qtd_item,
           item_1           			   LIKE omc_item_coleta.item,
           item_2           			   LIKE omc_item_coleta.item,
           item_3           			   LIKE omc_item_coleta.item,
           item_4           			   LIKE omc_item_coleta.item
                               END RECORD

 
   CALL esp0027_relat_inicializa_processo_pdf()
 
   call esp0027_layout(lr_relat.*)
 
   CALL esp0027_relat_gera_pdf()

   CALL log0030_mensagem("Relatorio extraido com sucesso","info")
   

END FUNCTION
 
 


#-------------------------------------#
 function esp0027_layout(lr_ordem_coleta)
#-------------------------------------#
define l_diretorio_img     CHAR(150)

   DEFINE l_texto                      CHAR(500)
   
   define l_den_imagem        char(100)
 DEFINE lr_ordem_coleta        RECORD
           ordem_coleta           LIKE omc_ordem_coleta.ordem_coleta,
           ord_coleta_oficial     LIKE omc_ordem_coleta.ord_coleta_oficial,
           remetent               LIKE omc_ordem_coleta.remetent,
           nom_remetent           LIKE omc_emitente.nom_emitente,
           contato                LIKE omc_emitente.contato,
           telefone_1             LIKE omc_emitente.telefone_1,
           endereco               CHAR(072),
           bairro                 LIKE omc_emitente.bairro,
           den_bairro             LIKE bairros.den_bairro,
           cidade                 LIKE omc_emitente.cidade,
           den_cidade             LIKE cidades.den_cidade,
           num_cnpj_cpf           LIKE omc_emitente.num_cnpj_cpf,
           inscr_estadual         LIKE omc_emitente.inscricao_estadual,
           veiculo                LIKE omc_ordem_coleta.veiculo,
           veiculo_ntracionad     LIKE omc_ordem_coleta.veiculo_ntracionad,
           veic_ntrac_aux_1       LIKE omc_ordem_coleta.veic_ntrac_aux_1,
           veic_ntrac_aux_2       LIKE omc_ordem_coleta.veic_ntrac_aux_2,
           placa_veiculo          LIKE frt_veiculo.placa,
           placa_ntrac1           LIKE frt_veiculo.placa,
           placa_ntrac2           LIKE frt_veiculo.placa,
           placa_ntrac3           LIKE frt_veiculo.placa,
           motorista              LIKE omc_ordem_coleta.motorista,
           nom_motorista          LIKE frt_motorista.nom_motorista,
           cpf                    LIKE frt_motorista.cpf,
           rg                     LIKE frt_motr_compl.num_registro_geral,
           peso_item              LIKE omc_item_coleta.peso_item,
           destinat               LIKE omc_ordem_coleta.remetent,
           nom_destinat           LIKE omc_emitente.nom_emitente,
           cidade_destinat        LIKE omc_emitente.cidade,
           den_cid_dest           LIKE cidades.den_cidade,
           estado_destinat        LIKE cidades.cod_uni_feder,
           dat_coleta             LIKE omc_ordem_coleta.dat_coleta,
           dat_inclusao           LIKE omc_ordem_coleta.dat_inclusao,
           hor_inclusao           LIKE omc_ordem_coleta.hor_inclusao,
           hor_fim_atendto        LIKE omc_emitente.hor_fim_atendto,
           observacao             LIKE omc_ordem_coleta.observacao,
           qtd_item_1             LIKE omc_item_coleta.qtd_item,
           qtd_item_2             LIKE omc_item_coleta.qtd_item,
           qtd_item_3             LIKE omc_item_coleta.qtd_item,
           qtd_item_4             LIKE omc_item_coleta.qtd_item,
           item_1                 LIKE omc_item_coleta.item,
           item_2                 LIKE omc_item_coleta.item,
           item_3                 LIKE omc_item_coleta.item,
           item_4                 LIKE omc_item_coleta.item
                               END RECORD

  DEFINE l_end_empresa         CHAR(36),
         l_den_munic           CHAR(30),
         l_uni_feder           CHAR(02),
         l_num_cgc             CHAR(19),
         l_ins_estadual        CHAR(16),
         l_imprime             CHAR(01)

  DEFINE l_placas_veic   CHAR(080)
  
  define lr_relat record 
  
                             empresa      char(2),
		                     ordem_coleta  integer,
		                     dat_inclusao  date,
		                     agendamento   date,
		                     hora_agend    char(8),
		                        mercadoria  char(100),		                     
		                     remetente     char(36),
		                        cidade      char(50),
								uf_rem      char(2),
		                     destinatario  char(36),
		                        cidade_dest  char(50) , 
								uf_dest      char(2),
		                     motorista     char(36),
		                     cpf           char(20),
		                     cnh           char(20),
		                     endereco      char(50),
     		                    cidade_mot  char(50) , 
								uf_mot      char(2),
		                     veiculo          char(20),
		                     marca            char(20),
		                     modelo           char(20),
		                     antt              char(20),
		                     carreta1           char(20),
		                     carreta2           char(20),
		                     carreta3           char(20),
		                     proprietario      char(50),
		                     cpf_cnpj          char(20),
		                     end_fornec         char(50),
		                        cidade_prop     char(50),
								uf_propr        char(2)
		                     
                  end record

   

   INITIALIZE l_placas_veic TO NULL
   
   declare cq_cursor_list cursor for 
   
   SELECT	a.empresa,                                                       
		a.ordem_coleta,                                                      
		convert(varchar, a.dat_inclusao, 103) data,                          
		convert(varchar, a.dat_agendamento, 103) data_coleta,                
		a.hor_agendamento hora_coleta,                                       
		b.item mercadoria,                                             
		cl.nom_cliente remetente,                                            
		c1.den_cidade cidade,                                                                      
		c1.cod_uni_feder uf_rem,                                                                 
		cl2.nom_cliente destinatario,                                                           
		c2.den_cidade cidade_dest,                                    
		c2.cod_uni_feder uf_dest,                                                     
		mt.nom_motorista motorista,                                                             
		mt.cpf,                                                       
		mt.cnh,                                                       
		mt.endereco,                                                  
		c3.den_cidade cidade_mot,                                                      
		mt.estado uf_mot,                                                            
		a.veiculo,                                                    
		m.des_marca marca,                                            
		md.des_modelo modelo,                                         
		v3.rntrc antt,                                                
		a.veiculo_ntracionad carreta1,                                
		a.veic_ntrac_aux_1 carreta2,                                  
		a.veic_ntrac_aux_2 carreta3,                                  
		f.raz_social proprietario,                                    
		f.num_cgc_cpf cpf_cnpj_prop,                                  
		f.end_fornec end_prop,                                        
		c4.den_cidade cidade_prop,                                    
		f.cod_uni_feder uf_propr                                      
FROM omc_ordem_coleta a -- sp_help omc_ordem_coleta

inner join omc_item_coleta b
	on a.empresa		= b.empresa
	and a.ordem_coleta	= b.ordem_coleta

inner join clientes cl
	on a.remetent		= cl.cod_cliente

inner join cidades c1
	on cl.cod_cidade = c1.cod_cidade

inner join clientes cl2
	on a.destinat		= cl2.cod_cliente

inner join cidades c2
	on cl2.cod_cidade = c2.cod_cidade

inner join frt_motorista mt
	on a.motorista		= mt.motorista

inner join cidades c3
	on mt.cidade = c3.cod_cidade

left join frt_veiculo v
	on a.empresa		= v.empresa
	and a.veiculo		= v.veiculo

left join frt_marca m
	on v.fabr_veiculo	= m.marca
	and m.tip_marca		= '1'

left join frt_modelo_marca md
	on m.tip_marca		= md.tip_marca
	and m.marca			= md.marca
	and v.modelo_veiculo = md.modelo

left join frt_veic_compl_2 v2
	on v.empresa		= v2.empresa
	and v.filial		= v2.filial
	and v.veiculo		= v2.veiculo

left join frt_fornecedor_complementar v3
	on v2.proprietario	= v3.fornecedor

left join fornecedor f
	on v2.proprietario	= f.cod_fornecedor

left join cidades c4
	on f.cod_cidade = c4.cod_cidade

WHERE a.empresa = p_cod_empresa                       
AND a.ordem_coleta = mr_consulta.ordem_coleta_ini     

#
#   SELECT	a.empresa,
#		    a.ordem_coleta,
#		    convert(varchar, a.dat_inclusao, 103) data,
#		    convert(varchar, a.dat_agendamento, 103) agendamento,
#		    a.hor_agendamento hora_agend,
#		    --a.remetent, 
#		    cl.nom_cliente remetente,
#		    --a.destinat,
#		    cl2.nom_cliente destinatario,
#		    --b.item,
#		    mt.nom_motorista motorista,
#		    mt.cpf,
#		    mt.cnh,
#		    mt.endereco,
#		    a.veiculo,
#		    m.des_marca marca,
#		    md.des_modelo modelo,
#		    v3.rntrc antt,
#		    a.veiculo_ntracionad carreta1,
#		    a.veic_ntrac_aux_1 carreta2,
#		    a.veic_ntrac_aux_2 carreta3,
#		    f.raz_social proprietario,
#		    f.num_cgc_cpf cpf_cnpj,
#		    f.end_fornec
#FROM omc_ordem_coleta a
#
#inner join omc_item_coleta b
#	on a.empresa		= b.empresa
#	and a.ordem_coleta	= b.ordem_coleta
#
#inner join clientes cl
#	on a.remetent		= cl.cod_cliente
#
#inner join clientes cl2
#	on a.destinat		= cl2.cod_cliente
#
#inner join frt_motorista mt
#	on a.motorista		= mt.motorista
#
#left join frt_veiculo v
#	on a.empresa		= v.empresa
#	and a.veiculo		= v.veiculo
#
#left join frt_marca m
#	on v.fabr_veiculo	= m.marca
#	and m.tip_marca		= '1'
#
#left join frt_modelo_marca md
#	on m.tip_marca		= md.tip_marca
#	and m.marca			= md.marca
#	and v.modelo_veiculo = md.modelo
#
#left join frt_veic_compl_2 v2
#	on v.empresa		= v2.empresa
#	and v.filial		= v2.filial
#	and v.veiculo		= v2.veiculo
#
#left join frt_fornecedor_complementar v3
#	on v2.proprietario	= v3.fornecedor
#
#left join fornecedor f
#	on v2.proprietario	= f.cod_fornecedor
#
#WHERE a.empresa = p_cod_empresa
#AND a.ordem_coleta = mr_consulta.ordem_coleta_ini
   
   open cq_cursor_list
   fetch cq_cursor_list into lr_relat.empresa,
		                     lr_relat.ordem_coleta,
		                     lr_relat.dat_inclusao,
		                     lr_relat.agendamento,
		                     lr_relat.hora_agend,
		                        lr_relat.mercadoria,
		                     lr_relat.remetente,
		                         lr_relat.cidade  ,
								 lr_relat.uf_rem  ,
		                     lr_relat.destinatario,   
		                         lr_relat.cidade_dest,          
								 lr_relat.uf_dest,              
		                     lr_relat.motorista,                    
		                     lr_relat.cpf,                          
		                     lr_relat.cnh,                          
		                     lr_relat.endereco,                     
		                         lr_relat.cidade_mot,               
							     lr_relat.uf_mot,                   
		                     lr_relat.veiculo,                      
		                     lr_relat.marca,                        
		                     lr_relat.modelo,                       
		                     lr_relat.antt,                         
		                     lr_relat.carreta1,                     
		                     lr_relat.carreta2,                     
		                     lr_relat.carreta3,                     
		                     lr_relat.proprietario,                 
		                     lr_relat.cpf_cnpj,                     
		                     lr_relat.end_fornec,                   
		                        lr_relat.cidade_prop,                
								lr_relat.uf_propr                   
   
   
   CALL esp0027_func_cria_pagina()
     
   LET l_diretorio_img = log150_procura_caminho('IMG') CLIPPED, 'coleta.jpg'
   
   
   ####LOGOTIPO DA EMPRESA
   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=adicionaImagem(",l_diretorio_img CLIPPED," ; ","854"," ; ","580"," ; ","5"," ; ","5"," );"
   ####DADOS DA EMPRESA
   
    
   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=defineFonte(","Courier","; 12);"
   
    let m_linha = m_linha - 37
 
    LET m_coluna = 780
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.ordem_coleta
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"
    
    let m_linha = m_linha - 17
    
    LET m_coluna = 780
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.dat_inclusao
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
   
   
   let m_linha = m_linha - 27
    
    LET m_coluna = 780
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.agendamento
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
   
 
  let m_linha = m_linha - 98
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.remetente
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    LET m_coluna = 550
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cidade
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 785
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.uf_rem
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
   
    let m_linha = m_linha - 16
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.remetente
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 550
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cidade
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 785
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.uf_rem
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    let m_linha = m_linha - 16
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.destinatario
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
     
    LET m_coluna = 550
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cidade_dest
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 785
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.uf_dest
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
     
    let m_linha = m_linha - 16
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.remetente
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 550
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cidade
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 785
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.uf_rem
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    let m_linha = m_linha - 16
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.destinatario
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 550
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cidade_dest
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 785
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.uf_dest
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
   
   let m_linha = m_linha - 32 
   
   
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.mercadoria
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
   
   
    let m_linha = m_linha - 48
    
    LET m_coluna = 96
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.motorista
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    LET m_coluna = 400
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cpf
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    LET m_coluna = 640
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cnh
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    
    
    let m_linha = m_linha - 17
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.endereco
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    LET m_coluna = 395
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cidade_mot
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 660
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.uf_mot
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
     
     
     
    let m_linha = m_linha - 17
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.veiculo
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 295
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.marca
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
     
    LET m_coluna = 495
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.modelo
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
     
    LET m_coluna = 660
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.antt
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
     
    
    
     
     
    
    let m_linha = m_linha - 17
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.carreta1
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    LET m_coluna = 295
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.carreta2
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
  
    LET m_coluna = 495
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.carreta3
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
  
    
    
    
    let m_linha = m_linha - 17
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.proprietario
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 550
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cpf_cnpj
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    
    
    let m_linha = m_linha - 17
    
    LET m_coluna = 95
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.end_fornec
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    
    
    LET m_coluna = 550
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.cidade_prop
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
    
    LET m_coluna = 785
    LET m_ind = m_ind + 1
    LET l_texto = lr_relat.uf_propr
    LET ma_config_pdf[m_ind].linha = "easypdf=adicionaTexto(",l_texto clipped," ; ",m_coluna," ; ",m_linha," ; ","0)",";"  
     
      
END function 

#----------------------------------#
 FUNCTION esp0027_func_cria_pagina()
#----------------------------------#

   DEFINE l_texto                      CHAR(500)

   #::: CRIAR UMA P�GINA EM BRANCO.
   LET m_ind = m_ind + 1
   LET ma_config_pdf[m_ind].linha = "easypdf=criarNovaPagina;"
 
      LET m_linha = 595

END FUNCTION

#--------------------------------------------------------#
 FUNCTION esp0027_busca_dados_ordem_coleta(l_ordem_coleta)
#--------------------------------------------------------#
 DEFINE  l_ordem_coleta        LIKE omc_ordem_coleta.ordem_coleta,
         l_remetent            LIKE omc_ordem_coleta.remetent,
         l_veiculo             LIKE omc_ordem_coleta.veiculo,
	        l_veiculo_ntracionad  LIKE omc_ordem_coleta.veiculo_ntracionad,
	        l_veic_ntrac_aux_1    LIKE omc_ordem_coleta.veic_ntrac_aux_1,
	        l_veic_ntrac_aux_2    LIKE omc_ordem_coleta.veic_ntrac_aux_2,
         l_motorista           LIKE omc_ordem_coleta.motorista,
         l_dat_coleta          LIKE omc_ordem_coleta.dat_coleta,
         l_dat_inclusao        LIKE omc_ordem_coleta.dat_inclusao,
         l_hor_inclusao        LIKE omc_ordem_coleta.hor_inclusao,
         l_observacao          LIKE omc_ordem_coleta.observacao,
         l_destinat            LIKE omc_ordem_coleta.destinat

 IF   m_reimpressao
 THEN WHENEVER ERROR CONTINUE
        SELECT remetent, veiculo, veiculo_ntracionad,
               veic_ntrac_aux_1, veic_ntrac_aux_2,
               motorista, dat_coleta, dat_inclusao,
               hor_inclusao, observacao, destinat
          INTO l_remetent, l_veiculo, l_veiculo_ntracionad,
               l_veic_ntrac_aux_1, l_veic_ntrac_aux_2,
               l_motorista, l_dat_coleta, l_dat_inclusao,
               l_hor_inclusao, l_observacao, l_destinat
          FROM omc_ordem_coleta
         WHERE empresa      = p_cod_empresa
           AND ord_coleta_oficial = l_ordem_coleta
           AND serie_ordem_coleta = m_ser_coleta  #717141 - Cesar
      WHENEVER ERROR STOP
 ELSE WHENEVER ERROR CONTINUE
        SELECT remetent, veiculo, veiculo_ntracionad,
               veic_ntrac_aux_1, veic_ntrac_aux_2,
               motorista, dat_coleta, dat_inclusao,
               hor_inclusao, observacao, destinat
          INTO l_remetent, l_veiculo, l_veiculo_ntracionad,
               l_veic_ntrac_aux_1, l_veic_ntrac_aux_2,
               l_motorista, l_dat_coleta, l_dat_inclusao,
               l_hor_inclusao, l_observacao, l_destinat
          FROM omc_ordem_coleta
         WHERE empresa      = p_cod_empresa
           AND ordem_coleta = l_ordem_coleta
      WHENEVER ERROR STOP
 END IF
 IF   SQLCA.sqlcode <> 0
 THEN CALL log003_err_sql('SELECT','omc_ordem_coleta')
 END IF

 RETURN l_remetent,l_veiculo, l_veiculo_ntracionad,
        l_veic_ntrac_aux_1, l_veic_ntrac_aux_2,
        l_motorista, l_dat_coleta, l_dat_inclusao,
        l_hor_inclusao, l_observacao, l_destinat

END FUNCTION

#----------------------------------------------#
 FUNCTION esp0027_busca_placa_veiculo(l_veiculo)
#----------------------------------------------#
 DEFINE l_veiculo    LIKE frt_veiculo.veiculo,
        l_placa      LIKE frt_veiculo.placa

 INITIALIZE l_placa TO NULL

 IF   l_veiculo IS NOT NULL
 THEN WHENEVER ERROR CONTINUE
	       SELECT placa
	         INTO l_placa
	         FROM frt_veiculo
	        WHERE veiculo = l_veiculo
	     WHENEVER ERROR STOP
      IF   SQLCA.sqlcode <> 0
      THEN CALL log003_err_sql('SELECT','frt_veiculo')
	     END IF
 END IF

 RETURN l_placa

END FUNCTION

#------------------------------------------------#
 FUNCTION esp0027_busca_dados_remetent(l_remetent)
#------------------------------------------------#
 DEFINE   l_remetent            LIKE omc_ordem_coleta.remetent,
          l_nom_emitente        LIKE omc_emitente.nom_emitente,
          l_contato             LIKE omc_emitente.contato,
          l_telefone_1          LIKE omc_emitente.telefone_1,
          l_num_cnpj_cpf        LIKE omc_emitente.num_cnpj_cpf,
          l_inscricao_estadual  LIKE omc_emitente.inscricao_estadual,
          l_hor_fim_atendto     LIKE omc_emitente.hor_fim_atendto

 WHENEVER ERROR CONTINUE
   SELECT nom_emitente,
          contato,
          telefone_1,
          num_cnpj_cpf,
          inscricao_estadual,
          hor_fim_atendto
     INTO l_nom_emitente,
          l_contato,
          l_telefone_1,
          l_num_cnpj_cpf,
          l_inscricao_estadual,
          l_hor_fim_atendto
     FROM omc_emitente
    WHERE emitente = l_remetent
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode <> 0
 THEN CALL log003_err_sql('SELECT','omc_emitente')
 END IF

 RETURN l_nom_emitente, l_contato, l_telefone_1,
        l_num_cnpj_cpf, l_inscricao_estadual, l_hor_fim_atendto

END FUNCTION

#----------------------------------------------------#
 FUNCTION esp0027_busca_dados_destinatario(l_destinat)
#----------------------------------------------------#
 DEFINE l_destinat            LIKE omc_ordem_coleta.remetent,
        l_nom_emitente        LIKE omc_emitente.emitente,
        l_cidade              LIKE omc_emitente.cidade,
        l_den_cidade          LIKE cidades.den_cidade,
        l_cod_uni_feder       LIKE cidades.cod_uni_feder

 WHENEVER ERROR CONTINUE
   SELECT nom_emitente,
          cidade
     INTO l_nom_emitente,
          l_cidade
     FROM omc_emitente
    WHERE emitente = l_destinat
 WHENEVER ERROR STOP
 IF   sqlca.sqlcode <> 0
 THEN CALL log003_err_sql('SELECT','omc_emitente')
 END IF

 IF   l_cidade IS NOT NULL
 THEN WHENEVER ERROR CONTINUE
	       SELECT den_cidade,
	              cod_uni_feder
	         INTO l_den_cidade,
	              l_cod_uni_feder
	         FROM cidades
	        WHERE cod_cidade = l_cidade
	     WHENEVER ERROR STOP
      IF   sqlca.sqlcode <> 0
      THEN CALL log003_err_sql('SELECT','cidades')
	     END IF
 END IF

 RETURN l_nom_emitente, l_den_cidade, l_cod_uni_feder

END FUNCTION

#----------------------------------------------------#
 FUNCTION esp0027_busca_dados_endereco(l_ordem_coleta)
#----------------------------------------------------#
 DEFINE l_ordem_coleta        LIKE omc_ordem_coleta.ordem_coleta,
        l_endereco            CHAR(072),
        l_endereco_coleta     LIKE omc_ordem_coleta.endereco_coleta,
        l_compl_endereco      LIKE omc_ordem_coleta.compl_endereco,
        l_num_endereco        LIKE omc_ordem_coleta.num_endereco,
        l_bairro              LIKE omc_emitente.bairro,
        l_cidade              LIKE omc_emitente.cidade

 IF   m_reimpressao
 THEN WHENEVER ERROR CONTINUE
        SELECT endereco_coleta,
               compl_endereco,
               num_endereco,
               bairro_coleta,
               cidade_coleta
          INTO l_endereco_coleta,
               l_compl_endereco,
               l_num_endereco,
               l_bairro,
               l_cidade
          FROM omc_ordem_coleta
         WHERE empresa            = p_cod_empresa
           AND ord_coleta_oficial = l_ordem_coleta
           AND serie_ordem_coleta = m_ser_coleta  #717141 - Cesar
      WHENEVER ERROR STOP
 ELSE WHENEVER ERROR CONTINUE
        SELECT endereco_coleta,
               compl_endereco,
               num_endereco,
               bairro_coleta,
               cidade_coleta
          INTO l_endereco_coleta,
               l_compl_endereco,
               l_num_endereco,
               l_bairro,
               l_cidade
          FROM omc_ordem_coleta
         WHERE empresa      = p_cod_empresa
           AND ordem_coleta = l_ordem_coleta
      WHENEVER ERROR STOP
 END IF

 LET l_endereco = l_endereco_coleta CLIPPED, ", ", l_num_endereco USING "<<<<<<<", " - ", l_compl_endereco

 RETURN l_endereco, l_bairro, l_cidade

END FUNCTION

#----------------------------------------------------#
 FUNCTION esp0027_busca_den_bairro(l_cidade, l_bairro)
#----------------------------------------------------#
 DEFINE l_cidade       LIKE bairros.cod_cidade,
        l_bairro       LIKE omc_emitente.bairro,
        l_den_bairro   LIKE bairros.den_bairro

 INITIALIZE l_den_bairro TO NULL

 IF   l_cidade IS NOT NULL
 AND  l_bairro IS NOT NULL
 THEN WHENEVER ERROR CONTINUE
	       SELECT den_bairro
	         INTO l_den_bairro
	         FROM bairros
	        WHERE cod_cidade = l_cidade
	          AND cod_bairro = l_bairro
	     WHENEVER ERROR STOP
      IF   sqlca.sqlcode <> 0
      THEN CALL log003_err_sql('SELECT','bairros')
	     END IF
 END IF

 RETURN l_den_bairro

END FUNCTION

#------------------------------------------#
 FUNCTION esp0027_busca_den_cidade(l_cidade)
#------------------------------------------#
 DEFINE l_cidade       LIKE cidades.cod_cidade,
        l_den_cidade   LIKE cidades.den_cidade

 INITIALIZE l_den_cidade TO NULL

 IF   l_cidade IS NOT NULL
 THEN WHENEVER ERROR CONTINUE
	       SELECT den_cidade
	         INTO l_den_cidade
	         FROM cidades
	        WHERE cod_cidade = l_cidade
	     WHENEVER ERROR STOP
      IF   sqlca.sqlcode <> 0
      THEN CALL log003_err_sql('SELECT','cidades')
	     END IF
 END IF

 RETURN l_den_cidade

END FUNCTION

#--------------------------------------------------#
 FUNCTION esp0027_busca_dados_motorista(l_motorista)
#--------------------------------------------------#
 DEFINE l_motorista      LIKE frt_motorista.motorista,
        l_nom_motorista  LIKE frt_motorista.nom_motorista,
        l_cpf            LIKE frt_motorista.cpf,
        l_rg             LIKE frt_motr_compl.num_registro_geral

 IF   l_motorista IS NOT NULL
 THEN WHENEVER ERROR CONTINUE
	       SELECT a.nom_motorista, a.cpf
	         INTO l_nom_motorista, l_cpf
	         FROM frt_motorista a
	        WHERE a.motorista = l_motorista
	     WHENEVER ERROR STOP
      IF   sqlca.sqlcode <> 0
      THEN LET l_nom_motorista = NULL
	          LET l_cpf = NULL
	     END IF

	     WHENEVER ERROR CONTINUE
	       SELECT b.num_registro_geral
	         INTO l_rg
	         FROM frt_motr_compl b
	        WHERE b.motorista = l_motorista
	     WHENEVER ERROR STOP
      IF   sqlca.sqlcode <> 0
      THEN LET l_rg = NULL
	     END IF
 END IF

 RETURN l_nom_motorista, l_cpf, l_rg

END FUNCTION

#------------------------------------------------#
 FUNCTION esp0027_busca_dados_item(l_ordem_coleta)
#------------------------------------------------#
 DEFINE l_ordem_coleta     LIKE omc_ordem_coleta.ordem_coleta,
        l_peso_item        LIKE omc_item_coleta.peso_item,
        l_peso_item_total  LIKE omc_item_coleta.peso_item,
        l_qtd_item         LIKE omc_item_coleta.qtd_item,
        l_qtd_item_1       LIKE omc_item_coleta.qtd_item,
        l_qtd_item_2       LIKE omc_item_coleta.qtd_item,
        l_qtd_item_3       LIKE omc_item_coleta.qtd_item,
        l_qtd_item_4       LIKE omc_item_coleta.qtd_item,
        l_item             LIKE omc_item_coleta.item,
        l_item_1           LIKE omc_item_coleta.item,
        l_item_2           LIKE omc_item_coleta.item,
        l_item_3           LIKE omc_item_coleta.item,
        l_item_4           LIKE omc_item_coleta.item,
        l_num_item         SMALLINT

 LET l_peso_item_total = 0
 LET l_num_item        = 1

 INITIALIZE l_qtd_item_1, l_qtd_item_2,
            l_qtd_item_3, l_qtd_item_4,
            l_item_1, l_item_2, l_item_3,
            l_item_4 TO NULL


 IF   m_reimpressao
 THEN LET sql_stmt = " SELECT omc_item_coleta.item,  ",
                            " omc_item_coleta.qtd_item,  ",
                            " omc_item_coleta.peso_item ",
                       " FROM omc_item_coleta, ",
                            " omc_ordem_coleta ",
                      " WHERE omc_ordem_coleta.empresa            = '", p_cod_empresa, "'",
                        " AND omc_ordem_coleta.ord_coleta_oficial =  ", l_ordem_coleta,
                        " AND omc_ordem_coleta.serie_ordem_coleta =  ",'"',m_ser_coleta,'"',  #717141 - Cesar
                        " AND omc_item_coleta.empresa      = omc_ordem_coleta.empresa",
                        " AND omc_item_coleta.ordem_coleta = omc_ordem_coleta.ordem_coleta "
 ELSE
      LET sql_stmt = " SELECT item, qtd_item, peso_item ",
                       " FROM omc_item_coleta ",
                      " WHERE empresa      = '", p_cod_empresa, "'",
                        " AND ordem_coleta =  ", l_ordem_coleta
 END IF

 WHENEVER ERROR CONTINUE
  PREPARE var_dados_item FROM sql_stmt
  DECLARE cq_dados_item CURSOR FOR var_dados_item

 FOREACH cq_dados_item INTO l_item, l_qtd_item, l_peso_item

         CASE l_num_item
              WHEN 1 LET l_qtd_item_1  = l_qtd_item
                     LET l_item_1      = l_item
              WHEN 2 LET l_qtd_item_2  = l_qtd_item
                     LET l_item_2      = l_item
              WHEN 3 LET l_qtd_item_3  = l_qtd_item
                     LET l_item_3      = l_item
              WHEN 4 LET l_qtd_item_4  = l_qtd_item
                     LET l_item_4      = l_item
         END CASE
         LET l_peso_item_total  = l_peso_item_total + l_peso_item
         LET l_num_item = l_num_item + 1

         IF   l_num_item >= 6    #Numero de itens do formul�rio.
         THEN EXIT FOREACH
         END IF
 END FOREACH

 WHENEVER ERROR STOP

 RETURN l_peso_item_total,
        l_qtd_item_1,
        l_qtd_item_2,
        l_qtd_item_3,
        l_qtd_item_4,
        l_item_1,
        l_item_2,
        l_item_3,
        l_item_4

END FUNCTION

#------------------------------------------------------------------#
FUNCTION esp0027_atualiza_ord_coleta_oficial(l_ordem_coleta,
                                             l_ord_coleta_oficial)
#------------------------------------------------------------------#
 DEFINE   l_ordem_coleta       LIKE omc_ordem_coleta.ordem_coleta,
          l_ord_coleta_oficial LIKE omc_ordem_coleta.ord_coleta_oficial

 WHENEVER ERROR CONTINUE
   UPDATE omc_ordem_coleta
      SET ord_coleta_oficial  = l_ord_coleta_oficial,
          serie_ordem_coleta  = m_ser_coleta,
          status_coleta       = '2'
    WHERE empresa             = p_cod_empresa
      AND ordem_coleta        = l_ordem_coleta
 WHENEVER ERROR STOP
 IF   SQLCA.sqlcode <> 0
 THEN CALL log003_err_sql('UPDATE','omc_ordem_coleta')
 END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION esp0027_consiste_ordem_coleta_ini()
#-------------------------------------------#
 IF   mr_consulta.ordem_coleta_ini < 0
 THEN CALL log0030_mensagem(" Ordem de coleta informada inv�lida. ","excl")
      RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

##-------------------------------------------#
# FUNCTION esp0027_consiste_ordem_coleta_fim()
##-------------------------------------------#
# IF   mr_consulta.ordem_coleta_fim < 0
# THEN CALL log0030_mensagem(" Ordem de coleta informada inv�lida. ","excl")
#      RETURN FALSE
# END IF
#
# IF   mr_consulta.ordem_coleta_fim < mr_consulta.ordem_coleta_ini
# THEN CALL log0030_mensagem(" Informe coleta final maior ou igual a coleta inicial. ","excl")
#      RETURN FALSE
# END IF
#
# RETURN TRUE
#
#END FUNCTION

#-----------------------------------------#
 FUNCTION esp0027_consiste_dat_coleta_fim()
#-----------------------------------------#
 IF   mr_consulta.dat_coleta_fim < mr_consulta.dat_coleta_ini
 THEN CALL log0030_mensagem(" Informe data final maior ou igual a data inicial. ","excl")
      RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-----------------------------------------#
 FUNCTION esp0027_consiste_hor_coleta_fim()
#-----------------------------------------#
 IF   mr_consulta.hor_coleta_fim < mr_consulta.hor_coleta_ini
 THEN CALL log0030_mensagem(" Informe hora final maior ou igual a hora inicial. ","excl")
      RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-----------------------------------------#
 FUNCTION esp0027_consiste_emitente(l_par)
#-----------------------------------------#
 DEFINE l_par   SMALLINT

 CASE l_par
      WHEN 1
           CALL esp0027_busca_den_emitente(mr_consulta.remetent)
                RETURNING mr_consulta.nom_remetent

           DISPLAY mr_consulta.nom_remetent TO nom_remetent

           IF   mr_consulta.remetent IS NOT NULL
           THEN WHENEVER ERROR CONTINUE
                  SELECT emitente
                    FROM omc_emitente
                   WHERE emitente = mr_consulta.remetent
                WHENEVER ERROR STOP
                IF   SQLCA.sqlcode <> 0
                THEN CALL log0030_mensagem(' Remetente informado n�o cadastrado. ', 'excl')
                     RETURN FALSE
                END IF
           END IF

      WHEN 2
           CALL esp0027_busca_den_emitente(mr_consulta.destinat)
                RETURNING mr_consulta.nom_destinat

           DISPLAY mr_consulta.nom_destinat TO nom_destinat

           IF   mr_consulta.destinat IS NOT NULL
           THEN WHENEVER ERROR CONTINUE
                  SELECT emitente
                    FROM omc_emitente
                   WHERE emitente = mr_consulta.destinat
                WHENEVER ERROR STOP
                IF   SQLCA.sqlcode <> 0
                THEN CALL log0030_mensagem(' Destinat�rio informado n�o cadastrado. ', 'excl')
                     RETURN FALSE
                END IF
           END IF
 END CASE

 RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION esp0027_busca_den_emitente(l_emitente)
#-----------------------------------------------#
 DEFINE l_emitente        LIKE omc_emitente.emitente,
        l_nom_emitente    LIKE omc_emitente.nom_emitente

 INITIALIZE  l_nom_emitente TO NULL

 IF   l_emitente IS NOT NULL
 THEN WHENEVER ERROR CONTINUE
	       SELECT nom_emitente
	         INTO l_nom_emitente
	         FROM omc_emitente
	        WHERE emitente = l_emitente
	     WHENEVER ERROR STOP
      IF   SQLCA.sqlcode <> 0
      AND	 SQLCA.sqlcode <> NOTFOUND
      THEN	CALL log003_err_sql('LEITURA','omc_emitente')
	     END IF
 END IF

 RETURN l_nom_emitente

END FUNCTION

#----------------------------------------------------------------#
 FUNCTION esp0027a_verifica_ordem_coleta_cadastrada(l_ordem_coleta)
#----------------------------------------------------------------#
 DEFINE l_ordem_coleta    LIKE omc_ordem_coleta.ordem_coleta

 WHENEVER ERROR CONTINUE
   SELECT ord_coleta_oficial
     FROM omc_ordem_coleta
    WHERE empresa   = p_cod_empresa
      AND ord_coleta_oficial = l_ordem_coleta
      AND serie_ordem_coleta = m_ser_coleta
 WHENEVER ERROR STOP
 IF   SQLCA.sqlcode = 0
 THEN RETURN TRUE
 ELSE RETURN FALSE
 END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION esp0027_seleciona_dados_impressao()
#-------------------------------------------#
 INITIALIZE mr_ordem_coleta.* TO NULL

 CALL log006_exibe_teclas('01 02 03 05 06 07', p_versao)
 CURRENT WINDOW IS w_esp0027

 CALL SET_COUNT(m_reg_array)
 INPUT ARRAY ma_ordem_coleta WITHOUT DEFAULTS
        FROM sc_ordem_coleta.*

       BEFORE INPUT
  	           --# CALL fgl_dialog_setkeylabel ("insert","")
  	           --# CALL fgl_dialog_setkeylabel ("delete","")

       BEFORE ROW
        	     LET m_ma_curr = ARR_CURR()
        	     LET m_sc_curr = SCR_LINE()

       AFTER  FIELD imprime
              IF  (ma_ordem_coleta[m_ma_curr].imprime <> 'S' AND
                  ma_ordem_coleta[m_ma_curr].imprime <> 'N') OR
                  (ma_ordem_coleta[m_ma_curr].imprime IS NULL AND
                   ma_ordem_coleta[m_ma_curr].ordem_coleta IS NOT NULL) THEN
                  CALL log0030_mensagem(' Informe S (Sim) ou N (N�o) no campo imprime. ',"excl")
                  NEXT FIELD imprime
              END IF

       ON KEY(control-w)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
          CALL esp0027_help()

       AFTER  INPUT
              IF   NOT INT_FLAG
              THEN IF   (   ma_ordem_coleta[m_ma_curr].imprime <> 'S'
                        AND ma_ordem_coleta[m_ma_curr].imprime <> 'N')
                   OR   (   ma_ordem_coleta[m_ma_curr].imprime IS NULL
                        AND ma_ordem_coleta[m_ma_curr].ordem_coleta IS NOT NULL)
                   THEN CALL log0030_mensagem(' Informe S (Sim) ou N (N�o) no campo imprime. ',"excl")
                        NEXT FIELD imprime
                   END IF
              END IF
 END INPUT

 CALL log006_exibe_teclas('01', p_versao)
 CURRENT WINDOW IS w_esp0027

 IF   INT_FLAG
 THEN LET INT_FLAG = FALSE
      ERROR ' Inclus�o cancelada. '
      RETURN FALSE
 END IF

 IF   m_reimpressao
 THEN RETURN TRUE
 END IF

 INPUT BY NAME mr_ordem_coleta.* WITHOUT DEFAULTS

       AFTER  FIELD cod_barra_ordem
              IF   mr_ordem_coleta.cod_barra_ordem < 0
              THEN CALL log0030_mensagem(' C�digo de barras informado inv�lido. ',"excl")
                   NEXT FIELD cod_barra_ordem
              END IF

              IF   mr_ordem_coleta.cod_barra_ordem IS NOT NULL
              THEN IF   esp0027a_verifica_ordem_coleta_cadastrada(mr_ordem_coleta.cod_barra_ordem)
                   THEN CALL log0030_mensagem(' C�digo de barras j� utilizado em outra ordem de coleta. ',"excl")
                        NEXT FIELD cod_barra_ordem
                   ELSE INITIALIZE mr_ordem_coleta.linh_ordem TO NULL
                        DISPLAY mr_ordem_coleta.linh_ordem TO linh_ordem
                        EXIT INPUT
                   END IF
              END IF

       BEFORE FIELD linh_ordem
    	         WHENEVER ERROR CONTINUE
    	           SELECT MIN(num_formulario)
    	             INTO mr_ordem_coleta.linh_ordem
  	               FROM omc_ctr_formulario
                 WHERE empresa          = p_cod_empresa
 		                AND dat_utilizacao     IS NULL
 		                AND cancelado       <> 'S'
 		                AND tip_formulario   = '2'
 		                AND serie_formulario = mr_consulta.serie_ordem_coleta #717141 - Cesar
 		           WHENEVER ERROR STOP

 	            DISPLAY mr_ordem_coleta.linh_ordem TO linh_ordem

       AFTER  FIELD linh_ordem
              IF   mr_ordem_coleta.linh_ordem < 0
              THEN CALL log0030_mensagem(' Linha digit�vel informada inv�lida. ',"excl")
                   NEXT FIELD linh_ordem
              END IF

              IF   mr_ordem_coleta.linh_ordem IS NOT NULL
              THEN IF   esp0027a_verifica_ordem_coleta_cadastrada(mr_ordem_coleta.linh_ordem)
                   THEN CALL log0030_mensagem(' Linha digit�vel j� utilizada em outra ordem de coleta. ',"excl")
                        NEXT FIELD linh_ordem
                   END IF
              END IF

       ON KEY(control-w)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
          CALL esp0027_help()

       ON KEY (control-z, f4)
          CALL esp0027_popup()

       AFTER INPUT

           IF   NOT INT_FLAG THEN

                IF   mr_ordem_coleta.cod_barra_ordem IS NULL
                AND  mr_ordem_coleta.linh_ordem IS NULL
                THEN CALL log0030_mensagem(' Informe c�digo de barra ou linha digit�vel. ',"excl")
                     NEXT FIELD cod_barra_ordem
                END IF
                {Inicio - #717141 - Cesar}
             	  IF mr_ordem_coleta.linh_ordem IS NOT NULL AND
             	     mr_ordem_coleta.linh_ordem <> ' ' THEN
                   IF NOT omc0875_valida_serie_formulario(p_cod_empresa, '4', mr_consulta.serie_ordem_coleta, mr_ordem_coleta.linh_ordem ) THEN
                      CALL log0030_mensagem('Este formul�rio n�o � v�lido para esta s�rie.','excl')
                      NEXT FIELD linh_ordem
                   END IF
             	  END IF
             	  {Fim - #717141 - Cesar}

           END IF
 END INPUT

 IF INT_FLAG THEN
    LET INT_FLAG = FALSE
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION

#------------------------#
 FUNCTION esp0027_popup()
#------------------------#
 DEFINE  l_remetent      LIKE omc_emitente.emitente,
         l_destinat      LIKE omc_emitente.emitente

 CASE
     WHEN INFIELD(remetent)
          LET l_remetent = omc0816_popup_emitente(7,3)
          CURRENT WINDOW IS w_esp0027

          IF   l_remetent IS NOT NULL
          AND  l_remetent <> ' '
          THEN LET mr_consulta.remetent = l_remetent
               CALL esp0027_busca_den_emitente(l_remetent)
                    RETURNING mr_consulta.nom_remetent
          END IF

          DISPLAY mr_consulta.remetent     TO remetent
          DISPLAY mr_consulta.nom_remetent TO nom_remetent

     WHEN INFIELD(destinat)
          LET l_destinat = omc0816_popup_emitente(7,3)
          CURRENT WINDOW IS w_esp0027

          IF   l_destinat IS NOT NULL
          AND  l_destinat <> ' '
          THEN LET mr_consulta.destinat = l_destinat
               CALL esp0027_busca_den_emitente(l_destinat)
                    RETURNING mr_consulta.nom_destinat
          END IF

          DISPLAY mr_consulta.destinat     TO destinat
          DISPLAY mr_consulta.nom_destinat TO nom_destinat

     {Inicio - #717141 - Cesar}
     WHEN infield(serie_ordem_coleta)
          LET mr_consulta.serie_ordem_coleta = omc0875_busca_serie_docum(p_cod_empresa, '4', TRUE)
          CURRENT WINDOW IS w_esp0027
          DISPLAY BY NAME mr_consulta.serie_ordem_coleta
     {Fim - #717141 - Cesar}

 END CASE

END FUNCTION

#-------------------------------#
 FUNCTION esp0027_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Sustentacao/10R2-11R0/10R2-11R0/logistica/tms/programas/esp0027.4gl $|$Revision: 10 $|$Date: 31/10/11 08:19 $|$Modtime: 25/05/10 17:05 $" #Informa��es do controle de vers�o do SourceSafe - N�o remover esta linha (FRAMEWORK)
 END FUNCTION



                                                                                                                  
#-----------------------------------------#                                                                       
FUNCTION esp0027_relat_inicializa_processo_pdf()                                                                 
#-----------------------------------------#                                                                       
                                                                                                                  
   DEFINE l_arquivo_remove   CHAR(150)                                                                            
   DEFINE l_diretorio_config CHAR(150)                                                                            
                                                                                                                  
   DEFINE l_tamanho          SMALLINT,                                                                            
          l_indice           SMALLINT,                                                                            
          l_diretorio        CHAR(100)                                                                            
                                                                                                                  
   #::: INICIALIZA��O DO PDF :::#                                                                                 
   LET m_ind = 0                                                                                                  
   INITIALIZE ma_config_pdf, m_diretorio_pdf TO NULL                                                              
   #:::::                                                                                                         
                                                                                                                  
   #::: DIRETORIO QUE SER� GRAVADO E DIRETORIO DE IMAGEM :::#                                                     
   CALL log150_procura_caminho('LST') RETURNING m_diretorio_pdf                                                   
   CALL log150_procura_caminho('IMG') RETURNING m_diretorio_img                                                   
   #:::                                                                                                           
   LET m_date = TODAY                                                                                             
   LET m_date = log0800_replace(m_date,'/','_')                                                                   
                                                                                                                  
   LET m_hora = TIME                                                                                              
   LET m_hora = log0800_replace(m_hora,':','_')                                                                   
                                                                                                                   
   LET l_diretorio_config = m_diretorio_pdf CLIPPED,m_date,'_',m_hora,'_',p_user CLIPPED,'_','config.txt' 
                                                                                                                  
   IF g_ies_ambiente = "W" THEN                                                                                   
      LET l_arquivo_remove = 'del ',l_diretorio_config CLIPPED                                                    
   ELSE                                                                                                           
      LET l_arquivo_remove = 'rm ',l_diretorio_config CLIPPED                                                     
   END IF                                                                                                         
                                                                                                                  
   RUN l_arquivo_remove                                                                                           
                                                                                                                  
                                                                                                                  
                                                                                                                  
                                                                                                                  
                                                                                                                  
                                                                                                                  
   #::: CONCATENAR :::#                                                                                           
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "concatenar=nao;"                                                             
                                                                                                                  
   #::: DIRETORIO + NOME DO PDF QUE SER� GERADO.                                                                  
   LET m_nome_arquivo =  m_diretorio_pdf CLIPPED,m_date,'_',m_hora,'_',p_user CLIPPED,'_','.pdf'                  
                                                                                                                  
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha ="caminho=", m_nome_arquivo CLIPPED                                             
                                                                                                                  
   #::: DIRETORIO TEMPORARIO :::#                                                                                 
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "temporario=",m_nome_arquivo CLIPPED                                          
                                                                                                                  
   #::: DEBUG :::#                                                                                                
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "debug=true"                                                                  
                                                                                                                  
   #::: WEIGHT :::#                                                                                               
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "weight=842"                                                                  
                                                                                                                  
   #::: HEIGHT :::#                                                                                               
   LET m_ind = m_ind + 1                                                                                          
   LET ma_config_pdf[m_ind].linha = "height=595"                                                                  
                                                                                                                  
   #:::::::::::::::::::::::::::::::::::#                                                                          
                                                                                                                  
END FUNCTION                                                                                           



#--------------------------------#
FUNCTION esp0027_relat_gera_pdf()
#--------------------------------#

   DEFINE l_ind     SMALLINT 
   DEFINE l_tst SMALLINT
   define l_comando char(200)

   DEFINE l_diretorio_config CHAR(100),
          l_diretorio_pdf    CHAR(100),
          l_caminho_pdf      CHAR(100),
          l_caminho_imp      CHAR(200)

   DEFINE l_mensagem         CHAR(100),
          l_arquivo          CHAR(30)


   LET l_diretorio_config = m_diretorio_pdf CLIPPED,m_date,'_',m_hora,'_',p_user CLIPPED,'_','config.txt' 
   CALL log4070_channel_open_file("configuracao",l_diretorio_config,"w")
   CALL log4070_channel_set_delimiter("configuracao","")

   FOR l_ind = 1 TO m_ind
      CALL log4070_channel_write("configuracao",ma_config_pdf[l_ind].linha)
   END FOR

   CALL log4070_channel_close("configuracao")
   LET l_comando = "java -Dfile.encoding=ISO-8859-1 easyPDF ",l_diretorio_config
   
   call conout(l_comando)

   RUN l_comando CLIPPED
   CALL _advpl_LOG_file_previewInClient(m_nome_arquivo,FALSE,NULL)

END FUNCTION           