package jk.kamoru.crazy;

import jk.kamoru.flayon.boot.error.FlayOnException;

public class CrazyException extends FlayOnException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;
	
	private static final String KIND = "Crazy";
	
	public CrazyException(String message, Throwable cause) {
		super(message, cause);
	}

	public CrazyException(String message) {
		super(message);
	}

	public CrazyException(Throwable cause) {
		super(cause);
	}

	public String getKind() {
		return KIND;
	}

}
