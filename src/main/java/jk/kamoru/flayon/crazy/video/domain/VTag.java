package jk.kamoru.flayon.crazy.video.domain;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jk.kamoru.flayon.crazy.CrazyException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class VTag {

	Integer id;
	String name;
	String description;
	
	@JsonIgnore
	List<Video> videoList = new ArrayList<>();

	public void addVideo(Video video) {
		if (!videoList.contains(video))
			videoList.add(video);
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

	public void validation() {
		if (id == null || StringUtils.isBlank(name))
			throw new CrazyException("Fail to valid. id or name is blank " + this);
	}

}
