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

import jk.kamoru.flayon.crazy.CrazyConfig;
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
@Slf4j
@Data
public class Actress {

	@Autowired @JsonIgnore CrazyConfig config;
	
	public static final String FAVORITE  = "FAVORITE";
	public static final String NAME      = "NAME";
	public static final String NEWNAME   = "NEWNAME";
	public static final String LOCALNAME = "LOCALNAME";
	public static final String BIRTH     = "BIRTH";
	public static final String BODYSIZE  = "BODYSIZE";
	public static final String HEIGHT    = "HEIGHT";
	public static final String DEBUT     = "DEBUT";
	public static final String COMMENT   = "COMMENT";
	
	private String name;
	private Boolean favorite;
	private String localName;
	private String birth;
	private String bodySize;
	private String debut;
	private String height;
	private String age;
	private String comment;
	
	@JsonIgnore private File image;
	
	@JsonIgnore private List<Video>   videoList;
	@JsonIgnore private List<Studio> studioList;

	private Actress() {
		localName  = "";
		birth      = "";
		bodySize   = "";
		debut      = "";
		height     = "";
		age        = "";
		comment    = "";
		favorite   = new Boolean(false);
		videoList  = new ArrayList<Video>();
		studioList = new ArrayList<Studio>();
	}
	
	public Actress(String name) {
		this();
		this.name = name;
	}
	
	@Override
	public String toString() {
		return String.format("%s%s %s %s %s %s %ss %sv",
						name, StringUtils.isEmpty(localName) ? "" : "("+localName+")", birth, bodySize, debut, StringUtils.isEmpty(height) ? "" : height + "cm", getScore(), videoList.size());
	}
	
	public boolean contains(String actressName) {
		return VideoUtils.equalsActress(name, actressName);
	}

	public boolean setFavorite(Boolean favorite) {
		this.favorite = favorite;
		saveInfo();
		return this.favorite;
	}

	public void addVideo(Video video) {
		if (!videoList.contains(video))
			videoList.add(video);
	}
	
	public void addStudio(Studio studio) {
		if (!studioList.contains(studio))
			studioList.add(studio);
	}
	
	public void emptyVideo() {
		videoList.clear();
	}

	public int getScore() {
		int score  = 0;
		for (Video video : getVideoList())
			score += video.getScore();
		return score;
	}
	
	public void loadAdditionalInfo() {
		log.debug("loadInfo : start [{}]", name);
		File infoFile = getInfoFile();
		File infoPath = infoFile.getParentFile();
		
		if (infoFile.isFile()) {
			Map<String, String>	info = CrazyUtils.readFileToMap(infoFile);
			String infoName = info.get(NAME);
			if (StringUtils.isBlank(infoName) || !StringUtils.equals(name, infoName))
				throw new CrazyException("actress [%s] name not equals [%s] in info file [%s]", name, infoName, infoFile);

			localName = CrazyUtils.trimToDefault(info.get(LOCALNAME), localName);
			birth     = CrazyUtils.trimToDefault(info.get(BIRTH),     birth);
			height    = CrazyUtils.trimToDefault(info.get(HEIGHT),    height);
			bodySize  = CrazyUtils.trimToDefault(info.get(BODYSIZE),  bodySize);
			debut     = CrazyUtils.trimToDefault(info.get(DEBUT),     debut);
			comment   = CrazyUtils.trimToDefault(info.get(COMMENT),   comment);
			favorite  = Boolean.valueOf(info.get(FAVORITE));
			if (StringUtils.isNotEmpty(birth))
				try {
					Calendar cal = Calendar.getInstance();
					int CurrYear = cal.get(Calendar.YEAR);
					int birthYear = Integer.parseInt(birth.substring(0, 4));
					age = String.valueOf(CurrYear - birthYear + 1);
				} catch(Exception e) {
					log.error("fail to calc age", e);
				}
		}
		
		// image
		File imageFile = new File(infoPath, name + ".jpg");
		if (imageFile.exists())
			image = imageFile;
		
		log.debug("loadInfo : end {}", toString());
	}

	private File getInfoFile() {
		return Paths.get(config.getStoragePath(), "_info", name + "." + VIDEO.EXT_ACTRESS).toFile();
	}
	
	private void saveInfo() {
		Map<String, String> data = new HashMap<>();
		data.put(NAME, name);
		data.put(LOCALNAME, localName);
		data.put(BIRTH, birth);
		data.put(HEIGHT, height);
		data.put(BODYSIZE, bodySize);
		data.put(DEBUT, debut);
		data.put(COMMENT, comment);
		data.put(FAVORITE, favorite.toString());
		saveInfo(data);
	}

	public void saveInfo(Map<String, String> params) {
		// check name, newname
		String name = params.get(NAME);
		String newname = params.get(NEWNAME);
		if (StringUtils.isNotBlank(newname) && !StringUtils.equalsIgnoreCase(name, newname)) {
			params.put(NAME, newname);
		}
		CrazyUtils.saveFileFromMap(getInfoFile(), params);
		log.info("saveInfo : {}", params);
		loadAdditionalInfo();
	}
	
	public void removeVideo(Video video) {
		if (!videoList.remove(video))
			log.warn("this actress[{}] not contains in video[{}]", name, video.getOpus());
	}

}
