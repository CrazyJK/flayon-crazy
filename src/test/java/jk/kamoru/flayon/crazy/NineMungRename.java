package jk.kamoru.flayon.crazy;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import org.apache.commons.lang3.math.NumberUtils;
import org.h2.util.StringUtils;

import net.sf.jmimemagic.Magic;
import net.sf.jmimemagic.MagicException;
import net.sf.jmimemagic.MagicMatch;
import net.sf.jmimemagic.MagicMatchNotFoundException;
import net.sf.jmimemagic.MagicParseException;

public class NineMungRename {
	static String path = "/Users/kamoru/Pictures/Girls/9Mung";

	public static void main(String[] args) throws IOException {
		File[] listFiles = new File(path).listFiles();
		for (File file : listFiles) {
			if (file.getName().equals(".DS_Store"))
				continue;
			
			String mime = checkMime(file);
			
			if ("image/jpeg".equals(mime)) {
				file.renameTo(new File(path, file.getName() + ".jpg"));
			}
			else if ("image/gif".equals(mime)) {
				file.renameTo(new File(path, file.getName() + ".gif"));
			}
			else {
				System.out.format("%s : %s%n", file, mime);
			}
		}
	}
	
	static String checkMime(File file) {
//		Magic parser = new Magic();
		try (FileInputStream is = new FileInputStream(file)) {
			byte[] data = new byte[1024];
			is.read(data);
			MagicMatch match = Magic.getMagicMatch(data);
			return match.getMimeType();
		} catch (MagicParseException | MagicMatchNotFoundException | MagicException | IOException e) {
			e.printStackTrace();
			return e.getMessage();
		}
	}
	
	public static void main_rename(String[] args) {
		File[] listFiles = new File(path).listFiles();
		for (File file : listFiles) {
			String name = Utils.getNameExceptExtension(file);
			String[] part = name.split("-");
			String newName = "";
			// [꿀밤율이]
			// NineMung-2-[꿀밤 율이] 사무실에서 몰래하는 섹스의 참맛 2-7
			// NineMung-5-[꿀민여동생 꿀밤] 다양한 자세로 그녀를 괴롭히기-10
			if (NumberUtils.isNumber(part[1]) && NumberUtils.isNumber(part[3])) {
				newName = String.format("%s-%s-%s-%s", "꿀민여동생", addZero(part[1]), addZero(part[3]), retitle(part[2].trim()));
			}
			// NineMung-45-[꿀민여동생 꿀밤] - 꿀민이 초대남 후기 (상)-50
			else if (NumberUtils.isNumber(part[1]) && NumberUtils.isNumber(part[4])) {
				newName = String.format("%s-%s-%s%s-%s", "꿀민여동생", addZero(part[1]), addZero(part[4]), retitle(part[2].trim()), retitle(part[3].trim()));
			}
			else {
				throw new NumberFormatException(name);
			}
			System.out.format("new name : %-60s => %s%n", name, newName);
			file.renameTo(new File(path, newName));
		}
	}

	private static String retitle(String s) {
		s = StringUtils.replaceAll(s, ".", "");
		s = StringUtils.replaceAll(s, "[꿀밤율이]", "");
		s = StringUtils.replaceAll(s, "[꿀밤 율이]", "");
		s = StringUtils.replaceAll(s, "[꿀민여동생 꿀밤]", "");
		return s.trim();
	}
	
	private static String addZero(String s) {
		s = s.trim();
		switch (s.length()) {
		case 1:
			return "00" + s;
		case 2:
			return "0" + s;
		case 3:
			return s; 
		}
		return s;
	}
}
