package jk.kamoru.flayon.crazy.video;


public class StudioNotFoundException extends VideoException {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private static final String KIND = "StudioNotFound";

	public StudioNotFoundException(String studioName, Throwable cause) {
		super("Studio not found : " + studioName, cause);
		super.setKind(KIND);
	}

	public StudioNotFoundException(String studioName) {
		super("Studio not found : " + studioName);
		super.setKind(KIND);
	}

}
