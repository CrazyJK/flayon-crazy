package jk.kamoru.flayon.crazy.video.domain;

/**video sort
 * @author kamoru
 */
public enum Sort {

	/** studio sort */			Studio("Studio"), 
	/** opus sort */			Opus("Opus"), 
	/** title sort */			Title("Title"), 
	/** actress name sort */	Actress("Actress"), 
	/** Release date */			Release("Release"),
	/** file modified sort */	Modified("Modified"), 
	/** play count sort */		PlayCount("PlayCount"), 
	/** rank sort */			Rank("Rank"), 
	/** video length sort */	Length("Length"), 
	/** score sort */			Score("Score"),
	/** videoCandidates */		Candidates("Candidates");
	
	private String sortString;
	
	Sort(String sort) {
		this.sortString = sort;
	}
	
	public String getDesc() {
		return sortString;
	}

	public String toString() {
		return getDesc();
	}

}
