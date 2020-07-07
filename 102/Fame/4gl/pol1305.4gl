# SISTEMA.: INTEGRAÇÃO DO LOGIX x EGA - MAN912                                 #
# PROGRAMA: pol1305                                                            #
# OBJETIVO: EXPORTAÇÃO DO LOGIX x EGA                                          #
# AUTOR...: IVO H BARBOSA             R                                        #
# DATA....: 11/11/2005                                                         #
# ALTERADO: 12/12/2006 por ANA PAULA                                           #
#------------------------------------------------------------------------------#
 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150)
END GLOBALS

DEFINE    m_msg                  CHAR(150),
          m_erro                 CHAR(10),
          m_tem_oper             SMALLINT

DEFINE    m_cod_item             LIKE item.cod_item,
          m_num_ordem            LIKE ordens.num_ordem,
          m_ies_situa            LIKE ordens.ies_situa,
          m_ies_oper_final       LIKE ord_oper.ies_oper_final,
          m_ies_impressao        LIKE ord_oper.ies_impressao,
          m_cod_operac           LIKE ord_oper.cod_operac,
          m_num_seq_operac       LIKE ord_oper.num_seq_operac,
          m_dat_entrega          LIKE ordens.dat_entrega,
          m_dat_abert            LIKE ordens.dat_abert,
          m_dat_ini_planej       LIKE man_oper_compl.dat_ini_planejada,
          m_dat_fim_planej       LIKE man_oper_compl.dat_trmn_planejada,
          m_qtd_planej           LIKE ordens.qtd_planej,
          m_num_docum            LIKE ordens.num_docum


DEFINE    mr_complete            RECORD LIKE TBLInWOComplete.*,
          mr_product             RECORD LIKE TBLInProduct.*,
          mr_queue               RECORD LIKE TBLInWOQueue.*,
          mr_item                RECORD LIKE item.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 30
   DEFER INTERRUPT 
   LET p_versao = "pol1186-12.00.01  "
   CALL func002_versao_prg(p_versao)

   CALL log001_acessa_usuario("ESPEC999","")     
       RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      LET m_msg = NULL
      CALL pol1186_processa() 
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')   
      END IF
   END IF

END MAIN

#------------------------------#
FUNCTION pol1186_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   #CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   #CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   #CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user
   
   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '01'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_user IS NULL THEN
      LET p_user = 'pol1186'
   END IF
      
   LET m_msg = NULL
   CALL pol1186_processa() 
   
   IF m_msg IS NOT NULL THEN
      RETURN 1
   ELSE
      RETURN 0
   END IF
   
END FUNCTION   

