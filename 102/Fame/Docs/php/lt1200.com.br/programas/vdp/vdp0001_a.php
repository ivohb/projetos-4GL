<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenção:     Henrique
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Vendas - Emissão de Pedido de Venda
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

 $erep=chop($mat["erep"]);
 $cod_rep=chop($mat["cod_rep"]);
 if($prog=="vendas/vdp0001")
 {
  $vend="select cod_repres 
          from pedidos
        where cod_empresa='".$empresa."'
          and num_pedido='".$pedido."'
       ";
  $resv = $cconnect("logix",$ifx_user,$ifx_senha);
  $resultv = $cquery($vend,$resv);
  $matv=$cfetch_row($resultv);
 }else{
  $vend="select cod_repres 
          from lt1200:lt1200_hist_orc
        where cod_empresa='".$empresa."'
          and num_pedido='".$pedido."'
       ";
  $resv = $cconnect("logix",$ifx_user,$ifx_senha);
  $resultv = $cquery($vend,$resv);
  $matv=$cfetch_row($resultv);
 }
 $codrepres=chop($matv["cod_repres"]);
 $geren="select a.cod_nivel_3 
          from canal_venda a
        where a.cod_nivel_4='".$codrepres."'
       ";
 $resg = $cconnect("logix",$ifx_user,$ifx_senha);
 $resultg = $cquery($geren,$resg);
 $matg=$cfetch_row($resultg);
 $gerente=chop($matg["cod_nivel_3"]);
 $cab1=trim($mat[den_empresa]);
 $cab2=trim($mat[end_empresa]).'       Bairro:'.trim($mat[den_bairro]);
 $cab3=$mat[cod_cep].' - '.trim($mat[den_munic]).' - '.trim($mat[uni_feder]);
 $cab4='Fone: '.$mat[num_telefone].'   Fax: '.$mat[num_fax];
 $cab5="C.G.C.  :".$mat[num_cgc]."     Ins.Estadual:".$mat["ins_estadual"];
 $vlm=0;
 $vlipi=0;
 $vlfrete=0;
 $vlftreipi=0;
 $frete="0";
 $pc_frete=0;
 $desc1=0;
 $desc2=0;
 if($empresa=="01")
 {
   $mail='lt1200@lt1200.com.br';
 }elseif($empresa=="02"){
   $mail='lt1200.pr@lt1200.com.br';
 }elseif($empresa=="10"){
   $mail='lt1200.pr@lt1200.com.br';
 }elseif($empresa=="03"){
   $mail='lt1200.sp@lt1200.com.br';
 }
 $cab6="www.lt1200.com.br      email:".$mail;
 $tipo_ped="NAO ENCONTROU";
 if($erep=="S")
 {
  $selec_tipo="select cod_repres,num_pedido,dat_emis_repres,num_pedido_cli,num_pedido_repres,
                ies_finalidade,pct_desc_financ,pct_desc_adic,pct_frete,ies_frete,
                   cod_cliente,cod_nat_oper,cod_cnd_pgto,cod_moeda
                   from  pedido_dig_mest
                   where cod_empresa='".$empresa."'
                     and num_pedido='".$pedido."' 
                      and cod_repres='".$cod_rep."' ";

  $res_tipo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_tipo = $cquery($selec_tipo,$res_tipo);
  $mat_tipo=$cfetch_row($result_tipo);
  $cod_moeda=$mat_tipo["cod_moeda"];
  $ped_confere=$mat_tipo["num_pedido"];
  if ($ped_confere==$pedido)
  {
   $tipo_ped="ORÇAMENTO";
   if(chop($progc)=="vendas/pedpdf")
   {
    $empresa=$empresa;
   }
  }
  if($tipo_ped=="NAO ENCONTROU")
  {
   $selec_tipo="select cod_repres ,num_pedido,dat_pedido as dat_emis_repres,num_pedido_cli,num_pedido_repres,
                  ies_finalidade,pct_desc_financ,pct_desc_adic,pct_frete,ies_frete,
                  cod_cliente,  cod_nat_oper,cod_cnd_pgto,cod_moeda
                  from  pedidos a 

                   where cod_empresa='".$empresa."'
                     and num_pedido='".$pedido."'
                      and cod_repres='".$cod_rep."'
    ";

   $res_tipo = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_tipo = $cquery($selec_tipo,$res_tipo);
   $mat_tipo=$cfetch_row($result_tipo);
   $ped_confere=$mat_tipo["num_pedido"]; 
   $cod_moeda=$mat_tipo["cod_moeda"];
   if ($ped_confere==$pedido)
   {
    $tipo_ped="PEDIDO";
    if(chop($progc)=="vdp/orcpdf")
    {
     $empresa=$empresa;
    }
   }
  }
  /* Fim do Representante*/  
 }else{
  $selec_tipo="select cod_repres,num_pedido,dat_emis_repres,num_pedido_cli,num_pedido_repres,
                ies_finalidade,pct_desc_financ,pct_desc_adic,pct_frete,ies_frete,
                   cod_cliente,cod_nat_oper,cod_cnd_pgto,cod_moeda
                   from  pedido_dig_mest
                   where cod_empresa='".$empresa."'
                     and num_pedido='".$pedido."'  ";

  $res_tipo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_tipo = $cquery($selec_tipo,$res_tipo);
  $mat_tipo=$cfetch_row($result_tipo);
  $ped_confere=$mat_tipo["num_pedido"];
  $cod_moeda=$mat_tipo["cod_moeda"];
  if ($ped_confere==$pedido) 
  {
   $tipo_ped="ORÇAMENTO";
   if(chop($progc)=="vdp/vdp0001")
   {
    $empresa=$empresa;
   }
  }
  if($tipo_ped=="NAO ENCONTROU")
  {
   $selec_tipo="select cod_repres ,num_pedido,dat_pedido as dat_emis_repres,num_pedido_cli,num_pedido_repres,
                ies_finalidade,pct_desc_financ,pct_desc_adic,pct_frete,ies_frete,
                  cod_cliente,cod_nat_oper,cod_cnd_pgto,cod_moeda
                  from  pedidos
                   where cod_empresa='".$empresa."'
                     and num_pedido='".$pedido."'";

   $res_tipo = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_tipo = $cquery($selec_tipo,$res_tipo);
   $mat_tipo=$cfetch_row($result_tipo);
   $ped_confere=$mat_tipo["num_pedido"];
   $cod_moeda=$mat_tipo["cod_moeda"];
   if ($ped_confere==$pedido)
   {
    if(chop($progc)=="vendas/orcpdf")
    {
     $empresa=$empresa;
    }
    $tipo_ped="PEDIDO";
   }
  }                 
 }
 $cod_rep=$mat_tipo["cod_repres"];
 $cod_cli=$mat_tipo["cod_cliente"];
 $fin=$mat_tipo["ies_finalidade"];
 $desc1=$mat_tipo["pct_desc_financ"];
 $desc2=$mat_tipo["pct_desc_adic"];
 $frete=substr($mat_tipo["ies_frete"],0,1);
 $pcfrete=$mat_tipo["pct_frete"];
 $cod_natureza=$mat_tipo["cod_nat_oper"];
 $cod_pagamento=$mat_tipo["cod_cnd_pgto"];
 $ped_cli=$mat_tipo["num_pedido_cli"];
 $ped_rep=$mat_tipo["num_pedido_repres"];
 if(chop($cod_moeda)=="10")
 {
  $moedas="GBP";
 }elseif(chop($cod_moeda)=="9"){
  $moedas="EUR";
 }elseif(chop($cod_moeda)=="2"){
  $moedas="US$";
 }else{
  $moedas="R$";
 }
 $titulo=trim($tipo_ped).':'.$pedido;
 $data="Data Emissão: ".$data;
 $data_emi="DATA DO  ".trim($tipo_ped).':'.$mat_tipo["dat_emis_repres"];
 if($tipo_ped<> "NAO ENCONTROU")
 {
  define('FPDF_FONTPATH','../fpdf151/font/');
  require('../fpdf151/fpdf.php');
  require('../fpdf151/rotation.php');
  //Page header
  include('../../bibliotecas/cabecalho.inc');
 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage(); 
 while(is_array($mat_tipo))
 {
  $gerente=$matg["cod_nivel_3"];
  $selec_cli="select a.cod_cliente,a.nom_cliente,a.end_cliente,a.ins_estadual,
                     a.den_bairro,a.cod_cep,a.num_telefone,a.num_cgc_cpf,
                     b.den_cidade,b.cod_uni_feder,a.num_fax
           
                  from  clientes a,
                        cidades b
                   where cod_cliente='".$cod_cli."'
                     and b.cod_cidade=a.cod_cidade ";
  $res_cli = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_cli = $cquery($selec_cli,$res_cli);
  $mat_cli=$cfetch_row($result_cli);
  $uf_cli=$mat_cli["cod_uni_feder"];
  if(trim($mat_cli["cod_cliente"])<>$cod_cli)
  {
   $selec_cli="select a.cod_cliente,a.nom_cliente,a.end_cliente,a.ins_estadual,	
                      a.den_bairro,a.cod_cep,a.num_telefone,a.num_cgc_cpf,
		      a.cidade as den_cidade,a.uf as cod_uni_feder,a.num_fax
                from  lt1200:lt1200_clientes a
               where  cod_cliente='".$cod_cli."' ";
   $res_cli = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_cli = $cquery($selec_cli,$res_cli);
   $mat_cli=$cfetch_row($result_cli);
   $uf_cli=trim($mat_cli["cod_uni_feder"]);
  }
  $pdf->SetFont('Arial','B',10);
  $pdf->SetFillColor(260);
  $pdf->setx(10);
  $xposr=$pdf->getx(); 
  $yposr=$pdf->gety();
  $pdf->SetFillColor(260);
  $pdf->RoundedRect(($xposr),($yposr-1), 190, 18, 3.5, 'FD');
  if(substr(trim($ped_cli),1,1) <>"")
  {
   $t_ped_cli='  Pedido: '.trim($ped_cli);
  }
  $pdf->Cell(190,4,'CLIENTE '.$t_ped_cli,0,0,'C');
  $pdf->ln();
  $pdf->setx(11);
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',8);
  $pdf->Cell(94,4,' '.trim($mat_cli["cod_cliente"]).' - '.trim($mat_cli["nom_cliente"]),0,0,'L',1);
  $pdf->setx(105);
  $pdf->Cell(94,4,'Fone :'.trim($mat_cli["num_telefone"]).'        Fax: '.trim($mat_cli["num_fax"]),0,0,'L',1);
  $pdf->ln();
  $pdf->setx(11);
  $pdf->Cell(95,4,'CEP:'.chop($mat_cli["cod_cep"]).' - '.chop($mat_cli["den_cidade"]).' - '.chop($mat_cli["cod_uni_feder"]),0,0,'L',1);
  $pdf->setx(105);
  $pdf->Cell(94,4,'End.: '.chop($mat_cli["end_cliente"]).'     Bairro:'.chop($mat_cli["den_bairro"]),0,0,'L',1);
  $pdf->ln();
  $pdf->setx(11);
  $pdf->Cell(94,4,'C.G.C.:'.trim($mat_cli["num_cgc_cpf"]),0,0,'L',1);
  $pdf->setx(105);
  $pdf->Cell(94,4,'Ins.Estadual:'.trim($mat_cli["ins_estadual"]),0,0,'L',1);
  $pdf->ln();
  $selec_rep="select *
                  from  representante a, cidades b
                   where cod_repres='".$cod_rep."'
                     and b.cod_cidade=a.cod_cidade ";
  $res_rep = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_rep = $cquery($selec_rep,$res_rep);
  $mat_rep_1=$cfetch_row($result_rep);
  if(chop($mat_rep_1["cod_repres"])=='165')
  {
   $pdf->setx(10);
   $pdf->ln();
   $yposr=$pdf->gety();
   $pdf->sety($yposr);
   $yposr=$pdf->gety();
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(10,($yposr-1), 190, 13, 3.5, 'FD');
   if(substr(trim($ped_rep),1,1) <>"")
   {
    $t_ped_rep='  Pedido: '.trim($ped_rep);
   }
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(190,4,' REPRESENTANTE :'.$t_ped_rep,0,0,'C');
   $pdf->ln();
   $pdf->SetFont('Arial','',7);
   $pdf->setx(11);
   $pdf->Cell(94,4,round($mat_rep_1["cod_repres"]).' - '.trim($mat_rep_1["raz_social"]),0,0,'L');
   $pdf->setx(105);
   $pdf->Cell(94,4,' Fone :'.trim($mat_rep_1["num_telefone"]).'  Fax:'.trim($mat_rep_1["num_fax"]).' Celular: ',0,0,'L');
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(94,4,'Cidade: '.trim($mat_rep_1["den_cidade"]),0,0,'L');
   $pdf->setx(105);
   $pdf->Cell(94,4,' Email :'.$email_rep,0,0,'L');
   $pdf->ln();
  }   
     $pdf->ln();
   $selec_rep="select *
                  from  representante a, cidades b
                   where cod_repres='".$cod_rep."'
                     and b.cod_cidade=a.cod_cidade ";

   $res_rep = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_rep = $cquery($selec_rep,$res_rep);
   $mat_rep=$cfetch_row($result_rep);
   if(chop($mat_rep["cod_repres"])<>'165')
   {
    $pdf->setx(10);
    $pdf->ln();
    $pdf->ln();
    $yposr=$pdf->gety();
    $pdf->sety($yposr);
    $yposr=$pdf->gety();
    $pdf->SetFillColor(260);
    $pdf->RoundedRect(10,($yposr-1), 190, 13, 3.5, 'FD');
    if(substr(trim($ped_rep),1,1) <>"")
    {
     $t_ped_rep='  Pedido: '.trim($ped_rep);
    }
    $pdf->SetFont('Arial','B',10);
    $pdf->Cell(190,4,' REPRESENTANTE :'.$t_ped_rep,0,0,'C');
    $pdf->ln();
    $pdf->SetFont('Arial','',7);
    $pdf->setx(11);
    $pdf->Cell(94,4,round($mat_rep["cod_repres"]).' - '.trim($mat_rep["raz_social"]),0,0,'L');
    $pdf->setx(105);
    $pdf->Cell(94,4,' Fone :'.trim($mat_rep["num_telefone"]).'  Fax: '.trim($mat_rep["num_fax"]).' Celular: ',0,0,'L');
    $pdf->ln();
    $pdf->setx(11);
    $pdf->Cell(94,4,'Cidade: '.trim($mat_rep["den_cidade"]),0,0,'L');
    $pdf->setx(105);
    $pdf->Cell(94,4,' Email :'.$email_rep,0,0,'L');
    $pdf->ln();
    $pdf->ln();
   }

  
  
  
  if($tipo_ped=="ORÇAMENTO")
  {
   $selec_entrega="SELECT  a.den_bairro, a.end_entrega, a.num_cgc, a.cod_cep, a.ins_estadual, 
                          b.den_cidade, b.cod_uni_feder 
                    from  pedido_dig_ent a,outer cidades b 
                    where a.cod_empresa='".$empresa."' 
                          and a.num_pedido='".$pedido."' 
                          and b.cod_cidade=a.cod_cidade
                         ";
   $res_entrega = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_entrega = $cquery($selec_entrega,$res_entrega);
   $mat_entrega=$cfetch_row($result_entrega);
  }else{
   $selec_entrega="SELECT  a.den_bairro, a.end_entrega, a.num_cgc, a.cod_cep, a.ins_estadual, 
                          b.den_cidade, b.cod_uni_feder 
                    from  ped_end_ent a,outer cidades b 
                    where a.cod_empresa='".$empresa."' 
                          and a.num_pedido='".$pedido."' 
                          and b.cod_cidade=a.cod_cidade ";
   $res_entrega = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_entrega = $cquery($selec_entrega,$res_entrega);
   $mat_entrega=$cfetch_row($result_entrega);
  }
  $pdf->ln();
  $pdf->SetFont('Arial','B',7);
  $pdf->SetFillColor(260);
  $pdf->setx(10);
  $xposr=$pdf->getx(); 
  $yposr=$pdf->gety();
  while(is_array($mat_entrega))
  {
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(($xposr),($yposr-1), 94, 14, 3.5, 'FD');
   $pdf->SetFillColor(260);
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(94,4,'LOCAL DA ENTREGA DO '.$tipo_ped,0,0,'C');
   $pdf->ln();
   $pdf->setx(10);
   $pdf->SetFillColor(260);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(94,4,'  End:'.trim($mat_entrega["end_entrega"]).'     Bairro:'.trim($mat_entrega["den_bairro"]),0,'L',1);
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(92,4,'CEP:'.trim($mat_entrega["cod_cep"]). '    Cidade: '.trim($mat_entrega["den_cidade"]).' - '.trim($mat_entrega["cod_uni_feder"]),0,'L',1);
   $pdf->ln();
   $pdf->ln();
   $mat_entrega=$cfetch_row($result_entrega);
  }
  
  
  $selec_cobranca="SELECT  a.den_bairro, a.end_cobr, a.cod_cep, 
                           b.den_cidade, b.cod_uni_feder 
                     from  cli_end_cob a, 
                           cidades b
                    where  b.cod_cidade=a.cod_cidade_cob 
                          and a.cod_cliente='".$cod_cli."' ";

  $res_cobranca = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_cobranca = $cquery($selec_cobranca,$res_cobranca);
  $mat_cobranca=$cfetch_row($result_cobranca);
  while(is_array($mat_cobranca))
  {
   $pdf->ln();
   $pdf->SetFont('Arial','B',7);
   $pdf->SetFillColor(260);
   $pdf->setx(110);

   $pdf->sety($yposr);
   $yposr=$pdf->gety();
   $pdf->SetFillColor(260);
   $pdf->RoundedRect((106),($yposr-1), 94, 14, 3.5, 'FD');
   $pdf->SetFont('Arial','B',10);
   $pdf->setx(106);
   $pdf->Cell(94,4,'LOCAL DE COBRANÇA DO '.$tipo_ped,0,0,'C');
   $pdf->ln();
   $pdf->setx(106);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(94,4,'  End: '.trim($mat_cobranca["end_cobr"]).'        Bairro: '.trim($mat_cobranca["den_bairro"]),0,'L',1);
   $pdf->ln();
   $pdf->setx(107);
   $pdf->Cell(92,4,'CEP:'.trim($mat_cobranca["cod_cep"]). '     Cidade: '.trim($mat_cobranca["den_cidade"]).' - '.trim($mat_cobranca["cod_uni_feder"]),0,'L',1);
   $pdf->ln();
   $pdf->ln();
   $mat_cobranca=$cfetch_row($result_cobranca);
  }
  $selec_obra="select *
                  from  lt1200_hist_orc a
                   where a.cod_empresa='".$empresa."'
                     and a.num_pedido='".$pedido."' ";
  $res_obra = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_obra = $cquery($selec_obra,$res_obra);
  $mat_obra=$cfetch_row($result_obra);
  while(is_array($mat_obra))
  {
   $pdf->SetFont('Arial','B',7);
   $pdf->SetFillColor(260);
   $pdf->setx(10);
   $xposr=$pdf->getx(); 
   $yposr=$pdf->gety();
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(($xposr),($yposr-1), 190, 14, 3.5, 'FD');
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(190,4,'DADOS SOBRE A OBRA',0,0,'C');
   $pdf->ln();
   $pdf->setx(11);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(94,4,'Nome da Obra: '.trim($mat_obra["obra"]),0,0,'L',1);
   $pdf->setx(105);
   $pdf->Cell(47,4,'Fone: '.trim($mat_obra["fone_obra"]),0,0,'L',1);
   $pdf->Cell(47,4,'Celular: '.trim($mat_obra["celular_obra"]),0,0,'L',1);
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(94,4,'Responsavel: '.trim($mat_obra["cont_obra"]),0,0,'L',1);
   $pdf->setx(105);
   $pdf->Cell(94,4,'Email: '.trim($mat_obra["email_obra"]),0,0,'L',1);
   $pdf->ln();
   $pdf->ln();
   $mat_obra=$cfetch_row($result_obra);
  }
  $selec_texto="SELECT c.den_texto_1,c.den_texto_2,c.den_texto_3,c.den_texto_4,c.den_texto_5 
                   from  ped_itens_texto c 
                  where c.cod_empresa='".$empresa."' 
                        and c.num_pedido='".$pedido."' 
                        and c.num_sequencia='0'  
                        and trim(c.den_texto_1) <> ' ' ";
  $res_texto = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_texto = $cquery($selec_texto,$res_texto);
  $mat_texto=$cfetch_row($result_texto);
  while(is_array($mat_texto))
  {
   $pdf->SetFillColor(260);
   $pdf->setx(10);
   $xposr=$pdf->getx(); 
   $yposr=$pdf->gety();
   $pdf->SetFillColor(260);
   $lin=26;
   $cell=190;
   $marg='RL';
   if(substr(trim($mat_texto["den_texto_5"]),1,1) =="")
   {
    $lin=$lin-4;
   }
   if(substr(trim($mat_texto["den_texto_4"]),1,1) =="")
   {
    $lin=$lin-4;
   }
   if(substr(trim($mat_texto["den_texto_3"]),1,1) =="")
   {
    $lin=$lin-4;
   }
   if(substr(trim($mat_texto["den_texto_2"]),1,1) =="")
   {
    $lin=$lin-4;
   }
   $pdf->RoundedRect(($xposr),($yposr-1), 190, $lin, 3.5, 'FD');
   $pdf->SetFillColor(260);
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(190,4,'TEXTO DO '.$tipo_ped,0,0,'C');
   $pdf->ln();
   $pdf->setx(11);
   $pdf->SetFillColor(260);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(188,4,trim($mat_texto["den_texto_1"]),0,0,'L',1);
   $pdf->ln();
   if(substr(trim($mat_texto["den_texto_2"]),1,1) <>"")
   {
    $pdf->setx(11);
    $pdf->Cell(188,4,trim($mat_texto["den_texto_2"]),0,0,'L',1);
    $pdf->ln();
   }
   if(substr(trim($mat_texto["den_texto_3"]),1,1) <>"")
   {
    $pdf->setx(11);
    $pdf->Cell(188,4,trim($mat_texto["den_texto_3"]),0,0,'L',1);
    $pdf->ln();
   }
   if(substr(trim($mat_texto["den_texto_4"]),1,1) <>"")
   {
    $pdf->setx(11);
    $pdf->Cell(188,4,trim($mat_texto["den_texto_4"]),0,0,'L',1);
    $pdf->ln();
   }
   if(substr(trim($mat_texto["den_texto_5"]),1,1) <>"")
   {
    $pdf->setx(11);
    $pdf->Cell(188,4,trim($mat_texto["den_texto_5"]),0,0,'L',1);
    $pdf->ln();
   }
   $mat_texto=$cfetch_row($result_texto);
  }
  $selec_obs="SELECT c.tex_observ_1,c.tex_observ_2 
                 from  ped_observacao c 
                where c.cod_empresa='".$empresa."' 
                      and c.num_pedido='".$pedido."' 
                      and trim(c.tex_observ_1) <> ' '";
  $res_obs = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_obs = $cquery($selec_obs,$res_obs);
  $mat_obs=$cfetch_row($result_obs);
  while(is_array($mat_obs))
  {
   $pdf->ln();
   $pdf->SetFont('Arial','B',7);
   $pdf->SetFillColor(260);
   $pdf->setx(10);
   $xposr=$pdf->getx(); 
   $yposr=$pdf->gety();
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(($xposr),($yposr-1), 190, 13, 3.5, 'FD');
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(($xposr),($yposr+5), 190, 8, 3.5, 'FD');
   $pdf->SetFont('Arial','B',10);
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(190,4,'OBSERVAÇOES DO '.$tipo_ped,0,0,'C');
   $pdf->ln();
   $pdf->setx(10);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(190,4,' '.trim($mat_obs["tex_observ_1"]),LR,0,'L',1);
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(188,4,trim($mat_obs["tex_observ_2"]),0,0,'L',1);
   $pdf->ln();
   $mat_obs=$cfetch_row($result_obs);
  }
  $selec_obs="SELECT c.tex_observ_1,c.tex_observ_2 
                 from  pedido_dig_obs c 
                where c.cod_empresa='".$empresa."' 
                      and c.num_pedido='".$pedido."' 
                      and trim(c.tex_observ_1) <> ' '";
  $res_obs = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_obs = $cquery($selec_obs,$res_obs);
  $mat_obs=$cfetch_row($result_obs);
  while(is_array($mat_obs))
  {
   $pdf->ln();
   $pdf->SetFont('Arial','B',7);
   $pdf->SetFillColor(260);
   $pdf->setx(10);
   $xposr=$pdf->getx(); 
   $yposr=$pdf->gety();
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(($xposr),($yposr-1), 190, 13, 3.5, 'FD');
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(($xposr),($yposr+5), 190, 8, 3.5, 'FD');
   $pdf->SetFont('Arial','B',10);
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(190,4,'OBSERVAÇOES DO '.$tipo_ped,0,0,'C');
   $pdf->ln();
   $pdf->setx(10);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(190,4,' '.trim($mat_obs["tex_observ_1"]),LR,0,'L',1);
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(188,4,trim($mat_obs["tex_observ_2"]),0,0,'L',1);
   $pdf->ln();
   $mat_obs=$cfetch_row($result_obs);
  }
  $selec_nat_pag="SELECT (g.cod_nat_oper||' - '||g.den_nat_oper) as oper,
                (h.cod_cnd_pgto||' - '||den_cnd_pgto) as pgto,
                i.ies_incid_ipi,j.entrega_txt

        from nat_operacao g,
             cond_pgto h,
             fiscal_par i,
             lt1200_hist_orc j
        where g.cod_nat_oper='".$cod_natureza."'
          and h.cod_cnd_pgto='".$cod_pagamento."'
          and i.cod_nat_oper=g.cod_nat_oper
          and i.cod_empresa='".$empresa."'
          and i.cod_uni_feder='".$uf_cli."' ";
  $res_nat_pag = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_nat_pag = $cquery($selec_nat_pag,$res_nat_pag);
  $mat_nat_pag=$cfetch_row($result_nat_pag);
  $incid_ipi=$mat_nat_pag["ies_incid_ipi"];
  $pgto=$mat_nat_pag["pgto"];
  $oper=$mat_nat_pag["oper"];
  $pdf->ln();
  $pdf->SetFont('Arial','B',7);
  $pdf->SetFillColor(260);
  $pdf->setx(10);
  $xposr=$pdf->getx(); 
  $yposr=$pdf->gety();
  $pdf->SetFillColor(260);
  $pdf->RoundedRect(($xposr),($yposr-1), 190, 18, 3.5, 'FD');
  $pdf->SetFont('Arial','B',10);
  $pdf->Cell(190,4,'INFORMAÇÕES DO '.$tipo_ped.' PARA FATURAMENTO' ,0,0,'C');
  $pdf->ln();
  $pdf->setx(10);
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',8);
  $pdf->SetFont('Arial','B',8);
  $pdf->Cell(45,4,' CONDIÇÃO DE PAGAMENTO:',L,0,'L',1);
  $pdf->SetFont('Arial','',7);
  $pdf->Cell(60,4,trim($pgto),0,0,'L',1);
  $selec_prazo="SELECT a.entrega_txt 
                 from  lt1200_hist_orc a 
                where a.cod_empresa='".$empresa."' 
                      and a.num_pedido='".$pedido."'                ";
  $res_prazo = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_prazo = $cquery($selec_prazo,$res_prazo);
  $mat_prazo=$cfetch_row($result_prazo);
  if($tipo_ped=="ORÇAMENTO")
  {
   $pdf->SetFont('Arial','B',8);
   $pdf->Cell(35,4,'PRAZO DE ENTREGA:',0,0,'L',1);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(50,4,$mat_prazo["entrega_txt"],R,0,'L',1);
  }
  if($fin=="1")
  {
   $textofin=("Comercializacao/Indust.");
  }
  if($fin=="2")
  {
   $textofin=("Consumo nao Contribuinte");
  }
  if($fin=="3")
  {
   $textofin=("Consumo Contribuinte.");
  }
  if($compara=(strcmp("1",$frete)==0))
  {
   $textof=("CIF (PAGO)");
   $moeda=("  " );
  }
  if($compara=(strcmp("2",$frete)==0))
  {
   $textof=("CIF (COBRADO)");
   $moeda=("R$" );
  }
  if($compara=(strcmp("3",$frete)==0))
  {
   $textof=("FOB (A PAGAR)");
   $moeda=("  " );
  }
  if($compara=(strcmp("4",$frete)==0))
  {
   $textof=("CIF (INF PCT)");
   $pe=("%");
   $moeda=("  " );
  }
  if($compara=(strcmp("5",$frete)==0))
  {
   $textof=("CIF (INF UNIT)");
  }
  if($compara=(strcmp("6",$frete)==0))
  {
   $textof=("ITEM TOT"); 
  }
  $pdf->ln();
  $pdf->setx(10);
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',8);
  $pdf->Cell(45,4,' NATUREZA DE OPERAÇÃO: ',L,0,'L',1);
  $pdf->SetFont('Arial','',7);
  $pdf->Cell(145,4,trim($oper).'    FINALIDADE: '.$textofin  ,R,0,'L',1);
  $pdf->ln();
  $pdf->setx(11);
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',8);
  $val_frete=0;
  $selec_frete="SELECT val_frete 
                  from pedidos_frete 
                  where cod_empresa='".$empresa."' 
                    and num_pedido='".$pedido."' " ;
  $res_frete = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_frete = $cquery($selec_frete,$res_frete);
  $mat_frete=$cfetch_row($result_frete);
  $val_frete=$mat_frete["val_frete"];
  $pdf->SetFont('Arial','B',8);
  $pdf->Cell(44,4,'FRETE:  ',0,0,'L',1);
  $pdf->SetFont('Arial','',7);
  if($compara=(strcmp("2",$frete)==0))
  {
   $pcfrete=number_format($val_frete,2,",",".");
  }
  if($c_saldo=="S")
  {
   $sel="a.qtd_pecas_solic-a.qtd_pecas_cancel";
  }else{
   $sel="a.qtd_pecas_solic-a.qtd_pecas_cancel-a.qtd_pecas_atend";
  }
  $pdf->Cell(144,4,trim($frete).' - '.$textof. '  ' . $moeda .' '.$pcfrete.' '.$pe,0,0,'L',1);

  $pdf->ln();
  $pdf->ln();
  $mat_tipo=$cfetch_row($result_tipo);
 }
 $selec_it="SELECT c.den_texto_1,c.den_texto_2,
                        c.den_texto_3,c.den_texto_4,
                        c.den_texto_5
                  from  pedido_dig_texto c
                  where c.cod_empresa='".$empresa."'
                    and c.num_pedido='".$pedido."'
                    and c.num_sequencia='0'  ";

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($selec_it,$res);
 $mat_it=$cfetch_row($result);
 if($mat_it["den_texto_1"]<>"")
 {
  $pdf->SetFillColor(260);
  $pdf->setx(10);
  $xposr=$pdf->getx(); 
  $yposr=$pdf->gety();
  $pdf->SetFillColor(260);
  $lin=26;
  $cell=190;
  $marg='RL';
  if(substr($mat_it["den_texto_5"],1,1) =="")
  {
   $lin=$lin-4;
  }
  if(substr($mat_it["den_texto_4"],1,1) =="")
  {
   $lin=$lin-4;
  }
  if(substr($mat_it["den_texto_3"],1,1) =="")
  {
   $lin=$lin-4;
  }
  if(substr($mat_it["den_texto_2"],1,1) =="")
  {
   $lin=$lin-4;
  }
  $pdf->RoundedRect(($xposr),($yposr-1), 190, $lin, 3.5, 'FD');
  $pdf->SetFillColor(260);
  $pdf->SetFont('Arial','B',10);
  $pdf->Cell(190,4,'TEXTO DA NOTA FISCAL',0,0,'C');
  if(substr($mat_it["den_texto_1"],1,1) <>"")
  {
   $pdf->ln();
   $pdf->setx(10);
   $pdf->SetFont('Arial','',7);
   $pdf->Cell(190,4,"  ".trim($mat_it["den_texto_1"]),LR,0,'L',1);
  }
  if(substr($mat_it["den_texto_2"],1,1) <>"")
  {
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(188,4,trim($mat_it["den_texto_2"]),0,0,'L',1);
  }
  if(substr($mat_it["den_texto_3"],1,1) <>"")
  {
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(188,4,trim($mat_it["den_texto_3"]),0,0,'L',1);
  }
  if(substr($mat_it["den_texto_4"],1,1) <>"")
  {
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(188,4,trim($mat_it["den_texto_4"]),0,0,'L',1);
  }
  if(substr($mat_it["den_texto_5"],1,1) <>"")
  {
   $pdf->ln();
   $pdf->setx(11);
   $pdf->Cell(188,4,"  ".trim($mat_it["den_texto_5"]),0,0,'L',1);
  }
  $pdf->ln();
 }
 if($tipo_ped=='ORÇAMENTO')
 {
  $ped_10="SELECT a.qtd_pecas_solic
                 as qtd_saldo,a.prz_entrega
             from pedido_dig_item a,
                  item b
            where a.cod_empresa='".$empresa."'
                  and a.num_pedido='".$pedido."'
                  and b.cod_empresa=a.cod_empresa
                  and b.cod_item=a.cod_item
                  and a.qtd_pecas_solic >0   ";
  $res10 = $cconnect("logix",$ifx_user,$ifx_senha);
  $result10 = $cquery($ped_10,$res10);
  $mat_10=$cfetch_row($result10);
  $qtd_tot=0;
  while (is_array($mat_10))
  {
   $qtd_tot=$qtd_tot+$mat_10["qtd_saldo"];
   $mat_10=$cfetch_row($result10);
  }
  $selec_itens="select a.num_sequencia,a.cod_item,a.prz_entrega,
                (a.qtd_pecas_solic) as qtd_saldo,
                 a.pre_unit,a.val_frete_unit,a.pct_desc_adic,
                 b.den_item,b.pct_ipi,b.cod_unid_med,
                 c.den_texto_1,c.den_texto_2,c.den_texto_3,c.den_texto_4,c.den_texto_5
                 from pedido_dig_item  a,
                      item b,
                      outer pedido_dig_texto c
                 where a.cod_empresa='".$empresa."'
                   and a.num_pedido='".$pedido."'
                   and b.cod_empresa=a.cod_empresa
                   and c.cod_empresa=a.cod_empresa
                   and c.num_pedido=a.num_pedido
                   and c.num_sequencia=a.num_sequencia
                   and b.cod_item=a.cod_item
                   order by a.num_sequencia  ";

  }
  if($tipo_ped=='PEDIDO')
  {
   $ped_10="SELECT ($sel)
                   as qtd_saldo,a.prz_entrega
             from ped_itens a,
                  item b
            where a.cod_empresa='".$empresa."'
                  and a.num_pedido='".$pedido."'
                  and b.cod_empresa=a.cod_empresa
                  and b.cod_item=a.cod_item
                  and ($sel) >0   ";
   $res10 = $cconnect("logix",$ifx_user,$ifx_senha);
   $result10 = $cquery($ped_10,$res10);
   $mat_10=$cfetch_row($result10);
   $qtd_tot=0;
   while (is_array($mat_10))
   {
    $qtd_tot=$qtd_tot+$mat_10["qtd_saldo"];
    $mat_10=$cfetch_row($result10);
   }
   $selec_itens="SELECT a.num_sequencia,a.cod_item,a.prz_entrega,
                 ($sel) as qtd_saldo,
                 a.pre_unit,a.val_frete_unit,a.pct_desc_adic,
                 b.den_item,b.pct_ipi,b.cod_unid_med,b.cod_local_estoq,
                 c.den_texto_1,c.den_texto_2,c.den_texto_3,c.den_texto_4,
                 c.den_texto_5
            from ped_itens a,
                 item b,
                 outer ped_itens_texto c
           where a.cod_empresa='".$empresa."'
                 and a.num_pedido='".$pedido."'
                 and b.cod_empresa=a.cod_empresa
                 and c.cod_empresa=a.cod_empresa
                 and c.num_pedido=a.num_pedido
                 and c.num_sequencia=a.num_sequencia
                 and b.cod_item=a.cod_item
                 and ($sel) >0   
            order by a.num_sequencia  ";
   }
   $res_itens = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_itens = $cquery($selec_itens,$res_itens);
   $mat_itens=$cfetch_row($result_itens);
   if($exportacao=="S")
   {
    $selec_texto="SELECT c.texto ,c.num_linha
                   from  exp_pedven_tex_val c
                  where c.cod_empresa='1'
                        and c.num_ped_venda='".$ped_rep."' 
                        and c.num_texto = '1' 
                        order by num_linha ";
    $res_texto = $cconnect("gecex",$ifx_user,$ifx_senha);
    $result_texto = $cquery($selec_texto,$res_texto);
    $mat_texto=$cfetch_row($result_texto);
    while(is_array($mat_texto))
    {
     $texto=chop($texto).chop($mat_texto["texto"]);
     $mat_texto=$cfetch_row($result_texto);
    }  
    $comprimento=strlen($texto);
    $pos=strpos($texto,'up0\dn0',0);
    $texto=substr($texto,$pos+7,$comprimento);
    $texto=str_replace('¦¿{\rtf1\ansi\deff0{\fonttbl{\f0\froman','',$texto);
    $texto=str_replace('Tms Rmn;}}{\colortbl\red0\green0\blue0;\red0\green0\blue255;\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;\red0\green0\blue¿¦¦¿127;\red0\green127\blue127;\red0\green127\blue0;\red127\green0\blue127;\red127\green0\blue0;\red127\green127\blue0;\red127\green127\blue127;\red192\green192\blue192;}{\info{\creatim\yr2004\mo10\dy25\hr9\min53\sec28}{\version1}{\vern262367}}\paperw1190¿¦¦¿3\paperh16833\margl244\margr8\margt244\margb0\deftab720\pard\ql{\f0\fs20\cf0\up0\dn0 \loch\af0 \loch\af0','',$texto);
    $texto=str_replace('{\par}\pard\ql{\f0\fs20\cf0\up0\dn0 \loch\af0','q_linha',$texto);
    $texto=str_replace('\hich\af0 \§©c7\§©c3\loch\af0','',$texto);
    $texto=str_replace('{\f0\fs20\cf0\up0\dn0 \loch\af0','',$texto);
    $texto=str_replace('{\par}\pard\ql{\f0\fs20\cf0\u¿¦','',$texto);
    $texto=str_replace('¦¿p0\dn0 \loch\af0','',$texto);
    $texto=str_replace('¦¿paperh16833\margl244\margr8\margt244\margb0\deftab720\pard\ql{\f0\fs20\cf0\up0\dn0 \loch\af0','',$texto);
    $texto=str_replace('¦¿127;\red0\green127\blue127;\red0\green127\blue0;\red127\green0','',$texto);
    $texto=str_replace('\blue127;\red127\green0\blue0;\red127\green127\blue0;\red127\gre','',$texto);
    $texto=str_replace('en127\blue127;\red192\green192\blue192}{\info{\creatim\yr2000\mo','',$texto);
    $texto=str_replace('11\dy6\hr10\min9\sec43}{\version1}{\vern262367}}\paperw11903\¿¦','',$texto);
    $texto=str_replace('{\par}\pard\ql','',$texto);
    $texto=str_replace('}}¿¦','',$texto);
    $texto=str_replace('¦¿','',$texto);                                        
    $texto=str_replace('¿¦','',$texto);
    $texto=str_replace('}','',$texto);
    $texto=chop($texto).'q_linha';
    $comprimento=strlen($texto);
    $pos=strpos($texto,'q_linha',0);
    while($pos  > 0)
    {
     $textoi=substr($texto,0,$pos);
     $pdf->SetFont('Arial','B',8);
     $pdf->setx(10);
     $pdf->MultiCell(190,4,$textoi,0,'J',0,8);
     $texto=substr($texto,$pos+7,$comprimento);
     $comprimento=strlen($texto);
     $pos=strpos($texto,'q_linha',0);
    }   
   }
   $pdf->ln();
   $pdf->SetFont('Arial','B',7);
   $pdf->SetFillColor(260);
   $pdf->setx(10);
   $xposr=$pdf->getx(); 
   $yposr=$pdf->gety();
   $pdf->SetFillColor(260);
   $pdf->RoundedRect(($xposr),($yposr-1), 190, 15, 3.5, 'FD');
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(190,4,'ITENS DO '.$tipo_ped,B,0,'C');
   $pdf->ln();
   $pdf->SetFont('Arial','B',7);
   $pdf->SetFillColor(260);
   $pdf->setx(10);
   $pdf->Cell(5,4,'',R,0,'C');
   $pdf->Cell(13,4,'',LR,0,'C');
   $pdf->Cell(13,4,'',LR,0,'C');
   $pdf->Cell(5,4,'',LR,0,'C');
   $pdf->Cell(96,4,'',LR,0,'C');
   if($exportacao=="S")
   {
    $pdf->Cell(37,4,'',R,0,'C');
   }else{
    $pdf->Cell(30,4,'VALOR',BLR,0,'C');
    $pdf->Cell(10,4,'',LR,0,'C');
   }
   $pdf->Cell(18,4,'ENTREGA NA',LR,0,'C');
   $pdf->ln();
   $pdf->SetFillColor(260);
   $pdf->setx(10);
   $pdf->Cell(5,4,'SQ',BR,0,'C');
   $pdf->Cell(13,4,'CODIGO',BLR,0,'C');
   $pdf->Cell(13,4,'QTD',BLR,0,'C');
   $pdf->Cell(5,4,'UN',BLR,0,'C');
   $pdf->Cell(96,4,'DESCRIÇÃO DO PRODUTO',BLR,0,'C');
   if($exportacao=="S"){
    $pdf->Cell(37,4,'',BR,0,'C');
   }else{
    $pdf->Cell(15,4,'UNITÁRIO',BLR,0,'C');
    $pdf->Cell(15,4,'TOTAL',BLR,0,'C');
    $pdf->Cell(10,4,'%IPI',BLR,0,'C');
   }
   $pdf->Cell(18,4,'EXPEDIÇÃO',BLR,0,'C');
   $pdf->ln();
   $pdf->SetFillColor(260);
   $pdf->Cell(190,4,'',T,0,'C',1);
   $cab=2; 
   while (is_array($mat_itens))
   {
    $qtd=$qtd+$mat_itens["qtd_saldo"];
    $vl_desc_1=($mat_itens["pre_unit"]*$mat_itens["pct_desc_adic"]/100);
    $vlmu=$mat_itens["pre_unit"]-round($vl_desc_1,2);
    $vl_desc_2=($vlmu*$desc2/100);
    $vlmu=$vlmu-round($vl_desc_2,2);
    $vlma=round(($mat_itens["qtd_saldo"]*$vlmu),3);
    $vlm=($vlm+$vlma);
    if($incid_ipi==1)
    {
     $vlipi=($vlipi+($vlma*$mat_itens["pct_ipi"]/100));
     $vlipi=(round(($vlipi*100),0)/100);
    }else{
     $vlipi=0;
    }
    if(substr(trim($mat_itens["den_texto_2"]),1,1) =="")
    {
     $marg='';
    }
    if(substr(trim($mat_itens["den_texto_1"]),1,1) =="")
    {
     $marg='';
    }
    $yposr=$pdf->gety();
    $pdf->sety($yposr);
    $pdf->ln();
    $pdf->SetFont('Arial','B',7);
    $pdf->SetFillColor(260);
    $pdf->Cell(5,4,round($mat_itens["num_sequencia"]),0,0,'R',1);
    $pdf->Cell(13,4,trim($mat_itens["cod_item"]),0,0,'R',1);
    if(trim($mat_itens["cod_unid_med"])=="PC")
    {
     $casas=0;
     $totpc=$totpc+1; 
    }elseif(trim($mat_itens["cod_unid_med"])=="MT"){
     $casas=2;
    }elseif(trim($mat_itens["cod_unid_med"])=="M2"){
     $casas=2;
    }elseif(trim($mat_itens["cod_unid_med"])=="M3"){
     $casas=3;
    }elseif(trim($mat_itens["cod_unid_med"])=="CJ"){
     $casas=0;
    }else{
     $casas=0;
    }
    if(chop($mat_itens["cod_local_estoq"])=="11")
    {
     $casasv=4;
    }else{
     $casasv=2;
    }
    $pdf->Cell(13,4,number_format($mat_itens["qtd_saldo"],$casas,",","."),0,0,'R',1);
    $pdf->Cell(5,4,$mat_itens["cod_unid_med"],0,0,'C',1);
    $pdf->Cell(96,4,trim($mat_itens["den_item"]),0,0,'L',1);
    if($exportacao=="S")
    {
     $pdf->Cell(37,4,'',0,0,'C');
    }else{
     $pdf->Cell(15,4,number_format($vlmu,$casasv,",","."),0,0,'R',1);
     $pdf->Cell(15,4,number_format($vlma,$casasv,",","."),0,0,'R',1);
     if($incid_ipi==1)
     {
      $pdf->Cell(10,4,number_format($mat_itens["pct_ipi"],2,",","."),0,0,'R',1);
     }else{
      $pdf->Cell(7,4,number_format(0,2,",","."),0,0,'R',1);
     }
    }
    $pdf->Cell(18,4,trim($mat_itens["prz_entrega"]),0,0,'R',1);
    if($frete=="4")
    {
     $vlfrete=($vlfrete+(($vlma*$pcfrete/100)));
     $vlfrete=round($vlfrete,2);
     $vlfretea=(($vlma*$pcfrete/100));
     $vlfretea=round($vlfretea,2);
     $vfrete=round(($vlfretea*$mat_itens["pct_ipi"]/100),2);
     if($incid_ipi==1)
     {
      $vlfreteipi=($vlfreteipi+$vfrete);
     }else{
      $vlfreteipi=0;
     }
    }
    if($frete=='2')
    {
     $vlfretea=($mat_itens["qtd_saldo"]*$val_frete/$qtd_tot);
     $vlfretea=(round(($vlfretea*10000),0)/10000);
     $vlfrete=($vlfrete+$vlfretea);
     $vfrete=(round((($vlfretea*$mat_itens["pct_ipi"])),0)/100);
     if($incid_ipi==1)
     {
      $vlfreteipi=($vlfreteipi+$vfrete);
     }else{
      $vlfreteipi=0;
     }
    }
    if(substr(trim($mat_itens["den_texto_2"]),1,1) =="")
    {
     $marg='B';
    }
    if(substr(trim($mat_itens["den_texto_1"]),1,1) <>"")
    {
     $pdf->ln();
     $pdf->setx(45);
     $pdf->SetFillColor(260);
     $pdf->SetFont('Arial','B',8);
     $pdf->Cell(155,4,$mat_itens["den_texto_1"],0,0,'L',1);
    }
    if(substr(trim($mat_itens["den_texto_3"]),1,1) =="")
    {
     $marg='';
    }
    if(substr(trim($mat_itens["den_texto_2"]),1,1) <>"")
    {
     $pdf->ln();
     $pdf->setx(45);
     $pdf->Cell(155,4,$mat_itens["den_texto_2"],0,0,'L',1);
    }
    if(substr(trim($mat_itens["den_texto_4"]),1,1) =="")
    {
     $marg='';
    }
    if(substr(trim($mat_itens["den_texto_3"]),1,1) <>"")
    {
     $pdf->ln();
     $pdf->setx(45);
     $pdf->Cell(155,4,$mat_itens["den_texto_3"],0,0,'L',1);
    }
    if(substr(trim($mat_itens["den_texto_5"]),1,1) =="")
    {
     $marg='B';
    }
    if(substr(trim($mat_itens["den_texto_4"]),1,1) <>"")
    {
     $pdf->ln();
     $pdf->setx(45);
     $pdf->Cell(155,4,$mat_itens["den_texto_4"],0,0,'L',1);
    }
    if(substr(trim($mat_itens["den_texto_5"]),1,1) <>"")
    {
     $pdf->ln();
     $pdf->setx(45);
     $pdf->Cell(155,4,$mat_itens["den_texto_5"],0,0,'L',1);
    }
    $marg='';
    $pdf->ln();
    $mat_itens=$cfetch_row($result_itens);
   }
   $pdf->ln();
   $pdf->setx(10);
   $pdf->SetFont('Arial','B',10);
   $pdf->Cell(45,5,' ',0,0,'C');
   $pdf->Cell(5,5,"",0,0,'R');
   $pdf->Cell(45,5,' ',0,0,'C');
   if($exportacao<>"S")
   {
    $cab=1;
    $pdf->setx(105);
    $pdf->SetFont('Arial','B',10);
    $pdf->Cell(60,5,'VALOR TOTAL MERCADORIA: ',TL,0,'L');
    $pdf->Cell(35,5,$moedas." ".number_format($vlm,$casasv,",","."),TR,0,'R');
    $pdf->ln();
    if($vlfrete > 0)
    {
     $pdf->setx(105);
     $pdf->Cell(60,5,'VALOR TOTAL DO FRETE: ',TL,0,'L');
     $pdf->Cell(35,5,$moedas." ".number_format($vlfrete,$casasv,",","."),TR,0,'R');
     $pdf->ln();
    }
    if(($vlipi+$vlfreteipi) > 0)
    {
     $pdf->setx(105);
     $pdf->Cell(60,5,'VALOR TOTAL DO IPI: ',TL,0,'L');
     $pdf->Cell(35,5,$moedas." ".number_format(($vlipi+$vlfreteipi),$casasv,",","."),TBR,0,'R');
     $pdf->ln();
    }
    $pdf->setx(10);
    $pdf->Cell(45,5,'_____________',0,0,'C');
    $pdf->Cell(5,5,"",0,0,'R');
    $pdf->Cell(45,5,'_____________',0,0,'C');
    $pdf->Cell(60,5,'VALOR TOTAL DO '.$tipo_ped.': ',TBL,0,'L');
    $pdf->Cell(35,5,$moedas." ".number_format(($vlm+$vlfrete+$vlipi+$vlfreteipi),$casasv,",","."),TBR,0,'R');
   }
 }
 $pdf->Output('pedpdf.pdf',true);
?>

