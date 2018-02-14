package jk.kamoru.flayon.crazy.video.dao;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import lombok.extern.slf4j.Slf4j;

// file dao implementation
@Slf4j
@Repository
public class TagDaoFile implements TagDao {
	
	@Autowired CrazyConfig config;

	private Path tagDataPath;
	private List<VTag> tags;
	private ObjectMapper mapper = new ObjectMapper();

	@PostConstruct
	public void init() {
		tagDataPath = Paths.get(config.getStoragePath(), VIDEO.TAG_DATA_FILENAME);
		log.info("load data... {}", tagDataPath);
		try {
			if (!Files.exists(tagDataPath)) {
				Files.createFile(tagDataPath);
				tags = new ArrayList<>();
				log.info("file is not exist. just make it");
			}
			else {
				tags = mapper.readValue(tagDataPath.toFile(), new TypeReference<List<VTag>>() {});
				log.info("found tags {}", tags.size());
			}
		} catch (IOException e) {
			log.error("Fail to read tag.data", e);
			throw new CrazyException("Fail to read tag.data", e);
		}
	}

	private Integer findMaxId() {
		int[] array = new int[tags.size()];
		int i = 0;
		for (VTag tag : tags) {
			array[i++] = tag.getId();
		}
		return (int)NumberUtils.max(array);
	}
	
	@Override
	public VTag persist(VTag tag) {
		if (tags.contains(tag))
			throw new CrazyException("Fail to persist tag : already exist " + tag);
		tag.setId(findMaxId() + 1);
		tag.validation();
		tags.add(tag);
		saveTagData();
		return tag;
	}

	@Override
	public VTag findById(Integer id) throws CrazyException {
		for (VTag tag : tags) {
			if (tag.getId() == id)
				return tag;
		}
		throw new CrazyException("not found tag by id:" + id);
	}

	@Override
	public VTag findByName(String name) throws CrazyException {
		for (VTag tag : tags) {
			if (StringUtils.equals(tag.getName(), name))
				return tag;
		}
		throw new CrazyException("not found tag by name:" + name);
	}

	@Override
	public List<VTag> findByDesc(String desc) {
		List<VTag> found = new ArrayList<>();
		for (VTag tag : tags) {
			if (StringUtils.containsIgnoreCase(tag.getDescription(), desc))
				found.add(tag);
		}
		return found.stream().sorted(Comparator.comparing(VTag::getName)).collect(Collectors.toList());
	}

	@Override
	public List<VTag> findAll() {
		return tags.stream().sorted(Comparator.comparing(VTag::getName)).collect(Collectors.toList());
	}

	@Override
	public VTag merge(VTag updateTag) {
		updateTag.validation();
		VTag foundTag = findById(updateTag.getId());
		tags.remove(foundTag);
		tags.add(updateTag);
		saveTagData();
		return updateTag;
	}

	@Override
	public boolean remove(VTag tag) {
		tags.remove(tag);
		saveTagData();
		return true;
	}

	private void saveTagData() {
		try {
			mapper.writeValue(tagDataPath.toFile(), tags);
		} catch (IOException e) {
			throw new CrazyException("Fail to write tag.data", e);
		}
	}

}
