<?php
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manuten�o:     Henrique
 //Data manuten�o:24/08/2005
 //Mdulo:         Fame
 //Processo:      Vendas - Gerar Relatório e arquivo TXT Controle Saida
 //-----------------------------------------------------------------------------
 $prog="fame/fam00005";
 $versao="1";
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $datam=substr($data,0,2).substr($data,3,2).substr($data,8,2);
 $ped=$pedido;
 $emp=$empresa;
 $vlm=0;
 $vlipi=0;
 $vlfrete=0;
 $vlftreipi=0;
 $frete="0";
 $pc_frete=0;
 $desc1=0;
 $desc2=0;

  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

 $cdv="SELECT a.cod_fornecedor,d.raz_social[1,30] as raz_social,
              d.num_agencia[1,5] as num_agencia,d.num_conta_banco[1,8] as num_conta_banco,
              sum(c.val_nom_ap) as val_dep
        from ad_mestre a,
             ad_ap b,
             ap c,
             fornecedor d
        where a.cod_empresa='".$empresa."'
          and b.cod_empresa=a.cod_empresa
          and b.num_ad=a.num_ad
          and c.cod_empresa=b.cod_empresa
          and c.num_ap=b.num_ap
          and c.ies_versao_atual='S'
          and d.cod_fornecedor=a.cod_fornecedor
          and c.cod_lote_pgto='17'
          and c.ies_lib_pgto_cap='S'
          and c.ies_baixada='N'
          group by 1,2,3,4
          order by 3
          
          ";
 $res_cdv = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_cdv = $cquery($cdv,$res_cdv);
 $mat=$cfetch_row($result_cdv);
