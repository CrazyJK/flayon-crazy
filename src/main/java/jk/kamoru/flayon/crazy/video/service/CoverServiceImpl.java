package jk.kamoru.flayon.crazy.video.service;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Random;

import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.base.util.IOUtils;
import jk.kamoru.flayon.base.util.ImageUtils;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.dao.VideoDao;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Video;

@Service
public class CoverServiceImpl implements CoverService {

	@Autowired VideoDao videoDao;

	@Override
//	@Cacheable(value="flayon-cover-cache", key="#opus")
	public CoverHttpEntity<byte[]> getVideoCover(HttpServletResponse response, String opus) {
		File file = videoDao.getVideo(opus).getCoverFile();
		byte[] bytes = readFileToByteArray(file);
		return httpEntity(response, file, bytes);
	}

	@Override
	public CoverHttpEntity<byte[]> getVideoCoverRandom(HttpServletResponse response) {
		List<Video> videoList = videoDao.getVideoList(true, false);
		Random random = new Random();
		int index = random.nextInt(videoList.size());
		
		File file = videoList.get(index).getCoverFile();
		byte[] bytes = readFileToByteArray(file);
		return httpEntity(response, file, bytes);
	}

	@Override
	public CoverHttpEntity<byte[]> getVideoCoverWithTitle(HttpServletResponse response, String opus) {
		Video video = videoDao.getVideo(opus);
		
		File file = video.getCoverFile();
		byte[] bytes = ImageUtils.mergeTextToImage(video.getTitle(), file);
		return httpEntity(response, file, bytes);
	}

	@Override
	public CoverHttpEntity<byte[]> getVideoCoverRandomWithTitle(HttpServletResponse response) {
		List<Video> videoList = videoDao.getVideoList(true, false);
		Random random = new Random();
		int index = random.nextInt(videoList.size());
		Video video = videoList.get(index);
		
		File file = video.getCoverFile();
		byte[] bytes = ImageUtils.mergeTextToImage(video.getTitle(), file);
		return httpEntity(response, file, bytes);
	}

	@Override
	public CoverHttpEntity<byte[]> getActressCover(HttpServletResponse response, String name) {
		File file = videoDao.getActress(name).getImage();
		byte[] bytes = readFileToByteArray(file);
		return httpEntity(response, file, bytes);
	}

	@Override
	public CoverHttpEntity<byte[]> getActressCoverWithName(HttpServletResponse response, String name) {
		Actress actress = videoDao.getActress(name);
		
		File file = actress.getImage();
		byte[] bytes = ImageUtils.mergeTextToImage(actress.getName(), file);
		return httpEntity(response, file, bytes);
	}

	private CoverHttpEntity<byte[]> httpEntity(HttpServletResponse response, File imageFile, byte[] imageBytes) {
		MediaType mediaType = MediaType.parseMediaType("image/" + IOUtils.getSuffix(imageFile));
		
		response.setHeader("Cache-Control", "public, max-age=" + VIDEO.WEBCACHETIME_SEC);
		response.setHeader("Pragma", "public");
		response.setDateHeader("Expires", new Date().getTime() + VIDEO.WEBCACHETIME_MILI);
		response.setDateHeader("Last-Modified", imageFile.lastModified());
		response.setContentType(mediaType.getType());

		HttpHeaders headers = new HttpHeaders();
		headers.setContentLength(imageBytes.length);
		headers.setContentType(mediaType);
		
		return new CoverHttpEntity<byte[]>(imageBytes, headers);
	}

	private byte[] readFileToByteArray(File file) {
		try {
			return FileUtils.readFileToByteArray(file);
		} catch (IOException e) {
			throw new CrazyException("fail to readFileToByteArray", e);
		}
	}

}
