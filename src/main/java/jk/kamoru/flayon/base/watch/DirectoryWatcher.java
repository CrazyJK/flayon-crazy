package jk.kamoru.flayon.base.watch;

import static java.nio.file.StandardWatchEventKinds.ENTRY_CREATE;
import static java.nio.file.StandardWatchEventKinds.ENTRY_DELETE;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.WatchEvent;
import java.nio.file.WatchEvent.Kind;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.ArrayUtils;

import jk.kamoru.flayon.base.error.BaseException;
import lombok.extern.slf4j.Slf4j;

/**
 * Directory watcher<br>
 * <pre>
 * about Exception, user limit of inotify watches reached
 * Case Ubuntu
 * 1. Add the following line to a new file under /etc/sysctl.d/ directory: 
 *   fs.inotify.max_user_watches = 524288
 * 2. read README in /etc/sysctl.d/
 *   sudo service procps start
 * @author kamoru
 *
 */
@Slf4j
public class DirectoryWatcher implements Runnable {

	private WatchService watcher;
	private Map<WatchKey, Path> keys;
	private String[] paths;
	
	public DirectoryWatcher(String[] paths) {
		this.paths = paths;
		log.info("DirectoryWatcher init : " + ArrayUtils.toString(paths));
	}
	
	@Override
	public void run() {
		try {
			watcher = FileSystems.getDefault().newWatchService();
			keys = new HashMap<>();
			for (String path : paths) {
				walkAndRegisterDirectories(Paths.get(path));
			}
			processEvents();
		} catch (IOException | InterruptedException e) {
			throw new BaseException("Fail to watcher run", e);
		}
	}

	/**
	 * Register the given directory, and all its sub-directories, with the WatchService.
	 * @throws IOException 
	 */
	private void walkAndRegisterDirectories(final Path start) throws IOException {
		// register directory and sub-directories
		Files.walkFileTree(start, new SimpleFileVisitor<Path>() {
			@Override
			public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
				registerDirectory(dir);
				return FileVisitResult.CONTINUE;
			}
		});
	}

	/**
	 * Register the given directory with the WatchService; 
	 * This function will be called by FileVisitor
	 * @throws IOException 
	 */
	private void registerDirectory(Path dir) throws IOException {
		WatchKey key = dir.register(watcher, ENTRY_CREATE, ENTRY_DELETE);
		keys.put(key, dir);
		log.info("Watch directory : " + dir);
	}

	private void processEvents() throws InterruptedException, IOException {
		for (;;) {
			// wait for key to be signalled
			WatchKey key = watcher.take();

			Path dir = keys.get(key);
			if (dir == null) {
				log.error("WatchKey not recognized!!");
				continue;
			}

			for (WatchEvent<?> event : key.pollEvents()) {
				@SuppressWarnings("unchecked")
				WatchEvent<Path> pathEvent = (WatchEvent<Path>) event;
				Kind<Path> kind = pathEvent.kind();
				Path file = pathEvent.context();
				Path child = dir.resolve(file);

				// print out event
				log.info("{}: {}", kind.name(), child);

				// if directory is created, and watching recursively, then register it and its sub-directories
				if (kind == ENTRY_CREATE)
					if (Files.isDirectory(child))
						walkAndRegisterDirectories(child);
			}

			// reset key and remove from set if directory no longer accessible
			boolean valid = key.reset();
			if (!valid) {
				keys.remove(key);

				// all directories are inaccessible
				if (keys.isEmpty()) {
					log.warn("all directories are inaccessible");
					break;
				}
			}
		}
	}

}
