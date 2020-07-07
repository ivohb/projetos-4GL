<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenï¿½o:     Henrique
 //Data manutenï¿½o30/08/2005
 //Mdulo:        VDP
 //Processo:      Posicao de pedidos
 //-----------------------------------------------------------------------------
 $prog="vdp/vdp0012";
 $versao=1;  
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $data_cab=sprintf("%02d/%02d/%04d",$dia_ctr,$mes_ctr,$ano_ctr);
 include("../../bibliotecas/usuario.inc");
 $cod_rep=chop($cod_rep);
 include("../../bibliotecas/atu_ped.inc");

 if($erep=="S")
 {
  $sel_rep="and b.cod_repres='".$cod_rep."'";
  $sel_rep1="and b.cdrepr='".$cod_rep."'";
 }elseif($erep=="C") {
  if($srepres=="todos")
  {
   $sel_rep="and x.cod_nivel_3='".$cod_rep."'";
   $sel_rep1="and x.cod_nivel_3='".$cod_rep."'";
  }else{
   $sel_rep="and b.cod_repres='".$srepres."' and x.cod_nivel_4='".$cod_rep."'";
   $sel_rep1="and b.cdrepr='".$srepres."' and x.cod_nivel_4='".$cod_rep."'";
  }    
 }else{
  if($srepres=="todos")
  {
   $sel_rep=" and b.cod_repres > 0";
   $sel_rep1="and b.cdrepr > 0";
  }else{
   if($supervisor=="S")
   {
    $sel_rep="and x.cod_nivel_3='".$srepres."'";
    $sel_rep1="and x.cod_nivel_3='".$srepres."'";
   }else{
    $sel_rep="and b.cod_repres='".$srepres."'";
    $sel_rep1="and b.cdrepr='".$srepres."'";
   }
  }    
 }
 $dia_ctr=substr(chop($prazo),0,2);
 $mes_ctr=substr(chop($prazo),3,4);
 $ano_ctr=substr(chop($prazo),6,9); 
 $prazo1=sprintf("%04d-%02d-%02d",$ano_ctr,$mes_ctr,$dia_ctr).' 00:00:00.000';
 $prazo=chop($prazo);
 $prazo1=chop($prazo1);
 $resumo=chop($resumo);
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
 $mes_num=$mes_ctr;
 require('../../bibliotecas/nome_mes.inc');

 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf_paisagem.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();

 $vendas="S"; 
 $ano_ini=substr($dini,6,4);
 $mes_ini=substr($dini,3,2);
 $dia_ini=substr($dini,0,2); 
 $ano_fin=substr($dfin,6,4);
 $mes_fin=substr($dfin,3,2);
 $dia_fin=substr($dfin,0,2); 

 $ini_orca=sprintf("%04d-%02d-%02d",$ano_ini,$mes_ini,$dia_ini);
 $fin_orca=sprintf("%04d-%02d-%02d",$ano_fin,$mes_fin,$dia_fin);
 $ini_orca=chop($ini_orca)." 00:00:00.000";
 $fin_orca=chop($fin_orca)." 00:00:00.000";

 $transac=" set isolation to dirty read";
 $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_trans = $cquery($transac,$res_trans);
  $selec_pedido=" SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  (b.cod_repres/1) as cod_repres,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,b.ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic-e.qtd_pecas_cancel-e.qtd_pecas_atend as qtd_pecas_solic,
                  e.qtd_pecas_atend,e.qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
                  e.qtd_pecas_romaneio as om,
		  year(b.dat_pedido) as ano ,month(b.dat_pedido) as mes,
		  (month(b.dat_pedido)||'/'||year(b.dat_pedido) ) as mesano,
		  i.nom_cliente as nom_cliente,i.cod_cliente,
                  day(b.dat_pedido) as dia,
		  year(e.prz_entrega) as ano_entr ,month(e.prz_entrega) as mes_entr,
                  day(e.prz_entrega) as dia_entr,
                  '' as sit_erp,(b.cod_nat_oper/1) as cod_tip_cli   
                  ,trim(num_pedido_repres) as cod_palm,
                  CASE when e.qtd_pecas_romaneio > 0 and e.qtd_pecas_atend =0 and e.qtd_pecas_cancel=0
                       then '4-EXPEDIÇÃO'
                       when  e.qtd_pecas_cancel > 0 and e.qtd_pecas_atend=0 and e.qtd_pecas_romaneio=0   
                       then '7-CANCELADOS'
                       when  e.qtd_pecas_atend > 0 and e.qtd_pecas_cancel=0 and e.qtd_pecas_romaneio=0   
                       then '6-FATURADOS'
                       ELSE '5-VENDAS'
                      end situacao,
                  '1' as controle
             from pedidos b,
                  ped_itens e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where b.cod_empresa ='01'
               and b.ies_sit_pedido in ('N','2','F','3','1','B')
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and e.qtd_pecas_solic-e.qtd_pecas_cancel-e.qtd_pecas_atend > 0
               and i.cod_cliente=b.cod_cliente
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
  

  
union all
          SELECT (b.num_pedido||'-'||b.cod_empresa) as ped_emp,
                  b.num_pedido,b.cod_empresa,
                  (b.cod_repres/1) as cod_repres,
                  b.pct_desc_financ,
                  (b.pct_desc_adic) as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  e.pre_unit,
                  e.qtd_pecas_solic, 0 as qtd_pecas_atend,0 as qtd_pecas_cancel,
                  e.pct_desc_adic,e.pct_desc_bruto,e.num_sequencia,
                  0 as om,
		  year(b.dat_digitacao) as ano ,month(b.dat_digitacao) as mes,
		  (month(b.dat_digitacao)||'/'||year(b.dat_digitacao)) as mesano,
		  i.nom_cliente as nom_cliente,i.cod_cliente,
                  day(b.dat_digitacao) as dia,
		  year(e.prz_entrega) as ano_entr ,month(e.prz_entrega) as mes_entr,
                  day(e.prz_entrega) as dia_entr,
                  '' as sit_erp ,(b.cod_nat_oper/1) as cod_tip_cli     
                  ,trim(num_pedido_repres) as cod_palm,
                  '2-PARADOS CREDITO' as situacao,'1' as controle
             from pedido_dig_mest b,
                  pedido_dig_item e,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n
             where b.cod_empresa ='01'
               and e.cod_empresa=b.cod_empresa
               and e.num_pedido=b.num_pedido
               and i.cod_cliente=b.cod_cliente
               and k.cod_empresa=e.cod_empresa
               and k.cod_item=e.cod_item
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0 
union all
          SELECT (b.cod||'-'||'01') as ped_emp,
                  (b.cod/1) as num_pedido,'01' as cod_empresa,
                  (b.cdrepr/1)  as cod_repres,
                  0 as pct_desc_financ,
                  0 as pct_desc_adic_ped,
                  b.pct_frete,'N' as ies_sit_pedido,
                  e.prunit as pre_unit,
                  e.qtde as qtd_pecas_solic,
                  0 as qtd_pecas_atend,
                  CASE when b.ies_sit_informacao='9'
                       then e.qtde
                       else 0
                       end qtd_pecas_cancel,
                  e.descont as pct_desc_adic,0 as pct_desc_bruto,1 as num_sequencia,
                  0 as om,
		  year(o.dt_import) as ano ,month(o.dt_import) as mes,
		  (month(o.dt_import)||'/'||year(o.dt_import) ) as mesano,
		  i.nom_cliente as nom_cliente,i.cod_cliente,
                  day(o.dt_import) as dia,
		  year(b.dtprz) as ano_entr ,month(b.dtprz) as mes_entr,
                  day(b.dtprz) as dia_entr,
                  b.sit_erp,(b.cdoperac/1) as cod_tip_cli
                  ,trim(o.cod_palm) as cod_palm,
                  CASE when b.ies_sit_informacao='9'
                       then '7-CANCELADOS'
                       else '1-PARADOS CRM'
                       end situacao,
                  '0' as controle

             from vnxeorca b,
                  vnxeorit e,
                  vnempre f,
                  clientes i,
                  item_vdp k,
                  grupo_item l,
                  item m,
                  linha_prod n,
                  vnimpped o 
             where
              (b.ies_sit_informacao not in  ('9') or b.ies_sit_informacao is null)
               and e.cdorca=b.cod
               and f.cod=b.cdempre
               and e.qtde > 0 
              and i.cod_cliente=f.cdclierp
               and b.cdoperac not in('16','32')
               and k.cod_empresa='01'
               and k.cod_item=e.cdprod
               and l.cod_grupo_item=k.cod_grupo_item
               and m.cod_item=k.cod_item
               and m.cod_empresa=k.cod_empresa
               and n.cod_lin_prod=m.cod_lin_prod
               and n.cod_lin_recei=0
               and n.cod_seg_merc=0
               and n.cod_cla_uso=0
               and o.cod_crm=b.cod
               and o.cod_item='000'
               and b.cdped is null


           order by  29,23,24,25,1            ";


 $res_pedido = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_pedido = $cquery($selec_pedido,$res_pedido);
 $mat_pedido=$cfetch_row($result_pedido);
 $ped_ant="0"; 
 $ped_atu=$mat_pedido["ped_emp"]; 
 $vlme=0;
 $vlmc=0;
 $vlma=0;
 $vlm=0;
 $matim=0;
 $matem=0;
 $totm=0;
 $matit=0;
 $matet=0;
 $tott=0;
 $mes_ant=0;
 $mes_atu=$mat_pedido["mesano"];
 $emp_ant=$mat_pedido["cod_empresa"];
 $emp_atu=$mat_pedido["cod_empresa"];
 $zero="";
 $s_qtd_ped_emis=0;
 $s_val_ped_emis=0;
 $s_qtd_ped_cancel=0;
 $s_val_ped_cancel=0;
 $s_qtd_ped_fat=0;
 $s_val_ped_fat=0;
 $s_qtd_ped_om=0;
 $r_qtd_ped_emis=0;
 $r_val_ped_emis=0;
 $r_qtd_ped_cancel=0;
 $r_val_ped_cancel=0;
 $r_qtd_ped_fat=0;
 $r_val_ped_fat=0;
 $r_qtd_ped_om=0;
 $t_qtd_ped_emis=0;
 $t_val_ped_emis=0;
 $t_qtd_ped_cancel=0;
 $t_val_ped_cancel=0;
 $t_qtd_ped_fat=0;
 $t_val_ped_fat=0;
 $t_qtd_ped_om=0;
 $om=0;
 $rep_atu=$mat_pedido["cod_repres"];
 $situacao_atu=chop($mat_pedido["situacao"]);
 $controle_atu=round($mat_pedido["controle"]);
 $cod_palm_atu=round($mat_pedido["cod_palm"]);
 while (is_array($mat_pedido))
 {
  if($situacao_ant<>$situacao_atu)
  {
   $titulo="PEDIDOS EM CARTEIRA ".$situacao_atu;
   $pdf->AddPage();
   $pdf->ln();
   $pdf->SetFont('Arial','B',12);
   $pdf->setx(10);
   $pdf->Cell(180,6,$situacao_atu,0,0,'C');
   $pdf->SetFont('Arial','B',8);
   $pdf->ln();
   $pdf->setx(10);
   $pdf->Cell(15,6,'COD',TBLR,0,'C');
   $pdf->Cell(15,6,'PEDIDO',TBLR,0,'C');
   $pdf->Cell(80,6,'NOME',TBLR,0,'C');
   $pdf->Cell(20,6,'DATA',TBLR,0,'C');
   $pdf->Cell(20,6,'PRAZO',TBLR,0,'C');
   $pdf->Cell(20,6,'VALOR',TBLR,0,'C');
   $pdf->Cell(40,6,'CANCELADO',TBLR,0,'C');
   $pdf->Cell(50,6,'NOTA FISCAL',TBLR,0,'C');
   $pdf->Cell(15,6,'O.M.',TBLR,0,'c');
   $pdf->ln();
   $pdf->setx(10);
   $pdf->Cell(15,6,'REP',TBLR,0,'C');
   $pdf->Cell(15,6,'LOGIX',TBLR,0,'C');
   $pdf->Cell(80,6,'CLIENTE',TBLR,0,'C');
   $pdf->Cell(20,6,'ENTRADA',TBLR,0,'C');
   $pdf->Cell(20,6,'ENTREGA',TBLR,0,'C');
   $pdf->Cell(20,6,'SALDO',TBLR,0,'C');
   $pdf->Cell(20,6,'DATA',TBLR,0,'C');
   $pdf->Cell(20,6,'VALOR',TBLR,0,'C');
   $pdf->Cell(15,6,'NUMERO',TBLR,0,'C');
   $pdf->Cell(15,6,'DATA',TBLR,0,'C');
   $pdf->Cell(20,6,'VALOR',TBLR,0,'C');
   $pdf->Cell(15,6,'O.M.',TBLR,0,'c');
   $pdf->ln();
  } 
  $unit=(($mat_pedido["pre_unit"]-($mat_pedido["pre_unit"]*$mat_pedido["pct_desc_adic"]/100)));
  $unit=(round(($unit*100),0)/100);
  $unit=(($unit-($unit*$mat_pedido["pct_desc_bruto"]/100)));
  $unit=(round(($unit*100),0)/100);
  $unit=(($unit-($unit*$mat_pedido["pct_desc_adic_ped"]/100)));
  $unit=(round(($unit*100),0)/100);
  $unit=(($unit-($unit*$mat_pedido["pct_desc_financ"]/100)));
  $unit=(round(($unit*100),0)/100);
  if(chop($mat_pedido["sit_erp"])=="F")
  {
   $qtd_pecas_atend=$mat_pedido["qtd_pecas_solic"];
  }else{
   if($mat_pedido["qtd_pecas_atend"] > 0)
   {
    $qtd_pecas_atend=$mat_pedido["qtd_pecas_atend"];
   }else{
     $qtd_pecas_atend=0;
   }
  }
  $vlme=($vlme+round(($unit*$mat_pedido["qtd_pecas_solic"]),2));
  $vlmc=($vlmc+round(($unit*$mat_pedido["qtd_pecas_cancel"]),2));
  $vlma=($vlma+round(($unit*$qtd_pecas_atend),2)) ;
  $vlmet=($vlmet+($unit*$mat_pedido["qtd_pecas_solic"]));
  $vlmct=($vlmct+($unit*$mat_pedido["qtd_pecas_cancel"]));
  $vlmat=($vlmat+($unit*$qtd_pecas_atend)) ;
  $valorm=$vlme-$vlmc;
  $valorm=$valorm;
  $valor=$vlme-$vlmc-$vlma;
  $valor=$valor;
  $valor_ped_s=$valor_ped_s+$vlme-$vlmc-$vlma;     
  $valor_rep_s=$valor_rep_s+$vlme-$vlmc-$vlma;     
  $valor_tot_s=$valor_tot_s+$vlme-$vlmc-$vlma;     
  $valor_local_s=$valor_local_s+$vlme-$vlmc-$vlma;     
  $valor_ped_e=$valor_ped_e+$valorm;     
  $valor_rep_e=$valor_rep_e+$valorm;     
  $valor_tot_e=$valor_tot_e+$valorm;     
  $valor_local_e=$valor_local_e+$valorm;     
  $valor_ped_a=$valor_ped_a+$vlma;     
  $valor_rep_a=$valor_rep_a+$vlma;     
  $valor_tot_a=$valor_tot_a+$vlma;     
  $valor_local_a=$valor_local_a+$vlma;     
  $ped_ant=$mat_pedido["num_pedido"];
  $ped_ant_1=$mat_pedido["ped_emp"];
  $mes_ant=$mat_pedido["mes"];
  $ano_ant=$mat_pedido["ano"];
  $mes_ant_ped=$mat_pedido["mes_ped"];  
  $ano_ant_ped=$mat_pedido["ano_ped"];
  $emp_ant=$mat_pedido["cod_empresa"];
  $rep_ant=$mat_pedido["cod_repres"];
  $cli_ant=$mat_pedido["nom_cliente"];
  $cod_cli_ant=$mat_pedido["cod_cliente"]; 
  $tip_cli_ant=$mat_pedido["cod_tip_cli"]; 
  $dir_ant=$mat_pedido["cod_nivel_2"];
  $grupo_ant=$mat_pedido["den_grupo_item"];
  $linha_ant=$mat_pedido["den_estr_linprod"];
  $cod_item_ant=$mat_pedido["cod_item"];
  $den_item_ant=$mat_pedido["den_item"];
  $local_ant=$mat_pedido["tipo_rel"];
  $cli_ant=chop($mat_pedido["nom_cliente"]);
  $cod_palm_ant=round($mat_pedido["cod_palm"]);
  $data_entrada=sprintf("%02d/%02d/%04d",$mat_pedido["dia"],$mat_pedido["mes"],$mat_pedido["ano"]);
  $data_entrega=sprintf("%02d/%02d/%04d",$mat_pedido["dia_entr"],$mat_pedido["mes_entr"],$mat_pedido["ano_entr"]);
  $om=$om+$mat_pedido["om"];
  $controle_ant=round($mat_pedido["controle"]);
  $situacao_ant=chop($mat_pedido["situacao"]);
  $mat_pedido=$cfetch_row($result_pedido);
  $data_entrega_a=sprintf("%02d/%02d/%04d",$mat_pedido["dia_entr"],$mat_pedido["mes_entr"],$mat_pedido["ano_entr"]);
  $situacao_atu=chop($mat_pedido["situacao"]);
  $controle=round($mat_pedido["controle"]);
  $cod_palm_atu=round($mat_pedido["cod_palm"]);
  $ped_atu=$mat_pedido["num_pedido"];
  $ped_atu_1=$mat_pedido["ped_emp"];
  $mes_atu=$mat_pedido["mes"];
  $ano_atu=$mat_pedido["ano"];
  $mes_atu_ped=$mat_pedido["mes_ped"];  
  $ano_atu_ped=$mat_pedido["ano_ped"];
  $emp_atu=$mat_pedido["cod_empresa"];
  $rep_atu=$mat_pedido["cod_repres"];
  $cli_atu=$mat_pedido["nom_cliente"];
  $cod_cli_atu=$mat_pedido["cod_cliente"]; 
  $tip_cli_atu=$mat_pedido["cod_tip_cli"]; 
  $dir_atu=$mat_pedido["cod_nivel_2"];
  $grupo_atu=$mat_pedido["den_grupo_item"];
  $linha_atu=$mat_pedido["den_estr_linprod"];
  $cod_item_atu=$mat_pedido["cod_item"];
  $local_atu=$mat_pedido["tipo_rel"];
  $pdf->SetFillColor(260);
  if($ped_atu.$cod_palm_atu<>$ped_ant.$cod_palm_ant)
  {
   $s_qtd_ped_emis=$s_qtd_ped_emis+1;
   $s_val_ped_emis=$s_val_ped_emis+$vlme;
   $r_qtd_ped_emis=$r_qtd_ped_emis+1;
   $r_val_ped_emis=$r_val_ped_emis+$vlme;
   $t_qtd_ped_emis=$t_qtd_ped_emis+1;
   $t_val_ped_emis=$t_val_ped_emis+$vlme;
   if($q_data<>"S")
   {
    $pdf->setx(10);
    $pdf->Cell(15,5,number_format($rep_ant,0,",","."),TBLR,0,'R',1);
    $pdf->Cell(15,5,number_format($ped_ant,0,",","."),TBLR,0,'R',1);
    $pdf->Cell(80,5,$cli_ant,TBLR,0,'L',1);
    $pdf->Cell(20,5,$data_entrada,TBLR,0,'R',1);
    $pdf->Cell(20,5,$data_entrega,TBLR,0,'R',1);
    $pdf->Cell(20,5,number_format($vlme,2,",","."),TBLR,0,'R',1);
   } 
    if($vlmc > 0)
    {
     if($q_data<>"S")
     {
      $pdf->Cell(20,5,$dat_canc,TBLR,0,'R',1);
      $pdf->Cell(20,5,number_format($vlmc,2,",","."),TBLR,0,'R',1);
     }
    $s_qtd_ped_cancel=$s_qtd_ped_cancel+1;
    $s_val_ped_cancel=$s_val_ped_cancel+$vlmc;
    $r_qtd_ped_cancel=$r_qtd_ped_cancel+1;
    $r_val_ped_cancel=$r_val_ped_cancel+$vlmc;
    $t_qtd_ped_cancel=$t_qtd_ped_cancel+1;
    $t_val_ped_cancel=$t_val_ped_cancel+$vlmc;
   }else{
    if($q_data<>"S")
    {
     $pdf->Cell(20,5,'',TBLR,0,'R',1);
     $pdf->Cell(20,5,'',TBLR,0,'R',1);
    }
   }
   if($vlma > 0)
   {
    if($q_data<>"S")
    {
     $pdf->Cell(15,5,$num_nff,TBRL,0,'R');
     $pdf->Cell(15,5,$dat_nff,TBRL,0,'R');
     $pdf->Cell(20,5,number_format($vlma,2,",","."),TBLR,0,'R',1);
    }
    $s_qtd_ped_fat=$s_qtd_ped_fat+1;
    $s_val_ped_fat=$s_val_ped_fat+$vlma;
    $r_qtd_ped_fat=$r_qtd_ped_fat+1;
    $r_val_ped_fat=$r_val_ped_fat+$vlma;
    $t_qtd_ped_fat=$t_qtd_ped_fat+1;
    $t_val_ped_fat=$t_val_ped_fat+$vlma;
   }else{
    if($q_data<>"S")
    {
     $pdf->Cell(15,5,'',TBRL,0,'R',1);
     $pdf->Cell(15,5,'',TBRL,0,'R',1);
     $pdf->Cell(20,5,'',TBRL,0,'R',1);
    }
   }
   if($om > 0)
   {
    if($num_ordens=='S')
    {
     $sel_om="select a.num_om
                     from ordem_montag_item a
                    where a.cod_empresa='".$empresa."'
                       and a.num_pedido='".$ped_ant."' ";
     $res_om = $cconnect("logix",$ifx_user,$ifx_senha);
     $result_om = $cquery($sel_om,$res_om);
     $mat_om=$cfetch_row($result_om);
     $num_om=round($mat_om["num_om"]);
    }else{
     $num_om="SIM";
    }
    if($q_data<>"S")
    {
     $pdf->Cell(15,5,$num_om,TBRL,0,'R');
     $pdf->ln();
    }
    $s_qtd_ped_om=$s_qtd_ped_om+1;
    $r_qtd_ped_om=$r_qtd_ped_om+1;
    $t_qtd_ped_om=$t_qtd_ped_om+1;
   }else{
    if($q_data<>"S")
    {
     $pdf->Cell(15,5,'',TBLR,0,'R',1);
     $pdf->ln();
    }
   }


   $om=0;
   $vlme=0;
   $vlmc=0;
   $vlma=0;
  }
  if($q_data=="S")
  {
   if($data_entrega<>$data_entrega_a)
   {
    $pdf->setx(10);
    $pdf->SetFont('Arial','B',8);
    $pdf->Cell(20,6,$data_entrega,TBLR,0,'L');
    $pdf->Cell(20,6,'SALDO:',TBL,0,'L');
    $pdf->Cell(10,6, number_format($r_qtd_ped_emis,0,",","."),TB,0,'R');
    $pdf->Cell(15,6,'VALOR:',TB,0,'L');
    $pdf->Cell(25,6, number_format($r_val_ped_emis,2,",","."),TBR,0,'R');
    $pdf->Cell(20,6,'CANCELADOS:',TBL,0,'L');
    $pdf->Cell(10,6, number_format($r_qtd_ped_cancel,0,",","."),TB,0,'R');
    $pdf->Cell(15,6,'VALOR:',TB,0,'L');
    $pdf->Cell(25,6, number_format($r_val_ped_cancel,2,",","."),TBR,0,'R');
    $pdf->Cell(20,6,'FATURADOS:',TBL,0,'L');
    $pdf->Cell(10,6, number_format($r_qtd_ped_fat,0,",","."),TB,0,'R');
    $pdf->Cell(15,6,'VALOR:',TB,0,'L');
    $pdf->Cell(25,6, number_format($r_val_ped_fat,2,",","."),TBR,0,'R');
    $pdf->Cell(15,6,'ORDENS:',TBL,0,'L');
    $pdf->Cell(20,6, number_format($r_qtd_ped_om,0,",","."),TBR,0,'R');
    $pdf->ln();
    $r_qtd_ped_emis=0;
    $r_val_ped_emis=0;
    $r_qtd_ped_cancel=0;
    $r_val_ped_cancel=0;
    $r_qtd_ped_fat=0;
    $r_val_ped_fat=0;
    $r_qtd_ped_om=0;
   } 
  }

 
  if($situacao_ant<>$situacao_atu)
  {
   $pdf->ln();
   $pdf->setx(10);
   $pdf->SetFont('Arial','B',12);
   $pdf->Cell(120,6,'TOTAL '.$situacao_ant,TBLR,0,'L');
   $pdf->SetFont('Arial','B',8);
   $pdf->ln();
   $pdf->setx(10);
   $pdf->Cell(20,6,'SALDO:',TBL,0,'L');
   $pdf->Cell(10,6, number_format($s_qtd_ped_emis,0,",","."),TB,0,'R');
   $pdf->Cell(20,6,'VALOR:',TB,0,'L');
   $pdf->Cell(25,6, number_format($s_val_ped_emis,2,",","."),TBR,0,'R');
   $pdf->Cell(20,6,'CANCELADOS:',TBL,0,'L');
   $pdf->Cell(10,6, number_format($s_qtd_ped_cancel,0,",","."),TB,0,'R');
   $pdf->Cell(20,6,'VALOR:',TB,0,'L');
   $pdf->Cell(25,6, number_format($s_val_ped_cancel,2,",","."),TBR,0,'R');
   $pdf->Cell(20,6,'FATURADOS:',TBL,0,'L');
   $pdf->Cell(10,6, number_format($s_qtd_ped_fat,0,",","."),TB,0,'R');
   $pdf->Cell(20,6,'VALOR:',TB,0,'L');
   $pdf->Cell(25,6, number_format($s_val_ped_fat,2,",","."),TBR,0,'R');
   $pdf->Cell(20,6,'ORDENS:',TBL,0,'L');
   $pdf->Cell(20,6, number_format($s_qtd_ped_om,0,",","."),TBR,0,'R');
   $s_qtd_ped_emis=0;
   $s_val_ped_emis=0;
   $s_qtd_ped_cancel=0;
   $s_val_ped_cancel=0;
   $s_qtd_ped_fat=0;
   $s_val_ped_fat=0;
   $s_qtd_ped_om=0;
  }
 }
 $pdf->ln();
 $pdf->setx(10);
 $pdf->SetFont('Arial','B',12);
 $pdf->Cell(120,6,'TOTAL DO PERÍODO:',TBLR,0,'L');
 $pdf->SetFont('Arial','B',8);
 $pdf->ln();
 $pdf->setx(10);
 $pdf->Cell(20,6,'SALDO:',TBL,0,'L');
 $pdf->Cell(10,6, number_format($t_qtd_ped_emis,0,",","."),TB,0,'R');
 $pdf->Cell(20,6,'VALOR:',TB,0,'L');
 $pdf->Cell(25,6, number_format($t_val_ped_emis,2,",","."),TBR,0,'R');
 $pdf->Cell(20,6,'CANCELADOS:',TBL,0,'L');
 $pdf->Cell(10,6, number_format($t_qtd_ped_cancel,0,",","."),TB,0,'R');
 $pdf->Cell(20,6,'VALOR:',TB,0,'L');
 $pdf->Cell(25,6, number_format($t_val_ped_cancel,2,",","."),TBR,0,'R');
 $pdf->Cell(20,6,'FATURADOS:',TBL,0,'L');
 $pdf->Cell(10,6, number_format($t_qtd_ped_fat,0,",","."),TB,0,'R');
 $pdf->Cell(20,6,'VALOR:',TB,0,'L');
 $pdf->Cell(25,6, number_format($t_val_ped_fat,2,",","."),TBR,0,'R');
 $pdf->Cell(20,6,'ORDENS:',TBL,0,'L');
 $pdf->Cell(20,6, number_format($t_qtd_ped_om,0,",","."),TBR,0,'R');
 $t_qtd_ped_emis=0;
 $t_val_ped_emis=0;
 $t_qtd_ped_cancel=0;
 $t_val_ped_cancel=0;
 $t_qtd_ped_fat=0;
 $t_val_ped_fat=0;
 $t_qtd_ped_om=0;
 $pdf->ln();
 if($resumo=="S")
 {
  $pdf->Output('res_pedidos.pdf',D);
 }else{
  $pdf->Output('carteira.pdf',D);
 }
?>