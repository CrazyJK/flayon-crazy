package jk.kamoru.flayon;

import java.io.File;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import lombok.extern.slf4j.Slf4j;


@Slf4j
public class Utils {

	/**
	 * 파일(logpath)을 읽어 구분자, 검색어, 최대수, and/or조건에 맞쳐 split해서 반환한다.
	 * @param logpath 읽을 파일
	 * @param delimeter 구분자
	 * @param max split 최대수
	 * @param search 검색어
	 * @param searchOper and/or조건
	 * @return
	 * @throws Exception
	 */
	public static List<String[]> readLines(String logpath, String delimeter, int max, String search, String searchOper) throws Exception {
		
		if (logpath.length() == 0)
			throw new Exception("log path is empty");
		File file = new File(logpath);
		if (file.isDirectory()) 
			throw new Exception("log path is directory");
		if (!file.exists())
			throw new Exception("log file not exist");
		
		List<String[]> lineArrayList = new ArrayList<String[]>();
		String[] searchArray = trimArray(StringUtils.splitByWholeSeparator(search, ",", -1));
		int count = 0;
		log.info("logView readLines Start");
		for (String line : Files.readAllLines(file.toPath())) {
			if (searchArray.length == 0 || containsByOper(line, searchArray, searchOper)) {
				line = StringUtils.replaceEach(line, new String[]{"<", ">"}, new String[]{"&lt;", "&gt;"});
				line = StringUtils.replaceEach(line, searchArray, wrapString(searchArray, "<em>", "</em>"));
				lineArrayList.add(delimeter.length() > 0 ? StringUtils.splitByWholeSeparator(line, delimeter, max) : new String[]{line});
				if (++count % 100 == 0)
					log.info("logView readLines " + count);
			}
		}
		log.info("logView readLines End");
		return lineArrayList;
	}
	
	/**
	 * strArr요소별로 앞뒤에 str1과 str2를 붙여준다
	 * @param strArr
	 * @param str1
	 * @param str2
	 * @return
	 */
	public static String[] wrapString(String[] strArr, String str1, String str2) {
		String[] retArr = Arrays.copyOf(strArr, strArr.length);
		for (int i=0; i < strArr.length; i++) {
			retArr[i] = str1 + strArr[i] + str2;
		}
		return retArr;
	}
	
	/**
	 * searchArr요소별로 포함되어 있는지 여부를 검사.<br>
	 * searchOper가 'or'이면 하나만 포함되어도 <code>true</code>. 'and'면 모두 포함될 때만 <code>true</code>
	 * @param str 
	 * @param searchArr
	 * @param searchOper 'or', 'and'
	 * @return
	 */
	public static boolean containsByOper(String str, String[] searchArr, String searchOper) {
		boolean result = true;
		for (String search : searchArr) {
			if (searchOper.equals("or")) {
				return StringUtils.contains(str, search);
			}
			else if (searchOper.equals("and")) {
				result = result && StringUtils.contains(str, search);
			}
		}
		return result;
	}
	
	/**
	 * 배열요소에 trim 처리
	 * @param strArr
	 * @return
	 */
	public static String[] trimArray(String[] strArr) {
		for (int i=0; i < strArr.length; i++) {
			strArr[i] = StringUtils.trim(strArr[i]);
		}
		return strArr;
	}
	
}
