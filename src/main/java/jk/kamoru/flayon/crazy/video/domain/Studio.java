package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.extern.slf4j.Slf4j;

@Component
@Scope("prototype")
@Data
@EqualsAndHashCode(callSuper=false)
@Slf4j
public class Studio extends CrazyProperties implements Serializable, Comparable<Studio> {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private static final String NEWNAME = "NEWNAME";
	private static final String HOMEPAGE = "HOMEPAGE";
	private static final String COMPANY = "COMPANY";
	
	private String name;
	private URL    homepage;
	private String company;

	@JsonIgnore
	private List<Video> videoList;
	@JsonIgnore
	private List<Actress> actressList;
	@JsonIgnore
	private boolean loaded;
	@JsonIgnore
	private StudioSort sort = StudioSort.NAME;
	
	public Studio() {
		name        = "";
		homepage    = null;
		company     = "";
		videoList   = new ArrayList<Video>();
		actressList = new ArrayList<Actress>();
	}

	public Studio(String name) {
		this();
		this.name = name;
	}
	
	@Override
	public String toString() {
		return String.format("%s H:%s C:%s S:%s",
				name, Utils.trimToEmpty(homepage), company, getScore());
	}

	public void addVideo(Video video) {
		if(!videoList.contains(video))
			this.videoList.add(video);		
	}
	
	public void addActress(Actress actress) {
		boolean found = false;
		for(Actress actressInList : this.actressList) {
			if(actressInList.getName().equalsIgnoreCase(actress.getName())) {
				actressInList = actress;
				found = true;
				break;
			}
		}
		if(!found)
			this.actressList.add(actress);
	}
	
	public URL getHomepage() {
		loadInfo();
		return homepage;
	}
	public String getCompany() {
		loadInfo();
		return company;
	}

	@Override
	public int compareTo(Studio comp) {
		switch (sort) {
		case NAME:
			return Utils.compareTo(this.getName(), comp.getName());
		case HOMEPAGE:
			return Utils.compareTo(this.getHomepage(), comp.getHomepage());
		case COMPANY:
			return Utils.compareTo(this.getCompany(), comp.getCompany());
		case VIDEO:
			return Utils.compareTo(this.getVideoList().size(), comp.getVideoList().size());
		case SCORE:
			return Utils.compareTo(this.getScore(), comp.getScore());
		default:
			return Utils.compareTo(this.getName(), comp.getName());
		}
	}

	private void loadInfo() {
		if (!loaded) {
			if (log.isDebugEnabled())
				log.debug("loadInfo : start {}", name);
			File file = getInfoFile();
			if (log.isDebugEnabled())
				log.debug("loadInfo : file {}", file);
			if (file.isFile()) {
				Map<String, String> info = Utils.readFileToMap(file);
				name 	 = Utils.trimToDefault(info.get(NEWNAME), name);
				company  = Utils.trimToDefault(info.get(COMPANY), company);
				homepage = makeURL(info.get(HOMEPAGE));
			}
			loaded = true;
			if (log.isDebugEnabled())
				log.debug("loadInfo : end {}", toString());
		}
	}
	public void reloadInfo() {
		loaded = false;
		loadInfo();
	}

	public void emptyVideo() {
		videoList.clear();
	}

	/**
	 * sum of video scoring in studio
	 * @return
	 */
	public int getScore() {
		int score = 0;
		for (Video video : getVideoList())
			score += video.getScore();
		return score;
	}

	private File getInfoFile() {
		return Paths.get(STORAGE_PATHS[0], "_info", name + "." + VIDEO.EXT_STUDIO).toFile();
	}

	private File getInfoFile(String name) {
		return Paths.get(STORAGE_PATHS[0], "_info", name + "." + VIDEO.EXT_STUDIO).toFile();
	}

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
					log.debug("saveInfo : save as file {}", getInfoFile(newname));
				Utils.saveFileFromMap(getInfoFile(newname), params);
			}

			// studio의 비디오 파일 이름 변경
			if (log.isDebugEnabled())
				log.debug("saveInfo : rename video {} -> {}", name, newname);
			for (Video video : getVideoList())
				video.renameOfStudio(newname);

			// 새이름 업데이트 
			name = newname;
		}

		if (log.isDebugEnabled())
			log.debug("saveInfo : end");
		
		reloadInfo();
		return name;
	}
	
	private URL makeURL(String string) {
		String str = StringUtils.trimToEmpty(string);
		if (StringUtils.isNotEmpty(str))
			if (!str.startsWith("http"))
				str = "http://" + str;
		try {
			return new URL(str);
		} catch (MalformedURLException e) {
			if (log.isDebugEnabled() && StringUtils.isNotEmpty(str))
				log.warn("Malformed URL {}", e.getMessage());
			return null;
		}
	}
	
}
