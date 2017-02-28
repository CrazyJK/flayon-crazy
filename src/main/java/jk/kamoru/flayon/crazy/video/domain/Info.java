package jk.kamoru.flayon.crazy.video.domain;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class Info {
	
	public static final SimpleDateFormat format = new SimpleDateFormat(VIDEO.DATE_TIME_PATTERN);
	
	String opus;
	Integer playCount;
	Integer rank;
	String overview;
	Date lastAccess;
	List<VTag> tags = new ArrayList<>();
	
	public List<VTag> getTags() {
		if (tags == null)
			return new ArrayList<VTag>();
		return tags;
	}
	
	public Info(String opus) {
		this(opus, 0, 0, "", new Date(), new ArrayList<VTag>());
	}

	@Override
	public String toString() {
		return String.format("Info [opus=%s, playCount=%s, rank=%s, lastAccess=%s, overview=%s, tags=%s]", 
				opus, playCount, rank, format.format(lastAccess), overview, VideoUtils.getTagNames(tags));
	}
	
	
}
