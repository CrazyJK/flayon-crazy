package jk.kamoru.flayon.crazy.error;

import jk.kamoru.flayon.crazy.CRAZY;

public class ActressNotFoundException extends NotFoundException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;

	public ActressNotFoundException(String actressName, Throwable cause) {
		super("Actress [" + actressName + "] not found", cause, KIND.ActressNotFound);
	}

	public ActressNotFoundException(String actressName) {
		super("Actress [" + actressName + "] not found", KIND.ActressNotFound);
	}

}
