package jk.kamoru.flayon.util;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Stack;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipArchiveInputStream;
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream;

import jk.kamoru.flayon.crazy.util.CrazyUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ZipUtils {
	
//	public static void main(String[] args) throws IOException {
//		File src = new File("/home/kamoru/utilities/sts-bundle/crazy/Stage");
//		File destDir = new File("/home/kamoru/workspace/flayon-backup");
//		String charSetName = "UTF-8";
//		boolean includeSrc = true;
//		ZipUtils zip = new ZipUtils();
//		zip.zip(src, destDir, charSetName, includeSrc);
//	}

	/**<pre>
	 * 압축 해제
	 * zip파일의 현재 위치에 푼다
	 * jvm default charset 사용
	 * @param zippedFile
	 * @throws IOException
	 */
	public static void unzip(File zippedFile) throws IOException {
		unzip(zippedFile, Charset.defaultCharset().name());
	}

	/**<pre>
	 * 압축 해제
	 * zip파일의 현재 위치에 푼다
	 * @param zippedFile
	 * @param charsetName
	 * @throws IOException
	 */
	public static void unzip(File zippedFile, String charsetName) throws IOException {
		unzip(zippedFile, zippedFile.getParentFile(), charsetName);
	}

	/**<pre>
 	 * 압축 해제
	 * jvm default charset 사용
	 * @param zippedFile
	 * @param destDir 압축풀 폴더
	 * @throws IOException
	 */
	public static void unzip(File zippedFile, File destDir) throws IOException {
		unzip(zippedFile, destDir, Charset.defaultCharset().name());
	}

	/**<pre>
 	 * 압축 해제
	 * @param zippedFile
	 * @param destDir 압축풀 폴더
	 * @param charsetName
	 * @throws IOException
	 */
	public static void unzip(File zippedFile, File destDir, String charsetName) throws IOException {
		log.info("unzip {} to {}. {}", zippedFile, destDir, charsetName);
		
		byte[] buf = new byte[1024 * 8];
		ZipArchiveInputStream zipInputStream = new ZipArchiveInputStream(new FileInputStream(zippedFile), charsetName, false);
		ZipArchiveEntry zipEntry;
		while ((zipEntry = zipInputStream.getNextZipEntry()) != null) {
			String name = zipEntry.getName();
			File targetFile = new File(destDir, name);
			if (zipEntry.isDirectory()) {
				targetFile.mkdirs();
			} 
			else {
				targetFile.createNewFile();
				BufferedOutputStream outputStrean = new BufferedOutputStream(new FileOutputStream(targetFile));
				int nWritten = 0;
				while ((nWritten = zipInputStream.read(buf)) >= 0) {
					outputStrean.write(buf, 0, nWritten);
				}
				outputStrean.close();
			}
		}
		zipInputStream.close();
	}

	// ---------------- zip
	
	/**<pre>
	 * 소스 파일/폴더를 압축
	 * zip파일 위치는 현재 폴더
	 * zip파일 이름은 src가 폴더이면 폴더이름으로, 파일이면 파일 이름으로 결정 
	 * charset은 jvm default charset
	 * src가 폴더면, zip에 폴더 포함
	 * @param src file or directory
	 * @throws IOException
	 */
	public static void zip(File src) throws IOException {
		zip(src, Charset.defaultCharset().name(), true);
	}

	/**<pre>
	 * 소스 파일/폴더를 압축
	 * zip파일 위치는 현재 폴더
	 * zip파일 이름은 src가 폴더이면 폴더이름으로, 파일이면 파일 이름으로 결정 
	 * charset은 jvm default charset
	 * @param src file or directory to compress
	 * @param includeSrc src가 폴더이고 true이면, zip에 폴더 포함
	 * @throws IOException
	 */
	public static void zip(File src, boolean includeSrc) throws IOException {
		zip(src, Charset.defaultCharset().name(), includeSrc);
	}

	/**<pre>
	 * 소스 파일/폴더를 압축
	 * zip파일 위치는 현재 폴더
	 * zip파일 이름은 src가 폴더이면 폴더이름으로, 파일이면 파일 이름으로 결정 
	 * @param src
	 * @param charSetName
	 * @param includeSrc src가 폴더이고 true이면, zip에 폴더 포함
	 * @throws IOException
	 */
	public static void zip(File src, String charSetName, boolean includeSrc) throws IOException {
		zip(src, src.getParentFile(), charSetName, includeSrc);
	}

	/**<pre>
	 * 소스 파일/폴더를 압축
	 * zip파일 이름은 src가 폴더이면 폴더이름으로, 파일이면 파일 이름으로 결정 
	 * @param src 소스
	 * @param destDir zip파일 위치
	 * @param charSetName
	 * @param includeSrc src가 폴더이고 true이면, zip에 폴더 포함
	 * @throws IOException
	 */
	public static void zip(File src, File destDir, String charSetName, boolean includeSrc) throws IOException {
		String fileName = src.getName();
		if (src.isFile()) {
			fileName = CrazyUtils.getNameExceptExtension(src);
		}
		fileName += ".zip";
		zip(src, destDir, fileName, charSetName, includeSrc);
	}

	/**
	 * 소스 파일/폴더를 압축
	 * @param src 압축 소스
	 * @param destDir zip파일 위치
	 * @param destFileName zip파일 이름
	 * @param charSetName
	 * @param includeSrc src가 폴더이고 true이면, zip에 폴더 포함
	 * @throws IOException
	 */
	public static void zip(File src, File destDir, String destFileName, String charsetName, boolean includeSrc) throws IOException {
		log.info("zip {} to {}/{}. {} {}", src, destDir, destFileName, charsetName, includeSrc);

		File zippedFile = new File(destDir, destFileName);
		if (!zippedFile.exists())
			zippedFile.createNewFile();

		File rootPath;
		Stack<File> stackFile = new Stack<>();
		if (src.isDirectory()) {
			if (includeSrc) {
				stackFile.push(src);
				rootPath = src.getParentFile();
			} 
			else {
				for (File file : src.listFiles()) {
					stackFile.push(file);
				}
				rootPath = src;
			}
		} 
		else {
			stackFile.push(src);
			rootPath = src.getParentFile();
		}

		byte[] buf = new byte[8 * 1024];
		ZipArchiveOutputStream zipOutputStrean = new ZipArchiveOutputStream(new FileOutputStream(zippedFile));
		zipOutputStrean.setEncoding(charsetName);
		while (!stackFile.isEmpty()) {
			File popFile = stackFile.pop();
			if (popFile.isDirectory()) {
				for (File file : popFile.listFiles()) {
					if (file.isDirectory())
						stackFile.push(file);
					else
						stackFile.add(0, file);
				}
			} 
			else {
				String entryName = toRelativePath(rootPath, popFile);
				zipOutputStrean.putArchiveEntry(new ZipArchiveEntry(entryName));
				FileInputStream fileInputStream = new FileInputStream(popFile);
				int length = -1;
				while ((length = fileInputStream.read(buf, 0, buf.length)) >= 0) {
					zipOutputStrean.write(buf, 0, length);
				}
				fileInputStream.close();
				zipOutputStrean.closeArchiveEntry();
			}
		}
		zipOutputStrean.close();
	}

	/**
	 * root로 부터 시작하는 file의 상대 경로. file이 폴더면 '/'를 붙인다.
	 * @param root
	 * @param file
	 * @return relative Path
	 */
	private static String toRelativePath(File root, File file) {
		String relativePath = file.getAbsolutePath();
		relativePath = relativePath.substring(root.getAbsolutePath().length()).replace(File.separatorChar, '/');
		if (relativePath.startsWith("/"))
			relativePath = relativePath.substring(1);
		if (file.isDirectory() && !relativePath.endsWith("/"))
			relativePath += "/";
		return relativePath;
	}

}
