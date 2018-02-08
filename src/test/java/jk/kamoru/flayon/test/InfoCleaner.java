package jk.kamoru.flayon.test;

import java.io.File;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.util.ActressUtils;
import jk.kamoru.flayon.crazy.util.CrazyUtils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.domain.TitleValidator;
import jk.kamoru.flayon.util.IOUtils;

public class InfoCleaner {

	static File crazyPath = new File("F:\\Crazy");
	static File infoPath = new File("F:\\Crazy\\Storage\\_info");

	public static void  nameAndNewname() {

		Collection<File> listFiles = FileUtils.listFiles(infoPath, new String[] {"actress", "studio"}, false);
		
		for (File file : listFiles) {
			Map<String, String> data = CrazyUtils.readFileToMap(file);
			String filename = IOUtils.getPrefix(file);
			String name = data.get("NAME");
			String newname = data.get("NEWNAME");

			if (!StringUtils.equals(filename, name)) {
				System.out.format("%s : %s : %s%n", filename, name, newname);
			}
			
			if (name == null && newname == null) {
				System.err.println("Wrong 둘다 null : " + file);
			}
			else if (name == null && newname != null) {
				if (!StringUtils.equals(filename, newname)) {
					System.out.print(file);
					data.put("NAME", newname);
					CrazyUtils.saveFileFromMap(file, data);
					System.out.println(data);
				}
				else {
					System.err.println("Wrong 파일이름과 newname이 다름 : " + file);
				}
			}
			else if (name != null && newname == null) {
				if (!StringUtils.equals(filename, name)) {
					System.out.print(file);
					data.put("NAME", filename);
					data.put("NEWNAME", filename);
					CrazyUtils.saveFileFromMap(file, data);
					System.out.println(data);
				}
			}
			else if (name != null && newname != null) {
				if (!StringUtils.equals(name, newname)) {
					if (StringUtils.equals(filename, newname)) {
						System.out.print(file);
						data.put("NAME", newname);
						CrazyUtils.saveFileFromMap(file, data);
						System.out.println(data);
					}
					else {
						System.err.println("Wrong 파일이름과 newname이 다름 : " + file);
					}
				}
			}
		}
	}

	/**
	 * actress info의 파일 이름과 내용의 NAME 값을 Capitalizing
	 */
	public static void capitalizeAtInfoFile() {
		Collection<File> listFiles = FileUtils.listFiles(infoPath, new String[] {"actress"}, false);
		for (File file : listFiles) {
			Map<String, String> data = CrazyUtils.readFileToMap(file);
			data.remove("NEWNAME");
			String name = CrazyUtils.capitalize(data.get("NAME"));
			data.put("NAME", name);

			String filename = CrazyUtils.capitalize(IOUtils.getPrefix(file));
			File newFile = new File(file.getParentFile(), filename + "." + VIDEO.EXT_ACTRESS);
			file.renameTo(newFile);
			System.out.format("%20s => %20s%n", file.getName(), newFile.getName());
			
			CrazyUtils.saveFileFromMap(newFile, data);
		}
	}
	
	/**<pre>
	 * 파일 이름 정리
	 *  - 전체 : NBSP(u-00a0) 제거
	 *  - 배우이름 : 앞뒤 공백 제거, 이름 Capitalizing
	 */
	public static void 파일이름정리() {
		
		List<String> exceptList = Arrays.asList(VIDEO.EXT_ACTRESS, VIDEO.EXT_STUDIO, "txt", "log", "data", "ini", "exe");
		
		Collection<File> listFiles = FileUtils.listFiles(crazyPath, null, true);
		int count = 0;
		for (File file : listFiles) {
			count++;
			String filename = IOUtils.getPrefix(file);
			String replaceNBSP = CrazyUtils.replaceNBSP(filename);
			String extension = IOUtils.getSuffix(file);
			TitleValidator validator = new TitleValidator(replaceNBSP);
			if (exceptList.contains(extension)) {
				continue;
			}
			else if (validator.isInvalid()) {
				System.out.println("invalid : " + file.getAbsolutePath());
			}
			else {
				String actressName = validator.getActress();
				String refineAndCapitalizeName = ActressUtils.refineAndCapitalizeName(actressName);
				if (StringUtils.equals(actressName, refineAndCapitalizeName))
					continue;
//				System.out.format("%-30s -> [%s]%n", actressName, refineAndCapitalizeName);
				validator.setActress(refineAndCapitalizeName);
				try {
					CrazyUtils.renameFile(file, validator.getStyleString());
					System.out.format("%-5s. %s%n", count, validator.getStyleString());
				} catch(Exception e) {
					System.err.format("%-5s. %s : %s%n", count, e.getClass().getName(), e.getMessage());
				}
			}
		}
	}
	
	public static void main(String[] args) {
		InfoCleaner.파일이름정리();
	}

}
