package jk.kamoru.crazy.video.domain;

/**video sort
 * @author kamoru
 */
public enum Sort {

	/** studio sort */
	S("Studio"), 
	/** opus sort */
	O("Opus"), 
	/** title sort */
	T("Title"), 
	/** actress name sort */
	A("Actress"), 
	/** Release date */
	D("Release"),
	/** file modified date sort */
	M("Modified"), 
	/** play count sort */
	P("PlayCount"), 
	/** rank sort */
	R("Rank"), 
	/** video length sort */
	L("Length"), 
	/** score sort */
	SC("Score"),
	/** videoCandidates */
	VC("VideoCandidates");
	
	private String sortString;
	
	Sort(String sort) {
		this.sortString = sort;
	}
	
	public String toString() {
		return sortString;
	}

	public String getDesc() {
		return sortString;
	}
}
