package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.base.util.IOUtils;
import jk.kamoru.flayon.base.watch.DirectoryWatchService;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.CrazyException;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class FileMoveService extends DirectoryWatchService {

	private static final String TASKNAME = "File Move";
	
	@Autowired CrazyConfig config;

	Map<String, MoveInfo> infoMap = new HashMap<>();
	String[] watchPaths;
	boolean loaded = false;
	
	@PostConstruct
	public void load() {
		initWatchPath();
		for (String src : watchPaths) {
			try {
				Files.walk(Paths.get(src)).forEach(path -> move(path));
			} catch (IOException e) {
				new CrazyException(TASKNAME + " walk fail", e);
			}
		}
	}
	
	@Override
	protected String getTaskName() {
		return TASKNAME;
	}

	@Override
	protected String[] getPath() {
		initWatchPath();
		return watchPaths;
	}

	@Override
	public void created(Path path) {
		move(path);
	}

	private synchronized void initWatchPath() {
		if (loaded)
			return;
		
		String[] moveFilePaths = config.getMoveFilePaths();

		// validation
		if (moveFilePaths == null || moveFilePaths.length == 0) { // 설정이 안됬거나
			log.error("PATH_MOVE_FILE is not set");
			return;
		}
		else if (moveFilePaths.length % 3 != 0) { // 3배수가 아니면
			log.error("PATH length is not 3 multiple", Arrays.toString(moveFilePaths));
			return;
		}
	
		List<String> srcFolders = new ArrayList<>();
		for (int i = 0; i < moveFilePaths.length;) {
			String suffix = moveFilePaths[i++].toUpperCase();
			File  srcPath = new File(moveFilePaths[i++]);
			File destPath = new File(moveFilePaths[i++]);

			if (!srcPath.isDirectory() || !destPath.isDirectory()) {
				continue;
			}
			
			srcFolders.add(srcPath.getAbsolutePath());
			infoMap.put(suffix, new MoveInfo(suffix, srcPath, destPath));
			log.info("{} : [{}] {} -> {}", TASKNAME, suffix, srcPath, destPath);
		}
		
		watchPaths = srcFolders.stream().distinct().collect(Collectors.toList()).toArray(new String[] {});
		loaded = true;
	}

	private void move(Path path) {
		File file = path.toFile();
		try {
			if (file.isDirectory())
				return;
			
			String suffix = IOUtils.getSuffix(file).toUpperCase();
			MoveInfo moveInfo = infoMap.get(suffix);
	
			if (moveInfo != null) {
				FileUtils.moveFileToDirectory(file, moveInfo.getDestPath(), false);
				log.info("{}... {} to {}", TASKNAME, file.getAbsolutePath(), moveInfo.getDestPath());
			}
		} catch (IOException | CrazyException e) {
			log.error("File move error - {}", e.getMessage());
		}
	}
	
}

@Data
@AllArgsConstructor
class MoveInfo {
	
	String suffix;
	File  srcPath;
	File destPath;
	
}