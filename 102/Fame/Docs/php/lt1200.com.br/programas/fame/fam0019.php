<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten�o:
 //Data manuten�o:28/11/2005
 //Mdulo:         Fame
 //Processo:      Etiquetas para Clientes com direito a Rel�gio
 //Vers�:         1.0
 $versao=1;
 $prog="fame/fam0019";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0019_a.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  printf("<td width='20'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Processo:</font></b>
    </td>
    <td width='20'  style=$n_style      align='left'>
       <input type='text' name='proc'  size='5' maxlenght='5' > 
      </td>

      </table>
      <table>
      <tr>
      <td width='50'  style=$n_style      align='center'>
       <input type='submit' name='Confirmar'>
      </td>
      <td width='50'  style=$n_style     align='center'>
       <input type='reset' name='Cancelar'>
      </td>
     </FORM>
     </tr>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>





