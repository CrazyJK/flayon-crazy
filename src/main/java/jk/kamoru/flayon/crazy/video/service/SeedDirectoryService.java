package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;

import jk.kamoru.flayon.base.watch.AsyncExecutorService;
import jk.kamoru.flayon.base.watch.DirectoryWatcher;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class SeedDirectoryService extends AsyncExecutorService implements DirectoryService {

	private List<Path> pathList;
	private String root;
	
	public SeedDirectoryService(String root) {
		this.root = root;
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
	protected Runnable getTask() {
		return new DirectoryWatcher("Seed", root) {

			@Override
			public void deleteEvent(Path file) {
				pathList.add(file);
				log.info("add seed {}", file);
			}

			@Override
			public void createEvent(Path file) {
				pathList.remove(file);
				log.info("remove seed {}", file);
			}

		};
	}

}
