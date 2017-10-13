package jk.kamoru.flayon.crazy.video.domain;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jk.kamoru.flayon.crazy.CrazyException;
import lombok.Data;

@Data
public class VTag {

	Integer id;
	String name;
	String description;
	
	@JsonIgnore
	List<Video> videoList;

	public VTag() {
		videoList = new ArrayList<>();
	}

	public VTag(Integer id, String name, String description, List<Video> videoList) {
		super();
		this.id = id;
		this.name = name;
		this.description = description;
		if (videoList == null)
			videoList = new ArrayList<>();
		else
			this.videoList = videoList;
	}
	
	public void addVideo(Video video) {
		if (!videoList.contains(video))
			videoList.add(video);
	}

	public void validation() {
		if (id == null || StringUtils.isBlank(name))
			throw new CrazyException("Fail to valid. id or name is blank " + this);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		VTag other = (VTag) obj;
		if (id == null) {
			if (name != null && name.equals(other.name))
				return true;
			if (other.id != null)
				return false;
			
		} else if (!id.equals(other.id))
			return false;
		return true;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}

}
