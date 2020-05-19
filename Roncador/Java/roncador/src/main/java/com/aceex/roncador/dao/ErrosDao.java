package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import main.java.com.aceex.roncador.connection.OracleConexao;
import main.java.com.aceex.roncador.model.PedidoErro;

public class ErrosDao {

	private final Connection conexao;
	
	public ErrosDao() {
		this.conexao = OracleConexao.getErroConexao();				
	}
	
	public void insereErro(PedidoErro erro) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query = "DELETE FROM pedido_erro_sical "
				+ " WHERE cnpj_empresa = ? and pedido_sical = ? ";

		PreparedStatement stmt = con.prepareStatement(query); 
		stmt.setString(1, erro.getEmpresa());
		stmt.setString(2, erro.getPedido());
		stmt.executeUpdate();
		stmt.close();

		 query = "INSERT INTO pedido_erro_sical"
			+ "(cnpj_empresa, pedido_sical, mensagem)"
			+ " VALUES(?,?,?)";	
		
		stmt = con.prepareStatement(query); 
		stmt.setString(1, erro.getEmpresa());
		stmt.setString(2, erro.getPedido());
		stmt.setString(3, erro.getMensagem());
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}

	
	public Connection getConexao() {
		return conexao;
	}
	
}
