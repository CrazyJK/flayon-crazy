package jk.kamoru.flayon.base.watch;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.annotation.PostConstruct;

import lombok.extern.slf4j.Slf4j;

/**
 * {@link AsyncExecutorService#getTask() getTask()}의 {@link Runnable}을 실행시킨다
 * @author kamoru
 *
 */
@Slf4j
public abstract class AsyncExecutorService {

	/**
	 * Async로 구동할 Task
	 * @return
	 */
	protected abstract Runnable getTask();
	
	@PostConstruct
	public void start() {
		Runnable task = getTask();
		ExecutorService service = Executors.newSingleThreadExecutor();
		service.execute(task);
		log.info("AsyncExecutorService Start : {}", task.getClass().getName());
	}
	
}
