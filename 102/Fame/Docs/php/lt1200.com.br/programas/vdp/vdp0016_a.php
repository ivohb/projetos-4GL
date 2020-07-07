<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenção:     Henrique
 //Data manutenção:24/06/2005
 //M¢dulo:         VDP
 //Processo:       Vendas - Recibo de Pagamento RPA/RPR
 //-----------------------------------------------------------------------------
 $prog="vdp/vdp0016";
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
 if($dados=="T")
 {
  $t_dados="";
 }else{
  $t_dados="and b.ies_tipo_lancto='".$dados."'";
 }

 if($tipo=="S")
 {
  $sel_repres='and d.cod_repres=b.cod_supervisor';
  $sel_tipo="";
  $t_canal_vendas='and g.cod_nivel_3=d.cod_repres and g.cod_nivel_4=0';
 }else{
  $sel_repres='and d.cod_repres=b.cod_repres';
  $sel_tipo="and f.tipo='".$tipo."' "; 
  $t_canal_vendas='and g.cod_nivel_4=d.cod_repres ';
 }
 if($tipo=="F" or $tipo=="C" or $tipo=="S")
 {
  $sel_sal=',h.salario';
  $tab_sal=',fun_salario h';
  $selec_sal='and h.cod_empresa=f.cod_empresa and
              h.num_matricula=f.num_matricula';
 }else{
  $sel_sal='';
  $tab_sal='';
  $selec_sal='';
}
    $consulta="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao,
                  b.num_pedido,b.num_pedido_repres,b.dat_pedido,b.dat_emis_repres,
                  c.cod_cliente,c.nom_cliente,c.end_cliente,
                  c.den_bairro as bairro_cli,c.cod_cep as cep_cli,
                  c.num_telefone as fone_cli, c.num_fax as fax_cli,
                  c.nom_contato,c.num_cgc_cpf,c.ins_estadual,
                  d.cod_repres,d.raz_social,d.num_telefone as fone_rep,

                  e.sit_func,e.sit_rep,e.sit_aut,e.sit_fr,
                  f.cota,f.pct_nff,f.pct_dp,f.ind,
                  f.fixo,f.teto,f.num_matricula,f.cod_empresa,
                  g.cod_nivel_4,g.cod_nivel_3
                  $sel_sal,
                  d.num_cgc,d.ins_estadual
             from lt1200:lt1200_comissoes b,     
                  clientes c,
                  representante d,
                  lt1200:lt1200_ctr_comis e,
                  lt1200:lt1200_representante f,
                  canal_venda g
		  $tab_sal
             where
               b.cod_empresa='".$empresa."'
               and b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and c.cod_cliente=b.cod_cliente
               $sel_repres
               and e.mes_ref=b.mes_ref
               and e.ano_ref=b.ano_ref
               and e.cod_empresa=b.cod_empresa 
               and f.cod_repres=d.cod_repres
               $sel_tipo
               $t_canal_vendas
               $selec_sal
            order by d.cod_repres,b.ies_tipo_lancto desc ,
                     b.ies_tip_docto desc,b.num_nff,b.num_docum             " ;

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result2 = $cquery($consulta,$res);


 $mat=$cfetch_row($result2);

 $cab=1;
 $nf_ant="0"; 
 $nf_atu=$mat["num_nff"]; 

 define('FPDF_FONTPATH','../fpdf151/font/'); 
 require('../fpdf151/fpdf.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabec_fame.inc');
 include('../../bibliotecas/extenso.inc');

 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $val_nf=0;
 $val_dp=0;
 $rep_atu=$mat["cod_repres"];
 $rep_ant="";
 $raz_atu=$mat["raz_social"];
 while (is_array($mat))
 {
   $num_ped_logix=round($mat["num_pedido"]);
   $num_ped_rep=round($mat["num_pedido_repres"]);
   $dat_emis=$mat["dat_pedido"];
   $dat_emis_rep=$mat["dat_emis_repres"];
  $salario=$mat["salario"];
  if($rep_ant<>$rep_atu)
  {
   //$cnpj=$mat["num_cgc_cpf"];
   $cnpj=$mat["num_cgc"];
   $num_cgc=$mat["num_cgc"];
   $raz_atu=$mat["raz_social"];
   if($tipo=="R")
   {
    $titulo="RECIBO DE PAGAMENTO A REPRESENTANTES - RPR";
    $den_repres="Representante.:".round($rep_atu)."-".$raz_atu;
    $cnpj="C.N.P.J.: ".chop($cnpj);
   }else{
    $titulo="RECIBO DE PAGAMENTO A AUTONOMOS - RPA";
     $den_repres="Representante.:".round($rep_atu)."-".$raz_atu;
     $cnpj="C.P.F.: ".chop($cnpj);
  }
   $raz_atu=$mat["raz_social"];
   $matricula=$mat["num_matricula"];
   $pdf->AddPage();
  } 
  $tipo_docto=chop($mat["ies_tip_docto"]);
  $num_nff=round($mat["num_nff"]);
  $emp_nff=chop($mat["emp_nff"]);
  if(chop($mat["ies_tip_docto"])=='NF')
  {
   $val_nf=$val_nf+$mat["val_tot_mercadoria"];
   $val_nf_t=$val_nf_t+$mat["val_tot_mercadoria"];
  }else{
   $val_dp=$val_dp+$mat["val_tot_mercadoria"];
   $val_dp_t=$val_dp_t+$mat["val_tot_mercadoria"];
  }
  $rep_ant=$mat["cod_repres"];
  $raz_ant=$mat["raz_social"];
  $cota=$mat["cota"];
  $pct_nff=$mat["pct_nff"];
  $pct_dp=$mat["pct_dp"];
  $teto=$mat["teto"];

  $matricula=chop($mat["num_matricula"]);
  $empresa=chop($mat["cod_empresa"]);
  $tipo_ant=$mat["ies_tipo_lancto"];
  $ind=$mat["ind"];
  if(chop($mat["cod_nivel_3"])=="0")
  {
   $gestor="S";
  }else{
   $gestor="N";
  }


  $mat=$cfetch_row($result2);

  $tipo_atu=$mat["ies_tipo_lancto"];

  $raz_atu=$mat["raz_social"];
  $rep_atu=$mat["cod_repres"];
  if($rep_ant<>$rep_atu)
  {
   $tipo_atu="";
  }
  if($tipo_atu<>$tipo_ant)
  {
   $val_nf_t=0;
   $val_dp_t=0;
  }
  if($rep_ant<>$rep_atu)
  {
   if($tipo=="F" or  $tipo=="S")
   {
    if($cota==0)
    {
     $pct_alcancado=0;
    }else{
     $pct_alcancado=round((($val_nf*100)/$cota));
    }
    if($gestor=="S")
    {
      $pct_alc=round($pct_alcancado);     
      $cons_faixa="SELECT *
                 from lt1200_faixas_comis a
                where '".$pct_alc."' between  a.pct_ini and a.pct_fin
                 " ;

     $res_faixa = $cconnect("lt1200",$ifx_user,$ifx_senha);
     $result_faixa = $cquery($cons_faixa,$res_faixa);
     $mat_faixa=$cfetch_row($result_faixa);
     $pct_sal=$mat_faixa["pct_sal"];

     $pct_alcancado=$pct_sal;
    }else{
     if($pct_alcancado < $pct_nff)
     {
      $pct_alcancado=0;
     }
    }
    $sal_alcancado=($salario*$pct_alcancado/100);
    if($ind=="S")
    {
     $val_ind=($sal_alcancado/12);
    }
   }

   if($tipo=="R" or $tipo=="A" or $tipo=="C")
   {
    $val_com_nff=($val_nf*$pct_nff/100);
    $val_com_dp=($val_dp*$pct_dp/100);

    $val_tot_com=$val_com_nff+$val_com_dp;
    $sal_alcancado=$val_tot_com;
    if($ind=="S")
    {
     $val_ind=($sal_alcancado/12);
    }
   }
   $val_nf=0;
   $val_dp=0;
   $cons_extra="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,b.cod_repres,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao
             from lt1200:lt1200_comissoes b     

             where
                b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and b.cod_repres='".$rep_ant."'
               and b.ies_tip_docto in ('GR')               
            order by b.val_tot_mercadoria             " ;
   $res_extra = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_extra = $cquery($cons_extra,$res_extra);
   $mat_extra=$cfetch_row($result_extra);
   $val_extra=0;
   while (is_array($mat_extra))
   {
    $val_extra=$val_extra+$mat_extra["val_tot_mercadoria"];
    $mat_extra=$cfetch_row($result_extra);
   }
   $cons_bonif="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,b.cod_repres,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao
             from lt1200:lt1200_comissoes b     

             where
                b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and b.cod_repres='".$rep_ant."'
               and b.ies_tip_docto in ('BC')               
            order by b.val_tot_mercadoria             " ;
   $res_bonif = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_bonif = $cquery($cons_bonif,$res_bonif);
   $mat_bonif=$cfetch_row($result_bonif);
   $val_bonif=0;
   while (is_array($mat_bonif))
   {
    $val_bonif=$val_bonif+$mat_bonif["val_tot_mercadoria"];
    $mat_bonif=$cfetch_row($result_bonif);
   }
   $cons_adiant="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,b.cod_repres,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao
             from lt1200:lt1200_comissoes b     

             where
                b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and b.cod_repres='".$rep_ant."'
               and b.ies_tip_docto in ('AC')               
            order by b.val_tot_mercadoria             " ;
   $res_adiant = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_adiant = $cquery($cons_adiant,$res_adiant);
   $mat_adiant=$cfetch_row($result_adiant);
   $val_adiant=0;
   while (is_array($mat_adiant))
   {
    $val_adiant=$val_adiant+$mat_adiant["val_tot_mercadoria"];
    $mat_adiant=$cfetch_row($result_adiant);
   }
   $val_adiant=($val_adiant);
   $cons_estind="SELECT
                  b.ies_tip_docto,b.ies_tipo_lancto,b.cod_repres,
                  b.num_nff,b.cod_empresa as emp_nff,
                  b.num_docum,b.dat_emissao,b.cod_cliente,
                  b.val_tot_mercadoria,b.val_tot_docum,b.observacao
             from lt1200:lt1200_comissoes b     

             where
                b.mes_ref='".$mes_ref."'
               and b.ano_ref='".$ano_ref."'
               and b.cod_repres='".$rep_ant."'
               and b.ies_tip_docto in ('EI')               
            order by b.val_tot_mercadoria             " ;
   $res_estind = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_estind = $cquery($cons_estind,$res_estind);
   $mat_estind=$cfetch_row($result_estind);
   $val_estind=0;
   while (is_array($mat_estind))
   {
    $val_estind=$val_estind+$mat_estind["val_tot_mercadoria"];
    $mat_estind=$cfetch_row($result_estind);
   }
   $val_estind=($val_estind);


   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(120,6,'DETALHAMENTO','LRTB',0,'L');
   $pdf->cell(25,6,'VALOR','LRTB',0,'R');
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'1 - Valor do Serviço Prestado:','LRTB',0,'L');
   $pdf->cell(25,6,number_format($sal_alcancado,2,",","."),'LRTB',0,'R');
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'2 - Créditos não Tributaveis:','LRTB',0,'L');
   if($val_extra > 0)
   {
    $creditos=$val_extra;
    $debitos=0;
    $pdf->cell(25,6,number_format($val_extra,2,",","."),'LRTB',0,'R');
   }else{
    $creditos=0;
    $debitos=($val_extra*-1);
    $pdf->cell(25,6,number_format(0,2,",","."),'LRTB',0,'R');
   }    
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'3 - Bonificação Construtoras:','LRTB',0,'L');
   if($val_bonif > 0)
   {
    $pdf->cell(25,6,number_format($val_bonif,2,",","."),'LRTB',0,'R');
   }else{
    $pdf->cell(25,6,number_format(0,2,",","."),'LRTB',0,'R');
   }    
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'4 - Indenização 1/12(LEI 4886):','LRTB',0,'L');
   $pdf->cell(25,6,number_format($val_ind,2,",","."),'LRTB',0,'R');
   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFillColor(230);
   $pdf->SetFont('Arial','B',10);
   $val_ganho=$sal_alcancado+$creditos+$val_ind+$val_bonif;
   $pdf->Cell(120,6,'    Total de Ganhos:','LRTB',0,'L',1);
   $pdf->cell(25,6,number_format($val_ganho,2,",","."),'LRTB',0,'R',1);
   $pdf->ln();
   $pdf->ln();
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'5 - Imposto de Renda:','LRTB',0,'L');
   if($tipo=="R")
   {
    $irrf=($sal_alcancado*1.5/100);
    if($irrf<10)
    {
     $irrf=0;
    }
   }else{
    $depend="select count(b.cod_fornecedor) as dependente 
                    from fornecedor a, fornec_depen b
                   where a.num_cgc_cpf='".$num_cgc."'
                         and b.cod_fornecedor=a.cod_fornecedor";
  
    $res_depend = $cconnect("logix",$ifx_user,$ifx_senha);
    $result_depend= $cquery($depend,$res_depend);
    $mat_depend=$cfetch_row($result_depend);
    $dependentes=$mat_depend["dependente"];    
    
    $dat_referencia=sprintf("%04d-%02d",$ano_ref,$mes_ref);
    $inss="select * from par_folha_mes 
                   where dat_referencia='".$dat_referencia."' ";
    $res_inss = $cconnect("logix",$ifx_user,$ifx_senha);
    $result_inss= $cquery($inss,$res_inss);
    $mat_inss=$cfetch_row($result_inss);
    $teto_inss=$mat_inss["val_teto_inss"];
    $val_dep=$mat_inss["val_desc_depend"];
    if($sal_alcancado >= $teto_inss)
    {
     $val_inss=(($teto_inss*11)/100);
    }else{
     $val_inss=(($sal_alcancado*11)/100);
    }
    $val_inss=round($val_inss,2);
    $val_base_irrf=$sal_alcancado-($val_dep*$dependentes);
    $val_base_irrf=$val_base_irrf-$val_inss;
    
    // Pesquisa da faixa IRRF a partir do valor líquido
   	$irrf="select * from irrf 
           where mes_ref='".$mes_ref."'
           and ano_ref='".$ano_ref."'
           order by lmt_sup_sal desc   ";
    $res_irrf = $cconnect("logix",$ifx_user,$ifx_senha);
    $result_irrf= $cquery($irrf,$res_irrf);
    $mat_irrf=$cfetch_row($result_irrf);
    while (is_array($mat_irrf))
    {
     $val_teto=$mat_irrf["lmt_sup_sal"];
     if($val_teto > $val_base_irrf)
     {
      $deducao=$mat_irrf["val_parcel_deduz"];
      $aliquota=$mat_irrf["pct_desc_irrf"];
     }
     $mat_irrf=$cfetch_row($result_irrf);
    }
    
    $val_base_irrf=round($val_base_irrf,2);
    $irrf=(($val_base_irrf*$aliquota)/100);
    $irrf=round($irrf,2);
    $irrf=$irrf-$deducao;
   }
   $pdf->cell(25,6,number_format($irrf,2,",","."),'LRTB',0,'R');
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'6 - Débitos não Tributaveis:','LRTB',0,'L');
   $pdf->cell(25,6,number_format($debitos,2,",","."),'LRTB',0,'R');
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'7 - Adiantamento de Comissões:','LRTB',0,'L');
   $pdf->cell(25,6,number_format($val_adiant,2,",","."),'LRTB',0,'R');
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->SetFillColor(210);
   $pdf->Cell(90,6,'8 - Estorno de Indenização:','LRTB',0,'L');
   $pdf->cell(25,6,number_format($val_estind,2,",","."),'LRTB',0,'R');
   $pdf->ln();
   $pdf->setx(50); 
   $pdf->Cell(90,6,'9 - INSS:','LRTB',0,'L');
   $pdf->cell(25,6,number_format($val_inss,2,",","."),'LRTB',0,'R');

   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFont('Arial','B',10);
   $pdf->SetFillColor(230);
   $pdf->Cell(120,6,'    Total de Descontos:','LRTB',0,'L',1);
   $val_desconto=$irrf+$debitos+$val_adiant+$val_estind+$val_inss;
   $pdf->cell(25,6,number_format($val_desconto,2,",","."),'LRTB',0,'R',1);
   $val_liquido=$val_ganho-$val_desconto;
   $pdf->ln();
   $pdf->ln();
   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFillColor(210);
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(120,6,'    Valor liquido:','LRTB',0,'L',1);
   $pdf->cell(25,6,number_format($val_liquido,2,",","."),'LRTB',0,'R',1);
   $pdf->ln();
   $pdf->ln();
   $pdf->ln();
   $pdf->ln();

   $mes_comis=sprintf("%02s/%04s",$mes_ref,$ano_ref);
   $texto="Recebemos da Empresa acima identificada, pela prestação de serviços de vendas do mes ".$mes_comis."  a importancia de R$".number_format($val_liquido,2,",",".");
   $texto_ext=Extenso($val_liquido);
   $texto_c=chop($texto)." (".chop($texto_ext).")"; 
   $pdf->setx(20); 
   $pdf->SetFillColor(210);
   $pdf->MultiCell(160,6,$texto_c,1,'J',1,8);

   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFillColor(210);
   $pdf->SetFont('Arial','B',10);
   $pdf->cell(160,6,$den_repres,'LRT',0,'L');
   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFillColor(210);
   $pdf->SetFont('Arial','B',10);
   $pdf->cell(160,6,$cnpj,'RL',0,'L');
   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFillColor(210);
   $pdf->SetFont('Arial','B',10);
   $pdf->cell(160,6,'','LR',0,'L');
   $pdf->ln();
   $pdf->setx(20); 
   $pdf->SetFillColor(210);
   $pdf->SetFont('Arial','B',10);
   $pdf->cell(160,6,'Assinatura:_______________________________________________','LRB',0,'L');
   $pdf->ln();
   $debitos=0;
   $creditos=0;
   $val_ind=0;
   $val_extra=0;
   $val_bonif=0;
   $val_adiant=0;
   $val_ganho=0;
   $val_liquido=0;
   $val_desconto=0;
   $irrf=0;
  }
 }
 $pdf->ln();
 $val_nf=0;
 $val_dp=0;
 $pdf->ln();
 $pdf->Output('recibo.pdf',true);
?>



