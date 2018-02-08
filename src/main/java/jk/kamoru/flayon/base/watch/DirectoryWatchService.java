package jk.kamoru.flayon.base.watch;

import java.nio.file.Path;

import jk.kamoru.flayon.base.AsyncExecutorService;

/**<pre>
 * Abstract Directory watch service
 * can override, if need
 * {@link #created(Path)} 
 * {@link #modified(Path)} 
 * {@link #deleted(Path)} 
 * @author kamoru
 */
public abstract class DirectoryWatchService extends AsyncExecutorService {

	protected abstract String getTaskName();
	protected abstract String[] getPath();

	protected void created(Path path) {}
	protected void deleted(Path path) {}
	protected void modified(Path path) {}

	@Override
	protected Runnable getTask() {
		return new DirectoryWatcher(getTaskName(), getPath()) {

			@Override
			protected void createEvent(Path path) {
				created(path);
			}

			@Override
			protected void deleteEvent(Path path) {
				deleted(path);
			}

			@Override
			protected void modifyEvent(Path path) {
				modified(path);
			}

		};
	}

}
