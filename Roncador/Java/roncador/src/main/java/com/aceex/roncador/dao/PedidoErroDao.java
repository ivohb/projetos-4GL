package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import main.java.com.aceex.roncador.model.PedidoErro;

public class PedidoErroDao extends Dao {

	private PreparedStatement stmt;

	public PedidoErroDao(Connection conexao) {
		super(conexao);
	}
	
	public void excluir(String empresa, String pedido) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query = "DELETE FROM pedido_erro_sical "
			+ "WHERE cnpj_empresa = ? and pedido_sical = ? ";
		
		stmt = con.prepareStatement(query); 
		stmt.setString(1, empresa);
		stmt.setString(2, pedido);
		
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}
	
	public void inserir(PedidoErro pe) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query =
			"INSERT INTO pedido_erro_sical (cnpj_empresa, pedido_sical, mensagem)"
			+ " VALUES(?,?,?)";

		stmt = con.prepareStatement(query); 
		stmt.setString(1, pe.getEmpresa());
		stmt.setString(2, pe.getPedido());
		stmt.setString(3, pe.getMensagem());
		
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}

	public List<PedidoErro> lstErros() throws SQLException {
		
		List<PedidoErro> erros = new ArrayList<PedidoErro>();
		PedidoErro erro;
		
		Connection con = getConexao();
		String query = "";

		query += "SELECT  cnpj_empresa, pedido_sical, mensagem from pedido_erro_sical ";
		
		PreparedStatement stmt = con.prepareStatement(query);
		ResultSet rs = stmt.executeQuery();

		while (rs.next()) {
			erro = new PedidoErro();
			erro.setEmpresa(rs.getString(1));
			erro.setPedido(rs.getString(2));
			erro.setMensagem(rs.getString(3));
			erros.add(erro);
		}

		return erros;
	}
}
