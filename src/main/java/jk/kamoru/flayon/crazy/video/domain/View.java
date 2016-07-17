package jk.kamoru.flayon.crazy.video.domain;

/**view type
 * @author kamoru
 */
public enum View {
	
	/** card type */
	C("Card"), 
	/** box type */
	B("Box"), 
	/** ihover type */
	IH("ihover"), 
	/** table type */
	T("Table"), 
	/** slide type */
	S("Slide"), 
	/** large type */
	L("Large"), 
	/** video type */
	V("Video"),
	/** Flay */
	F("Flay"),
	/** Aperture */
	A("Aperture"),
	/** Test */
	Test("Test");
	
	private String desc;
	
	View(String desc) {
		this.desc = desc;
	}
	
	public String toString() {
		return desc;
	}

	public String getDesc() {
		return desc;
	}

}
