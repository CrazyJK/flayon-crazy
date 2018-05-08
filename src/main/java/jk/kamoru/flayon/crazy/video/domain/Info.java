package jk.kamoru.flayon.crazy.video.domain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

import jk.kamoru.flayon.crazy.util.CrazyUtils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class Info {
	
	String opus;
	Integer playCount;
	Integer rank;
	String overview;
	Date lastAccess;
	List<VTag> tags = new ArrayList<>();
	
	public Info(String opus) {
		this(opus, 0, 0, "", new Date(), new ArrayList<VTag>());
	}

	public List<VTag> getTags() {
		return tags == null ? new ArrayList<VTag>() : tags;
	}
	
	@Override
	public String toString() {
		return String.format("Info [opus=%s, playCount=%s, rank=%s, lastAccess=%s, overview=%s, tags=%s]", 
				opus, playCount, rank, 
				lastAccess == null ?  "" : VIDEO.DateTimeFormat.format(lastAccess), 
				overview, 
				CrazyUtils.listToSimpleString(tags.stream()
						.map(VTag::getName).collect(Collectors.toList())));
	}
	
}