#--------------------------#
FUNCTION pol1186_processa()#
#--------------------------#
   
   DEFINE l_cod_empresa    LIKE empresa.cod_empresa,
          l_qtd_planej     LIKE ordens.qtd_planej,
          l_dat_entrega    LIKE ordens.dat_entrega,
          l_integra        SMALLINT
   
   LET l_integra = FALSE
   
   DECLARE cq_ordens CURSOR WITH HOLD FOR 
    SELECT cod_empresa,
           num_ordem, 
           cod_item,
           dat_abert,       #Data de Emissão da Ordem
           dat_entrega,     #Data do Prazo da ordem
           qtd_planej,
           ies_situa,       #Status da Ordem
           num_docum        #Código do Processo que deu origem às operações
      FROM ordens 
     WHERE cod_empresa = p_cod_empresa
       AND ies_situa   = '4' 
       AND num_ordem NOT IN
        (SELECT num_ordem from ordens_export_912
          WHERE ordens_export_912.cod_empresa = ordens.cod_empresa
            AND ordens_export_912.qtd_planej = ordens.qtd_planej)

   FOREACH cq_ordens INTO 
           l_cod_empresa,
           m_num_ordem,
           m_cod_item,
           m_dat_abert,
           m_dat_entrega,
           m_qtd_planej,
           m_ies_situa,
           m_num_docum
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ',m_erro CLIPPED,
             ' LENDO A TABELA ORDENS.'
         RETURN
      END IF
      
      INITIALIZE mr_complete.* TO NULL      
      
      LET mr_complete.WOSituation = '0'
      
      LET p_cod_empresa = l_cod_empresa
           
      SELECT qtd_planej,
             dat_entrega
        INTO l_qtd_planej,
             l_dat_entrega
        FROM ordens_export_912
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = m_num_ordem

      IF STATUS = 100 THEN
      ELSE
         IF STATUS = 0 THEN
            IF l_qtd_planej = m_qtd_planej THEN
               CONTINUE FOREACH
            END IF
         ELSE
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED,
                ' LENDO A TABELA ORDENS_EXPORT_912.'
            RETURN
         END IF
      END IF       
      
      MESSAGE 'Ordem: ', m_num_ordem
      #lds CALL LOG_refresh_display()
      
      LET mr_complete.ProcListCode = m_num_docum
      LET mr_complete.TotalQty = m_qtd_planej
      LET mr_complete.ProductCode = m_cod_item
      LET mr_complete.WoCode = m_num_ordem
      LET mr_complete.DtIssue = m_dat_abert
      LET mr_complete.DtDue = m_dat_entrega
      IF mr_complete.DtDue IS NULL THEN
         LET mr_complete.DtDue = TODAY
      END IF
      
      LET mr_complete.BaseQty = 1         #Quantidade base para o cálculo de consumo de material   
      LET mr_complete.FlgEng = 0          #Determina o tipo de Ordem da tabela TBLWOHD             
      LET mr_complete.Excluded = 0        #Registro excluído no ERP                                
      LET mr_complete.Integrated = 0      #Status do registro(liberado para ser integrado)         
      LET mr_complete.Selected = 0        #Campo destinado ao uso no Filemanager                   

      IF m_ies_situa = '4' THEN
         LET mr_complete.Status = 20
      ELSE
         IF m_ies_situa = '9' THEN
            LET mr_complete.Status = 60
         ELSE
            LET mr_complete.Status = 0
         END IF
      END IF
   
      SELECT *
        INTO mr_item.*
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = m_cod_item
      
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED,
                ' LENDO A TABELA ITEM.'
            RETURN
         END IF
      END IF
      
      LET mr_complete.Unit1Code = mr_item.cod_unid_med
      
      LET m_tem_oper = FALSE
      
      BEGIN WORK
      
      DECLARE cq_operacoes CURSOR WITH HOLD FOR 
       SELECT a.cod_operac,      #código da operação
              a.num_seq_operac,
              b.den_operac,      #Nome da operação
              a.qtd_horas_setup, #Tempo de set-up na unidade definida pelo campo SetupTimeFormat
              a.ies_oper_final,
              a.ies_impressao,
              a.qtd_planejada    #Quantidade prevista para essa operação
    
         FROM ord_oper a, operacao b
        WHERE a.cod_empresa = p_cod_empresa
          AND a.cod_empresa = b.cod_empresa
          AND a.cod_operac  = b.cod_operac
          AND a.num_ordem   = m_num_ordem
        ORDER BY a.num_seq_operac

      FOREACH cq_operacoes INTO
            m_cod_operac,
            m_num_seq_operac,
            mr_complete.WODetName,
            mr_complete.SetUpTime,
            m_ies_oper_final,
            m_ies_impressao,
            mr_complete.Qty

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ',m_erro CLIPPED,
               ' LENDO A TABELA ORD_OPER.'
            EXIT FOREACH
         END IF
                  
         LET mr_complete.WODetCode = m_cod_operac
         LET mr_complete.SetUpTimeFormat = 3  #Formato de apresentação tempo de set-up (Hr)
         LET mr_complete.FlgQCInspection = 0  #Indica se a operação sofrerá inspeção por amostragem

         IF m_ies_oper_final = 'S' THEN
            LET mr_complete.ReportTrigger = 1
         ELSE
            LET mr_complete.ReportTrigger = 0
         END IF

         IF m_ies_impressao = 'S' THEN
            LET mr_complete.DisablePrint = 1
         ELSE
            LET mr_complete.DisablePrint = 0
         END IF

         LET mr_complete.DtCreation = CURRENT
      
         #-----------------------------#
         # campos que tenho dúvidas
         LET mr_complete.StdSpeed = 0 
         LET mr_complete.StdSpeedFormat = 0
         LET mr_complete.WODetStatus = 20
         LET mr_complete.ManagerGrpCode = ' '
         LET mr_complete.DefaultOrigin = 2
         LET mr_complete.DefaultType = 1
         LET mr_complete.PlanType = 0
         #-----------------------------#
         
         SELECT dat_ini_planejada,
                dat_trmn_planejada
           INTO m_dat_ini_planej,
                m_dat_fim_planej
           FROM man_oper_compl
          WHERE empresa = p_cod_empresa
            AND ordem_producao = m_num_ordem
            AND operacao = m_cod_operac
            AND sequencia_operacao = m_num_seq_operac

         IF STATUS = 100 THEN
            LET m_dat_ini_planej = NULL
            LET m_dat_fim_planej = NULL
         ELSE
            IF STATUS <> 0 THEN
               LET m_erro = STATUS
               LET m_msg = 'ERRO ',m_erro CLIPPED,
                   ' LENDO A TABELA MAN_OPER_COMPL.'
               EXIT FOREACH
            END IF
         END IF
          
         LET mr_complete.DtPlanStart = m_dat_ini_planej  #Data Planejada de Inicio da ordem
         LET mr_complete.DtPlanEnd = m_dat_fim_planej    #Data Planejada de Fim da ordem
         LET mr_complete.WoTypeCode = ' '
         
         IF NOT pol1305_ins_complete() THEN
            EXIT FOREACH
         END IF

         IF NOT pol1305_ins_queue() THEN
            EXIT FOREACH
         END IF

         LET m_tem_oper = TRUE
      
      END FOREACH
      
      IF m_msg IS NOT NULL THEN
         ROLLBACK WORK
         RETURN
      END IF

      IF NOT m_tem_oper THEN
         ROLLBACK WORK
         CONTINUE FOREACH
      END IF

      IF NOT pol1305_ins_product() THEN
         ROLLBACK WORK
         RETURN
      END IF
      
      IF NOT pol1305_ins_ordens_912() THEN
         ROLLBACK WORK
         RETURN
      END IF
      
      COMMIT WORK
      
      LET l_integra = TRUE
      
   END FOREACH

   IF l_integra THEN
      CALL pol1305_chama_delphi()
   END IF
   
