<?
 class PDF extends PDF_Rotate
 {
  function Header()
  {
   global $datae;
   global $prog;
   global $tipo_ped;
   global $cab;
   global $titulo;
   global $titulo_rel;
   global $titulo_sup;
   global $data_emi;
   global $data;
   global $datal;
   global $cab1;
   global $cab2;
   global $cab3;
   global $cab4;
   global $cab5;
   global $cab6;
   global $win;
   $this->SetFillColor(260);
   $this->RoundedRect(10, 8, 195, 23, 3.5, 'FD');
   $this->Image('../../imagens/fame.jpg',12,10,116,15);
   $this->Cell(80);
   $this->SetFont('Arial','B',10);
   $this->Cell(150,4,$cab1,0,0,'C');
   $this->Ln();
   $this->Cell(80);
   $this->SetFont('Arial','B',7);
   $this->Cell(150,3,$cab2,0,0,'C');
   $this->Ln();
   $this->Cell(80);
   $this->Cell(150,3,$cab3,0,0,'C');
   $this->Ln();
   $this->Cell(80);
   $this->Cell(150,3,$cab4,0,0,'C');
   $this->Ln();
   $this->Cell(80);
   $this->Cell(150,3,$cab5,0,0,'C');
   $this->Ln();
   $this->Cell(80);
   $this->SetFont('Arial','B',10);
   $this->Cell(150,4,$cab6,0,0,'L');
   $this->Ln();
   $this->SetFillColor(260);
   $this->SetFont('Arial','B',10);
   $this->Ln();
   $xpos=$this->getx();
   $ypos=$this->gety();
   $this->RoundedRect(($xpos),($ypos-1), 195, 6, 3.5, 'FD');
   $this->Settextcolor('250','0','0');
   $this->SetFont('Arial','B',12);
   $this->Cell(150,4,' '.trim($titulo),0,0,'L');
   $this->Settextcolor('0','0','0');
   $this->SetFont('Arial','B',10);
   $this->Cell(45,4,$datae,0,0,'R');
   $this->SetFont('Arial','B',8);
   $this->Ln();
   $this->Ln();
   if($prog=="sup/sup0002")
   {
    $this->setx(10);
    $this->cell(15,5,"LOCAL",'LRTB',0,'C');
    $this->cell(15,5,"CODIGO",'LRTB');
    $this->cell(115,5,"DESCRI��O",'LRTB');
    $this->cell(20,5,"LOTE",'LRTB');
    $this->cell(10,5,"UN",'LRTB',0,'C');
    $this->cell(20,5,"SALDO",'LRTB',0,'R');
    $this->Ln();
   }

   if($prog=="vdp/vdp0014")
   {
    $this->SetFont('Arial','B',10);
    $this->ln();
    $this->cell(70,6,'CIDADE','LRTB',0,'L');
    $this->cell(20,6,'UF','LRTB',0,'L');
    $this->cell(40,6,'VALOR','LRTB',0,'R');
    $this->Ln();
    $this->SetFont('Arial','B',8);
   }

   if($prog=="fame/fam0010")
   {
    $this->cell(100,5,"Descri��o",0,0,'C');
    $this->cell(20,5,"QTD",0,0,'C');
    $this->cell(20,5,"Pre Unit",0,0,'C');
    $this->cell(25,5,"Valor",0,0,'C');
    $this->cell(5,5,"",0,0,'L');
    $this->cell(25,5,"Valor Desc".$per,0,1,'C');
   }
   if($prog=="fame/fam0016")
   {
     $this->setx(50);
     $this->SetFillColor(260);
     $this->Cell(20,6,'Numero',TBLR,0,'R',1);
     $this->Cell(20,6,'Mes',TBLR,0,'R',1);
     $this->Cell(20,6,'Emissao',TBLR,0,'R',1);
     $this->Cell(20,6,'Atendidos',TBLR,0,'R',1);
     $this->Cell(20,6,'Saldo',TBLR,0,'R',1);
     $this->Cell(15,6,'Local',TBLR,0,'R',1);
     $this->Cell(15,6,'Repres',TBLR,0,'R',1);
    $this->Ln();
   }

   if($prog=="fame/fam0012")
   {
    $this->cell(20,5,"Quant",0,0,'C');
    $this->cell(20,5,"C�digo",0,0,'C');
    $this->cell(20,5,"Volt",0,0,'C');
    $this->cell(25,5,"Valor",0,0,'C');
    $this->cell(100,5,"Descri��o".$per,0,1,'C');
   }

   if($prog=="fame/fam0011")
   {
    $this->setfont('Arial','B',9);
    $this->cell(10,5,'',0,0,'C');
    $this->cell(15,5,"NFF",LRTB,0,'C');
    $this->cell(15,5,"DATA",LRTB,0,'C');
    $this->cell(20,5,"VALOR",LRTB,0,'C');
    $this->cell(10,5,'',0,0,'C');
    $this->cell(15,5,"NFF",LRTB,0,'C');
    $this->cell(15,5,"DATA",LRTB,0,'C');
    $this->cell(20,5,"VALOR",LRTB,0,'C');
    $this->cell(10,5,'',0,0,'C');
    $this->cell(15,5,"NFF",LRTB,0,'C');
    $this->cell(15,5,"DATA",LRTB,0,'C');
    $this->cell(20,5,"VALOR",LRTB,0,'C');
    $this->ln();
   }
   if($prog=="fame/fam0015")
   {
    $this->setx(10);
    $this->SetFillColor(260);
    $this->Cell(20,5,"Cod Repres",TRBL,0,'C',1);
    $this->Cell(30,5,"Data Entrada",TRBL,0,'C',1);
    $this->Cell(25,5,"Numero Pedido",LTRB,0,'C',1);
    $this->Cell(25,5,"Numero Logix",TRLB,0,'C',1);
    $this->Cell(25,5,"Total Liquido",LTRB,0,'C',1);
    $this->Cell(25,5,"Situa��o",LTRB,0,'C',1);
    $this->ln();
   }
   if($prog=="vdp/vdp0005")
   {
    $this->cell(10,5,'TP','LRTB',0,'L');
    $this->cell(20,5,'NUM.NFF','LRTB',0,'L');
    $this->cell(20,5,'NUM.PED.','LRTB',0,'L');
    $this->cell(20,5,'N.PED.REP','LRTB',0,'L');
    $this->cell(20,5,'DAT.EMIS','LRTB',0,'L');
    $this->cell(20,5,'D.EMIS.REP','LRTB',0,'L');
    $this->cell(25,5,'NUM.DP','LRTB',0,'L');
    $this->cell(70,5,'CLIENTE','LRTB',0,'L');
    $this->cell(20,5,'DATA DOCTO','LRTB',0,'R');
    $this->cell(25,5,'VALOR FAT','LRTB',0,'R');
    $this->cell(25,5,'VALOR PAGO','LRTB',0,'R');
    $this->Ln();
   }

   if($prog=="vdp/vdp0011")
   {
    $this->cell(95,5,$titulo_rel,'LRTB',0,'C');
    $this->cell(5,5,'',0,0,'C');
    $this->cell(95,5,$titulo_sup,'LRTB',0,'C');
    $this->Ln();
    $this->setx(10);
    $this->cell(50,5,'NOTA FISCAL','LTB',0,'C');
    $this->cell(85,5,'NOME','LTRB',0,'C');
    $this->cell(20,5,'PEDIDO','LTRB',0,'C');
    $this->cell(20,5,'PEDIDO','LTRB',0,'C');
    $this->cell(20,5,'DATA','LTRB',0,'C');
    $this->Ln();
    $this->setx(10);
    $this->cell(15,5,'NUMERO','LB',0,'C');
    $this->cell(15,5,'DATA','LB',0,'C');
    $this->cell(20,5,'VL.MERC.','LRB',0,'R');
    $this->cell(85,5,'CLIENTE','LRB',0,'C');
    $this->cell(20,5,'LOGIX','LRB',0,'C');
    $this->cell(20,5,'PALM','LRB',0,'C');
    $this->cell(20,5,'ENTRADA','LRB',0,'R');
    $this->Ln();
   }

   if($prog=="vdp/vdp0013")
   {
    $this->Ln();
    $this->setx(10);
    $this->cell(176,5,'NOTA FISCAL','LTB',0,'C');
    $this->cell(54,5,'NOME','LTRB',0,'C');
    $this->cell(15,5,'PEDIDO','LTRB',0,'C');
    $this->cell(15,5,'PEDIDO','LTRB',0,'C');
    $this->cell(15,5,'DATA','LTRB',0,'C');
    $this->Ln();
    $this->setx(10);
    $this->cell(15,5,'NUMERO','LB',0,'C');
    $this->cell(15,5,'DATA','LB',0,'C');
    $this->cell(28,5,'C.F.O.P','LB',0,'C');
    $this->cell(18,5,'MERC.','LRB',0,'R');
    $this->cell(16,5,'ICM.','LRB',0,'R');
    $this->cell(16,5,'SUB.TRI.','LRB',0,'R');
    $this->cell(16,5,'IPI','LRB',0,'R');
    $this->cell(16,5,'DESC.(-)','LRB',0,'R');
    $this->cell(16,5,'ACRES.(+)','LRB',0,'R');
    $this->cell(20,5,'TOT.NFF','LRB',0,'R');
    $this->cell(54,5,'CLIENTE','LRB',0,'C');
    $this->cell(15,5,'LOGIX','LRB',0,'C');
    $this->cell(15,5,'PALM','LRB',0,'C');
    $this->cell(15,5,'ENTRADA','LRB',0,'R');
    $this->Ln();
   }

   if($prog=="vdp/vdp0010")
   {
    $this->cell(100,5,'REPRESENTANTE','LRTB',0,'L');
    $this->cell(25,5,'MAT/EMP','LRTB',0,'L');
    $this->cell(35,5,'TOTAL NFF.','LRTB',0,'L');
    $this->cell(35,5,'TOTAL DP PAGA','LRTB',0,'L');
    $this->cell(30,5,'VALOR COMISSAO','LRTB',0,'L');
    $this->cell(30,5,'B�NUS','LRTB',0,'L');
    $this->cell(20,5,'PCT ALC','LRTB',0,'L');
    $this->Ln();
   }
   if($prog=="sup/sup0003")
   {
    $this->setx(10);
    $this->cell(140,5,"Fornecedor",'LRTB',0,'L');
    $this->Ln();
    $this->setx(15);
    $this->cell(15,5,"N./Ser�e",'LRTB',0,'C');
    $this->cell(20,5,"VL Nota",'LRTB',0,'L');
    $this->cell(10,5,"Seq",'LRTB',0,'L');
    $this->cell(15,5,"C�digo",'LRTB',0,'L');
    $this->cell(80,5,"CFOP - Descri��o",'LRTB',0,'L');
    $this->cell(10,5,"UN",'LRTB',0,'L');
    $this->cell(20,5,"Qtd",'LRTB',0,'L');
    $this->cell(20,5,"VL Cont",'LRTB',0,'L');
    $this->Ln();
   }
   
   if($prog=="vdp/vdp0018")
   {
    $this->cell(75,5,'REPRESENTANTE','LRTB',0,'L');
    $this->cell(20,5,'COMISS�O','LRTB',0,'L');
    $this->cell(20,5,'CRED N TRIB','LRTB',0,'L');
    $this->cell(20,5,'BONIF.','LRTB',0,'L');
    $this->cell(20,5,'INDEN.1/12','LRTB',0,'L');
    $this->cell(20,5,'IRRF','LRTB',0,'L');
    $this->cell(20,5,'D�B N TRIB','LRTB',0,'L');
    $this->cell(20,5,'ADIANT.','LRTB',0,'L');
    $this->cell(20,5,'EST. INDEN.','LRTB',0,'L');
    $this->cell(20,5,'INSS','LRTB',0,'L');
    $this->cell(20,5,'L�QUIDO','LRTB',0,'L');    
    $this->Ln();
   }
   
   if($prog=="vdp/vdp0015")
   {
    $this->cell(15,6,'MES/ANO','LRTB',0,'L');
    $this->cell(20,6,'COTA','LTRB',0,'R');
    $this->cell(20,6,'FATUR.','LRTB',0,'R');
    $this->cell(20,6,'BRUTO','LRTB',0,'R');
    $this->cell(20,6,'LIQUIDO','LRTB',0,'R');
    $this->cell(10,6,'%Cob','LRTB',0,'R'); 
    $this->cell(20,6,'FIXO','LRTB',0,'R');
    $this->cell(10,6,'%','LRTB',0,'R');
    $this->cell(20,6,'COMISS.','LRTB',0,'R');
    $this->cell(10,6,'%','LRTB',0,'R');
    $this->cell(15,6,'D.S.R','LRTB',0,'R');
    $this->cell(10,6,'%','LRTB',0,'R');
    $this->cell(20,6,'ENCARGOS','LRTB',0,'R');
    $this->cell(10,6,'%','LRTB',0,'R');
    $this->cell(15,6,'DESP.','LRTB',0,'R');
    $this->cell(10,6,'%','LRTB',0,'R');
    $this->cell(20,6,'TOTAL','LRTB',0,'C');
    $this->cell(15,6,'CUSTO','LRTB',0,'C');
    $this->ln();
   }
  }
  //Page footer
  function Footer()
  {
   global $data;
   //Position at 1.5 cm from bottom
   $this->SetY(-15);
   //Arial italic 8
   $this->SetFont('Arial','I',8);
   //Page number
   $xposr=$this->getx();
   $yposr=$this->gety();
   $this->SetFillColor(260);
   $this->RoundedRect(($xposr),($yposr+2), 190, 6, 3.5, 'FD');
   $this->Cell(10,10,' Departamento:____________________________ Assinatura do Resp. pela Aprova��o:______________________',0,0,'L');
   $this->Cell(0,10,$data.'         Pagina: '.$this->PageNo().'/{nb}',0,0,'R');
  }
 }
?>