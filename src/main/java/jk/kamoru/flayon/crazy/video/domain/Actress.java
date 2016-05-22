package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import org.apache.commons.lang3.StringUtils;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.extern.slf4j.Slf4j;

@Component
@Scope("prototype")
@EqualsAndHashCode(exclude={"studioList", "videoList"}, callSuper=false)
@Data
@Slf4j
@XmlRootElement(name = "actress", namespace = "http://www.w3.org/2001/XMLSchema-instance")
@XmlAccessorType(XmlAccessType.FIELD)
public class Actress extends CrazyProperties implements Serializable, Comparable<Actress> {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	public static String NAME = "NAME";
	public static String FAVORITE = "FAVORITE";
	public static String LOCALNAME = "LOCALNAME";
	public static String BIRTH = "BIRTH";
	public static String BODYSIZE = "BODYSIZE";
	public static String HEIGHT = "HEIGHT";
	public static String DEBUT = "DEBUT";
	public static String POINTS = "POINTS";
	
	private String name;
	private String localName;
	private String birth;
	private String bodySize;
	private String debut;
	private String height;
	private String age;
	private Boolean favorite;
	
	@XmlTransient
	private List<Studio> studioList;
	@XmlTransient
	private List<Video>   videoList;

	/**
	 * is loaded actress infomation
	 */
	private boolean loaded;
	
	private ActressSort sort = ActressSort.NAME;

	public Actress() {
		name = "";
		localName = "";
		birth = "";
		bodySize = "";
		debut = "";
		height = "";
		age = "";
		favorite = new Boolean(false);
		studioList = new ArrayList<Studio>();
		videoList = new ArrayList<Video>();
	}
	public Actress(String name) {
		this();
		this.name = name;
	}
	
	@Override
	public String toString() {
		return String.format("%s %s점 %s %s %s년 %scm %s %s편",
						name, getScore(), StringUtils.trimToEmpty(birth), StringUtils.trimToEmpty(bodySize), StringUtils.trimToEmpty(debut), StringUtils.trimToEmpty(height), StringUtils.trimToEmpty(localName), videoList.size());
	}
	@Override
	public int compareTo(Actress comp) {
		switch (sort) {
		case NAME:
			return Utils.compareTo(this.getName(), comp.getName());
		case BIRTH:
			return Utils.compareTo(comp.getBirth(), this.getBirth());
		case BODY:
			return Utils.compareTo(comp.getBodySize(), this.getBodySize());
		case HEIGHT:
			return Utils.compareTo(comp.getHeight(), this.getHeight());
		case DEBUT:
			return Utils.compareTo(comp.getDebut(), this.getDebut());
		case VIDEO:
			return comp.getVideoList().size() - this.getVideoList().size();
		case SCORE:
			return comp.getScore() - this.getScore();
		case FAVORITE:
			return Utils.compareTo(comp.getFavorite(), this.getFavorite());
		default:
			return Utils.compareTo(this.getName(), comp.getName());
		}
	}
	
	public boolean contains(String actressName) {
		return VideoUtils.equalsActress(name, actressName);
	}
	
	public String getBirth() {
		loadInfo();
		return birth;
	}
	public String getBodySize() {
		loadInfo();
		return bodySize;
	}
	public String getDebut() {
		loadInfo();
		return debut;
	}
	public String getHeight() {
		loadInfo();
		return height;
	}
	public String getLocalName() {
		loadInfo();
		return localName;
	}
	public String getAge() {
		loadInfo();
		if (StringUtils.isEmpty(age) && !StringUtils.isEmpty(birth))
			try {
				Calendar cal = Calendar.getInstance();
				int CurrYear = cal.get(Calendar.YEAR);
				int birthYear = Integer.parseInt(birth.substring(0, 4));
				age = String.valueOf(CurrYear - birthYear + 1);
				log.debug("{} - {} + 1 = {}", CurrYear, birthYear, age);
			} catch(Exception e) {}
		return age;
	}
	public Boolean getFavorite() {
		loadInfo();
		return favorite;
	}

	public Map<String, String> getInfoMap() {
		try {
			return Utils.readFileToMap(getInfoFile());
		} 
		catch (CrazyException e) {
			log.debug("info load error : {} - {}", name, e.getMessage());
			return new HashMap<String, String>();
		}
	}
	
	private void loadInfo() {
		if (!loaded) {
			Map<String, String> info = getInfoMap();
			if (info == null)
				return;
			this.localName = StringUtils.trimToEmpty(info.get(LOCALNAME));
			this.birth     = StringUtils.trimToEmpty(info.get(BIRTH));
			this.height    = StringUtils.trimToEmpty(info.get(HEIGHT));
			this.bodySize  = StringUtils.trimToEmpty(info.get(BODYSIZE));
			this.debut     = StringUtils.trimToEmpty(info.get(DEBUT));
			this.favorite  = Boolean.valueOf(info.get(FAVORITE));
			loaded = true;
		}
	}
	private File getInfoFile() {
		return new File(new File(STORAGE_PATHS[0], "_info"), name + "." + VIDEO.EXT_ACTRESS);
	}
	public void reloadInfo() {
		loaded = false;
		loadInfo();
	}
	public void addStudio(Studio studio) {
		if(!this.studioList.contains(studio))
			this.studioList.add(studio);
	}
	public void addVideo(Video video) {
		if(!this.videoList.contains(video))
			this.videoList.add(video);
	}
	
	public void emptyVideo() {
		videoList.clear();
	}
	/**
	 * sum of video scoring in actress
	 * @return
	 */
	public int getScore() {
		int score  = 0;
		for (Video video : getVideoList()) {
			score += video.getScore();
		}
		return score;
	}
	
	/**
	 * reverse name
	 * @return
	 */
	public String getReverseName() {
		String[] names = StringUtils.split(name, ' ');
		if (names != null && names.length > 1) {
			String reverseName = "";
			for (int i = names.length-1; i > -1; i--) {
				reverseName += names[i] + " ";
			}
			return reverseName;
		}
		return name;
	}
	
	public void renameInfo(String newName) {
		File infoFile = getInfoFile();
		if (infoFile.exists())
			Utils.renameFile(getInfoFile(), newName + "." + VIDEO.EXT_ACTRESS);
		reloadInfo();
	}
	
}
