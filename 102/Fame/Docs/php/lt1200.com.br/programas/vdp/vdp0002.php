<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:24/06/2005
 //Módulo:         VDP
 //Processo:       Emissao Ordem de Montagem
 //Versão:         1.0
 $prog="vdp/vdp0002";
 $versao=1;
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0002_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  include("../../bibliotecas/autentica.inc");

  printf("<td width='50'  style=$n_style colspan='5'     align='center'>
           <i><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
           OM:</font></i>
         </td>
         <td width='50'  style=$n_style colspan='5'     align='center'>
           <input type='text' name='om' size='10' maxlenght='10'> 
         </td>
         </tr>
         <tr>
          <td width='50'  colspan='5' style=$n_style      align='center'>
           <input type='submit' name='Confirmar' value='Emitir Ordem'>
          </td>
          <td width='50'  colspan='5' style=$n_style     align='center'>
           <input type='reset' name='Cancelar' value='Limpar Campos'>
          </td>
         </tr>
       </FORM> ");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>


