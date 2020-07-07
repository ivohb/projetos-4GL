<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten��o:     Henrique
 //Data manuten��o:24/06/2005
 //M�dulo:         SUP
 //Processo:       SUPRIMENTOS - Emiss�o de Posi��o de Estoque
 //-----------------------------------------------------------------------------
 $prog="sup/sup0003";
 $versao=1;  
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $funcio="select a.cod_empresa,a.den_empresa,a.num_cgc,a.den_munic,a.end_empresa,
                a.num_telefone,a.cod_cep,a.ins_estadual,a.den_bairro,
		a.uni_feder,a.num_fax,
                b.cod_usuario,b.cod_rep,b.erep,
                b.fone,b.fax,b.celular,b.email

	from	empresa a,
                lt1200:lt1200_usuarios b
	where	a.cod_empresa='".$empresa."'
	        and b.cod_usuario='".$ifx_user."'
	";

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($funcio,$res);
 $mat=$cfetch_row($result);
 $cab1=trim($mat[den_empresa]);
 $cab2=trim($mat[end_empresa]).'       Bairro:'.trim($mat[den_bairro]);
 $cab3=$mat[cod_cep].' - '.trim($mat[den_munic]).' - '.trim($mat[uni_feder]);
 $cab4='Fone: '.$mat[num_telefone].'   Fax: '.$mat[num_fax];
 $cab5="C.G.C.  :".$mat[num_cgc]."     Ins.Estadual:".$mat["ins_estadual"];

// incluir aqui codigos para notas de conserto
 if($cons=="S")
 {
  $nat_cons="'1.915','2.915'";
  $tipo_cons="and d.cod_operacao='RECO'";
 }else{
  $nat_cons="9999";
 }

// incluir aqui codigos para notas de compras
 if($comp=="S")
 {
  $nat_comp="and c.cod_fiscal_item   in('1.101','1.102','1.126','1.252','1.302','1.401','1.403','1.551','1.556','2.101','2.102',
       '1.124','2.124','2.252','2.302','2.401','2.403','2.551','3.101','3.102')";
  $tipo_comp="and d.cod_operacao='AR'";
 }else{
  $nat_comp="and c.cod_fiscal_item='9999' ";
 }

// incluir aqui codigos para notas de devolucoes
 if($dev=="S")
 {
  $nat_dev="'1.201','1.202','2.410','2.411','2.201','2.202'";
  $tipo_dev="and d.cod_operacao='DEVC'";
 }else{
  $nat_dev="99999";
 }

// incluir aqui codigos para notas de fretes

 if($frete=="S")
 {
  $nat_frete="'2.352','1.352'";
 }else{
  $nat_frete="99999";
 }

// incluir aqui codigos para notas de transferencias
 if($tra=="S")
 {
  $nat_tra="'1.101','1.151','1.152','1.906','1.905','2.905','2.906'";
  $tipo_tra="and d.cod_operacao IN ('TRAE','TSAB')";
 }else{
  $nat_tra="99999";
 }

  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

 $consulta= "select 'Notas de Compras' as tp_nf,a.ies_especie_nf,
                    a.cod_empresa,a.num_nf,a.ser_nf,
                    a.cod_fornecedor,a.val_tot_nf_d,
                    a.val_tot_icms_nf_d,a.val_ipi_nf,a.val_despesa_aces,
                    a.cod_operacao,
                    b.raz_social,
                    c.cod_item,c.cod_fiscal_item||' - '||c.den_item as den_item,
                    c.val_contabil_item,c.qtd_declarad_nf,
                    c.num_seq,c.cod_unid_med_nf
                 from nf_sup a,fornecedor b, aviso_rec c,
                      aviso_rec_compl d
                where a.cod_empresa='".$empresa."'
                   and dat_entrada_nf between '".$dini."' and '".$dfin."'
                   and b.cod_fornecedor=a.cod_fornecedor
                   and c.cod_empresa=a.cod_empresa
                   and c.num_aviso_rec=a.num_aviso_rec
                   $nat_comp
                   $tipo_comp
                   and d.cod_empresa=c.cod_empresa
                   and d.num_aviso_rec=c.num_aviso_rec
                   and d.ies_situacao ='N'
union
             select 'Notas de Consertos' as tp_nf,a.ies_especie_nf,a.cod_empresa,a.num_nf,a.ser_nf,
                    a.cod_fornecedor,a.val_tot_nf_d,
                    a.val_tot_icms_nf_d,a.val_ipi_nf,a.val_despesa_aces,
                    a.cod_operacao,
                    b.raz_social,
                    c.cod_item,c.cod_fiscal_item||' - '||c.den_item  as den_item,
                    c.val_contabil_item,c.qtd_declarad_nf,
                    c.num_seq,c.cod_unid_med_nf
                 from nf_sup a,fornecedor b, aviso_rec c,
                      aviso_rec_compl d

                where a.cod_empresa='".$empresa."'
                   and dat_entrada_nf between '".$dini."' and '".$dfin."'
                   and b.cod_fornecedor=a.cod_fornecedor
                   and c.cod_empresa=a.cod_empresa
                   and c.num_aviso_rec=a.num_aviso_rec
                   and c.cod_fiscal_item  in($nat_cons)
                   and d.cod_empresa=c.cod_empresa
                   and d.num_aviso_rec=c.num_aviso_rec
                   and d.ies_situacao ='N'
                   $tipo_cons
