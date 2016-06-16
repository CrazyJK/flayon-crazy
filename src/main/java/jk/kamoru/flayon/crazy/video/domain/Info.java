package jk.kamoru.flayon.crazy.video.domain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

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
	List<VTag> tags;
	
	public Info(String opus) {
		this(opus, 0, 0, "", new Date(), new ArrayList<VTag>());
	}
}
