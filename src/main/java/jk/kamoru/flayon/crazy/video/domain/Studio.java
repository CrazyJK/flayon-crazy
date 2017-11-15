package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.net.URL;
import java.nio.file.Paths;
import java.util.ArrayList;
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
@EqualsAndHashCode(exclude={"actressList", "videoList"}, callSuper=false)
@Slf4j
@Data
public class Studio {

	@Autowired @JsonIgnore CrazyConfig config;

	public static final String NAME     = "NAME";
	public static final String NEWNAME  = "NEWNAME";
	public static final String HOMEPAGE = "HOMEPAGE";
	public static final String COMPANY  = "COMPANY";
	
	private String name;
	private URL    homepage;
	private String company;

	@JsonIgnore	private List<Video>     videoList;
	@JsonIgnore	private List<Actress> actressList;
	
	private Studio() {
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
				name, CrazyUtils.trimToEmpty(homepage), company, getScore());
	}

	public void addVideo(Video video) {
		if (!videoList.contains(video))
			this.videoList.add(video);		
	}
	
	public void addActress(Actress actress) {
		boolean found = false;
		for (Actress actressInList : actressList) {
			if (VideoUtils.equalsActress(actressInList.getName(), actress.getName())) {
				actressInList = actress;
				found = true;
				break;
			}
		}
		if (!found)
			this.actressList.add(actress);
	}

	public void emptyVideo() {
		videoList.clear();
	}

	public int getScore() {
		int score = 0;
		for (Video video : getVideoList())
			score += video.getScore();
		return score;
	}

	public void loadAdditionalInfo() {
		log.debug("loadInfo : start {}", name);

		File infoFile = getInfoFile();
		if (infoFile.isFile()) {
			Map<String, String> info = CrazyUtils.readFileToMap(infoFile);
			String infoName = info.get(NAME);
			if (StringUtils.isBlank(infoName) || !StringUtils.equals(name, infoName))
				throw new CrazyException("studio [%s] name not equals [%s] in info file [%s]", name, infoName, infoFile);

			name 	 = CrazyUtils.trimToDefault(info.get(NEWNAME), name);
			company  = CrazyUtils.trimToDefault(info.get(COMPANY), company);
			homepage = CrazyUtils.makeURL(info.get(HOMEPAGE));
		}

		log.debug("loadInfo : end {}", toString());
	}

	private File getInfoFile() {
		return Paths.get(config.getStoragePath(), "_info", name + "." + VIDEO.EXT_STUDIO).toFile();
	}

	public void saveInfo(Map<String, String> params) {
		String name = params.get(NAME);
		String newname = params.get(NEWNAME);
		if (StringUtils.isNotBlank(newname) && !StringUtils.equalsIgnoreCase(name, newname)) {
			params.put(NAME, newname);
		}
		CrazyUtils.saveFileFromMap(getInfoFile(), params);
		log.debug("saveInfo : end");
		loadAdditionalInfo();
	}
	
	public void removeVideo(Video video) {
		if (!videoList.remove(video))
			log.warn("this studio[{}] not contains in video[{}]", name, video.getOpus());
	}

}
