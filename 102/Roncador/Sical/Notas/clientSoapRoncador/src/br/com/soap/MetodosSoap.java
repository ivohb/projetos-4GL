package br.com.soap;

import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.axis.message.MessageElement;
import org.tempuri.DownloadPedidosResponseDownloadPedidosResult;
import org.tempuri.ServiceSoapProxy;

// http://177.130.29.33:90/ws_sical/Service.asmx?WSDL

public class MetodosSoap {
	protected String cnpj;
	protected String senha;
	protected boolean debug;
	
	public MetodosSoap(String cnpj,String senha, boolean debug) {
		this.cnpj = cnpj;
		this.senha = senha;
		this.debug = debug;
	}
	
	/*
	public static void main(String args[]) {
		
		try {
			new MetodosSoap("05872541000123", "mds123",true).getPedidos();
			
			//new MetodosSoap("05872541000123", "mds123",true).enviaNota("<xml></xml>");
			
			//new MetodosSoap("05872541000123", "mds123",true).enviaNotaCancelada("<xml></xml>");
			
		} catch (RemoteException e) {			
			e.printStackTrace();
		}
		
	}
	*/
	
	public List<String> getPedidos() throws RemoteException {
		List<String> lXML = new ArrayList<String>();
		DownloadPedidosResponseDownloadPedidosResult pedidos = new ServiceSoapProxy().downloadPedidos(cnpj, senha);
		 				
		if(pedidos !=null) {			
			MessageElement[] retorno = pedidos.get_any();
			
			List<MessageElement> lRetorno = Arrays.asList(retorno);
			
			for (int i =0; i<lRetorno.size();i++) {
				if(debug) {
					System.out.println(lRetorno.get(i).toString());
				}
				
				lXML.add(lRetorno.get(i).toString());
			}						
		}	
		
		return lXML;
	}
	
	public String enviaNota(String xml) throws RemoteException {
			
		String retorno =  new ServiceSoapProxy().uploadNotasNOVO(cnpj, senha, xml);	
		
		if(debug) {
			System.out.println(retorno);
		}
		
		return retorno;
				
	}
	
	public String enviaNotaCancelada(String xml) throws RemoteException {
		
		String retorno =  new ServiceSoapProxy().uploadNotasCanceladasNOVO(cnpj, senha, xml);	
		
		if(debug) {
			System.out.println(retorno);
		}
		
		return retorno;
				
	}
	
}
