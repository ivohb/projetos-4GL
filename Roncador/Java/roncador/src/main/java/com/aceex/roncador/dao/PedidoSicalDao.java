package main.java.com.aceex.roncador.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import main.java.com.aceex.roncador.model.PedidoSical;

public class PedidoSicalDao extends Dao {

	private PreparedStatement stmt;
	private ResultSet rs;

	public PedidoSicalDao(Connection conexao) {
		super(conexao);
	}
	
	public Integer getVersao(String cnpjEmpresa, String numPedido) throws SQLException {

		Integer numVersao = 0;
		String query = "";

		query += "select max(num_versao) as versao from pedido_sical ";
		query += "where cnpj_empresa = ? and pedido_sical = ? ";
		
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, cnpjEmpresa);
		stmt.setString(2, numPedido);

		rs = stmt.executeQuery();

		if (rs.next()) {
			numVersao = rs.getInt("versao");
		}

		rs.close();
		stmt.close();

		return numVersao;
	}

	public Integer getVersao(String cnpjEmpresa, 
			String numPedido, String situacao) throws SQLException {

		Integer numVersao = 0;
		String query = "";

		query += "select max(num_versao) as versao from pedido_sical ";
		query += "where cnpj_empresa = ? and pedido_sical = ? and situacao = ? ";
		
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, cnpjEmpresa);
		stmt.setString(2, numPedido);
		stmt.setString(3, situacao);

		rs = stmt.executeQuery();

		if (rs.next()) {
			numVersao = rs.getInt("versao");
		}

		rs.close();
		stmt.close();

		return numVersao;
	}

	public Integer getPedidoLogix(Integer numVersao,
			String cnpjEmpresa, String numPedido) throws SQLException {

		Integer pedido = 0;
		String query = "";

		query += "SELECT pedido_logix from pedido_sical ";
		query += "where cnpj_empresa = ? and pedido_sical = ? and num_versao = ? ";
		
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, cnpjEmpresa);
		stmt.setString(2, numPedido);
		stmt.setInt(3, numVersao);
		
		rs = stmt.executeQuery();

		if (rs.next()) {
			pedido = rs.getInt("pedido_logix");
		}

		rs.close();
		stmt.close();

		return pedido;
	}

	public PedidoSical getPedido(Integer numVersao,
			String cnpjEmpresa, String numPedido) throws SQLException {

		PedidoSical ps = null;
		String query = "";

		query += "SELECT cnpj_empresa, tipo_pedido, cnpj_cpf_cliente, ";
		query += "pedido_sical, dt_emissao, entrega_futura, cod_portador, ";
		query += "cod_cond_pagto, cnpj_cpf_vendedor, pedido_logix ";
		query += "num_versao, versao_atual, situacao ";
		query += "from pedido_sical";
		query += "where cnpj_empresa = ? and pedido_sical = ? and num_versao = ?";
		
		stmt = getConexao().prepareStatement(query);
		stmt.setString(1, cnpjEmpresa);
		stmt.setString(2, numPedido);
		stmt.setInt(3, numVersao);
		
		rs = stmt.executeQuery();

		if (rs.next()) {
			ps = new PedidoSical();
			ps.setCnpj_empresa(rs.getString(1));
			ps.setTipo_pedido(rs.getString(2));
			ps.setCNPJ_CPF_cliente(rs.getString(3));
			ps.setNum_pedido(rs.getString(4));
			ps.setDt_emissao(rs.getString(5));
			ps.setEntrega_futura(rs.getString(6));
			ps.setCod_portador(rs.getString(7));
			ps.setCod_cond_pagto(rs.getString(8));
			ps.setCNPJ_CPF_vendedor(rs.getString(9));
			ps.setPedido_logix(rs.getInt(10));
			ps.setNum_versao(rs.getInt(11));
			ps.setVersao_atual(rs.getString(12));
			ps.setSituacao(rs.getString(13));

		}

		rs.close();
		stmt.close();

		return ps;
	}

	public void atuVersao(Integer numVersao,
			String cnpjEmpresa, String numPedido) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);
		String query = "";
		
		query += "UPDATE pedido_sical SET versao_atual = 'N' ";
		query += " WHERE cnpj_empresa = ? and pedido_sical = ? and num_versao = ?";

		stmt = con.prepareStatement(query);
		stmt.setString(1, cnpjEmpresa);
		stmt.setString(2, numPedido);
		stmt.setInt(3, numVersao);		
	    stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}

	public Integer getMaxId() throws SQLException {

		int id = 0;
		String query = "";

		query += "select max(id_processo) from pedido_sical";

		stmt = getConexao().prepareStatement(query);

		rs = stmt.executeQuery();

		if (rs.next()) {
			id = rs.getInt(1);
		}

		rs.close();
		stmt.close();

		return id;
	}

	public void inserir(PedidoSical ps) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);

		String query =
			"INSERT INTO pedido_sical (cnpj_empresa, tipo_pedido, cnpj_cpf_cliente, "
			+ " pedido_sical, dt_emissao, entrega_futura, cod_portador, "
			+ " cod_cond_pagto, cnpj_cpf_vendedor, pedido_logix, situacao, "
			+ " num_versao, versao_atual, cod_empresa, pedido_bloqueado, tipo_frete )"
			+ " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		stmt = con.prepareStatement(query); 
		stmt.setString(1, ps.getCnpj_empresa());
		stmt.setString(2, ps.getTipo_pedido());
		stmt.setString(3, ps.getCNPJ_CPF_cliente());
		stmt.setString(4, ps.getNum_pedido());
		stmt.setString(5, ps.getDt_emissao());
		stmt.setString(6, ps.getEntrega_futura());
		stmt.setString(7, ps.getCod_portador());
		stmt.setString(8, ps.getCod_cond_pagto());
		stmt.setString(9, ps.getCNPJ_CPF_vendedor());
		stmt.setInt(10, ps.getPedido_logix());
		stmt.setString(11,  ps.getSituacao());
		stmt.setInt(12, ps.getNum_versao());
		stmt.setString(13, ps.getVersao_atual());
		stmt.setString(14, ps.getCod_empresa());
		stmt.setString(15, ps.getPedido_bloqueado());
		stmt.setString(16, ps.getTipo_frete());
		stmt.executeUpdate();
		stmt.close();
		con.commit();

	}
	
	public void atualizar(PedidoSical ps) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);
		String query = "";
		
		query += "UPDATE pedido_sical SET tipo_pedido = '"+ps.getTipo_pedido()+"' ";
		query += ", entrega_futura = '"+ps.getEntrega_futura()+"' ";
		query += ", cod_cond_pagto = '"+ps.getCod_cond_pagto()+"' ";
		query += ", situacao = 'N' ";
		query += " WHERE cnpj_empresa = ? and pedido_sical = ?";

		stmt = con.prepareStatement(query);
		stmt.setString(1, ps.getCnpj_empresa());
		stmt.setString(2, ps.getNum_pedido());

	    stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}

	public void atuStatus(String empresa, String pedSial,
			Integer versao, Integer pedLogix) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);
		String query = "";
		
		query += "UPDATE pedido_sical SET situacao = 'F', pedido_logix '"+pedLogix+"' ";
		query += " WHERE cnpj_empresa = ? and pedido_sical = ? and num_versao = ?";

		stmt = con.prepareStatement(query);
		stmt.setString(1, empresa);
		stmt.setString(2, pedSial);
		stmt.setInt(3, versao);

	    stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}

	public void atuStatus(String empresa, String situa,
			String pedido) throws SQLException {
		
		Connection con = getConexao();
		con.setAutoCommit(false);
		String query = "";
		
		query += "UPDATE pedido_sical SET situacao = '"+situa+"' ";
		query += " WHERE cnpj_empresa = ? and pedido_sical = ?";

		stmt = con.prepareStatement(query);
		stmt.setString(1, empresa);
		stmt.setString(2, pedido);

	    stmt.executeUpdate();
	    stmt.close();	
	    con.commit();		    
	}

	public List<PedidoSical> listaPedido() throws SQLException {
		
		List<PedidoSical> pedidos = new ArrayList<PedidoSical>();
		PedidoSical ps = null;
		Connection con = getConexao();
		String data = null;
		String query = "";

		query += "SELECT cnpj_empresa, tipo_pedido, cnpj_cpf_cliente, ";
		query += "pedido_sical, dt_emissao, entrega_futura, cod_portador, ";
		query += "cod_cond_pagto, cnpj_cpf_vendedor, pedido_logix, num_versao, ";
		query += "cod_empresa, pedido_bloqueado, tipo_frete FROM pedido_sical ";
		query += "WHERE (situacao = 'N' OR situacao = 'C') and versao_atual = 'S' ";

		stmt = con.prepareStatement(query);
		rs = stmt.executeQuery();

		while (rs.next()) {
			ps = new PedidoSical();
			ps.setCnpj_empresa(rs.getString(1));
			ps.setTipo_pedido(rs.getString(2));
			ps.setCNPJ_CPF_cliente(rs.getString(3));
			ps.setNum_pedido(rs.getString(4));
			data = rs.getString(5);
			data = data.trim();
			if (data.length() >= 10) {
				data = data.substring(0,10);
			} else {
				data = "";
			}
			ps.setDt_emissao(data);
			ps.setEntrega_futura(rs.getString(6));
			ps.setCod_portador(rs.getString(7));
			ps.setCod_cond_pagto(rs.getString(8));
			ps.setCNPJ_CPF_vendedor(rs.getString(9));
			ps.setPedido_logix(rs.getInt(10));
			ps.setNum_versao(rs.getInt(11));
			ps.setCod_empresa(rs.getString(12));
			ps.setPedido_bloqueado(rs.getString(13));
			ps.setTipo_frete(rs.getString(14));
			pedidos.add(ps);
		}
		return pedidos;		
	}

	public List<PedidoSical> listaPedido(String situacao) throws SQLException {
		
		List<PedidoSical> pedidos = new ArrayList<PedidoSical>();
		PedidoSical ps = null;
		Connection con = getConexao();
		String data = null;
		String query = "";

		query += "SELECT cnpj_empresa, tipo_pedido, cnpj_cpf_cliente, ";
		query += "pedido_sical, dt_emissao, entrega_futura, cod_portador, ";
		query += "cod_cond_pagto, cnpj_cpf_vendedor, pedido_logix, num_versao ";
		query += "FROM pedido_sical ";
		query += "WHERE versao_atual = 'S' and situacao = ? ";

		stmt = con.prepareStatement(query);
		stmt.setString(1, situacao);		
		rs = stmt.executeQuery();

		while (rs.next()) {
			ps = new PedidoSical();
			ps.setCnpj_empresa(rs.getString(1));
			ps.setTipo_pedido(rs.getString(2));
			ps.setCNPJ_CPF_cliente(rs.getString(3));
			ps.setNum_pedido(rs.getString(4));
			data = rs.getString(5);
			data = data.trim();
			if (data.length() >= 10) {
				data = data.substring(0,10);
			} else {
				data = "";
			}
			ps.setDt_emissao(data);
			ps.setEntrega_futura(rs.getString(6));
			ps.setCod_portador(rs.getString(7));
			ps.setCod_cond_pagto(rs.getString(8));
			ps.setCNPJ_CPF_vendedor(rs.getString(9));
			ps.setPedido_logix(rs.getInt(10));
			ps.setNum_versao(rs.getInt(11));
			pedidos.add(ps);
		}
		return pedidos;		
	}

}
