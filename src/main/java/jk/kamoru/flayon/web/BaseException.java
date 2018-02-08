package jk.kamoru.flayon.web;

import jk.kamoru.flayon.FLAYON;

public class BaseException extends RuntimeException {

	private static final long serialVersionUID = FLAYON.SERIAL_VERSION_UID;

	public BaseException(String message) {
		super(message);
	}

	public BaseException(String message, Throwable cause) {
		super(message, cause);
	}

}
