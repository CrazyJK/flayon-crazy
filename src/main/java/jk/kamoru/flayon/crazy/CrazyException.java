package jk.kamoru.flayon.crazy;

import jk.kamoru.flayon.FlayOnException;

public class CrazyException extends FlayOnException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;
	
	private static final String KIND = "Crazy";
	
	String kind = KIND;
	
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
		return kind;
	}

	public void setKind(String kind) {
		this.kind = kind;
	}
}
