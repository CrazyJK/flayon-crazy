package jk.kamoru.flayon.web;

import jk.kamoru.flayon.FLAYON;

public class FlayException extends RuntimeException {

	private static final long serialVersionUID = FLAYON.SERIAL_VERSION_UID;

	public FlayException(String message) {
		super(message);
	}

	public FlayException(String message, Throwable cause) {
		super(message, cause);
	}

}
