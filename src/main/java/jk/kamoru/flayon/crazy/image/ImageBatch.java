package jk.kamoru.flayon.crazy.image;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import javax.annotation.PostConstruct;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jk.kamoru.flayon.base.watch.AsyncExecutorService;
import jk.kamoru.flayon.base.watch.DirectoryWatcher;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.error.ImageException;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class ImageBatch extends AsyncExecutorService{

	@Autowired CrazyConfig config;

	@PostConstruct
	public synchronized void renameSoraPicture() {
		log.info("Rename Sora picture Start");
		for (String soraPath : config.getSoraPicturesPaths()) {
			try {
				Files.walk(Paths.get(soraPath)).forEach(path -> renameImageFile(path));
			} catch (IOException e) {
				throw new ImageException("sora path walk error", e);
			}
		}
		log.info("Rename Sora picture End");
	}
	
	private void renameImageFile(Path path) {
		File file = path.toFile();
		if (file.isDirectory())
			return;
		String folderName = file.getParentFile().getName();
		if (StringUtils.startsWith(file.getName(), folderName))
			return;
		Path renamed = CrazyUtils.renameFile(path, folderName + "-" + file.lastModified());
		log.info("rename {} -> {}", path, renamed);
	}

	@Override
	protected Runnable getTask() {
		return new DirectoryWatcher("Sora rename", config.getSoraPicturesPaths()) {

			@Override
			protected void createEvent(Path path) {
				renameImageFile(path);
			}
		};
	}
	
}
