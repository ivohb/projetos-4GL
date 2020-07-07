<?
 class PDF extends PDF_Rotate
 {
  function Header()
  {
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
   $this->Ln();
   $this->SetFillColor(260);
   $this->SetFont('Arial','B',10);
   $this->Ln();
   $xpos=$this->getx();
   $ypos=$this->gety();
   $this->RoundedRect(($xpos),($ypos-1), 190, 6, 3.5, 'FD');
   $this->Cell(93,4,' '.trim($titulo),0,0,'L');
   $this->SetFont('Arial','B',10);
   $this->Cell(93,4,$data_emi,0,0,'R');
   $this->SetFont('Arial','B',8);
   $this->Ln();
   $this->Ln();
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
   $this->Cell(10,10,' Local:_____________________ Data:___/___/____  Assinatura:_____________________________',0,0,'L');
   $this->Cell(0,10,$data.'         Pagina: '.$this->PageNo().'/{nb}',0,0,'R');
  }
 }
?>