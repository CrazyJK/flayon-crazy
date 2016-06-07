package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.io.Serializable;
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

	public static String NAME = "NAME";
	public static String NEWNAME = "NEWNAME";
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
		return String.format("%s %s점 %s %s %s년 %scm %s %s편",
						name, getScore(), StringUtils.trimToEmpty(birth), StringUtils.trimToEmpty(bodySize), StringUtils.trimToEmpty(debut), StringUtils.trimToEmpty(height), StringUtils.trimToEmpty(localName), videoList.size());
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
		if (StringUtils.isEmpty(age) && !StringUtils.isEmpty(birth))
			try {
				Calendar cal = Calendar.getInstance();
				int CurrYear = cal.get(Calendar.YEAR);
				int birthYear = Integer.parseInt(birth.substring(0, 4));
				age = String.valueOf(CurrYear - birthYear + 1);
				log.trace("{} - {} + 1 = {}", CurrYear, birthYear, age);
			} catch(Exception e) {}
		return age;
	}
	public Boolean getFavorite() {
		loadInfo();
		return favorite;
	}
	
	private void loadInfo() {
		if (!loaded) {
			File file = getInfoFile();
			log.trace("loadInfo() name={} file={}", name, file);
			if (file.isFile()) {
				info = Utils.readFileToMap(file);
				if (info == null)
					return;
				this.name      = Utils.trimToDefault(info.get(NEWNAME), name);
				this.localName = Utils.trimToDefault(info.get(LOCALNAME), localName);
				this.birth     = Utils.trimToDefault(info.get(BIRTH), birth);
				this.height    = Utils.trimToDefault(info.get(HEIGHT), height);
				this.bodySize  = Utils.trimToDefault(info.get(BODYSIZE), bodySize);
				this.debut     = Utils.trimToDefault(info.get(DEBUT), debut);
				this.favorite  = Boolean.valueOf(info.get(FAVORITE));
				log.trace("loadInfo() {} : {} : {} : {} : {} : {} : {}", name, localName, birth, height, bodySize, debut, favorite);
			}
			else {
				info = new HashMap<>();
			}
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
	
	public String saveInfo(Map<String, String> params) {
		String newname = params.get("newname");
		// actress 이름이 변했고, 파일이 있으면
		if (!StringUtils.equals(name, newname) && getInfoFile().exists()) {
			// info 파일이름 변경
			Utils.renameFile(getInfoFile(), newname);
			// actress의 비디오 파일 이름 변경
			for (Video video : getVideoList()) {
				video.renameOfActress(name, newname);
			}
			// 저장된 info내용 갱신
			name = newname;
		}
		// info 파일에 내용 저장
		Utils.saveFileFromMap(new File(getInfoFile().getParent(), newname + "." + VIDEO.EXT_ACTRESS), params);
		reloadInfo();
		return name;
	}
	
	public void setFavorite(Boolean favorite) {
		this.favorite = favorite;
		loadInfo();
		info.put("favorite", favorite.toString());
		info.put("newname", name);
		saveInfo(info);
	}
}
