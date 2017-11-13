package jk.kamoru.flayon.crazy.video;


public class VideoNotFoundException extends VideoException {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private static final String KIND = "VideoNotFound";

	public VideoNotFoundException(String opus, Throwable cause) {
		super("Video not found : " + opus, cause);
		super.setKind(KIND);
	}

	public VideoNotFoundException(String opus) {
		super("Video not found : " + opus);
		super.setKind(KIND);
	}
	
}