//          and a.cod_tip_despesa='6000'
//          and c.ies_lib_pgto_cap='S'
//          and c.ies_baixada='N'


 $filename = 'tmp/cdv.txt';
 $pula_linha="\n";

 if (is_writable($filename))
 {
  if (!$fp = fopen($filename, 'w+'))
  {
   print "Cannot open file ($filename)";
   exit;
  }             
  fwrite($fp, '01REMESSA03CREDITO C/C    ');
  fwrite($fp, $agencia);
  fwrite($fp, $razao);
  fwrite($fp, $c_corrente);
  fwrite($fp, '  ');
  fwrite($fp, $dado);
  fwrite($fp, $n_fame);
  fwrite($fp, '237BRADESCO       ');
  fwrite($fp, $datam);
  fwrite($fp, '00000BPI');
  fwrite($fp, $datam);
  fwrite($fp, '                                                                                ');
  $seq=1;
  // variavel com tamanho do campo a ser formatado
  $tamanho="000000";
  // tamanho da variavel
  $tc=6;
  // retorna o tamanho utilizado pelo valor a ser impresso
  $seq=round($seq);
  $tam=strlen($seq);
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam).$seq);
  fwrite($fp,"\n");
  $val_tot=0;
  while (is_array($mat))
  {
   fwrite($fp, '1');
   fwrite($fp, '                                                             ');
   $agenciaf=chop($mat["num_agencia"]);
   $agenciaf=str_replace("-","",$agenciaf);
   // variavel com tamanho do campo a ser formatado
   $tamanho="00000";
   // tamanho da variavel
   $tc=5;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $tam=strlen($agenciaf);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam).$agenciaf);
   fwrite($fp, chop($razao));

   $contaf=chop($mat["num_conta_banco"]);
   $contaf=str_replace("-","",$contaf);

   // variavel com tamanho do campo a ser formatado
   $tamanho="00000000";
   // tamanho da variavel
   $tc=8;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $tam=strlen($contaf);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam).$contaf);
   fwrite($fp, '  ');

   $raz_social=chop($mat["raz_social"]);
   // variavel com tamanho do campo a ser formatado
   $tamanho="                              ";
   // tamanho da variavel
   $tc=30;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $tam=strlen($raz_social);
   $tam=($tc-$tam);
   fwrite($fp, $raz_social.substr($tamanho,0,$tam));
   fwrite($fp, '           ');
   fwrite($fp, '     ');
   $val_tot=$val_tot+$mat["val_dep"];
   $val_deposito=round(($mat["val_dep"]*100));
   // variavel com tamanho do campo a ser formatado
   $tamanho="0000000000000";
   // tamanho da variavel
   $tc=13;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $tam=strlen($val_deposito);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam).$val_deposito);
   fwrite($fp, chop($dado1));
   fwrite($fp, '                                                  ');
   $seq=$seq+1;
   // variavel com tamanho do campo a ser formatado
   $tamanho="000000";
   // tamanho da variavel
   $tc=6;
   // retorna o tamanho utilizado pelo valor a ser impresso
   $seq=round($seq);
   $tam=strlen($seq);
   $tam=($tc-$tam);
   fwrite($fp, substr($tamanho,0,$tam).$seq);
   fwrite($fp,"\n");
   $mat=$cfetch_row($result_cdv);
  }
  fwrite($fp, '9');
  $val_deposito=round(($val_tot*100));
  // variavel com tamanho do campo a ser formatado
  $tamanho="0000000000000";
  // tamanho da variavel
  $tc=13;
  // retorna o tamanho utilizado pelo valor a ser impresso
  $tam=strlen($val_deposito);
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam).$val_deposito);

  fwrite($fp, '                                                                                ');
  $tamanho='                                                                                                    ';
  fwrite($fp, $tamanho);
  // variavel com tamanho do campo a ser formatado
  $tamanho="000000";
  $seq=$seq+1;
  // variavel com tamanho do campo a ser formatado
  // tamanho da variavel
  $tc=6;
  // retorna o tamanho utilizado pelo valor a ser impresso
  $seq=round($seq);
  $tam=strlen($seq);
  $tam=($tc-$tam);
  fwrite($fp, substr($tamanho,0,$tam).$seq);
  fwrite($fp,"\n");
  fwrite($fp,"");

  fclose($fp);


  $funcio="select a.cod_empresa,a.den_empresa,a.num_cgc,a.den_munic,a.end_empresa,
                a.num_telefone,a.cod_cep,a.ins_estadual,a.den_bairro,
		a.uni_feder,a.num_fax

	from	empresa a
	where	a.cod_empresa='".$empresa."'
	";

 $res_cab = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_cab = $cquery($funcio,$res_cab);
 $mat_cab=$cfetch_row($result_cab);

 $cab1=trim($mat_cab[den_empresa]);
 $cab2=trim($mat_cab[end_empresa]).'       Bairro:'.trim($mat_cab[den_bairro]);
 $cab3=$mat_cab[cod_cep].' - '.trim($mat_cab[den_munic]).' - '.trim($mat_cab[uni_feder]);
 $cab4='Fone: '.$mat_cab[num_telefone].'   Fax: '.$mat_cab[num_fax];
 $cab5="C.G.C.  :".$mat_cab[num_cgc]."     Ins.Estadual:".$mat_cab["ins_emp"];
 $cdv="SELECT a.cod_fornecedor,d.raz_social,
              d.num_agencia,d.num_conta_banco[1,8] as num_conta_banco,
              c.val_nom_ap,c.num_ap,a.num_ad,c.dat_emis
        from ad_mestre a,
             ad_ap b,
             ap c,
             fornecedor d
        where a.cod_empresa='".$empresa."'
          and c.cod_lote_pgto='17'
          and b.cod_empresa=a.cod_empresa
          and b.num_ad=a.num_ad
          and c.cod_empresa=b.cod_empresa
          and c.num_ap=b.num_ap
          and c.ies_baixada='N'
          and c.ies_versao_atual='S'
          and d.cod_fornecedor=a.cod_fornecedor
          and c.ies_lib_pgto_cap='S'
          order by 2
          
          ";
 $res_cdv = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_cdv = $cquery($cdv,$res_cdv);
 $mat=$cfetch_row($result_cdv);


 $titulo="Relatorio de Conferencia Remessa CDV" ;
 define('FPDF_FONTPATH','../fpdf151/font/');
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $linha=0;

 $val_t_forn=0;
 $val_tot_dep=0;
 $forn_atu=$mat["raz_social"];

   $pdf->ln();
   $pdf->SetFillColor(0);
   $pdf->SetFont('Arial','B',10);
   $pdf->setx(20);
   $pdf->cell(20,5,'AP','RLTB',0,'L');
   $pdf->cell(20,5,'AD','RLTB',0,'L');
   $pdf->cell(20,5,'DATA','RLTB',0,'L');
   $pdf->cell(25,5,'AGENCIA','RLTB',0,'L');
   $pdf->cell(35,5,'CONTA','RLTB',0,'L');
   $pdf->cell(40,5,'VALOR','RLTB',0,'R');
 while (is_array($mat))
 {
  if($forn_ant<>$forn_atu)
  {
   $pdf->ln();
   $pdf->SetFillColor(0);
   $pdf->SetFont('Arial','B',10);
   $pdf->setx(10);
   $pdf->cell(170,5,chop($mat["raz_social"]),'LRTB',0,'L');
  }
  $pdf->SetFont('Arial','B',8);
  $pdf->ln();
  $pdf->setx(20);
  $pdf->cell(20,5,round($mat["num_ap"]),'LRTB',0,'L');
  $pdf->cell(20,5,round($mat["num_ad"]),'LRTB',0,'L');
  $pdf->cell(20,5,$mat["data_emis"],'LRTB',0,'L');
  $agenciaf=chop($mat["num_agencia"]);
  $agenciaf=str_replace("-","",$agenciaf);
  $pdf->cell(25,5,$agenciaf,'LRTB',0,'L');
  $pdf->cell(35,5,$mat["num_conta_banco"],'LRTB',0,'L');
  $pdf->cell(40,5,number_format($mat["val_nom_ap"],2,",","."),'LRTB',0,'R');
  $val_t_forn=$val_t_forn+$mat["val_nom_ap"];
  $val_tot_dep=$val_tot_dep+$mat["val_nom_ap"];
  $forn_ant=$mat["raz_social"];

  $mat=$cfetch_row($result_cdv);

  $forn_atu=$mat["raz_social"];
  if($forn_ant<>$forn_atu)
  {
   $pdf->ln();
   $pdf->SetFillColor(0);
   $pdf->SetFont('Arial','B',9);
   $pdf->setx(30);
   $pdf->cell(110,5,'TOTAL REPRESENTANTE: '.$forn_ant,'RTB',0,'L');
   $pdf->cell(40,5,number_format($val_t_forn,2,",","."),'LRTB',0,'R');
   $val_t_forn=0;
  }
 }
 $pdf->ln();
 $pdf->SetFillColor(0);
 $pdf->SetFont('Arial','B',9);
 $pdf->setx(20);
 $pdf->cell(120,5,'TOTAL GERAL ','LRTB',0,'L');
 $pdf->cell(40,5,number_format($val_tot_dep,2,",","."),'LRTB',0,'R');

 $pdf->Output('entrega.pdf',true);



 } else {
  print "The file $filename is not writable";
 }
?>
