<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor:   Rubens Facundo
 //Manutenção:
 //Data manutenção: 20/10/2005
 //Mdulo:           Fame
 //Processo:        Relatorio do Mapa de Vendas
 //Versão:          1.0
 $versao=1;
 $prog="fame/fam0015";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0015_a.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  include("../../bibliotecas/empresa.inc");
   printf("
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






