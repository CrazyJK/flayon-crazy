package jk.kamoru.flayon.base.config;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import jk.kamoru.flayon.base.beans.MethodExecutionBeanPostProcessor;

@Configuration
public class BaseConfig {

	@Bean
	public BeanPostProcessor methodExecutionBeanPostProcessor() {
		MethodExecutionBeanPostProcessor processor = new MethodExecutionBeanPostProcessor();
		Map<String, String> beans = new HashMap<>();
		beans.put("infoWatch", "start");
		beans.put("userDataLoader", "loadInitData");
		
		processor.setBeans(beans);
		return processor;
	}

}
