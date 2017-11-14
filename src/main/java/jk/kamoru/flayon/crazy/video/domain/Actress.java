package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import jk.kamoru.flayon.crazy.util.VideoUtils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.extern.slf4j.Slf4j;

@Component
@Scope("prototype")
@EqualsAndHashCode(exclude={"studioList", "videoList"}, callSuper=false)
@Data
@Slf4j
public class Actress {

	@Autowired CrazyProperties crazyProperties;
	
	private static final String NEWNAME = "NEWNAME";
	private static final String FAVORITE = "FAVORITE";
	private static final String LOCALNAME = "LOCALNAME";
	private static final String BIRTH = "BIRTH";
	private static final String BODYSIZE = "BODYSIZE";
	private static final String HEIGHT = "HEIGHT";
	private static final String DEBUT = "DEBUT";
	private static final String COMMENT = "COMMENT";
	
	private String name;
	private Boolean favorite;
	@JsonIgnore private String localName;
	@JsonIgnore private String birth;
	@JsonIgnore private String bodySize;
	@JsonIgnore private String debut;
	@JsonIgnore private String height;
	@JsonIgnore private String age;
	@JsonIgnore private String comment;
	
	@JsonIgnore private File image;
	
	@JsonIgnore private List<Studio> studioList;
	@JsonIgnore private List<Video>   videoList;
	@JsonIgnore private Map<String, String> info;

	/** is loaded actress infomation */
	@JsonIgnore private boolean loaded;

	public Actress() {
		name = "";
		localName = "";
		birth = "";
		bodySize = "";
		debut = "";
		height = "";
		age = "";
		comment = "";
		favorite = new Boolean(false);
		studioList = new ArrayList<Studio>();
		videoList = new ArrayList<Video>();
	}
	public Actress(String name) {
		this();
		this.name = name;
	}
	
	@JsonIgnore
	public boolean isExistImage() {
		return image != null;
	}
	
	@Override
	public String toString() {
		return String.format("%s%s %s %s %s %s %ss %sv",
						name, StringUtils.isEmpty(localName) ? "" : "("+localName+")", birth, bodySize, debut, StringUtils.isEmpty(height) ? "" : height + "cm", getScore(), videoList.size());
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
	public String getComment() {
		loadInfo();
		return comment;
	}
	public Boolean getFavorite() {
		loadInfo();
		return favorite;
	}
	public boolean setFavorite(Boolean favorite) {
		this.favorite = favorite;
		loadInfo();
		info.put("favorite", favorite.toString());
		info.put("newname", name);
		saveInfo(info);
		return this.favorite;
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
	@JsonIgnore
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
	@JsonIgnore
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
		try {
			if (!loaded) {
				if (log.isDebugEnabled())
					log.debug("loadInfo : start [{}]", name);
				File file = getInfoFile();
				if (log.isDebugEnabled())
					log.debug("loadInfo : file {}", file);
				if (file.isFile()) {
					info = CrazyUtils.readFileToMap(file);
					this.name      = CrazyUtils.trimToDefault(info.get(NEWNAME), name);
					this.localName = CrazyUtils.trimToDefault(info.get(LOCALNAME), localName);
					this.birth     = CrazyUtils.trimToDefault(info.get(BIRTH), birth);
					this.height    = CrazyUtils.trimToDefault(info.get(HEIGHT), height);
					this.bodySize  = CrazyUtils.trimToDefault(info.get(BODYSIZE), bodySize);
					this.debut     = CrazyUtils.trimToDefault(info.get(DEBUT), debut);
					this.favorite  = Boolean.valueOf(info.get(FAVORITE));
					this.comment   = CrazyUtils.trimToDefault(info.get(COMMENT), comment);
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
				// image
				File _image = new File(getInfoFile().getParentFile(), name + ".jpg");
				if (_image.exists()) {
					image = _image;
				}
				
				loaded = true;
				if (log.isDebugEnabled())
					log.debug("loadInfo : end {}", toString());
			}
		} catch(Throwable e) {
			log.error("loadInfo error : " + name, e);
			throw new CrazyException("loadInfo error : " + name, e);
		}
	}

	private File getInfoFile() {
		try {
			return Paths.get(crazyProperties.getSTORAGE_PATH(), "_info", name + "." + VIDEO.EXT_ACTRESS).toFile();
		} catch (NullPointerException e) {
			throw new CrazyException("Why name=[" + name + "]", e);
		}
	}

	private File getInfoFile(String name) {
		return Paths.get(crazyProperties.getSTORAGE_PATH(), "_info", name + "." + VIDEO.EXT_ACTRESS).toFile();
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
			CrazyUtils.saveFileFromMap(getInfoFile(), params);
		}
		// 이름이 변했으면
		else {
			if (getInfoFile(newname).exists()) { // 이미 같은 새이름의 파일이 있으면, No Action
				
			}
			else { // 타깃 없으면, 타깃에 저장
				// info 파일에 내용 저장
				if (log.isDebugEnabled())
					log.debug("saveInfo : save file {}", getInfoFile(newname));
				CrazyUtils.saveFileFromMap(getInfoFile(newname), params);
			}
			
			// actress의 비디오 파일 이름 변경
//			if (log.isDebugEnabled())
//				log.debug("saveInfo : rename video {} -> {}", name, newname);
//			for (Video video : getVideoList())
//				video.renameOfActress(name, newname);

			// 새이름 업데이트 
			name = newname;
		}

		if (log.isDebugEnabled())
			log.debug("saveInfo : end");

		reloadInfo();
		return name;
	}
	public void removeVideo(Video video) {
		if (videoList.contains(video))
			if (!videoList.remove(video))
				log.warn("fail to remove {}", video);
	}
	
}
