<?php
 $link=$cconnect("lt1200",$ifx_user,$ifx_senha);
 $sel_progs="select b.nome,c.erep,c.cod_rep
              from lt1200_ctr_usuario a,
                   lt1200_programas b,
                   lt1200_usuarios c

             where a.usuario='".$ifx_user."' 
	           and b.programa=a.programa
		   and a.programa='".$prog."'		
                   and c.cod_usuario=a.usuario ";
 $res_sel =$cquery($sel_progs,$link);
 $mat_prog=$cfetch_row($res_sel);
 $nome_=chop($mat_prog["nome"]);
 $erep=chop($mat_prog["erep"]);
 $cod_rep=round($mat_prog["cod_rep"]);
 $nome=$sel_progs;

 if($nome_==""){
  fechar();
  header("location:../../index.php"); 
 }
?>