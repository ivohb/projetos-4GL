<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten��o:    
 //Data manuten��o:21/06/2005
 //M�dulo:         SUP
 //Processo:       Emissao Posi��o estoque Simples
 //Vers�o:         1.0
 $prog="sup/sup0002";
 $versao=1;
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");

 if($prog_c=="C")
 {
  $fazer="L";
 }else{
  $fazer="N";
 } 
 if($nome_<>"")
 {
  if($fazer=="N")
  {
   include("../../bibliotecas/style.inc");
   printf("<tr> <FORM METHOD='POST' ACTION='sup0002.php'></tr>");
   include("../../bibliotecas/empresa.inc");
   include("../../bibliotecas/autentica.inc");
   printf("</tr> 
       </tr>
       <tr>
        <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Emitir Relat�rio'>
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar Campos'>
        </td>
       </tr>
       <tr>
        <td width='0'  style=$n_style colspan='1'     align='left'>
         <input type='hidden' value='C' name='prog_c' size='1' maxlenght='1' readonly> 
        </td>
      </tr>
      </FORM>");
  }
  if($fazer=="L")
  {
   include("../../bibliotecas/style.inc");
   printf("<tr> <FORM METHOD='POST' ACTION='sup0002_a.php'></tr>");
   include("../../bibliotecas/local.inc");
   include("../../bibliotecas/autentica.inc");
   printf("</tr> 
       </tr>
       <tr>
        <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Emitir Relat�rio'>
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar Campos'>
        </td>
       </tr>
       <tr>
        <td width='0'  style=$n_style colspan='1'     align='left'>
         <input type='hidden' value='".$empresa."' name='empresa' size='1' maxlenght='1' readonly> 
        </td>
        <td width='0'  style=$n_style colspan='1'     align='left'>
         <input type='hidden' value='C' name='prog_c' size='1' maxlenght='1' readonly> 
        </td>
      </tr>
      </FORM>");
  }


 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
