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