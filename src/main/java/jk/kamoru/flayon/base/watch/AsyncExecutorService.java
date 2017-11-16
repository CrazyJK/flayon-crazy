package jk.kamoru.flayon.base.watch;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.springframework.scheduling.annotation.Async;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public abstract class AsyncExecutorService {

	protected abstract Runnable getTask();
	
	/**
	 * async method<br>
	 * <code>@</code>EnableAsync 설정 필요
	 * <pre>
	 *   <code>@</code>SpringBootApplication
	 *   <code>@</code>EnableAsync
	 *   public class FlayOnApplication {
	 * </pre>
	 */
	@Async
	public void start() {
		Runnable task = getTask();
		ExecutorService service = Executors.newSingleThreadExecutor();
		service.submit(task);
		log.info("AsyncExecutorService Start : {}", task.getClass().getName());
	}
	
}
