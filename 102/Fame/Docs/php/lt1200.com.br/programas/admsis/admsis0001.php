<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten��o:    
 //Data manuten��o:21/06/2005
 //M�dulo:         ADMSIS
 //Processo:       Consulta Programas por Cliente
 //Vers�o:         1.0
 $prog="admsis/admsis0001";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='admsis0001_a.php'></tr>");
  include("../../bibliotecas/cliente.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</tr> 
       <tr>
        <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Enviar Consulta'>
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar Campos'>
        </td>
       </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