END FUNCTION

#------------------------------#
FUNCTION pol1305_ins_complete()#
#------------------------------#
   
   LET mr_complete.IDInWOComplete = 0
   LET mr_complete.ies_exportar = 'S'
   
   INSERT INTO TBLInWOComplete (
      WoCode,                   
      ProductCode,              
      WOSituation,              
      ExtCode,                  
      Auxcode1,                 
      Auxcode2,                 
      WoTypeCode,               
      DtIssue,                  
      DtDue,                    
      DtPlanStart,              
      DtPlanEnd,                
      TotalQty,                 
      Status,                   
      Comments,                 
      TechDoc,                  
      ProcListCode,             
      FlgPrinted,               
      WODetCode,                
      WODetName,                
      WODetExtCode,             
      WODetAuxCode1,            
      WODetAuxCode2,            
      WODetTechDoc,             
      StdSpeed,                 
      StdSpeedFormat,           
      ResourceCode,             
      WODetStatus,              
      WODetDtPlanStart,         
      WODetDtPlanEnd,           
      ManagerGrpCode,           
      DefaultOrigin,           
      DefaultType,              
      SetUpTime,                
      SetUpTimeFormat,          
      StdCrew,                  
      PlanType,                 
      Unit1Factor,              
      ReportTrigger,            
      DisablePrint,             
      BaseQty,                  
      MatListCode,              
      Qty,                      
      Unit1Code,                
      Unit2Factor,              
      Unit2Code,                
      Unit3Factor,              
      Unit3Code,                
      LabelCode,                
      FlgQCInspection,          
      DefaultAddressCode,       
      ConsAddressCode,          
      ProdAddressCode,          
      ScrapAddressCode,         
      ReWorkAddressCode,        
      Yield,                    
      Unit1FactorScrap,         
      Unit1FactorReWork,        
      MPSPlanHDCode,            
      WOCodeOrigin,             
      BackFlushType,            
      LotCodeBackFlushType,     
      DefaultFactorOrigin,      
      DefaultFactorScrapOrigin, 
      DefaultFactorReWorkOrigin,
      StdCycleTime,             
      StdCycleTimeOrigin,       
      DefaultCycleTimeOrigin,   
      CommittedStdSpeed,        
      FlgEng,                   
      ToolingTypeCode,          
      Excluded,                 
      Integrated,               
      DtCreation,               
      DtIntegration,            
      ErrDescription,           
      Selected,                 
      DataOrigin,               
      DtTimeStampImp)
   VALUES(mr_complete.WoCode,                   
          mr_complete.ProductCode,              
          mr_complete.WOSituation,              
          mr_complete.ExtCode,                  
          mr_complete.Auxcode1,                 
          mr_complete.Auxcode2,                     
          mr_complete.WoTypeCode,               
          mr_complete.DtIssue,                  
          mr_complete.DtDue,                    
          mr_complete.DtPlanStart,              
          mr_complete.DtPlanEnd,                    
          mr_complete.TotalQty,                 
          mr_complete.Status,                   
          mr_complete.Comments,                 
          mr_complete.TechDoc,                  
          mr_complete.ProcListCode,                 
          mr_complete.FlgPrinted,               
          mr_complete.WODetCode,                
          mr_complete.WODetName,                
          mr_complete.WODetExtCode,             
          mr_complete.WODetAuxCode1,                
          mr_complete.WODetAuxCode2,            
          mr_complete.WODetTechDoc,             
          mr_complete.StdSpeed,                 
          mr_complete.StdSpeedFormat,           
          mr_complete.ResourceCode,                 
          mr_complete.WODetStatus,              
          mr_complete.WODetDtPlanStart,         
          mr_complete.WODetDtPlanEnd,           
          mr_complete.ManagerGrpCode,           
          mr_complete.DefaultOrigin,                
          mr_complete.DefaultType,              
          mr_complete.SetUpTime,                
          mr_complete.SetUpTimeFormat,          
          mr_complete.StdCrew,                  
          mr_complete.PlanType,                     
          mr_complete.Unit1Factor,              
          mr_complete.ReportTrigger,            
          mr_complete.DisablePrint,             
          mr_complete.BaseQty,                  
          mr_complete.MatListCode,                  
          mr_complete.Qty,                      
          mr_complete.Unit1Code,                
          mr_complete.Unit2Factor,              
          mr_complete.Unit2Code,                
          mr_complete.Unit3Factor,                  
          mr_complete.Unit3Code,                
          mr_complete.LabelCode,                
          mr_complete.FlgQCInspection,          
          mr_complete.DefaultAddressCode,       
          mr_complete.ConsAddressCode,              
          mr_complete.ProdAddressCode,          
          mr_complete.ScrapAddressCode,         
          mr_complete.ReWorkAddressCode,        
          mr_complete.Yield,                    
          mr_complete.Unit1FactorScrap,             
          mr_complete.Unit1FactorReWork,        
          mr_complete.MPSPlanHDCode,            
          mr_complete.WOCodeOrigin,             
          mr_complete.BackFlushType,            
          mr_complete.LotCodeBackFlushType,         
          mr_complete.DefaultFactorOrigin,      
          mr_complete.DefaultFactorScrapOrigin, 
          mr_complete.DefaultFactorReWorkOrigin,
          mr_complete.StdCycleTime,             
          mr_complete.StdCycleTimeOrigin,           
          mr_complete.DefaultCycleTimeOrigin,   
          mr_complete.CommittedStdSpeed,        
          mr_complete.FlgEng,                   
          mr_complete.ToolingTypeCode,          
          mr_complete.Excluded,                     
          mr_complete.Integrated,               
          mr_complete.DtCreation,               
          mr_complete.DtIntegration,            
          mr_complete.ErrDescription,           
          mr_complete.Selected,                     
          mr_complete.DataOrigin,               
          mr_complete.DtTimeStampImp)           
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,
         ' GRAVANDO A TABELA TBLInWOComplete.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1305_ins_queue()#
