package jk.kamoru.flayon.crazy.image.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jk.kamoru.flayon.crazy.image.domain.Image;
import jk.kamoru.flayon.crazy.image.domain.Image.Type;
import jk.kamoru.flayon.crazy.image.source.ImageSource;
import lombok.extern.slf4j.Slf4j;

/**
 * Implementation of {@link ImageService}
 * @author kamoru
 *
 */
@Service
@Slf4j
public class ImageServiceImpl implements ImageService {

	@Autowired
	private ImageSource imageSource;
	
	@Override
	public Image getImage(int idx) {
		return imageSource.getImage(idx);
	}

	@Override
	public int getImageSourceSize() {
		return imageSource.getImageSourceSize();
	}

	@Override
	public Image getImageByRandom() {
		return imageSource.getImage(getRandomImageNo());
	}

	@Override
	public List<Image> getImageList() {
		return imageSource.getImageList();
	}

	@Override
	public String getImageNameJSON() {
		ObjectMapper mapper = new ObjectMapper();
		Map<Integer, String> nameMap = getImageNameMap();
		try {
			return mapper.writeValueAsString(nameMap);
		} catch (JsonProcessingException e) {
			return "{error: \"" + e.getMessage() + "\"}";
		}
	}

	@Override
	public Map<Integer, String> getImageNameMap() {
		Map<Integer, String> map = new HashMap<>();
		int index = 0;
		for (Image image : imageSource.getImageList()) {
			map.put(index++, image.getName());
		}
		return map;
	}

	@Override
	public void delete(int idx) {
		imageSource.delete(idx);
	}

	@Override
	public int getRandomImageNo() {
		return (int)(Math.random() * imageSource.getImageSourceSize());
	}

	@Override
	@Cacheable(value="flayon-image-cache")
	public byte[] getBytes(int idx, Type imageType) {
		log.debug("getBytes {}, {}", idx, imageType);
		return imageSource.getImage(idx).getByteArray(imageType);
	}
}
