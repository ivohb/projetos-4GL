package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class NatOperSical implements Serializable {
	private static final long serialVersionUID = 1L;

	private String tip_pedido;
	private String entrega_furura;
	private Integer cod_nat_venda;
	private Integer cod_nat_remessa;
	
	public NatOperSical() {}
	
	public String getTip_pedido() {
		return tip_pedido;
	}
	public void setTip_pedido(String tip_pedido) {
		this.tip_pedido = tip_pedido;
	}
	public String getEntrega_furura() {
		return entrega_furura;
	}
	public void setEntrega_furura(String entrega_furura) {
		this.entrega_furura = entrega_furura;
	}
	public Integer getCod_nat_venda() {
		return cod_nat_venda;
	}
	public void setCod_nat_venda(Integer cod_nat_venda) {
		this.cod_nat_venda = cod_nat_venda;
	}
	public Integer getCod_nat_remessa() {
		return cod_nat_remessa;
	}
	public void setCod_nat_remessa(Integer cod_nat_remessa) {
		this.cod_nat_remessa = cod_nat_remessa;
	}

}
