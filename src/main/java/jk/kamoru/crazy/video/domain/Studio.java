package jk.kamoru.crazy.video.domain;

import java.io.File;
import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import jk.kamoru.crazy.CrazyProperties;
import jk.kamoru.crazy.Utils;
import jk.kamoru.crazy.video.VIDEO;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.extern.slf4j.Slf4j;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

@Component
@Scope("prototype")
@Data
@EqualsAndHashCode(callSuper=false)
@Slf4j
@XmlRootElement(name = "studio", namespace = "http://www.w3.org/2001/XMLSchema-instance")
@XmlAccessorType(XmlAccessType.FIELD)
public class Studio extends CrazyProperties implements Serializable, Comparable<Studio> {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private String name;
	private URL    homepage;
	private String company;

	@XmlTransient
	private List<Video> videoList;
	@XmlTransient
	private List<Actress> actressList;

	private boolean loaded;

	private StudioSort sort = StudioSort.NAME;
	
	public Studio() {
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
			return Utils.compareToIgnoreCase(this.getName(), comp.getName());
		case HOMEPAGE:
			return Utils.compareTo(this.getHomepage(), comp.getHomepage());
		case COMPANY:
			return Utils.compareToIgnoreCase(this.getCompany(), comp.getCompany());
		case VIDEO:
			return this.getVideoList().size() - comp.getVideoList().size();
		case SCORE:
			return this.getScore() - comp.getScore();
		default:
			return Utils.compareToIgnoreCase(this.getName(), comp.getName());
		}
	}

	private void loadInfo() {
		if (!loaded) {
			File file = new File(new File(STORAGE_PATHS[0], "_info"), name + "." + VIDEO.EXT_STUDIO);
			if (file.isFile())
				try {
					Map<String, String> info = Utils.readFileToMap(file);
					this.company = info.get("COMPANY");
					this.homepage = new URL(info.get("HOMEPAGE"));
				} catch (MalformedURLException e) {
					log.warn("malformed url error : {}", e.getMessage());
				}
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
	
	
}
