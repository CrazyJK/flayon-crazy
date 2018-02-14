package jk.kamoru.flayon.crazy.video.service.webfile;

import java.io.File;
import java.util.concurrent.CompletableFuture;

import org.springframework.scheduling.annotation.Async;

/**
 * 비디오 관련 웹의 파일을 찾아 다운로드<br>
 * @author kamoru
 *
 */
public interface WebFileLookupService {

	/**
	 * 파일 찾아 다운로드 
	 * <code>@EnableAsync</code> 설정이 되어 있으면 비동기로 수행
	 * @param keyword 찾을 키워드
	 * @param saveFilename 저장할 파일에 사용될 이름
	 * @param saveLocation 저장할 위치
	 * @return 찾은 파일, 못찾으면 null
	 */
	@Async
	public CompletableFuture<File> get(String keyword, String saveFilename, String saveLocation);
	
}
