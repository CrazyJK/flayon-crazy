package jk.kamoru.flayon.test;

import java.io.File;
import java.util.Collection;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.util.CrazyUtils;

public class InfoCleaner {

	public static void main(String[] args) {
		File path = new File("F:\\Crazy\\Storage\\_info");

		Collection<File> listFiles = FileUtils.listFiles(path, new String[] {"actress", "studio"}, false);
		
		for (File file : listFiles) {
			Map<String, String> data = CrazyUtils.readFileToMap(file);
			String filename = CrazyUtils.getNameExceptExtension(file);
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

}
