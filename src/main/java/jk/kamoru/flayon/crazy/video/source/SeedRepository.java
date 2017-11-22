package jk.kamoru.flayon.crazy.video.source;

import static java.nio.file.StandardWatchEventKinds.ENTRY_CREATE;
import static java.nio.file.StandardWatchEventKinds.ENTRY_DELETE;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.WatchEvent.Kind;
import java.util.List;
import java.util.stream.Collectors;

import jk.kamoru.flayon.base.watch.AsyncExecutorService;
import jk.kamoru.flayon.base.watch.DirectoryWatcher;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class SeedRepository extends AsyncExecutorService implements DirectoryRepository {

	private List<Path> pathList;
	private String root;
	
	public SeedRepository(String root) {
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
			public void action(Kind<Path> kind, Path file) {
				if (kind == ENTRY_CREATE) {
					pathList.add(file);
					log.info("add seed {}", file);
				}
				else if (kind == ENTRY_DELETE) {
					pathList.remove(file);
					log.info("remove seed {}", file);
				}
			}
		};
	}

}