union
           select 'Notas de Devolu��es' as tp_nf,a.ies_especie_nf,a.cod_empresa,a.num_nf,a.ser_nf,
                    a.cod_fornecedor,a.val_tot_nf_d,
                    a.val_tot_icms_nf_d,a.val_ipi_nf,a.val_despesa_aces,
                    a.cod_operacao,
                    b.raz_social,
                    c.cod_item,c.cod_fiscal_item||' - '||c.den_item  as den_item,
                    c.val_contabil_item,c.qtd_declarad_nf,
                    c.num_seq,c.cod_unid_med_nf
                 from nf_sup a,fornecedor b, aviso_rec c,
                      aviso_rec_compl d

                where a.cod_empresa='".$empresa."'
                   and dat_entrada_nf between '".$dini."' and '".$dfin."'
                   and b.cod_fornecedor=a.cod_fornecedor
                   and c.cod_empresa=a.cod_empresa
                   and c.num_aviso_rec=a.num_aviso_rec
                   and c.cod_fiscal_item in($nat_dev)
                   and d.cod_empresa=c.cod_empresa
                   and d.num_aviso_rec=c.num_aviso_rec
                   and d.ies_situacao ='N'
                   $tipo_dev
union
           select 'FRETES' as tp_nf,a.ies_especie_nf,a.cod_empresa,a.num_nf,a.ser_nf,
                    a.cod_fornecedor,a.val_tot_nf_d,
                    a.val_tot_icms_nf_d,a.val_ipi_nf,a.val_despesa_aces,
                    a.cod_operacao,
                    b.raz_social,
                    c.cod_item,c.cod_fiscal_item||' - '||c.den_item  as den_item,
                    c.val_contabil_item,c.qtd_declarad_nf,
                    c.num_seq,c.cod_unid_med_nf
                 from nf_sup a,fornecedor b, aviso_rec c,
                      aviso_rec_compl d

                where a.cod_empresa='".$empresa."'
                   and dat_entrada_nf between '".$dini."' and '".$dfin."'
                   and b.cod_fornecedor=a.cod_fornecedor
                   and c.cod_empresa=a.cod_empresa
                   and c.num_aviso_rec=a.num_aviso_rec
                   and c.cod_fiscal_item in($nat_frete)
                   and d.cod_empresa=c.cod_empresa
                   and d.num_aviso_rec=c.num_aviso_rec
                   and d.ies_situacao ='N'
                   $tipo_fre

