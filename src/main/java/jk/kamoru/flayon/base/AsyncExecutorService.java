package jk.kamoru.flayon.base;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.annotation.PostConstruct;

/**
 * {@link AsyncExecutorService#getTask() getTask()}의 {@link Runnable}을 실행시킨다
 * @author kamoru
 *
 */
public abstract class AsyncExecutorService {

	/**
	 * Async로 구동할 Task
	 * @return
	 */
	protected abstract Runnable getTask();
	
	@PostConstruct
	public void post() {
		ExecutorService service = Executors.newSingleThreadExecutor();
		service.execute(getTask());
	}
	
}
