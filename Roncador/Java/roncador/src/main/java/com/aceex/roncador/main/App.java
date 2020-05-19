package main.java.com.aceex.roncador.main;

import main.java.com.aceex.roncador.action.Notas;
import main.java.com.aceex.roncador.action.Pedidos;

public class App {

	public static void main(String[] args) {
		//PedidosBean pb = new PedidosBean();
		//pb.processa("05872541000123");
		//NotasBean nb = new NotasBean();
		//nb.processa("05872541000123");
		
		new IntegraSical().contextInitialized(null);
	}
	
}
