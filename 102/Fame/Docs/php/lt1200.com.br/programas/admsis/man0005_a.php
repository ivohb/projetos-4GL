<?PHP
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $hora=date("h");
 $min=date("i");
 $data=sprintf("%02d/%02d/%04d-%02d:%02d",$dia,$mes,$ano,$hora,$min);
 $ip=$HTTP_X_FORWARDED_FOR;
 $ip_ext=$REMOTE_ADDR;
 $teste=session_register("id");
 session_register("ifx_user");
 session_register("ifx_senha");
 if(!$teste)
 {
  $msg = "Não foi possível registrar essa sessão. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
 $uid3=trim($ctr_usu);
 printf("<script language='javascript' type='TEXT/JAVASCRIPT'>");
 printf("function validForm(passForm){
	if(passForm.usud_.value==''){
	   alert('Voce deve digitar o Usuario')
	   passForm.usud_.focus()
	   return false
        }
        return true }");
 printf("</script>");
 /*Programa*/
 printf("<script language='javascript'>
  function chamada_pi(n,b,c,d)
  {
   url='man0005_b.php?uid='+n+'&uid1='+b+'&uid2='+c+'&uid3='+d;
   window.close();
   window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
  }
  </script>");
 printf("<script language='javascript'>
  function chamada_pe(n,b,c,d)
  {
   url='man0005_d.php?uid='+n+'&uid1='+b+'&uid2='+c+'&uid3='+d;
   window.close();
   window.open(url,n);
  }
  </script>");
 /*Sub_menu*/
 printf("<script language='javascript'>
  function chamada_s(n,b,d)
  {
   url='man0005_as.php?uid='+n+'&uid1='+b+'&uid3='+d;
   window.close();
   window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
  }
  </script>");
 printf("<script language='javascript'>
  function chamada_ds(n,b,d)
  {
   url='man0005_asd.php?uid='+n+'&uid1='+b+'&uid3='+d;
   window.close();
   window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
  }
  </script>");
 /*Menu*/
 printf("<script language='javascript'>
 function chamada_m(n,d)
 {
  url='man0005_am.php?uid='+n+'&uid3='+d;
  window.close();
  window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
 }
 </script>");
 printf("<script language='javascript'>
 function chamada_dm(n,b,d)
 {
  url='man0005_amd.php?uid='+n+'&uid3='+d;
  window.close();
  window.open(url,n,'resizable=yes,scrollbars=yes,menubar=yes');
 }
 </script>");
 function fechar()
 {
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                               
 $prog="man0005";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 $menu="select * from lt1200_menu
	    where cod_class=0
	   order by cod_menu,cod_class";
 $res_menu=ifx_query($menu,$link);
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 include("../../bibliotecas/style.inc");
 printf("<tr>
      </tr>
     <tr>
      <td width='750'  style=$top_bot_style colspan='75'     align='center'>
      <i><font face='Arial, Helvetica, sans-serif' size='6' color=$c_color>
      Acesso aos Programas para $uid3</font></i>");
 printf("<BODY BGCOLOR='WHITE'>");
 printf("<FORM onSubmit='return validForm(this)'
	ACTION='man0005_c.php' method=post>"); 
 printf("<tr>
      </tr>
     <tr>
      <td width='150'  style=$top_bot_style colspan='15'     align='center'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      Copia tudo para usuário:</font></i>
 
     <td width='50'  style=$top_bot_style colspan='5'     align='left'
      <i><input type='text' size='15'  name='usud_'  
      <font face='Arial, Helvetica, sans-serif' size='2' color='red'>
      </font></i>
      </td>
      <td width='150'  style=$top_bot_style colspan='15'     align='center'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      Do usuário:</font></i>
 
     <td width='50'  style=$top_bot_style colspan='5'     align='left'
      <i><input type='text' size='15'  name='usu_' value=$uid3  readonly
      <font face='Arial, Helvetica, sans-serif' size='2' color='red'>
      </font></i>
      </td>");
 printf("<td width='450'  style=$top_bot_style colspan='45'     align='left'>
      <P><input type='submit' value='Confirma Copia'>&nbsp;&nbsp;&nbsp;&nbsp
      </td>
      </tr>");
 printf("</FORM>");
 printf("</BODY>");
 $mat_menu=ifx_fetch_row($res_menu);
 while(is_array($mat_menu))
 {
  $new_clas=0;
  $cab_menu=$mat_menu["cod_menu"];
  $tit_menu=$mat_menu["titulo"];
  $uid=$cab_menu;
  $linha= "<a href='javascript:chamada_m(\"".$uid."\",\"".$uid3."\");'>".$tit_menu."</a><br>";
  $linha_d= "<a href='javascript:chamada_dm(\"".$uid."\",\"".$uid3."\");'>Excluir</a><br>";
  printf("</tr>
      <tr>
      <td width='550'  style=$bot_style colspan='55'     align='left'>
      <b><i><font face='Arial, Helvetica, sans-serif' size='4' color=$c_color>
      $tit_menu</font></i></b>
      </td>
      </tr>");
 
  $clas_c="select max(cod_class) as ult_clas from lt1200_menu
 	    where cod_menu=$cab_menu
		and cod_class <> 0
 	   ";
  $res_clas_c=ifx_query($clas_c,$link);
  $mat_clas=ifx_fetch_row($res_clas_c);
  $new_clas=$mat_clas["ult_clas"]+1;
  $clas="select * from lt1200_menu
 	    where cod_menu=$cab_menu
		and cod_class <> 0
		order by cod_class
	   ";
  $res_clas=ifx_query($clas,$link);
  $mat_clas=ifx_fetch_row($res_clas);
  while(is_array($mat_clas))
  {
   $cab_clas=$mat_clas["cod_class"];
   $tit_clas=$mat_clas["titulo"];
   $class_menu=$mat_menu["cod_class"];   
   $uid1=$cab_clas; 
   $linha= "<a href='javascript:chamada_s(\"".$uid."\",\"".$uid1."\",\"".$uid3."\");'>".$tit_clas."</a><br>";
   $linha_d= "<a href='javascript:chamada_ds(\"".$uid."\",\"".$uid1."\",\"".$uid3."\");'>Excluir</a><br>";
   printf("</tr>
      <tr>
      <td width='50'  style=$n_style colspan='5'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      &nbsp</font></i>
      </td>
      <td width='550'  style=$bot_style colspan='55'     align='left'>
      <b><i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      $tit_clas</font></i></b>
      </td>
      </td>
      </tr>");
   $acessa="";
   $uid=trim($uid);      	
   $prog="select a.class,a.programa,a.codigo,a.nome,
                    b.programa as sit_prog
            from lt1200_programas a,
		outer lt1200_ctr_usuario b
 	    where a.codigo=$cab_menu
		and a.class=$cab_clas
                and b.programa=a.programa
		and b.usuario='".$uid3."'	    
	order  by a.programa
 	   ";
      
   $res_prog=ifx_query($prog,$link);
   $mat_prog=ifx_fetch_row($res_prog);
   while(is_array($mat_prog))
   {
    $class_menu=$mat_menu["cod_class"];   
    $nome_prog=trim($mat_prog["programa"]).'-'.trim($mat_prog["nome"]);
    $acessa=trim($mat_prog["sit_prog"]);
    $uid1=$cab_clas; 
    $uid2=trim($mat_prog["programa"]);
    if($acessa=="")
    {
     $bgcolor='#ffcc99';
     $linha_d= "<a href='javascript:chamada_pi(\"".$uid."\",\"".$uid1."\",\"".$uid2."\",\"".$uid3."\");'>Incluir</a><br>";
    }else{
     $bgcolor='#b3b3b3';
     $linha_d= "<a href='javascript:chamada_pe(\"".$uid."\",\"".$uid1."\",\"".$uid2."\",\"".$uid3."\");'>Excluir</a><br>";
    }
    printf("</tr>
        <tr>
        <td width='50'  style=$n_style colspan='5'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        &nbsp</font></i>
        </td>
        <td width='50'  style=$n_style colspan='5'     align='left'>
        <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        &nbsp</font></i>
        </td>
        <td width='550'  style=$n_style colspan='55' bgcolor=$bgcolor    align='left'>
        <b><i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
        $nome_prog</font></i></b>
        </td>");
    printf("<td width='50'  style=$n_style bgcolor=$bgcolor colspan='5'     align='center'>
        <i><font face='Arial, Helvetica, sans-serif' size='2'  color=$c_color>
        $linha_d</font></i>
        </td>");
    printf("</tr>
        <tr>");
    $mat_prog=ifx_fetch_row($res_prog);
   }
   $uid2="";
   $mat_clas=ifx_fetch_row($res_clas);
  }
  $mat_menu=ifx_fetch_row($res_menu);
 }
 printf("</html>");
?>
