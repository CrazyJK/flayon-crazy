package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;

import org.apache.commons.lang3.StringUtils;
import org.junit.Test;

import jk.kamoru.flayon.crazy.video.util.VideoUtils;

public class TitlePartTest {

	@Test
	public void test() {
		String path = "D:\\test";
		for (File file : new File(path).listFiles()) {
			System.out.println("file=[" + file + "]");
			String name = file.getName();
			TitlePart titlePart = new TitlePart(name);
			
			for (String actressName : StringUtils.split(titlePart.getActress(), ",")) {
				String forwardActressName = VideoUtils.sortForwardName(actressName);
				actressName = VideoUtils.trimBlank(actressName);
				System.out.println("actressName=[" + actressName + "]");
				System.out.println("forwardActr=[" + forwardActressName + "]");
			}

		}
	}

}
