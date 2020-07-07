<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         SUP
 //Processo:       Emissao Pedido de COMPRAS
 //Versão:         1.0
 $prog="sup/sup0001";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='sup0001_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  include("../../bibliotecas/pedido.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</tr> 
       </tr>
       <tr>
        <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Emitir Pedido'>
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
