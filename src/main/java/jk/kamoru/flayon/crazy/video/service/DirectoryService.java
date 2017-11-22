package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.util.List;

public interface DirectoryService {

	File find(String name);
	
	List<File> query(String query);
	
}
