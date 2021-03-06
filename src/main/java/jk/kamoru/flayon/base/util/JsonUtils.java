package jk.kamoru.flayon.base.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class JsonUtils {

	static ObjectMapper mapper = new ObjectMapper();

	public static String toJsonString(Object obj) {
		try {
			return mapper.writeValueAsString(obj);
		} catch (JsonProcessingException e) {
			return "{error: \"" + e.getMessage() + "\"}";
		}
	}
}
