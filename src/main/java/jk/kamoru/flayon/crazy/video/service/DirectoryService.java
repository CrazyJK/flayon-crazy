package jk.kamoru.flayon.crazy.video.source;

import java.io.File;
import java.util.List;

public interface DirectoryRepository {

	File find(String name);
	
	List<File> query(String query);
	
}
