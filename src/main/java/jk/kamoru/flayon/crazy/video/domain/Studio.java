package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;
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

	private String name;
	private URL    homepage;
	private String company;

	@JsonIgnore
	private List<Video> videoList;
	@JsonIgnore
	private List<Actress> actressList;

	private boolean loaded;

	private StudioSort sort = StudioSort.NAME;
	
	public Studio() {
		name = "";
		try {
			homepage = new URL("");
		} catch (MalformedURLException e) {
		}
		company = "";
		videoList = new ArrayList<Video>();
		actressList = new ArrayList<Actress>();
	}

	public Studio(String name) {
		this();
		this.name = name;
	}
	
	@Override
	public String toString() {
		return String.format("%s Score %s %s %s",
				name, getScore(), Utils.trimToEmpty(homepage), Utils.trimToEmpty(company));
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
			return this.getVideoList().size() - comp.getVideoList().size();
		case SCORE:
			return this.getScore() - comp.getScore();
		default:
			return Utils.compareTo(this.getName(), comp.getName());
		}
	}

	private void loadInfo() {
		if (!loaded) {
			File file = getInfoFile();
			if (file.isFile()) 
				try {
					Map<String, String> info = Utils.readFileToMap(file);
					name 	 = Utils.trimToDefault(info.get("NEWNAME"), name);
					company  = Utils.trimToDefault(info.get("COMPANY"), company);
					homepage = new URL(StringUtils.trimToEmpty(info.get("HOMEPAGE")));
				} catch (MalformedURLException e) {
					log.warn("malformed url error : {}", e.getMessage());
				}
			log.trace("{} : {} : {}", name, company, homepage);
			loaded = true;
		}
	}
	public void reloadInfo() {
		loaded = false;
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
		return new File(new File(STORAGE_PATHS[0], "_info"), name + "." + VIDEO.EXT_STUDIO);
	}

	public String saveInfo(Map<String, String> params) {
		String newname = params.get("newname");
		// studio 이름이 변했고, 파일이 있으면
		if (!StringUtils.equals(name, newname) && getInfoFile().exists()) {
			// info 파일이름 변경
			Utils.renameFile(getInfoFile(), newname);
			// studio의 비디오 파일 이름 변경
			for (Video video : getVideoList()) {
				video.renameOfStudio(newname);
			}
			// 저장된 info내용 갱신 
			name = newname;
		}
		// info 파일에 내용 저장
		Utils.saveFileFromMap(new File(getInfoFile().getParent(), newname + "." + VIDEO.EXT_STUDIO), params);
		reloadInfo();
		return name;
	}
	
	
}
