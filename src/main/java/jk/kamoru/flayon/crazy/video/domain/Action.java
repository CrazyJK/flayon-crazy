package jk.kamoru.flayon.crazy.video.domain;

/**Video action
 * @author kamoru
 */
public enum Action {
	/** play video */		PLAY("Play"), 
	/** save overview */	OVERVIEW("Overview"), 
	/** view cover */		COVER("Cover"), 
	/** edit subtitles */	SUBTITLES("Subtitles"), 
	/** remove video */		REMOVE("Remove"),
	/** delete video*/		DELETE("Delete"),
	/** mark rank*/			RANK("Rank");

	private String actionString;
	
	Action(String action) {
		this.actionString = action;
	}
	
	public String toString() {
		return actionString;
	}
}
