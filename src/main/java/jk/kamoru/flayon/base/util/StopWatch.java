package jk.kamoru.flayon.base.util;

import java.text.NumberFormat;
import java.util.LinkedList;
import java.util.List;

/**
 * org.springframework.util.StopWatch override<br>
 * add {@link #stop(String)}
 * @author kamoru
 * @see {@link org.springframework.util.StopWatch}
 */
public class StopWatch {

	private final String id;
	private final List<TaskInfo> taskList = new LinkedList<>();
	private long startTimeMillis;
	private boolean running;
	private String currentTaskName;
	private TaskInfo lastTaskInfo;
	private int taskCount;
	private long totalTimeMillis;

	static NumberFormat nf = NumberFormat.getNumberInstance();
	static NumberFormat pf = NumberFormat.getPercentInstance();

	static {
		nf.setMinimumIntegerDigits(5);
		nf.setGroupingUsed(false);
		pf.setMinimumIntegerDigits(3);
		pf.setGroupingUsed(false);
	}
	
	public StopWatch() {
		this("");
	}

	public StopWatch(String id) {
		this.id = id;
	}

	public String getId() {
		return this.id;
	}

	public void start() throws IllegalStateException {
		start("");
	}

	public void start(String taskName) throws IllegalStateException {
		if (this.running) {
			throw new IllegalStateException("Can't start StopWatch: it's already running");
		}
		this.running = true;
		this.currentTaskName = taskName;
		this.startTimeMillis = System.currentTimeMillis();
	}

	public void stop(String taskName) throws IllegalStateException {
		this.currentTaskName = taskName;
		stop();
	}
	
	public void stop() throws IllegalStateException {
		if (!this.running) {
			throw new IllegalStateException("Can't stop StopWatch: it's not running");
		}
		long lastTime = System.currentTimeMillis() - this.startTimeMillis;
		this.totalTimeMillis += lastTime;
		this.lastTaskInfo = new TaskInfo(this.currentTaskName, lastTime);
		this.taskList.add(lastTaskInfo);
		++this.taskCount;
		this.running = false;
		this.currentTaskName = null;
	}

	public boolean isRunning() {
		return this.running;
	}

	public String currentTaskName() {
		return this.currentTaskName;
	}

	public long getLastTaskTimeMillis() throws IllegalStateException {
		if (this.lastTaskInfo == null) {
			throw new IllegalStateException("No tasks run: can't get last task interval");
		}
		return this.lastTaskInfo.getTimeMillis();
	}

	public String getLastTaskName() throws IllegalStateException {
		if (this.lastTaskInfo == null) {
			throw new IllegalStateException("No tasks run: can't get last task name");
		}
		return this.lastTaskInfo.getTaskName();
	}

	public TaskInfo getLastTaskInfo() throws IllegalStateException {
		if (this.lastTaskInfo == null) {
			throw new IllegalStateException("No tasks run: can't get last task info");
		}
		return this.lastTaskInfo;
	}

	public long getTotalTimeMillis() {
		return this.totalTimeMillis;
	}

	public double getTotalTimeSeconds() {
		return this.totalTimeMillis / 1000.0;
	}

	public int getTaskCount() {
		return this.taskCount;
	}

	public List<TaskInfo> getTaskInfo() {
		return this.taskList;
	}

	public String shortSummary() {
		return getId() + ": running time = " + getTotalTimeMillis() + " ms";
	}

	public String prettyPrint() {
		StringBuilder sb = new StringBuilder(shortSummary());
		sb.append('\n');
		sb.append("---------------------------------------------------\n");
		sb.append("ms     %     Task name\n");
		sb.append("---------------------------------------------------\n");
		for (TaskInfo task : getTaskInfo()) {
			sb.append(nf.format(task.getTimeMillis())).append("  ");
			sb.append(pf.format(task.getTimeSeconds() / getTotalTimeSeconds())).append("  ");
			sb.append(task.getTaskName()).append("\n");
		}
		return sb.toString();
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder(shortSummary());
		for (TaskInfo task : getTaskInfo()) {
			long percent = Math.round((100.0 * task.getTimeSeconds()) / getTotalTimeSeconds());
			sb.append("; ['")
				.append(task.getTaskName()).append("' ")
				.append(task.getTimeMillis()).append("ms, ")
				.append(percent).append("%]");
		}
		return sb.toString();
	}


	public static final class TaskInfo {

		private final String taskName;
		private final long timeMillis;

		TaskInfo(String taskName, long timeMillis) {
			this.taskName = taskName;
			this.timeMillis = timeMillis;
		}

		public String getTaskName() {
			return this.taskName;
		}

		public long getTimeMillis() {
			return this.timeMillis;
		}

		public double getTimeSeconds() {
			return (this.timeMillis / 1000.0);
		}
	}

}
