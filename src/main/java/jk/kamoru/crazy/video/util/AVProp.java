package jk.kamoru.crazy.video.util;

import java.io.InputStream;
import java.io.Serializable;
import java.net.InetAddress;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * AV properties<br>
 * usage) private AVProp prop = AVProp.getInstance();<br>
 * properties file location is /resource/av.[hostname].properties
 * @author kamoru
 *
 */
public class AVProp implements Serializable {

	private static final long serialVersionUID = -4595380642230830517L;

	protected static final Logger logger = LoggerFactory.getLogger(AVProp.class);

	public String                  player = "\"C:\\Program Files (x86)\\The KMPlayer\\KMPlayer.exe\" ";
	public String                  editor = "\"C:\\Program Files (x86)\\The KMPlayer\\KMPlayer.exe\" ";
	public String             noImagePath = "/home/kamoru/DaumCloud/MyPictures/삽질금지.jpg";
	public String                basePath = "/home/kamoru/ETC/collection";
	public String        video_extensions = "avi,mpg,wmv,mp4";
	public String        cover_extensions = "jpg,jpeg,gif";
	public String    subtitles_extensions = "smi,srt";
	public String     overview_extensions = "txt,html";
	public String backgroundImagePoolPath = "/home/kamoru/DaumCloud/MyPictures";
	
	private String propertiesPath;

	private static AVProp prop;
	
	public AVProp() {
		loadProperties();
	}
	
	public static AVProp getInstance() {
		if(prop == null)
			prop = new AVProp();
		return prop;
	}
	
	private void loadProperties() {
		Properties prop = new Properties();
		try {
			propertiesPath = "/av." + InetAddress.getLocalHost().getHostName() + ".properties";
			logger.debug("AV properties load... {}", propertiesPath);
			
			InputStream in = getClass().getResourceAsStream(propertiesPath);
			prop.load(in);
			                 player = prop.getProperty("player", 					player).trim();
			                 editor = prop.getProperty("editor", 					editor).trim();
			            noImagePath = prop.getProperty("noImagePath", 				noImagePath).trim(); 
			               basePath = prop.getProperty("basePath", 					basePath).trim(); 
			       video_extensions = prop.getProperty("video_extensions", 			video_extensions).trim().toLowerCase(); 
			       cover_extensions = prop.getProperty("cover_extensions", 			cover_extensions).trim().toLowerCase(); 
			   subtitles_extensions = prop.getProperty("subtitles_extensions", 		subtitles_extensions).trim().toLowerCase(); 
				overview_extensions = prop.getProperty("overview_extensions",  		overview_extensions).trim().toLowerCase();
			backgroundImagePoolPath = prop.getProperty("backgroundImagePoolPath",  	backgroundImagePoolPath).trim();
			in.close();
			
			logger.debug("\tplayer : {}", player);
			logger.debug("\teditor : {}", editor);
			logger.debug("\tnoImagePath : {}", noImagePath);
			logger.debug("\tbasePath : {}", basePath);
			logger.debug("\tvideo_extensions : {}", video_extensions);
			logger.debug("\tcover_extensions : {}", cover_extensions);
			logger.debug("\tsubtitles_extensions : {}", subtitles_extensions);
			logger.debug("\toverview_extensions : {}", overview_extensions);
			logger.debug("\tbackgroundImagePoolPath : {}", backgroundImagePoolPath);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