#---------------------------#

   INITIALIZE mr_queue TO NULL
   
   LET mr_queue.IDInWOQueue = 0
   LET mr_queue.Sequence = m_num_seq_operac
   LET mr_queue.WOCode = m_num_ordem
   LET mr_queue.WODetCode = m_cod_operac
   LET mr_queue.WOEngCode = ' '
   LET mr_queue.Qty = m_qtd_planej
   LET mr_queue.DtStart = m_dat_ini_planej
   LET mr_queue.DtEnd = m_dat_fim_planej
   LET mr_queue.Excluded = 0
   LET mr_queue.Integrated = 0
   LET mr_queue.DtCreation = CURRENT
   LET mr_queue.Selected = 0
   LET mr_queue.ies_exportar = 'S'
   
   INSERT INTO TBLInWOQueue(
      ManagerGrpCode,
      ResourceCode,  
      Sequence,      
      WOCode,        
      WODetCode,     
      WOEngCode,     
      Qty,           
      DtStart,       
      DtEnd,         
      Excluded,      
      Integrated,    
      DtCreation,    
      DtIntegration, 
      ErrDescription,
      Selected,      
      DataOrigin,    
      DtTimeStampImp)
   VALUES(mr_queue.ManagerGrpCode, 
          mr_queue.ResourceCode,   
          mr_queue.Sequence,       
          mr_queue.WOCode,         
          mr_queue.WODetCode,      
          mr_queue.WOEngCode,      
          mr_queue.Qty,            
          mr_queue.DtStart,        
          mr_queue.DtEnd,          
          mr_queue.Excluded,       
          mr_queue.Integrated,     
          mr_queue.DtCreation,     
          mr_queue.DtIntegration,  
          mr_queue.ErrDescription, 
          mr_queue.Selected,       
          mr_queue.DataOrigin,     
          mr_queue.DtTimeStampImp) 

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,
         ' GRAVANDO A TABELA TBLInWOQueue.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1305_ins_product()#
