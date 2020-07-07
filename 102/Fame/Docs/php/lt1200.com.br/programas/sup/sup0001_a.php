<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenção:     Henrique
 //Data manutenção:24/06/2005
 //Módulo:         SUP
 //Processo:       SUPRIMENTOS - Emissão de Pedido de Compras
 //-----------------------------------------------------------------------------
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
 $transac=" set isolation to dirty read";
  $res_trans = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);
 $consulta="SELECT a.den_empresa,a.end_empresa,a.den_bairro,a.den_munic,a.uni_feder,a.num_telefone,a.num_fax,a.num_cgc,a.ins_estadual as ins_emp,a.cod_cep,
                b.num_pedido,b.dat_emis,
                c.cod_fornecedor,c.raz_social,c.end_fornec,
                c.den_bairro as bairro_for,c.cod_cep as cep_for,
                c.num_telefone as fone_for, c.num_fax as fax_for,
                c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                d.cod_comprador,d.nom_comprador,
                e.cod_mod_embar,e.den_mod_embar as fret,
                f.cod_uni_feder as uf_for,f.den_cidade as cidade_for,
                h.des_cnd_pgto as pgto,
                g.cod_fornecedor cod_trans ,g.raz_social as raz_trans,g.num_telefone as fone_trans,
                i.e_mail,b.num_texto_loc_entr,b.num_texto_loc_cobr
                     from empresa a,
                     pedido_sup b,
                     fornecedor c,
                     comprador d,
                     modo_embarque e,
                     cidades f,
                     outer  fornecedor g ,
                     cond_pgto_cap h,
                     outer fornec_compl i

                     where a.cod_empresa='".$empresa."'
                       and b.cod_empresa=a.cod_empresa
                       and b.ies_versao_atual='S'
                       and d.cod_empresa=a.cod_empresa
                       and b.num_pedido='".$pedido."'
                       and b.cod_fornecedor=c.cod_fornecedor
                       and i.cod_fornecedor=c.cod_fornecedor
                       and d.cod_comprador=b.cod_comprador
                       and e.cod_mod_embar=b.cod_mod_embar
                       and f.cod_cidade=c.cod_cidade
                       and h.cnd_pgto=b.cnd_pgto   
                       and b.cod_transpor=g.cod_fornecedor ";

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($consulta,$res);
 $mat=$cfetch_row($result);
 $cab1=trim($mat[den_empresa]);
 $cab2=trim($mat[end_empresa]).'       Bairro:'.trim($mat[den_bairro]);
 $cab3=$mat[cod_cep].' - '.trim($mat[den_munic]).' - '.trim($mat[uni_feder]);
 $cab4='Fone: '.$mat[num_telefone].'   Fax: '.$mat[num_fax];
 $cab5="C.G.C.  :".$mat[num_cgc]."     Ins.Estadual:".$mat["ins_emp"];
 $cab6='COMPRAS FONE: 0(XX)11 6090-5635   FAX: 0(XX)11 6090-5668';
 $cab7='FAX: 0(XX)11 6090-5668';

 $cab0=round($mat["num_pedido"]);
 $cab8=$mat["num_cgc"];
 $cab9=$mat["ins_emp"];
 $cab10=$mat["cod_cep"];
 $cab11=$mat["pgto"];
 $cab12=$mat["fret"];
 $cab13=$mat["cod_trans"];
 $cab14=$mat["raz_trans"];
 $cab15=$mat["fone_trans"];
 $datae=$mat["dat_emis"];
 $pgto=$mat["pgto"];
 $oper=$mat["oper"];
 $desc1=$mat["pct_desc_financ"];
 $desc2=$mat["pct_desc_adic"];
 $frete=substr($mat["ies_frete"],0,1);
 $tee=$mat["num_texto_loc_entr"];
 $tec=$mat["num_texto_loc_cobr"];
 $comp=$mat["cod_comprador"]; 
 $nom_comp=$mat["nom_comprador"]; 
 $nom_contato=chop($mat["nom_contato"]);
 $pcfrete=$mat["pct_frete"];
 if(chop($empresa=="51")){
  $logo='selo_reflorest.jpg';
 }else{
  $logo='logop.jpg';
 }
 $emp=$cab1;
 $titulo="Pedido de Compra : ".$cab0;
 $datae="Data: ".$datae;
 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');
 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage();
 $linha=0;
 $pdf->ln(3);
 $pdf->SetFont('Arial','B',8);
 $pdf->setx(10);
 $pdf->cell(195,5,'FORNECEDOR : '.$mat["cod_fornecedor"].' - '.$mat["raz_social"],'LRT',0,'L');
 $cod_fornecedor=$mat["cod_fornecedor"];
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(10,5,"",'L',0,'L');
 $pdf->cell(185,5,trim($mat["end_fornec"]).'    Bairro: '.trim($mat["bairro_for"]),'R',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(10,5,"",'L',0,'L');
 $pdf->cell(185,5,$mat["cep_for"].'  '.trim($mat["cidade_for"]).' - '.trim($mat["uf_for"]),'R',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(10,5,"",'L',0,'L');
 $pdf->cell(185,5,'CONTATO:'.$nom_contato.'   Fone: '.$mat["fone_for"].' Fax: '.$mat["fax_for"].' E-mail : '.$mat["e_mail"],'R',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(10,5,"",'LB',0,'L');
 $pdf->cell(185,5,'CNPJ: '.$mat["num_cgc_cpf"].'  Inscrição Estadual : '.$mat["ins_estadual"],'RB',0,'L');
 $pdf->ln(6);
 $pdf->SetFont('Arial','B',12);
 $pdf->setx(10);
 $pdf->cell(195,5,'DADOS GERAIS','LRT',0,'C');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->SetFont('Arial','B',8);
 $pdf->cell(195,5,'Condições de Pagamento: '.$cab11,'LR',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(195,5,'FRETE : '.$cab12.'  TRANSPORTADORA :'.$cab14.' Fone : '.$cab15,'LR',0,'L');
 $pdf->ln();
 $pedido7="SELECT ies_tip_texto,tex_observ,num_seq
           from  texto_sup
           where cod_empresa='".$empresa."'
           and ies_tip_texto in ('E')
	   and num_texto='".$tee."'
	   order by num_seq ";
 $res7 = $cconnect("logix",$ifx_user,$ifx_senha);
 $result7 = $cquery($pedido7,$res7);
 $mate=$cfetch_row($result7);
 $ent=$mate["tex_observ"];
 $pdf->setx(10);
 $pdf->cell(195,5,'Local de Entrega : '.$ent,'LR',0,'L');
 $pdf->ln();

 $pedido6="SELECT ies_tip_texto,tex_observ,num_seq
          from  texto_sup 
          where cod_empresa='".$empresa."'
          and ies_tip_texto in ('C')
	  and num_texto='".$tec."'
	  order by num_seq ";
 $res6 = $cconnect("logix",$ifx_user,$ifx_senha);
 $result6= $cquery($pedido6,$res6);
 $matc=$cfetch_row($result6);
 $cob=$matc["tex_observ"];
 $pdf->setx(10);
 $pdf->cell(195,5,'Local de Cobrança/Faturamento: '.$cob,'LR',0,'L');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(195,5,'Comprador : '.round($comp).'-'.$nom_comp,'LRB',0,'L');
 $pdf->ln();
 $pedido5="SELECT ies_tip_texto,tex_observ,num_seq
          from  texto_sup 
          where cod_empresa='".$empresa."'
          and ies_tip_texto in ('I')
          order by ies_tip_texto,num_seq   ";
 $res5 = $cconnect("logix",$ifx_user,$ifx_senha);
 $result5 = $cquery($pedido5,$res5);
 $matc=$cfetch_row($result5);
 while (is_array($matc))
 {
  $obs=trim($matc["tex_observ"]);
  $pdf->ln();
  $pdf->setx(10);
  $pdf->SetFont('Arial','B',12);
  $pdf->cell(195,5,$obs,'LR',0,'C');
  $matc=$cfetch_row($result5);
 }
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(195,1,"",'T',0,'C');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(195,5,"ITENS DO PEDIDO",'LRT',0,'C');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->SetFont('Arial','B',10);
 $pdf->cell(10,5,"OC",'LRTB',0,'C');
 $pdf->cell(15,5,"CODIGO",'LRTB',0,'C');
 $pdf->cell(20,5,"QTD",'LRTB',0,'C');
  $pdf->SetFont('Arial','B',8);
 $pdf->cell(5,5,"UN",'LRTB',0,'C');
  $pdf->SetFont('Arial','B',10);
 $pdf->cell(95,5,"DESCRIÇÃO",'LRTB',0,'C');
 $pdf->cell(15,5,"LIQUIDO",'LRTB',0,'C');
 $pdf->cell(25,5,"TOTAL",'LRTB',0,'C');
 $pdf->cell(10,5,"% IPI",'LRTB',0,'C');
 $pedido2="SELECT
                (a.num_oc||d.dat_entrega_prev) as num_sequencia,a.num_oc,
                a.cod_item,(d.qtd_solic/a.fat_conver_unid) as qtd_saldo,
                (a.pre_unit_oc*a.fat_conver_unid) as pre_unit,a.pct_ipi,d.dat_entrega_prev,
                b.den_item,a.cod_unid_med,0 as pct_desc_adic,
                c.num_seq,c.tex_observ_oc as den_texto,c.ies_tip_texto,e.des_esp_item
                from ordem_sup a,
                     item b,
                     outer ordem_sup_txt c,
                     prog_ordem_sup d,
	             outer item_esp e
                     where a.cod_empresa='".$empresa."'
                       and b.cod_empresa=a.cod_empresa
                       and c.cod_empresa=a.cod_empresa
                       and d.cod_empresa=a.cod_empresa
		       and e.cod_empresa=a.cod_empresa
                       and c.num_oc=a.num_oc
                       and d.num_oc=a.num_oc
                       and b.cod_item=a.cod_item
		       and e.cod_item=b.cod_item
                       and d.num_versao=a.num_versao
                       and a.num_pedido='".$pedido."'
                       and a.ies_situa_oc <> 'C'
                       and a.ies_versao_atual='S'
                       and c.ies_tip_texto <> 'O'
                       order by a.num_oc,num_sequencia,c.ies_tip_texto,c.num_seq ";
 $res2 = $cconnect("logix",$ifx_user,$ifx_senha);
 if (!$res2)
 {
  printf("Nao foi possivel abrir a conexao.");
  exit;
 }
 $result2 = $cquery($pedido2,$res2);
 if (!$result2)
 {
  printf("Nao foi possivel abrir a consulta.");
  exit;
 }
 $mat=$cfetch_row($result2);
 $cab=1;
 $oc_ant="0"; 
 $oc_atu=$mat["num_sequencia"]; 
 $lexus=1;
 while (is_array($mat))
 {
  if($compara=strcmp($oc_ant,$oc_atu))
  {
   $lexus=1;
   $qtd=$qtd+$mat["qtd_saldo"];
   $vlma=(($mat["qtd_saldo"]*$mat["pre_unit"]-($mat["pre_unit"]*$mat["pct_desc_adic"]/100)));
   $vlma=(($vlma-($vlma*$desc1/100)));
   $vlma=(($vlma-($vlma*$desc2/100)));
   //$vlma=(round($vlma*100)/100);
   $vlmu=($mat["pre_unit"]-($mat["pre_unit"]*$mat["pct_desc_adic"]/100));
   $vlmu=(($vlmu-($vlmu*$desc1/100)));
   $vlmu=(($vlmu-($vlmu*$desc2/100)));
   $vlmu=$vlmu;
   $vlm=($vlm+$vlma);
   $vlipi=($vlipi+($vlma*$mat["pct_ipi"]/100));
   //$vlipi=(round($vlipi*100)/100);
   if(substr($mat["cod_item"],0,2) == "MD")
   {
    $pdf->ln();
    $pdf->setx(10);
    $pdf->SetFont('Arial','B',8);
    $pdf->cell(10,5,round($mat["num_oc"]),'LT',0,'R');
    $pdf->cell(15,5,$mat["cod_item"],'T',0,'L');
    $pdf->cell(20,5,number_format($mat["qtd_saldo"],2,",","."),'T',0,'R');
    $pdf->cell(5,5,$mat["cod_unid_med"],'T',0,'C');
    if(trim($mat["den_texto"]) <>"")
    {
     $pdf->cell(95,5,$mat["den_texto"],'T',0,'L');
    }
    $pdf->cell(15,5,number_format($vlmu,4,",","."),'T',0,'R');
    $pdf->cell(25,5,number_format($vlma,2,",","."),'T',0,'R');
    $pdf->cell(10,5,number_format($mat["pct_ipi"],2,",","."),'RT',0,'R');
    $pdf->ln();
    $lexus=1;
    $pdf->setx(10);
    $pdf->SetFont('Arial','B',10);
    $pdf->cell(195,5,"ENTREGAR ATÉ :".$mat["dat_entrega_prev"],'LR',0,'L');
    $pdf->cell(145,5,$mat["des_esp_item"],'R',0,'L');
   }
   if(substr($mat["cod_item"],0,2) <> "MD")
   {
    $pdf->ln();
    $pdf->setx(10);
    $pdf->SetFont('Arial','B',8);
    $pdf->cell(10,5,round($mat["num_oc"]),'LT',0,'R');
    $pdf->cell(15,5,$mat["cod_item"],'T',0,'L');
    $cod_item_atu=$mat["cod_item"];
    $pdf->cell(20,5,number_format($mat["qtd_saldo"],2,",","."),'T',0,'R');
    $pdf->cell(5,5,$mat["cod_unid_med"],'T',0,'C');
    $den_item=trim($mat["den_item"]);
    $pdf->cell(95,5,substr($den_item,0,55),'T',0,'L');
    $pdf->cell(15,5,number_format($vlmu,4,",","."),'T',0,'R');
    $pdf->cell(25,5,number_format($vlma,2,",","."),'T',0,'R');
    $pdf->cell(10,5,number_format($mat["pct_ipi"],2,",","."),'RT',0,'R');
    $lexus=2;
    if(trim(substr($den_item,55,55))<>'')
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFont('Arial','B',8);
     $pdf->cell(10,5,'','L',0,'R');
     $pdf->cell(15,5,'','',0,'L');
     $pdf->cell(20,5,'','',0,'R');
     $pdf->cell(5,5,'','',0,'C');
     $pdf->cell(95,5,substr($den_item,55,55),'',0,'L');
     $pdf->cell(15,5,'','',0,'R');
     $pdf->cell(25,5,'','',0,'R');
     $pdf->cell(10,5,'','R',0,'R');
    }
    if(trim(substr($den_item,110,55))<>'')
    {
     $pdf->ln();
     $pdf->setx(10);
     $pdf->SetFont('Arial','B',8);
     $pdf->cell(10,5,'','L',0,'R');
     $pdf->cell(15,5,'','',0,'L');
     $pdf->cell(20,5,'','',0,'R');
     $pdf->cell(5,5,'','',0,'C');
     $pdf->cell(95,5,substr($den_item,110,55),'',0,'L');
     $pdf->cell(15,5,'','',0,'R');
     $pdf->cell(25,5,'','',0,'R');
     $pdf->cell(10,5,'','R',0,'R');
    }
    $sel_df="select * from lt1200_forn_item
                          where cod_fornecedor='".$cod_fornecedor."'
                           and cod_item='".$cod_item_atu."'
                           order by seq ";
    $res_df = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_df= $cquery($sel_df,$res_df);
    $mat_df=$cfetch_row($result_df);
    $c_i=0;
    while (is_array($mat_df))
    {
     if($c_i==0)
     {
      $pdf->ln();
      $pdf->setx(10);
      $pdf->Settextcolor('250','0','0');
      $pdf->cell(50,5,'Descrição do Fornecedor: ','L',0,'R');
      $pdf->Settextcolor('0','0','0');
      $pdf->SetFont('Arial','B',8);
      $pdf->cell(145,5,$mat_df["desc"],'R',0,'L');
      $c_i=$c_i+1;
     }else{        
      $pdf->ln();
      $pdf->setx(10);
      $pdf->cell(50,5,' ','L',0,'L');
      $pdf->SetFont('Arial','B',8);
      $pdf->cell(145,5,$mat_df["desc"],'R',0,'L');
      $c_i=$c_i+1;
     }
     $mat_df=$cfetch_row($result_df);
    } 
    $pdf->ln();
    $pdf->setx(10);
    $pdf->SetFont('Arial','B',10);
    $pdf->cell(195,5,"ENTREGAR ATÉ :".$mat["dat_entrega_prev"],'LR',0,'L');
   }
   if($compara=(strcmp("4",$frete)==0))
   {
    $vlfrete=($vlfrete+(($vlma*$pcfrete/100)));
    $vlfretea=(($vlma*$pcfrete/100));
    $vlfreteipi=($vlfreteipi+($vlfretea*$mat["pct_ipi"]/100));
   }
   if($compara=(strcmp("2",$frete)==0))
   {
    $vlfrete=($vlfrete+($mat["qtd_saldo"]*$val_frete/$qtd_tot));
    $vlfretea=($mat["qtd_saldo"]*$val_frete/$qtd_tot);
    $vlfreteipi=($vlfreteipi+($vlfretea*$mat["pct_ipi"]/100));
   }
  }
  $den_texto_ant=trim($mat["den_texto"]);
  $oc_ant=$mat["num_sequencia"]; 
  $mat=$cfetch_row($result2);
  $oc_atu=$mat["num_sequencia"]; 
  $den_texto_atu=trim($mat["den_texto"]);
  if($den_texto_atu<>$den_texto_ant)
  {
   if(chop($den_texto_ant)<>'')
   {
    $pdf->ln();
    $pdf->setx(10);
    $pdf->SetFont('','',8);
    $pdf->cell(10,5,'','L',0,'L');
    $pdf->cell(15,5,'','',0,'L');
    $pdf->cell(15,5,'','',0,'L');
    $pdf->cell(10,5,'','',0,'L');
    $pdf->cell(95,5,$den_texto_ant,'0',0,'L');
    $pdf->cell(15,5,'','',0,'L');
    $pdf->cell(25,5,'','',0,'L');
    $pdf->cell(10,5,'','R',0,'L');
    $den_texto=''; 
   }
  }
 }
 $pdf->ln();
 $pdf->setx(10);
 $pdf->SetFont('','',8);
 $pdf->cell(195,5,'','LRTB',0,'L');
 $pdf->ln();
 $pedido5="SELECT tex_observ_pedido,num_seq
          from  pedido_sup_txt 
          where cod_empresa='".$empresa."'
                and num_pedido='".$pedido."'
                and ies_tip_texto in ('F')

          order by num_seq   ";


 $res5 = $cconnect("logix",$ifx_user,$ifx_senha);
 $result5 = $cquery($pedido5,$res5);
 $matc=$cfetch_row($result5);
 while (is_array($matc))
 {
  $obs=trim($matc["tex_observ_pedido"]);
  if(chop($obs)<>"")
  {
   $pdf->setx(10);
   $pdf->SetFont('Arial','B',12);
   $pdf->cell(195,5,$obs,'LR',0,'L');
   $pdf->ln();
  }
  $matc=$cfetch_row($result5);
 }
 $pdf->setx(10);
 $pdf->cell(195,5," ",'T',0,'C');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->SetFont('Arial','B',12);
 $pdf->cell(195,5,"TOTAIS DO PEDIDO",'LRTB',0,'C');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->SetFont('Arial','B',10);
 $pdf->cell(170,5,"Valor da Mercadoria:",'L',0,'R');
 $vlm=(round($vlm*100)/100);
 $pdf->cell(25,5,number_format($vlm,2,",","."),'R',0,'R');
 $pdf->ln();
 $pdf->setx(10);
 $vlipi=(round($vlipi*100)/100);
 $pdf->cell(170,5,"Valor do IPI:",'L',0,'R');
 $pdf->cell(25,5,number_format($vlipi,2,",","."),'R',0,'R');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(170,5,"Valor do Pedido:",'LB',0,'R');
 $pdf->cell(25,5,number_format($vlm+$vlipi,2,",","."),'RB',0,'R');

 $pdf->ln();
 $pdf->setx(10);
 $pdf->cell(195,5," ",'T',0,'C');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->SetFont('Arial','B',12);
 $pdf->cell(195,5,"HORARIOS PARA ENTREGAS:",'LRT',0,'C');
 $pdf->ln();
 $pdf->setx(10);
 $pdf->Settextcolor('250','0','0');
 $pdf->cell(195,5,'DE SEGUNDA A SEXTA-FEIRA DAS 7:00 AS 11:30 HRS E DAS 13:00 AS 16:00 HRS','LRB',0,'C');
 $pdf->Settextcolor('0','0','0');
 $pdf->ln();


 $pdf->Output('compra.pdf',true);
 ifx_close();
?>
