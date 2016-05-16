package jk.kamoru.flayon.crazy.video;


public class ActressNotFoundException extends VideoException {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	public ActressNotFoundException(String actressName, Throwable cause) {
		super("Actress not found : " + actressName, cause);
	}

	public ActressNotFoundException(String actressName) {
		super("Actress not found : " + actressName);
	}

}
