package jk.kamoru.flayon.tools;

import java.io.File;
import java.util.Collection;
import java.util.Comparator;
import java.util.stream.Collectors;

import org.apache.commons.io.FileUtils;
import org.springframework.util.StringUtils;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class FileRenameBatch {

//	public static void main(String[] args) {
//		FileRenameBatch.rename("E:\\kAmOrU\\Pictures\\Girls\\Entertainer\\수지", "수지");
//
//	}

	static void rename(String path, String prefixName) {
		File filePath = new File(path);
		if (!filePath.isDirectory()) {
			log.warn("{} is not a directory", path);
			return;
		}
			
		if (StringUtils.isEmpty(prefixName)) {
			prefixName = filePath.getName();
		}

		Collection<File> listFiles = FileUtils.listFiles(filePath, null, false);
		log.info("Scan {} ... found {}", filePath.getAbsolutePath(), listFiles.size());
		int count = 1;
		for (File file : listFiles.stream().sorted(Comparator.comparing(File::lastModified)).collect(Collectors.toList())) {
			String name = file.getName();
			String[] split = StringUtils.split(name, ".");
			if (split == null || split.length < 1) {
				log.warn("name invalid {} {}", name, split.length);
				continue;
			}
			File dest = new File(path, prefixName + "-" + count++ + "_" + file.lastModified() + "." + split[split.length-1]);
			file.renameTo(dest);
			log.info("{} -> {}", file.getName(), dest.getName());
		}
	}
	
}
