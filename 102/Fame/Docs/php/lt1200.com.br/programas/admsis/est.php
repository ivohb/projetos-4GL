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
  print "\nIniciando transferência para o banco de dados.";
  print "\nDependendo do tamanho do mesmo e da velocidade
  de sua máquina isso pode demorar alguns minutos.\n\n";
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
   print "\nErro:\nQuantidade de campos no arquivo não corresponde a
   quantidade de campos no banco de dados, ou a tabela no banco de dados não existe.\n";
   exit;
  }
  //Se tabela existir remove o conteúdo caso selecionar opcao s
  if($argv[3]=="S" or $argv[3]=="s")
  {
   $query="delete from ".$argv[2]."
             where cod_empresa <> '' ";
  
   $res = ifx_connect("lt1200",'admlog','admlog');
   $result = ifx_query($query,$res);
  }
  $ac = count($arquivo);
  unset($sql);
  for($x=0;$x<$ac;$x++)
  {
   $valor_campo = explode("$delimita",$arquivo[$x]);
   $valor_campo[0] = str_replace("\"","",$valor_campo[0]);
   $valor_campo[0] = str_replace('\'','',$valor_campo[0]);

   $sql = 'insert into lt1200_imp_fame (cod_empresa,num_lote,cod_sistema,dat_refer,num_conta,ies_tipo_lanc,dat_movto,val_lanc,cod_rateio,cod_hist,tex_compl,ies_sit_lanc,cod_lin_prod,cod_lin_recei,cod_seg_merc,cod_cla_uso,vaz1,vaz2) values('.'"'.$valor_campo[0] ;
   for($y=1;$y<$qtdecampos;$y++)
   {

    $valor_campo[$y] = str_replace("\"'","",$valor_campo[$y]);
    $valor_campo[$y] = str_replace(",",".",$valor_campo[$y]);
    $valor_campo[$y] = str_replace(" ","",$valor_campo[$y]);
    $sql=$sql.'","'.$valor_campo[$y];
   }
   $sql=rtrim($sql).'")';
   $res = ifx_connect("lt1200",'admlog','admlog');
   $result=ifx_query($sql,$res); 
   printf($sql);   
  }

  print "Dados inseridos com êxito\n\n";
 } else {
  print "\nO arquivo $argv[1] não existe\n";
  exit;    
 }
?> 