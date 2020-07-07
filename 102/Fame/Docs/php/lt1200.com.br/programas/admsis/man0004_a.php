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
 $prog="man0004";
 $ifx_user=trim($ifx_user);
 $link=ifx_connect("lt1200",$ifx_user,$ifx_senha);
 $uid=trim($uid);
 $menu="select a.cod_usuario,a.cod_empresa_padrao,a.nom_funcionario,
	        b.fone,b.fax,b.celular,b.email,              
                b.erep,b.cod_rep,b.ctr_exp
            from logix:usuarios a,
                outer lt1200_usuarios b
	    where a.cod_usuario='".$uid."'
	     and b.cod_usuario=a.cod_usuario
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
	ACTION='man0004_b.php' method=post>");

 $mat_menu=ifx_fetch_row($res_menu);
 $nome_func=$mat_menu["nom_funcionario"];
 $emp_func=$mat_menu["cod_empresa_padrao"];
 $fone_func=$mat_menu["fone"];
 $fax_func=$mat_menu["fax"];
 $e_mail_func=$mat_menu["email"];
 $erep_func=$mat_menu["erep"];
 $codrep_func=$mat_menu["cod_rep"];
 $usuario_=$mat_menu["cod_usuario"];
 $erep_=$mat_menu["erep"];
 $cod_rep_=$mat_menu["cod_rep"];
 $celular=$mat_menu["celular"];
 $ctr_exp1=$mat_menu["ctr_exp"];
 printf("<tr>
      <td width='750'  style=$all_style colspan='75'     align='center'>
      <i><font face='Arial, Helvetica, sans-serif' size='6' color=$c_color>
      Dados do Usuario</font></i>");
 printf("</td>
      </tr>
      <tr>
      <b><td width='150'  style=$n_style colspan='15'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      Nome Completo:</font></i></b>
      </td>
      <b><td width='600'  style=$n_style colspan='60'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      $nome_func</font></i></b>
      </td>
      </tr>
      <tr>
      <b><td width='100'  style=$n_style colspan='10'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      Empresa Padrão:</font></i></b>
      </td>
      <b><td width='650'  style=$n_style colspan='65'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      $emp_func</font></i></b>
      </td>
      </tr>
      <tr>
      <b><td width='100'  style=$n_style colspan='10'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      Telefone:</font></i></b>
      </td>
      <td width='650'  style=$top_style colspan='65' align='left'
      <input type='text' size='30' value='$fone_func' name='fone_func' 
      </td>
      </tr>
      <tr>
      <b><td width='100'  style=$n_style colspan='10'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      Fax:</font></i></b>
      </td> 
      <td width='650'  style=$top_style colspan='65' align='left'
      <i><input type='text' size='30' value='$fax_func' name='fax_func' 
      </td>
      </tr>
      <tr>
      <b><td width='100'  style=$n_style colspan='10'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      Controle EXP:</font></i></b>
      </td> 
      <td width='650'  style=$top_style colspan='65' align='left'
      <i><input type='text' size='4' value='$ctr_exp1' name='ctr_exp1' 
      </td>
      </tr>
      <tr>
      <b><td width='100'  style=$n_style colspan='10'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      Celular:</font></i></b>
       </td> 
     <td width='650'  style=$top_style colspan='65' align='left'
      <i><input type='text' size='30' value='$celular' name='celular' 
      </td>
      </tr>
      <tr>
      <b><td width='100'  style=$n_style colspan='10'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
      E_Mail:</font></i></b>
      </td>
      <td width='650'  style=$top_style colspan='65' align='left'
      <i><input type='text' size='30' value='$e_mail_func' name='e_mail_func' 
      </td>
      </tr>
      <tr>
      <b><td width='100'  style=$top_style colspan='10'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      Usuario:</font></i></b>
      <td width='100'  style=$top_style colspan='10' align='left'
      <i><input type='text' size='10'value='$usuario_' name='usuario_' 
      <font face='Arial, Helvetica, sans-serif' size='2' color='red'>
      </font></i>
      </td>
      <b><td width='250'  style=$top_style colspan='25'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      Representante(S)Coordenador(C) outros(N):</font></i></b>
      <td width='10'  style=$top_style colspan='1' align='left'
      <i><input type='text' size='10'value='$erep_' name='erep_' 
      <font face='Arial, Helvetica, sans-serif' size='2' color='red'>
      </font></i>
      </td>
      <b><td width='150'  style=$top_style colspan='15'     align='left'>
      <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
      Codigo do Representante:</font></i></b>
      <td width='550'  style=$top_style colspan='55' align='left'
      <i><input type='text' size='10'value='$cod_rep_' name='cod_rep_' 
      <font face='Arial, Helvetica, sans-serif' size='2' color='red'>
      </font></i>
      </td>
      </tr>");
 printf("<td width='450'  style=$n_style colspan='45'     align='left'>
      <P><input type='submit' value='Confirma'>&nbsp;&nbsp;&nbsp;&nbsp
      </td>
      </tr>");
 printf("</FORM>");
 printf("</BODY>");
 printf("</html>");
?>
