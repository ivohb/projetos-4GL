package main.java.com.aceex.roncador.main;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import main.java.com.aceex.roncador.dao.FabricaDao;
import main.java.com.aceex.roncador.dao.PedidoSicalDao;

public class TestaConexao {

	private FabricaDao fd = new FabricaDao();
	
	public static void main(String[] args)  {
		new TestaConexao().conecta();

	}
	
	private void conecta() {
		
		PedidoSicalDao psDao = fd.getPedidoSicalDao();
		
		if (psDao != null) {
			System.out.println("Conexão OK");
		}
	}
	
	
	public Connection getConexao() throws ClassNotFoundException, SQLException {
		
		Connection conn = null;
		
		try{
			String db_connect_string = "jdbc:sqlserver://192.168.1.56;DatabaseName=LOGIXPRD";
            conn = DriverManager.getConnection(
            		db_connect_string,"logix","logix");
            System.out.println( "connected" );
        }
        catch( SQLException e ){
            e.printStackTrace();
        }
		
		return conn;
		
	}
	
}
