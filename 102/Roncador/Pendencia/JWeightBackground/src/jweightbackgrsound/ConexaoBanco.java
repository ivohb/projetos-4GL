package jweightbackgrsound;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ConexaoBanco {
	
	public String driver;
	public String url;
	public String usuario;
	public String senha;

	public ConexaoBanco() {
		try {
			FileReader arqConfig = new FileReader(
					"D:\\totvs\\logix\\bin\\smartclient\\visio\\arq_config_bd.txt");
			BufferedReader bfrLeitor = new BufferedReader(arqConfig, 1024);
			driver = bfrLeitor.readLine();
			driver = driver.trim();
			url = bfrLeitor.readLine();
			url = url.trim();
			usuario = bfrLeitor.readLine();
			usuario = usuario.trim();
			senha = bfrLeitor.readLine();
			senha = senha.trim();
		} catch (FileNotFoundException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(
					Level.SEVERE, null, ex);
		} catch (IOException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(
					Level.SEVERE, null, ex);
		}
	}

	
}
