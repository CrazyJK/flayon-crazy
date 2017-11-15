package jk.kamoru.flayon.crazy.video.source;

import java.util.Map;

public interface AdditionalInfoProvider {

	Map<String, String> find(String key);
	
}
