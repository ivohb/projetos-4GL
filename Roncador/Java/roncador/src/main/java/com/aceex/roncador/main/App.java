package main.java.com.aceex.roncador.main;

import main.java.com.aceex.roncador.action.Erros;
import main.java.com.aceex.roncador.action.Notas;
import main.java.com.aceex.roncador.action.Pedidos;
import main.java.com.aceex.roncador.connection.OracleConexao;

public class App {

	public static void main(String[] args) {

		OracleConexao.abreConexao();
		new Pedidos().execute();
		new Notas().execute();
		
		OracleConexao.abreErroConexao();
		new Erros().processa();

		OracleConexao.fechaErroConexao();
		OracleConexao.fechaConexao();

		//new IntegraSical().contextInitialized(null);
	}
	
}
