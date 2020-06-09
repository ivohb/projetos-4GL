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
	
	public void excluir(int versao, 
			String empresa, String pedido) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query = "DELETE FROM pedido_erro_sical "
		+ "WHERE num_versao = ? and trim(cnpj_empresa) = ? and trim(pedido_sical) = ? ";
		
		stmt = con.prepareStatement(query); 
		stmt.setInt(1, versao);
		stmt.setString(2, empresa.trim());
		stmt.setString(3, pedido.trim());
		
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}
	
	public void inserir(PedidoErro pe) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query =
			"INSERT INTO pedido_erro_sical "
			+ "(num_versao, cnpj_empresa, pedido_sical, mensagem)"
			+ " VALUES(?,?,?,?)";

		stmt = con.prepareStatement(query); 
		stmt.setInt(1, pe.getVersao());
		stmt.setString(2, pe.getEmpresa());
		stmt.setString(3, pe.getPedido());
		stmt.setString(4, pe.getMensagem());
		
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}

	public List<PedidoErro> lstErros() throws SQLException {
		
		List<PedidoErro> erros = new ArrayList<PedidoErro>();
		PedidoErro erro;
		
		Connection con = getConexao();
		String query = "";

		query += "SELECT e.num_versao, e.cnpj_empresa, "
			+ " e.pedido_sical, i.cod_produto, e.mensagem "
			+ "from pedido_erro_sical e, ped_item_sical i "
		    + " where e.cnpj_empresa = i.cnpj_empresa "
		    + " and e.pedido_sical = i.pedido_sical "
		    + " and e.num_versao = i.num_versao ";
		    
		PreparedStatement stmt = con.prepareStatement(query);
		ResultSet rs = stmt.executeQuery();

		while (rs.next()) {
			erro = new PedidoErro();
			erro.setVersao(rs.getInt(1));
			erro.setEmpresa(rs.getString(2));
			erro.setProduto(rs.getString(3));
			erro.setPedido(rs.getString(4));
			erro.setMensagem(rs.getString(5));
			erros.add(erro);
		}

		return erros;
	}
}
