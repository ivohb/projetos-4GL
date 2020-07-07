<?
 //-----------------------------------------------------------------------------
 //Desenvolvedor:  Henrique Conte
 //Manutenção:     Denis 
 //Data manutenção:23/06/2004
 //Módulo:         EXp
 //Processo:       Ordem de Produção
 //-----------------------------------------------------------------------------
 $data=sprintf("%02d/%02d/%04d-%02d:%02d",$dia,$mes,$ano,$hora,$min);
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $data=sprintf("%02d/%02d/%04d",$dia,$mes,$ano);
 $funcio="select a.cod_empresa,a.den_empresa,a.num_cgc,a.den_munic,a.end_empresa,
                a.num_telefone,a.cod_cep,a.ins_estadual,a.den_bairro,
		a.uni_feder,a.num_fax,
                b.cod_usuario,b.cod_rep,b.erep,b.ctr_exp,
                b.fone,b.fax,b.celular,b.email
	from	empresa a,
                lt1200:lt1200_usuarios b
	where	a.cod_empresa='".$empresa."'
	        and b.cod_usuario='".$ifx_user."'
	";

 $res = $cconnect("logix",$ifx_user,$ifx_senha);
 $result = $cquery($funcio,$res);
 $mat=$cfetch_row($result);
 $erep=trim($mat["erep"]);
 $cod_rep=trim($mat["cod_rep"]);
 $cab1=trim($mat[den_empresa]);
 $cab2=trim($mat[end_empresa]).'       Bairro:'.trim($mat[den_bairro]);
 $cab3=$mat[cod_cep].' - '.trim($mat[den_munic]).' - '.trim($mat[uni_feder]);
 $cab4='Fone: '.$mat[num_telefone].'   Fax: '.$mat[num_fax];
 $cab5="C.G.C.  :".$mat[num_cgc]."     Ins.Estadual:".$mat["ins_estadual"];
 $control=$mat["ctr_exp"];
 define('FPDF_FONTPATH','../fpdf151/font/');
 require('../fpdf151/fpdf_paisagem.php');
 require('../fpdf151/rotation.php');
 include('../../bibliotecas/cabecalho.inc');
 $selec_pedido="select a.cod_item,a.num_om,a.qtd_volume_item,
                       b.num_pedido,b.qtd_pecas_solic,c.den_item
                  from ordem_montag_item a,
                       ped_itens b,
                       item c
                 where a.cod_empresa='".$empresa."'
                  and  a.num_om='".$om."'
                  and  b.cod_empresa=a.cod_empresa
                  and  b.num_pedido=a.num_pedido
                  and  b.cod_item=a.cod_item
                  and  c.cod_empresa=b.cod_empresa
                  and  c.cod_item=b.cod_item
            order by  1,3 ,2,4    ";
 $res_pedido = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_pedido = $cquery($selec_pedido,$res_pedido);
 $mat_pedido=$cfetch_row($result_pedido);
 $esp=$mat_pedido["espessura"];
 $larg=$mat_pedido["largura"];
 $comp=$mat_pedido["comprimento"];
 $qtd_solic=$mat_pedido["qtd_pecas_solic"];
 $metros=$mat_pedido["metros"];
 $pedido=$mat_pedido["num_pedido"];
 $selec_cliente="select a.cod_empresa,a.cod_cliente,a.num_pedido_repres,a.num_pedido_cli,b.nom_cliente,b.end_cliente,
                       b.den_bairro,b.cod_cep,b.cod_cidade,c.den_cidade,c.cod_uni_feder,a.num_pedido
  
                   from pedidos a,
                        clientes b,
                        cidades c
                  where a.cod_empresa='".$empresa."'
                        and a.num_pedido='".$pedido."'
                        and b.cod_cliente=a.cod_cliente
                        and c.cod_cidade=b.cod_cidade
                     ";
 $res_cliente = $cconnect("logix",$ifx_user,$ifx_senha);
 $result_cliente = $cquery($selec_cliente,$res_cliente);
 $mat_cliente=$cfetch_row($result_cliente);
 $completo="S";
 $pdf=new PDF();
 $pdf->Open();
 $pdf->AliasNbPages();
 $pdf->AddPage(); 
 $pdf->SetFont('Arial','B',10);
 $pdf->SetFillColor(260);
 $pdf->setx(10);
 $xposr=$pdf->getx(); 
 $yposr=$pdf->gety();
 $pdf->SetFillColor(260);
 $pdf->RoundedRect(($xposr),($yposr-1), 190,10, 3.5, 'FD');
 $t_ped_cli='Pedido Cliente: '.trim($mat_cliente["num_pedido_cli"]);
 $pdf->Cell(190,4,'PROPOSTA DE FATURAMENTO: '.$om,0,0,'C');
 $pdf->ln();
 $pdf->Cell(190,4,$t_ped_cli."                                      Pedido Repres.:".$mat_cliente["num_pedido_repres"]."        Pedido Logix:".$pedido,0,0,'L');
 $pdf->ln();
 $pdf->ln();
 $pdf->SetFont('Arial','B',10);
 $pdf->SetFillColor(260);
 $pdf->setx(10);
 $xposr=$pdf->getx(); 
 $yposr=$pdf->gety();
 $pdf->SetFillColor(260);
 $pdf->RoundedRect(($xposr),($yposr-1), 190, 25, 3.5, 'FD');
 $pdf->Cell(190,4,'CLIENTE ',0,0,'C');
 $pdf->ln();
 $pdf->setx(11);
 $pdf->SetFillColor(260);
 $pdf->SetFont('Arial','',7);
 $pdf->Cell(94,4,' '.trim($mat_cliente["cod_cliente"]).' - '.trim($mat_cliente["nom_cliente"]),0,0,'L',1);
 $pdf->setx(105);
 $pdf->Cell(94,4,'Fone :'.trim($mat_cliente["num_telefone"]).'        Fax: '.trim($mat_cliente["num_fax"]),0,0,'L',1);
 $pdf->ln();
 $pdf->setx(11);
 $pdf->Cell(95,4,'CEP:'.trim($mat_cliente["cod_cep"]).' - '.trim($mat_cliente["den_cidade"]),0,0,'L',1);
 $pdf->setx(105);
 $pdf->Cell(94,4,'End.: '.trim($mat_cliente["end_cliente"]).'     Bairro: '.trim($mat_cliente["den_bairro"]),0,0,'L',1);
 $pdf->ln();
 $pdf->setx(11);
 $pdf->Cell(94,4,'C.G.C.:'.trim($mat_cliente["num_cgc_cpf"]),0,0,'L',1);
 $pdf->setx(105);
 $pdf->Cell(94,4,'Ins.Estadual:'.trim($mat_cliente["ins_estadual"]),0,0,'L',1);
 $pdf->ln();
 $pdf->ln();
 $pdf->Ln();
 $pdf->ln();
 $pdf->SetFillColor(220);
 $pdf->cell(15,5,'PEDIDO','LTBR',0,L,1);
 $pdf->cell(15,5,'CODIGO','LTBR',0,L,1);
 $pdf->cell(15,5,'QTDE','LTBR',0,L,1);
 $pdf->cell(5,5,'UN','LTBR',0,L,1);
 $pdf->cell(15,5,'QTDE M3','LTBR',0,L,1);
 $pdf->cell(120,5,'DESCRIÇÃO DO PRODUTO','LTBR',0,L,1);
 while (is_array($mat_pedido))
 {
  $metros=$mat_pedido["metros"];
  $totm3=$totm3+$metros;
  $totpc=$totpc+$mat_pedido["qtd_pecas_solic"];
  $pdf->SetFillColor(260);
  $pdf->Ln();
  $pdf->cell(15,5,$mat_pedido["num_pedido"],'LTBR',0,L,1);
  $pdf->cell(15,5,$mat_pedido["cod_item"],'LTBR',0,L,1);
  $pdf->cell(15,5,$mat_pedido["qtd_pecas_solic"],'LTBR',0,L,1);
  $pdf->cell(5,5,$mat_pedido["uni_med"],'LTBR',0,L,1);
  $pdf->cell(15,5,round($metros,3),'LTBR',0,L,1);
  $pdf->cell(120,5,$mat_pedido["den_item"],'LTBR',0,L,1);
  $mat_pedido=$cfetch_row($result_pedido);
 }
 $pdf->Ln();
 $pdf->SetFillColor(220);
 $pdf->cell(30,5,'Totais','LTBR',0,L,1);
 $pdf->cell(15,5,$totpc,'LTBR',0,L,1);
 $pdf->cell(5,5,"",'LTBR',0,L,1);
 $pdf->cell(15,5,round($totm3,3),'LTBR',0,L,1);
 $pdf->cell(120,5,'','LTBR',0,L,1);
 $pdf->Output('om001.pdf',true);
?>



