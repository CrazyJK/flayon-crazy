package jk.kamoru.flayon.crazy;

public abstract class CrazyNotFoundException extends CrazyException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;

	public CrazyNotFoundException(String msg, KIND kind) {
		super(msg, kind);
	}

	public CrazyNotFoundException(String msg, Throwable cause, KIND kind) {
		super(msg, cause, kind);
	}

}
