<?
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
    if($frete==1)
   {
   $textof=("CIF PAGO");
   $moeda=("  " );
  }
  if($frete==2)
  {
   $textof=("CIF COBRADO");
   $moeda=("R$" );
  }
  if($frete==3)
  {
   $textof=("FOB");
   $moeda=("  " );
  }
  if($frete==4)
  {
   $textof=("CIF INF PCT");
   $pe=("%");
   $moeda=("  " );
  }
  if($frete==5)
  {
   $textof=("CIF INF UNIT");
  }
  if($frete==6)
  {
   $textof=("ITEM TOT");
  }
?>