union
           select 'TRANSFER�NCIAS' as tp_nf,a.ies_especie_nf,a.cod_empresa,a.num_nf,a.ser_nf,
                    a.cod_fornecedor,a.val_tot_nf_d,
                    a.val_tot_icms_nf_d,a.val_ipi_nf,a.val_despesa_aces,
                    a.cod_operacao,
                    b.raz_social,
                    c.cod_item,c.cod_fiscal_item||' - '||c.den_item  as den_item,
                    c.val_contabil_item,c.qtd_declarad_nf,
                    c.num_seq,c.cod_unid_med_nf
                 from nf_sup a,fornecedor b, aviso_rec c,
                      aviso_rec_compl d

                where a.cod_empresa='".$empresa."'
                   and dat_entrada_nf between '".$dini."' and '".$dfin."'
                   and b.cod_fornecedor=a.cod_fornecedor
                   and c.cod_empresa=a.cod_empresa
                   and c.num_aviso_rec=a.num_aviso_rec
                   and c.cod_fiscal_item in($nat_tra)
                   and d.cod_empresa=c.cod_empresa
                   and d.num_aviso_rec=c.num_aviso_rec
                   and d.ies_situacao ='N'
                   $tipo_tra
                   order by 1,3,12,6,4,17";
 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($consulta,$res);
 $mat=$cfetch_row($result);
 $titulo="Notas Fiscais de Entrada no per�odo de :".$dini." a ".$dfin;
 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $forn_atu=$mat["cod_fornecedor"];
 $tval_nf=0;
 $tval_icms_nf=0;
 $tval_ipi_nf=0;
 $fval_nf=0;
 $fval_icms_nf=0;
 $fval_ipi_nf=0;
 $nf_atu=$mat["num_nf"].$mat["ser_nf"];
 $tp_atu=$mat["tp_nf"];
 while (is_array($mat))
 {
  if($tp_atu<>$tp_ant)
  {
   if($resumo<>"S")
   {
    $pdf->ln();
    $pdf->SetFillColor(0);
    $pdf->SetFont('Arial','B',10);
    $pdf->setx(10);
    $pdf->cell(190,5,chop($mat["tp_nf"]),'LRTB',0,'C');
    $pdf->ln();
   }
  }
  if($forn_ant<>$forn_atu)
  {
   if($resumo<>"S")
   {
    $pdf->ln();
    $pdf->SetFillColor(0);
    $pdf->SetFont('Arial','B',8);
    $pdf->setx(10);
    $pdf->cell(25,5,$mat["cod_fornecedor"],'LRTB',0,'C');
    $pdf->cell(115,5,$mat["raz_social"],'LRTB');
   }
  }  
  if($resumo<>"S")
  {
   $pdf->ln();
   $pdf->setx(15);
  }
  if($nf_ant<>$nf_atu)
  {
   if($resumo<>"S")
   {
    $pdf->SetFont('Arial','B',6);
    $pdf->cell(15,5,round($mat["num_nf"])."-".$mat["ser_nf"],'LRTB');
    $pdf->cell(20,5,number_format($mat["val_tot_nf_d"],2,",","."),'LRTB',0,'R');
   }
   $fval_nf=$fval_nf+$mat["val_tot_nf_d"];
   $fval_icms_nf=$fval_icms_nf+$mat["val_tot_icms_nf_d"];
   $fval_ipi_nf=$fval_ipi_nf+$mat["val_ipi_nf"];
   $tval_nf=$tval_nf+$mat["val_tot_nf_d"];
   $tval_icms_nf=$tval_icms_nf+$mat["val_tot_icms_nf_d"];
   $tval_ipi_nf=$tval_ipi_nf+$mat["val_ipi_nf"];
   $stval_nf=$stval_nf+$mat["val_tot_nf_d"];
   $stval_icms_nf=$stval_icms_nf+$mat["val_tot_icms_nf_d"];
   $stval_ipi_nf=$stval_ipi_nf+$mat["val_ipi_nf"];
  }else{
   if($resumo<>"S")
   {
    $pdf->cell(35,5,'','R');
   }
  }
  if($resumo<>"S")
  {
   $pdf->SetFont('Arial','B',6);
   $pdf->cell(10,5,round($mat["num_seq"]),'LRTB');
   $pdf->cell(15,5,chop($mat["cod_item"]),'LRTB');
   $pdf->cell(80,5,chop($mat["den_item"]),'LRTB');
   $pdf->cell(10,5,chop($mat["cod_unid_med_nf"]),'LRTB');
   $pdf->cell(20,5,number_format($mat["qtd_declarad_nf"],0,",","."),'LRTB',0,'R');
   $pdf->cell(20,5,number_format($mat["val_contabil_item"],2,",","."),'LRTB',0,'R');
  }
  $forn_ant=$mat["cod_fornecedor"];
  $nf_ant=$mat["num_nf"].$mat["ser_nf"];
  $tp_ant=$mat["tp_nf"];
  $mat=$cfetch_row($result);
  $tp_atu=$mat["tp_nf"];
  if($tp_ant<>$tp_atu)
  {
   $pdf->ln();
   $pdf->SetFillColor(0);
   $pdf->SetFont('Arial','B',10);
   $pdf->setx(10);
   $pdf->cell(60,5,'Total '.$tp_ant,'LRTB',0,'C');
   $pdf->cell(20,5,'Val. NF:','LTB',0,'L');
   $pdf->cell(25,5,number_format($stval_nf,2,",","."),'RTB',0,'R');
   $pdf->cell(20,5,'Val. ICMS:','LTB',0,'L');
   $pdf->cell(25,5,number_format($stval_icms_nf,2,",","."),'RTB',0,'R');
   $pdf->cell(20,5,'Val. IPI:','LTB',0,'L');
   $pdf->cell(25,5,number_format($stval_ipi_nf,2,",","."),'RTB',0,'R');
   $pdf->ln();
   $pdf->ln();
   $stval_nf=0;
   $stval_icms_nf=0;
   $stval_ipi_nf=0;
  }
  $forn_atu=$mat["cod_fornecedor"];
  $nf_atu=$mat["num_nf"].$mat["ser_nf"];
  if($forn_ant<>$forn_atu)
  {
   if($resumo<>"S")
   {
     $pdf->ln();
   }
   $fval_nf=0;
   $fval_icms_nf=0;
   $fval_ipi_nf=0;
  }  
 }
 $pdf->ln();
 $pdf->SetFillColor(0);
 $pdf->SetFont('Arial','B',10);
 $pdf->setx(10);
 $pdf->cell(60,5,'Total Geral','LRTB',0,'C');
 $pdf->cell(20,5,'Val. NF:','LTB',0,'L');
 $pdf->cell(25,5,number_format($tval_nf,2,",","."),'RTB',0,'R');
 $pdf->cell(20,5,'Val. ICMS:','LTB',0,'L');
 $pdf->cell(25,5,number_format($tval_icms_nf,2,",","."),'RTB',0,'R');
 $pdf->cell(20,5,'Val. IPI:','LTB',0,'L');
 $pdf->cell(25,5,number_format($tval_ipi_nf,2,",","."),'RTB',0,'R');
 $pdf->ln();
 $fval_nf=0;
 $fval_icms_nf=0;
 $fval_ipi_nf=0;

 $pdf->Output('entradas.pdf',true);
?>