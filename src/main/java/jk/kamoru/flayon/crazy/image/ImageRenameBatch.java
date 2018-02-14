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

import jk.kamoru.flayon.base.watch.DirectoryWatchServiceAdapter;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class ImageRenameBatch extends DirectoryWatchServiceAdapter {

	private static final String TASKNAME = "Rename Sora picture";
	
	@Autowired CrazyConfig config;

	@PostConstruct
	public void renameSoraPicture() {
		for (String soraPath : config.getSoraPicturesPaths()) {
			try {
				log.info("Start {} : {}", TASKNAME, soraPath);
				Files.walk(Paths.get(soraPath)).forEach(path -> renameImageFile(path));
			} catch (IOException e) {
				throw new ImageException(TASKNAME, e);
			}
		}
	}
	
	@Override
	protected String getTaskName() {
		return TASKNAME;
	}

	@Override
	protected String[] getPath() {
		return config.getSoraPicturesPaths();
	}
	
	@Override
	protected void created(Path path) {
		renameImageFile(path);
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

}
