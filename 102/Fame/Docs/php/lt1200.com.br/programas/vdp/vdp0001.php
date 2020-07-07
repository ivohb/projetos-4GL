<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Emissao Pedido de Vendas
 //Versão:         1.0
 $prog="vdp/vdp0001";
 $versao="1";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0001_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  include("../../bibliotecas/pedido.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</tr> 
       <tr>
        <td width='750'  colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='c_saldo' value='S' >
         Imprime o Pedido Completo (incluindo itens já Faturados)
        </td>
       </tr>
       <tr>
        <td width='750' colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='win' value='S' >
         Clique aqui se estiver usando Windows 2000,XP
        </td>
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
