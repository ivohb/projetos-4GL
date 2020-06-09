package main.java.com.aceex.roncador.action;

import java.sql.SQLException;
import java.util.List;

import javax.management.RuntimeErrorException;

import org.apache.log4j.Logger;

import br.com.soap.MetodosSoap;
import main.java.com.aceex.roncador.dao.EmpresaDao;
import main.java.com.aceex.roncador.dao.FabricaDao;
import main.java.com.aceex.roncador.dao.NotaDao;
import main.java.com.aceex.roncador.model.Empresa;
import main.java.com.aceex.roncador.model.Nota;

public class Notas {

	private FabricaDao fd = new FabricaDao();
	private List<Nota> notasEmitidas;
	private String codEmpresa;

	private static Logger log = Logger.getLogger(Notas.class);

	public Notas() {}

	public void execute() {

		EmpresaDao eDao = fd.getEmpresaDao();
		
		try {
			List<Empresa> empresas = eDao.getEmpresas();
			for (Empresa empresa : empresas) {
				codEmpresa = empresa.getCodigo();	
				log.info(" empresa = "+codEmpresa);
				processa();
			}		

		} catch (SQLException e) {
			log.info(new RuntimeException(e));
			e.printStackTrace();
		}
	}

	private void processa() {
		
		try {
			notaCancelada();
			notaEmitida();
		} catch (Exception e) {
			log.info("Erro: Notas.processa ");
			log.info(new RuntimeException(e));
			e.printStackTrace();
		}
	}
	
	private void notaCancelada() throws Exception {
		NotaDao nDao = fd.getNotaDao();
		notasEmitidas = nDao.lstCanceladas(codEmpresa);

		log.info("Notas canceladas: "+notasEmitidas.size());
		
		if (notasEmitidas.size() == 0) {
			return;
		}

		String retorno = null;
		String xml = "<NewDataSet>\r\n";

		for (Nota nota : notasEmitidas) {
			
			log.info("Exportando nota "+nota.getNum_nota());
			
			xml = xml + "<NotasCanceladas>\r\n";
			xml = xml + "<num_nota>"+nota.getNum_nota()+"</num_nota>\r\n";
			xml = xml + "<serie>"+nota.getSerie()+"</serie>\r\n";
			xml = xml + "<dt_cancelato>"+nota.getDt_emissao()+"</dt_cancelato>\r\n";
			xml = xml + "</NotasCanceladas>\r\n";
		}
		
		xml = xml + "</NewDataSet>\r\n";
		
		retorno = new MetodosSoap("05872541000123", "mds123",false).enviaNotaCancelada(xml);
		System.out.println(retorno);
		
		if (retorno.contains("sucesso")) {
			for (Nota nota : notasEmitidas) {
				salva(nota);
			}
		}

	}

	private void notaEmitida() throws Exception {
		NotaDao nDao = fd.getNotaDao();
		notasEmitidas = nDao.lstEmitidas(this.codEmpresa);
		
		log.info("Notas emitidas: "+notasEmitidas.size());
		
		if (notasEmitidas.size() == 0) {
			return;
		}

		String retorno = null;
		String xml = "<NewDataSet>\r\n";

		for (Nota nota : notasEmitidas) {
			
			log.info("Exportando nota "+nota.getNum_nota());
			
			if (nota.getPlaca_veiculo() == null) {
				nota.setPlaca_veiculo(" ");
			}
			xml = xml + "<notas>\r\n";
			xml = xml + "<num_nota>"+nota.getNum_nota()+"</num_nota>\r\n";
			xml = xml + "<serie>"+nota.getSerie()+"</serie>\r\n";
			xml = xml + "<num_pedido>"+nota.getNum_pedido()+"</num_pedido>\r\n";
			xml = xml + "<dt_emissao>"+nota.getDt_emissao()+"</dt_emissao>\r\n";
			xml = xml + "<tipo_operacao>"+nota.getTipo_operacao()+"</tipo_operacao>\r\n";
			xml = xml + "<num_nota_origem>"+" "+"</num_nota_origem>\r\n";
			xml = xml + "<serie_origem>"+" "+"</serie_origem>\r\n";
			xml = xml + "<quant>"+nota.getQuant()+"</quant>\r\n";
			xml = xml + "<placa_veiculo>"+nota.getPlaca_veiculo()+"</placa_veiculo>\r\n";						
			xml = xml + "</notas>\r\n";
		}
		
		xml = xml + "</NewDataSet>\r\n";
		
		retorno = new MetodosSoap("05872541000123", "mds123",false).enviaNota(xml);
		System.out.println(retorno);
		
		if (retorno.contains("sucesso")) {
			for (Nota nota : notasEmitidas) {
				salva(nota);
			}
		}

	}
	
	private void salva(Nota nota) throws Exception {
		NotaDao nDao = fd.getNotaDao();
		log.info("Salvando nota "+nota.getNum_nota());
		nDao.salva(nota);
	}
}

