<?php
session_register("id");
$versao="1";
if($id)
session_destroy();

if($prog_c="L")
{
 session_unregister("ifx_user");
 session_unregister("ifx_senha");
 $ifx_user='';
}
printf("<html>");
printf("<head>");
printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
printf("<title>LOGIN WEB LT1200</title>");
printf("</head>");
$nome_="IDENTIFICAÇÃO NO SISTEMA LT1200";

printf("<table border=0 width=750>
<td width=375 rowspan='5'><img src='../imagens/logocpd3.jpg'></td>
<td width=375><font face='Book Antiqua' size='3' color='#0033CC'><span style='letter-spacing: 1pt'> $nome_ </font></td>
</tr>
<tr>
<td width=375 align='right'><font face='Book Antiqua' size='3' color='#0033CC'><span style='letter-spacing: 1pt'> Usuario: $ifx_user    /    Versão: $versao</font></td>
</tr>
</table>");
echo "<hr>";


printf("<script language='javascript' type='TEXT/JAVASCRIPT'>");

printf("function validForm(passForm){
	if(passForm.ifx_user.value==''){
	   alert('Voce deve digitar o Nome')
	   passForm.ifx_user.focus()
	   return false;
        }

	if(passForm.ifx_senha.value==''){
	   alert('Voce deve digitar a Senha')
	   passForm.ifx_senha.focus()
	   return false
        }
        return true } ");



printf("</script>");

printf("<BODY BGCOLOR='WHITE'>");
printf("<FORM onSubmit='return validForm(this)'
	ACTION='programas/login.php' method=post>
	<table border=0 width='750'>

<td width='182' align='right' height='50' rowspan='2'>
      <img src='../imagens/319.jpg' align='right' width='32' height='32'>

      </td>
      <td width='1' align='right' height='25'>
      <font face='Book Antiqua' size='2' color='#0033CC'><span style='letter-spacing: 1pt'>Nome:</span></font>

      </td>
      <td width='685' align='left' height='25'>
      <input name='ifx_user' size='30' style='border: 1 solid #0033CC' >
      </td>
      <tr>
      <td width='1' align='right' height='25'>
      <font face='Book Antiqua' size='2' color='#0033CC'><span style='letter-spacing: 1pt'>Senha:</span></font>

      </td>
      <td width='685' align='left' height='25'>
      <input type='password' name='ifx_senha' size='30' style='border: 1 solid #0033CC'>
      </td>
      </tr>
      <tr>
      <td width='382'     align='right' height='27'>
      </td>
      <td width='58'     align='right' height='27'>
      </td>
      <td width='685'     align='left' height='27'>
      <P align='left'><input type='submit' value='Confirma' style='font-family: Book Antiqua; color: #0033CC; border: 1 outset #0033CC'>&nbsp;&nbsp;&nbsp;&nbsp;<input type='reset' value='Limpa' style='color: #0033CC; font-family: Book Antiqua; border: 1 outset #0033CC'>
      </td>
        </FORM>");

printf("</BODY>");

printf("</html>");
?>
