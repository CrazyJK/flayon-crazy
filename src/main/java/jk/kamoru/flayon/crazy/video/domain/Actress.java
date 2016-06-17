package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.io.Serializable;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.annotation.JsonIgnore;

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
public class Actress extends CrazyProperties implements Serializable, Comparable<Actress> {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	public static final String NAME = "NAME";
	public static final String NEWNAME = "NEWNAME";
	public static final String FAVORITE = "FAVORITE";
	public static final String LOCALNAME = "LOCALNAME";
	public static final String BIRTH = "BIRTH";
	public static final String BODYSIZE = "BODYSIZE";
	public static final String HEIGHT = "HEIGHT";
	public static final String DEBUT = "DEBUT";
	
	private String name;
	private String localName;
	private String birth;
	private String bodySize;
	private String debut;
	private String height;
	private String age;
	private Boolean favorite;
	
	@JsonIgnore
	private List<Studio> studioList;
	@JsonIgnore
	private List<Video>   videoList;
	@JsonIgnore
	private Map<String, String> info;
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
		return String.format("%s(%s) B:%s S:%s D:%s H:%scm F:%s S:%s V:%s",
						name, localName, birth, bodySize, debut, height, favorite, getScore(), videoList.size());
	}

	@Override
	public int compareTo(Actress comp) {
		switch (sort) {
		case NAME:
			return Utils.compareTo(this.getName(), comp.getName());
		case BIRTH:
			return Utils.compareTo(this.getBirth(), comp.getBirth());
		case BODY:
			return Utils.compareTo(this.getBodySize(), comp.getBodySize());
		case HEIGHT:
			return Utils.compareTo(this.getHeight(), comp.getHeight());
		case DEBUT:
			return Utils.compareTo(this.getDebut(), comp.getDebut());
		case VIDEO:
			return this.getVideoList().size() - comp.getVideoList().size();
		case SCORE:
			return this.getScore() - comp.getScore();
		case FAVORITE:
			return Utils.compareTo(this.getFavorite(), comp.getFavorite());
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
		return age;
	}
	public Boolean getFavorite() {
		loadInfo();
		return favorite;
	}
	public void setFavorite(Boolean favorite) {
		this.favorite = favorite;
		loadInfo();
		info.put("favorite", favorite.toString());
		info.put("newname", name);
		saveInfo(info);
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
	
	/**
	 * actress info load
	 */
	private void loadInfo() {
		if (!loaded) {
			if (log.isDebugEnabled())
				log.debug("loadInfo : start {}", name);
			File file = getInfoFile();
			if (log.isDebugEnabled())
				log.debug("loadInfo : file {}", file);
			if (file.isFile()) {
				info = Utils.readFileToMap(file);
				this.name      = Utils.trimToDefault(info.get(NEWNAME), name);
				this.localName = Utils.trimToDefault(info.get(LOCALNAME), localName);
				this.birth     = Utils.trimToDefault(info.get(BIRTH), birth);
				this.height    = Utils.trimToDefault(info.get(HEIGHT), height);
				this.bodySize  = Utils.trimToDefault(info.get(BODYSIZE), bodySize);
				this.debut     = Utils.trimToDefault(info.get(DEBUT), debut);
				this.favorite  = Boolean.valueOf(info.get(FAVORITE));
				if (!StringUtils.isEmpty(birth))
					try {
						Calendar cal = Calendar.getInstance();
						int CurrYear = cal.get(Calendar.YEAR);
						int birthYear = Integer.parseInt(birth.substring(0, 4));
						age = String.valueOf(CurrYear - birthYear + 1);
					} catch(Exception e) {}
			}
			else {
				info = new HashMap<>();
			}
			loaded = true;
			if (log.isDebugEnabled())
				log.debug("loadInfo : end {}", toString());
		}
	}

	private File getInfoFile() {
		return Paths.get(STORAGE_PATHS[0], "_info", name + "." + VIDEO.EXT_ACTRESS).toFile();
	}

	private File getInfoFile(String name) {
		return Paths.get(STORAGE_PATHS[0], "_info", name + "." + VIDEO.EXT_ACTRESS).toFile();
	}
	
	/**
	 * Actress Info를 갱신한다.
	 * @param params
	 * @return
	 */
	public String saveInfo(Map<String, String> params) {
		if (log.isDebugEnabled())
			log.debug("saveInfo : start {}", params);
		String newname = params.get("newname");
		
		// 이름 그대로
		if (StringUtils.equals(name, newname)) {
			// info 파일에 내용 저장
			if (log.isDebugEnabled())
				log.debug("saveInfo : save file {}", getInfoFile());
			Utils.saveFileFromMap(getInfoFile(), params);
		}
		// 이름이 변했으면
		else {
			if (getInfoFile(newname).exists()) { // 이미 같은 새이름의 파일이 있으면, No Action
				
			}
			else { // 타깃 없으면, 타깃에 저장
				// info 파일에 내용 저장
				if (log.isDebugEnabled())
					log.debug("saveInfo : save file {}", getInfoFile(newname));
				Utils.saveFileFromMap(getInfoFile(newname), params);
			}
			// actress의 비디오 파일 이름 변경
			if (log.isDebugEnabled())
				log.debug("saveInfo : rename video {} -> {}", name, newname);
			for (Video video : getVideoList())
				video.renameOfActress(name, newname);

			// 새이름 업데이트 
			name = newname;
		}

		if (log.isDebugEnabled())
			log.debug("saveInfo : end");

		reloadInfo();
		return name;
	}
	
}
