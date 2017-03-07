package jk.kamoru.flayon.base.watch;

import static java.nio.file.StandardWatchEventKinds.ENTRY_CREATE;
import static java.nio.file.StandardWatchEventKinds.ENTRY_DELETE;
import static java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.WatchEvent;
import java.nio.file.WatchEvent.Kind;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.util.concurrent.Future;

import javax.annotation.PostConstruct;

import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;

import lombok.extern.slf4j.Slf4j;

/**
 * async method<br>
 * <code>@</code>EnableAsync 설정 필요
 * <pre>
 *   <code>@</code>SpringBootApplication
 *   <code>@</code>EnableAsync
 *   public class FlayOnApplication {
 *   ...
 *   <code>@</code>Bean MethodExecutionBeanPostProcessor 설정필! 
 * </pre>
 * @author kamoru
 *
 */
@Slf4j
public abstract class SimpleWatchDirectory {

	protected abstract String getPath();
	
	@Async
	public Future<Object> start() throws IOException {
		WatchService watcher = FileSystems.getDefault().newWatchService();
		Path path = Paths.get(getPath());
		path.register(watcher, ENTRY_CREATE, ENTRY_DELETE, ENTRY_MODIFY);
		log.info("Start watch service : {}", path.toAbsolutePath());
		
		while (true) {
			WatchKey key = null;
			try {
				key = watcher.take();
			} catch (InterruptedException e) {
				return new AsyncResult<Object>(e);
			}
			
			for (WatchEvent<?> _event : key.pollEvents()) {
				Kind<?> kind = _event.kind();

				@SuppressWarnings("unchecked")
				WatchEvent<Path> event = (WatchEvent<Path>) _event;
				Path filename = event.context();
				log.info("{} : {}", kind.name(), filename);
			}
			if (!key.reset()) {
				break;
			}
		}
		return new AsyncResult<Object>(path);
	}

}
