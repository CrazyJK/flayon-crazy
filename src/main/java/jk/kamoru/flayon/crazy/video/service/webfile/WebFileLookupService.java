package jk.kamoru.flayon.crazy.video.service.webfile;

import java.io.File;
import java.util.concurrent.CompletableFuture;

public interface WebFileLookupService {

	public CompletableFuture<File> get(String opus, String title, String saveLocation);
	
}
