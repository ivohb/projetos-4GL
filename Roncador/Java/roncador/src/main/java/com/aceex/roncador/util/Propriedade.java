package main.java.com.aceex.roncador.util;

import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.util.Properties;

import org.apache.log4j.Logger;

public class Propriedade {

	private static Properties properties = null;
	
	private static Logger log = Logger.getLogger(Connection.class);

	public Propriedade() {}
	
	
	//retorna tempo em minuto
	
	public int getTempo(){

		int retorno = 1;
				
		try {		
			FileInputStream		fis	= null;
			fis = new FileInputStream(
				new File(new File(
					new File(System.getProperty("catalina.home")),"/conf"),"tempo.props"));

			properties = new Properties();
			properties.load(fis);
			
			if (properties.getProperty("tempo") != null) {
				String tempo = properties.getProperty("tempo").toString();
				retorno = Integer.parseInt(tempo);
			}
			fis.close();	
			log.info("Tempo do robo: "+retorno);
		} catch (Exception e) {			
			log.fatal("Erro ao carregar o arquivo tempo.props");
			e.printStackTrace();
		}

		
		return retorno;		
	}
	

}
