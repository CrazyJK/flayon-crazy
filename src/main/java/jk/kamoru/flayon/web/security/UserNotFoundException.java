package jk.kamoru.flayon.web.security;

import jk.kamoru.flayon.FLAYON;
import jk.kamoru.flayon.web.FlayException;

public class UserNotFoundException extends FlayException {

	private static final long serialVersionUID = FLAYON.SERIAL_VERSION_UID;

	public UserNotFoundException(String message) {
		super(message);
	}

	public UserNotFoundException(String message, Throwable cause) {
		super(message, cause);
	}

}
