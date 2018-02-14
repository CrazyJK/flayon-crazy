package jk.kamoru.flayon.base;

import java.io.IOException;
import java.lang.ProcessBuilder.Redirect;

import org.apache.commons.lang3.ArrayUtils;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CommandExecutor {

	/**
	 * execute command by asynchronous
	 * @param command
	 * @param arguments
	 */
	@Async
	public void exec(String command, String... arguments) {
		log.info("exec {}, {}", command, arguments);
		try {
			String[] commands = ArrayUtils.addAll(new String[] {command}, arguments);
			ProcessBuilder builder = new ProcessBuilder(commands);
			builder.redirectOutput(Redirect.INHERIT);
			builder.redirectError(Redirect.INHERIT);
			builder.start();
		} catch (IOException e) {
			log.error("exec error", e);
			throw new BaseException("exec error", e);
		}
	}

}
