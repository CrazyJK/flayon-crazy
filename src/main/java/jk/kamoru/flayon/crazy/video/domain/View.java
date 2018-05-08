package jk.kamoru.flayon.crazy.video.domain;

/**view type
 * @author kamoru
 */
public enum View {
	
	/** card type */	Card("Card"), 
	/** box type */		Box("Box"), 
	/** ihover type */	Ihover("ihover"), 
	/** table type */	Table("Table"), 
	/** slide type */	Slide("Slide"), 
	/** large type */	Large("Large"), 
	/** video type */	Video("Video"),
	/** Flay */			Flay("Flay"),
	/** Aperture */		Aperture("Aperture"),
	/** jk */			JK("jk"),
	/** Test */			Test("Test");

	private String desc;
	
	View(String desc) {
		this.desc = desc;
	}
	
	public String getDesc() {
		return desc;
	}

	public String toString() {
		return getDesc();
	}

}
