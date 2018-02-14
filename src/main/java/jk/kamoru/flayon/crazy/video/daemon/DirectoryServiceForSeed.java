package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.base.watch.DirectoryWatchService;
import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class SeedDirectoryService extends DirectoryWatchService implements DirectoryService {

	private static final String TASKNAME = "Seed Directory Service";
	
	@Autowired CrazyConfig config;

	private List<Path> pathList = new ArrayList<>();;
	
	@PostConstruct
	public void load() {
		String root = config.getTorrentSeedPath();
		try {
			pathList = Files.walk(Paths.get(root)).collect(Collectors.toList());
			log.info("Seed load {} files", pathList.size());
		} catch (IOException e) {
			throw new CrazyException("seed loading error", e);
		}
	}

	@Override
	public File find(String name) {
		throw new CrazyException("find is not supported");
	}

	@Override
	public List<File> query(String opus) {
		log.info("query {}", opus);
		return pathList.stream()
				.filter(p -> CrazyUtils.containsAny(p.toString(), opus, opus.replace("-", "")))
				.map(p -> p.toFile())
				.collect(Collectors.toList());
	}

	@Override
	public void created(Path path) {
		pathList.add(path);
	}

	@Override
	public void deleted(Path path) {
		pathList.remove(path);
	}

	@Override
	protected String getTaskName() {
		return TASKNAME;
	}

	@Override
	protected String[] getPath() {
		return new String[] {config.getTorrentSeedPath()};
	}

}
