package jk.kamoru.flayon.test;

import java.io.File;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jk.kamoru.flayon.base.util.IOUtils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

public class VideoInfoTransfer {

	ObjectMapper mapper = new ObjectMapper();

	File backPath = new File("C:\\_info.back");

	SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");

	public static void main(String[] args) throws Exception {
		VideoInfoTransfer transfer = new VideoInfoTransfer();
		String[] paths = {"D:\\Crazy", "E:\\Crazy"};

		Collection<File> listFiles = IOUtils.listFiles(paths, new String[]{"info"}, true);
		System.out.println("found " + listFiles.size());
		int count = 0;
		for (File file : listFiles) {
			try {
				transfer.transfer(file);
				System.out.print(".");
				if (++count % 100 == 0)
					System.out.println();
			} catch(Exception e) {
				System.err.println(file);
				e.printStackTrace();
				break;
			}
		}
	}

	void transfer(File file) throws Exception {
//		System.out.println(file);
		// read / check original
		String infoText = FileUtils.readFileToString(file, VIDEO.ENCODING);
		if (StringUtils.isBlank(infoText))
			return;

		// backup info file
		FileUtils.copyFileToDirectory(file, backPath);

		// read json
		Map<String, Map<String, String>> rootMap = mapper.readValue(infoText, new TypeReference<Map<String, Map<String, String>>>() {});
		
		Map<String, String> map = rootMap.get("info");
		String opus     = map.get("opus");
		int rank        = parseInt(map.get("rank"));
		int playCount   = parseInt(map.get("playCount"));
		String overview = map.get("overview");
		Date lastAccess = dateFormat(map.get("lastAccess"));
		Info info = new Info(opus, playCount, rank, overview, lastAccess, new ArrayList<Tag>());

//		System.out.println(info);
		// write result
		mapper.writeValue(file, info);
	
	}
	
	private Date dateFormat(String dateString) throws ParseException {
		if (StringUtils.isBlank(dateString))
			return null;
		return format.parse(dateString);
	}
	
	private int parseInt(String number) {
		try {
			return Integer.parseInt(number);
		} catch(Exception e) {
			return 0;
		}
	}
	
	void writeAndReadSample() throws Exception {
		ObjectMapper mapper = new ObjectMapper();

		Info info = new Info();
		info.setOpus("ART-111");
		info.setPlayCount(4);
		info.setRank(3);
		info.setOverview("ewewrwerw");
		info.setLastAccess(new Date());
		info.setTags(generateTagList());
		System.out.println(info);

		File src = new File("/home/kamoru/jsonTest.json");
		// convert object to JSON and save file 
		mapper.writeValue(src, info);
		
		// convert file to object and read JSON
		Info readInfo = mapper.readValue(src, Info.class);
		System.out.println(readInfo);

		// pretty JSON
		String jsonString = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(readInfo);
		System.out.println(jsonString);

		// check equals both
		System.out.println(info.toString().equals(readInfo.toString()));
		System.out.println(info.equals(readInfo));		
	}
	
	private List<Tag> generateTagList() {
		Tag tag1 = new Tag(1, "JK", "high student");
		Tag tag2 = new Tag(2, "OL", "Office lady");
		return Arrays.asList(tag1, tag2);
	}
}

@AllArgsConstructor
@NoArgsConstructor
@Data
class Info {
	String opus;
	Integer playCount;
	Integer rank;
	String overview;
	Date lastAccess;
	List<Tag> tags;
}

@AllArgsConstructor
@NoArgsConstructor
@Data
class Tag {
	Integer id;
	String name;
	String description;
}