#-----------------------------#

   INITIALIZE mr_product TO NULL
   
   LET mr_product.IDInProduct = 0
   LET mr_product.PlantCode = '-10'
   LET mr_product.ProductTypeCode = mr_item.ies_tip_item
   LET mr_product.Code = mr_item.cod_item
   LET mr_product.Name = mr_item.den_item
   LET mr_product.Unit1Code = mr_item.cod_unid_med
   LET mr_product.FlgEnable = 1
   LET mr_product.FlgPrintP00 = 0 
   LET mr_product.FlgPrintP01 = 0 
   LET mr_product.FlgPrintP02 = 0 
   LET mr_product.FlgPrintP03 = 0 
   LET mr_product.FlgPrintP04 = 0 
   LET mr_product.FlgPrintP05 = 0 
   LET mr_product.FlgPrintP06 = 0 
   LET mr_product.FlgPrintP07 = 0 
   LET mr_product.FlgPrintP08 = 0 
   LET mr_product.FlgPrintP09 = 0 
   LET mr_product.FlgPrintP10 = 0 
   LET mr_product.FlgPrintP11 = 0 
   LET mr_product.FlgprintP12 = 0 
   LET mr_product.FlgBackFlush = 0
   LET mr_product.Excluded = 0
   LET mr_product.Integrated = 0
   LET mr_product.DtCreation = CURRENT
   LET mr_product.Selected = 0
   LET mr_product.ies_exportar = 'S'
  
   INSERT INTO TBLInProduct (
      PlantCode,            
      ProductTypeCode,      
      Code,                 
      Name,                 
      Description,          
      Unit1Code,            
      Unit2Code,            
      Unit2Factor,          
      Unit3Code,            
      Unit3Factor,          
      ExtCode,              
      FlgEnable,            
      FlgPrintP00,          
      FlgPrintP01,          
      FlgPrintP02,          
      FlgPrintP03,          
      FlgPrintP04,          
      FlgPrintP05,          
      FlgPrintP06,          
      FlgPrintP07,          
      FlgPrintP08,          
      FlgPrintP09,          
      FlgPrintP10,          
      FlgPrintP11,          
      FlgprintP12,          
      QtyPackage,           
      QtyProdReport,        
      QtyCEP,               
      QtyQC,                
      ValiditPeriod,        
      ValPeriodUnit,        
      ProductLabelCode,     
      QualityLabelCode,     
      BUnitCode,            
      Yield,                
      WOCriteria,           
      MinLot,               
      EconomicLot,          
      LogLeadTime,          
      QueueLeadTime,        
      CostCenterCode,       
      QtdBillMatCons,       
      DefaultAddressCode,   
      FlgBackFlush,         
      BackFlushType,        
      LotBackFlushType,     
      AddressBackFlushType, 
      SecondName,           
      FamilyProductCode,    
      FamilyProductName,    
      ValueScrap,           
      Label_ItemCode,       
      ReportByLot,          
      BackFlushTypeOrigin,  
      ScrapBFlush,          
      FlgTooling,           
      Excluded,             
      Integrated,           
      DtCreation,           
      DtIntegration,        
      ErrDescription,       
      Selected,             
      DataOrigin,           
      DtTimeStampImp)       
   VALUES(mr_product.PlantCode,            
          mr_product.ProductTypeCode,      
          mr_product.Code,                 
          mr_product.Name,                 
          mr_product.Description,          
          mr_product.Unit1Code,            
          mr_product.Unit2Code,            
          mr_product.Unit2Factor,          
          mr_product.Unit3Code,            
          mr_product.Unit3Factor,          
          mr_product.ExtCode,              
          mr_product.FlgEnable,            
          mr_product.FlgPrintP00,          
          mr_product.FlgPrintP01,          
          mr_product.FlgPrintP02,          
          mr_product.FlgPrintP03,          
          mr_product.FlgPrintP04,          
          mr_product.FlgPrintP05,          
          mr_product.FlgPrintP06,          
          mr_product.FlgPrintP07,          
          mr_product.FlgPrintP08,          
          mr_product.FlgPrintP09,          
          mr_product.FlgPrintP10,          
          mr_product.FlgPrintP11,          
          mr_product.FlgprintP12,          
          mr_product.QtyPackage,           
          mr_product.QtyProdReport,        
          mr_product.QtyCEP,               
          mr_product.QtyQC,                
          mr_product.ValiditPeriod,        
          mr_product.ValPeriodUnit,        
          mr_product.ProductLabelCode,     
          mr_product.QualityLabelCode,     
          mr_product.BUnitCode,            
          mr_product.Yield,                
          mr_product.WOCriteria,           
          mr_product.MinLot,               
          mr_product.EconomicLot,          
          mr_product.LogLeadTime,          
          mr_product.QueueLeadTime,        
          mr_product.CostCenterCode,       
          mr_product.QtdBillMatCons,       
          mr_product.DefaultAddressCode,   
          mr_product.FlgBackFlush,         
          mr_product.BackFlushType,        
          mr_product.LotBackFlushType,     
          mr_product.AddressBackFlushType, 
          mr_product.SecondName,           
          mr_product.FamilyProductCode,    
          mr_product.FamilyProductName,    
          mr_product.ValueScrap,           
          mr_product.Label_ItemCode,       
          mr_product.ReportByLot,          
          mr_product.BackFlushTypeOrigin,  
          mr_product.ScrapBFlush,          
          mr_product.FlgTooling,           
          mr_product.Excluded,             
          mr_product.Integrated,           
          mr_product.DtCreation,           
          mr_product.DtIntegration,        
          mr_product.ErrDescription,       
          mr_product.Selected,             
          mr_product.DataOrigin,           
          mr_product.DtTimeStampImp)       
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,
         ' GRAVANDO A TABELA TBLInProduct.'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION
   
   
