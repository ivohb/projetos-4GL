package main.java.com.aceex.roncador.action;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

import org.apache.log4j.Logger;

import br.com.soap.MetodosSoap;
import main.java.com.aceex.roncador.dao.EmpresaDao;
import main.java.com.aceex.roncador.dao.FabricaDao;
import main.java.com.aceex.roncador.dao.NotaDao;
import main.java.com.aceex.roncador.model.Empresa;
import main.java.com.aceex.roncador.model.Nota;
import main.java.com.aceex.roncador.util.Biblioteca;

public class Notas {

	private FabricaDao fd = new FabricaDao();
	private Biblioteca bib = new Biblioteca();

	private List<Nota> notasEmitidas;
	private String codEmpresa;
	private String cnpj;
	private String datCorte;

	private static Logger log = Logger.getLogger(Notas.class);

	public Notas() {}

	public void execute() {

		EmpresaDao eDao = fd.getEmpresaDao();
		
		try {
			List<Empresa> empresas = eDao.getEmpresas();
			for (Empresa empresa : empresas) {
				codEmpresa = empresa.getCodigo();	
				log.info(" empresa = "+codEmpresa);
				cnpj = empresa.getCnpj();
				cnpj = bib.tiraFormato(cnpj);

				if (cnpj.length() == 15) {
					cnpj = cnpj.substring(1, 15);
				}
				
				datCorte = empresa.getDatCorte();				
				
				log.info("Empresa NF: "+codEmpresa+" Cnpj: "+cnpj+" Corte: "+datCorte);
				
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
		
		retorno = new MetodosSoap(cnpj, "mds123",false).enviaNotaCancelada(xml);
		System.out.println(retorno);
		
		if (retorno.contains("sucesso")) {
			for (Nota nota : notasEmitidas) {
				salva(nota);
			}
		}

		gravaXmlEnviado(xml);
	}

	private void notaEmitida() throws Exception {
		NotaDao nDao = fd.getNotaDao();
		notasEmitidas = nDao.lstEmitidas(this.codEmpresa);
		
		log.info("Notas emitidas: "+notasEmitidas.size());
		
		if (notasEmitidas.size() == 0) {
			return;
		}

		NumberFormat nf = NumberFormat.getCurrencyInstance(new Locale("pt", "BR"));

		String retorno = null;
		String xml = "<NewDataSet>\r\n";

		for (Nota nota : notasEmitidas) {
			
			log.info("Exportando nota "+nota.getNum_nota()+"Quant "+nota.getQuant());
			
			if (nota.getPlaca_veiculo() == null) {
				nota.setPlaca_veiculo(" ");
			}
			
			String quant = nf.format(nota.getQuant());
			quant = quant.substring(3);
			log.info("Quant "+nota.getQuant()+" "+nf.format(nota.getQuant())+" "+quant);

			xml = xml + "<notas>\r\n";
			xml = xml + "<num_nota>"+nota.getNum_nota()+"</num_nota>\r\n";
			xml = xml + "<serie>"+nota.getSerie()+"</serie>\r\n";
			xml = xml + "<num_pedido>"+nota.getNum_pedido()+"</num_pedido>\r\n";
			xml = xml + "<dt_emissao>"+nota.getDt_emissao()+"</dt_emissao>\r\n";
			xml = xml + "<tipo_operacao>"+nota.getTipo_operacao()+"</tipo_operacao>\r\n";
			xml = xml + "<num_nota_origem>"+" "+"</num_nota_origem>\r\n";
			xml = xml + "<serie_origem>"+" "+"</serie_origem>\r\n";
			xml = xml + "<quant>"+quant+"</quant>\r\n";
			xml = xml + "<placa_veiculo>"+nota.getPlaca_veiculo()+"</placa_veiculo>\r\n";						
			xml = xml + "</notas>\r\n";
		}
		
		xml = xml + "</NewDataSet>\r\n";
		
		retorno = new MetodosSoap(cnpj, "mds123",false).enviaNota(xml);
		System.out.println(retorno);
		
		if (retorno.contains("sucesso")) {
			for (Nota nota : notasEmitidas) {
				salva(nota);
			}
		}

		gravaXmlEnviado(xml);

	}
	
	private void salva(Nota nota) throws Exception {
		NotaDao nDao = fd.getNotaDao();
		log.info("Salvando nota "+nota.getNum_nota());
		
		if (nDao.jaExportou(nota.getEmpresa(), 
				nota.getTransac(), nota.getSit_nota())) {			
		} else {
			nDao.salva(nota);
		}
	}
	
	private void gravaXmlEnviado(String xml) throws Exception {
		
		try {
			String nomeArq = cnpj.trim()+" "+bib.dataPesquisa(0);
			nomeArq = nomeArq.trim()+" "+bib.horaAtual();
			nomeArq = nomeArq.trim()+".xml";
			String path = System.getProperty("catalina.home")+"\\xml_enviado\\";
			log.info(path);
			nomeArq = path+nomeArq;
			log.info(nomeArq);

		    FileWriter arq = 
		    		new FileWriter(nomeArq);
		    PrintWriter gravarArq = new PrintWriter(arq);
		 
		    gravarArq.printf(xml.toString());
		 
		    arq.close();
			
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
}

