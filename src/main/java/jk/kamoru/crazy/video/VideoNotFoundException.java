package jk.kamoru.crazy.video;


public class VideoNotFoundException extends VideoException {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	public VideoNotFoundException(String opus, Throwable cause) {
		super("Video not found : " + opus, cause);
	}

	public VideoNotFoundException(String opus) {
		super("Video not found : " + opus);
	}
	
}