#--------------------------------#
FUNCTION pol1305_ins_ordens_912()#
#--------------------------------#

   DELETE FROM ordens_export_912
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,
         ' DELETANDO DADOS DA TABELA ordens_export_912.'
      RETURN FALSE
   END IF

   INSERT INTO ordens_export_912 (
      cod_empresa, 
      num_ordem,   
      qtd_planej,  
      dat_entrega)
   VALUES(p_cod_empresa,
          m_num_ordem,
          m_qtd_planej,
          m_dat_entrega)
           
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED,
         ' GRAVANDO A TABELA ordens_export_912.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1305_chama_delphi()#
#------------------------------#

   DEFINE p_param    CHAR(42),
          p_comando  CHAR(200)
   
   SELECT nom_caminho
     INTO p_caminho
     FROM path_logix_v2
    WHERE cod_empresa = p_cod_empresa 
      AND cod_sistema = 'DPH'
  
   IF p_caminho IS NULL THEN
      LET p_caminho = 'Caminho do sistema DPH não en-\n',
                      'contrado. Consulte a log1100.'
      CALL log0030_mensagem(p_caminho,'Info')
      RETURN
   END IF

   LET p_comando = p_caminho CLIPPED, 'pgi1174.exe ' #colocar nome do pgi aqui

   #CALL conout(p_comando)                            #tirar o comentario

   #CALL runOnClient(p_comando)                       #tirar o comentario

END FUNCTION   


   