<?php
 copy($import1,"tmp/".$destino);
 unlink($import1);
 printf("<html>
  <head>
  <title>Importar Arquivos</title>
  </head>
  <body>
  <center>
  <h1>Arquivos Importados Perfeitamente</h1>
 ");

 //#!/usr/bin/php -q
 # gvim :set tab stop=2
 # /*** Informacoes do cvs ***
 # $Author: ricardo $
 # $Revision: 1.5 $
 # $Date: 2004/07/08 02:43:45 $
 # $Id: export.php,v 1.5 2004/07/08 02:43:45 ricardo Exp $
 # $Log: export.php,v $
 # Revision 1.5  2004/07/08 02:43:45  ricardo
 # - controle de file exist
 #
 # Revision 1.4  2004/07/08 02:42:15  ricardo
 # - uso de CVS
 #
 $ifx_dados['usuario'] = "admlog";
 $ifx_dados['senha']   = "admlog";
 $ifx_dados['host']    = "lt1200";
 $ifx_dados['banco']   = "lt1200";
 $argv[0];
 $argv[1]='tmp/lt1200_imp_fame.txt';
 $argv[2]='lt1200_imp_fame';
 $argv[3]='S';
 
 //DELIMITADORES
 $delimita = "|";
 if(!$argv[3])
 {
  print "\nUso: $argv[0] arquivo tabela remove[s/n]
  \n(EX: $argv[0] tabela.txt tabela s (limpa a tabela clientes se existir))\n";
  exit;
 }
 if(file_exists($argv[1])) 
 {
  print "\nIniciando transfer�ncia para o banco de dados.";
  print "\nDependendo do tamanho do mesmo e da velocidade
  de sua m�quina isso pode demorar alguns minutos.\n\n";
  //Conectando
  $conecta_ifx = ifx_connect("$ifx_dados[host]","$ifx_dados[usuario]","$ifx_dados[senha]") or die ("Erro 1 - IFX");
  $arquivo= file("$argv[1]");
  $qtdecampos = explode("$delimita",$arquivo[0]);
  $qtdecampos = count($qtdecampos);
  // Verificando se a quantidade de campos concide com o banco
  $query=" select count(a.tabname) as mqc
                from  systables a, syscolumns b
               where b.tabid=a.tabid
                     and a.tabname='".$argv[2]."'";
  
  $res = ifx_connect("lt1200",'admlog','admlog');
  $result = ifx_query($query,$res);
  $mat=ifx_fetch_row($result);
  $mqc=$mat["mqc"];
  if($mqc != $qtdecampos)
  {
   print "\nErro:\nQuantidade de campos no arquivo n�o corresponde a
   quantidade de campos no banco de dados, ou a tabela no banco de dados n�o existe.\n";
   exit;
  }
  //Se tabela existir remove o conte�do caso selecionar opcao s
  if($argv[3]=="S" or $argv[3]=="s")
  {
   $remove_sql="DELETE FROM $argv[2]";
   ifx_query($remove_sql);
  }
  $ac = count($arquivo);
  unset($sql);
  for($x=0;$x<$ac;$x++)
  {
   $valor_campo = explode("$delimita",$arquivo[$x]);
   $valor_campo[0] = str_replace("\"","",$valor_campo[0]);
   $valor_campo[0] = str_replace('\'','',$valor_campo[0]);
   $sql = "INSERT INTO $argv[2] VALUES('$valor_campo[0]'";
   for($y=1;$y<$qtdecampos;$y++)
   {
    $valor_campo[$y] = str_replace("\"","",$valor_campo[$y]);
    $valor_campo[$y] = str_replace('\'','',$valor_campo[$y]);
    $sql .= ",'$valor_campo[$y]'";
   }
   $sql .= ");";
   ifx_query($sql) or die("Erro 3-Mysql");
  }
  printf("$sql");
  ifx_close($conecta_ifx);
  print "Dados inseridos com �xito\n\n";
 } else {
  print "\nO arquivo $argv[1] n�o existe\n";
  exit;    
 }
?> 