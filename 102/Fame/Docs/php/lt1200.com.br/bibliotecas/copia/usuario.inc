<?php
 $link=$cconnect("lt1200",$ifx_user,$ifx_senha);
 $sel_progs="select b.nome
              from lt1200_ctr_usuario a,
                   lt1200_programas b
             where a.usuario='".$ifx_user."' 
	           and b.programa=a.programa
		   and a.programa='".$prog."'		";
 $res_sel =$cquery($sel_progs,$link);
 $mat_prog=$cfetch_row($res_sel);
 $nome_=chop($mat_prog["nome"]);
 $nome=$sel_progs;
 if($nome_==""){
  fechar();
  header("location:../../index.php"); 
 }
?>