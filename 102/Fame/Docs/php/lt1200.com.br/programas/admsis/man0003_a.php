<?PHP
 $versao="1";
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
 function fechar()
 {
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                               
 printf("<script language='javascript' type='TEXT/JAVASCRIPT'>");
 printf("function validForm(passForm){
	if(passForm.titulo_.value==''){
	   alert('Voce deve digitar a Descrição')
	   passForm.titulo_.focus()
	   return false
        }
        return true }");
 printf("</script>");
 $prog="man0003";
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 $menu="select * from lt1200_programas
	    where class=$uid1
	     and codigo=$uid
	     and programa='".$uid2."' 
	      ";
 $res_menu=ifx_query($menu,$link);
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 printf("<title>$nome_</title>");
 printf("</head>");
 include("../../bibliotecas/style.inc");
 printf("<BODY BGCOLOR='WHITE'>");
 printf("<FORM onSubmit='return validForm(this)'
	ACTION='man0003_b.php' method=post>");

 $msg="Informe a descrição do Programa";
 printf("<tr>
      </tr>
     <tr>
      <td width='750'  style=$top_bot_style colspan='75'     align='center'>
      <i><font face='Arial, Helvetica, sans-serif' size='6' color=$c_color>
      $msg</font></i>");

 $mat_menu=ifx_fetch_row($res_menu);
 $cab_menu=$mat_menu["codigo"];
 $class_menu=$mat_menu["class"];   
 $prog_=$mat_menu["programa"];
 $nome_prog=$mat_menu["nome"];  
 printf("</tr>
      <tr>
      <td width='100'  style=$n_style colspan='10'     align='left'
      <i><input type='text' size='10'value='$prog_' name='prog_' 
      <font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      </font></i>
      </td>

      <td width='450'  style=$n_style colspan='45'     align='left'
      <i><input type='text' size='60'value='$nome_prog' name='nomep_' 
      <font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      </font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='left'
      <i><input type='text' size='6'value='$uid' name='cod_menu_' readonly 
      <font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      </font></i>
      </td>
      <td width='50'  style=$n_style colspan='5'     align='left'
      <i><input type='text' size='6'value='$uid1' name='cod_class_' readonly 
      <font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      </font></i>
      </td>
      </tr>
      <tr>");
 printf("<td width='450'  style=$n_style colspan='45'     align='left'>
      <P><input type='submit' value='Confirma'>&nbsp;&nbsp;&nbsp;&nbsp
      </td>
      </tr>");
 printf("</FORM>");
 printf("</BODY>");
 printf("</html>");
?>
