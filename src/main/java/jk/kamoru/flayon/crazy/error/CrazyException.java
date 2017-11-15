package jk.kamoru.flayon.crazy.error;

import jk.kamoru.flayon.crazy.CRAZY;

public class CrazyException extends RuntimeException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;
	
	private KIND kind = KIND.Crazy;
	
	public CrazyException(String message, Throwable cause, KIND kind) {
		super(message, cause);
		this.kind = kind;
	}
	
	public CrazyException(String message, Throwable cause) {
		this(message, cause, KIND.Crazy);
	}

	public CrazyException(String message, KIND kind) {
		super(message);
		this.kind = kind;
	}
	
	public CrazyException(String message) {
		this(message, KIND.Crazy);
	}

	public CrazyException(String format, Object...params) {
		this(String.format(format, params), KIND.Crazy);
	}
	
	public KIND getKind() {
		return kind;
	}
	
	public static enum KIND {
		Crazy, Video, Image,
		VideoNotFound, StudioNotFound, ActressNotFound, ImageNotFound;
	}
}
