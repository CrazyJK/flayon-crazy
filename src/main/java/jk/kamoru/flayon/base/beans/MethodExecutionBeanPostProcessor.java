package jk.kamoru.flayon.base.beans;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.util.Assert;

import lombok.extern.slf4j.Slf4j;

/**
 * Method execution BeanPostProcessor
 * <p>빈 생성후 설정에의해 채택된 메서드를 수행한다.
 * <pre>
	@Bean
	public BeanPostProcessor methodExecutionBeanPostProcessor() {
		MethodExecutionBeanPostProcessor processor = new MethodExecutionBeanPostProcessor();
		Map<String, String> beans = new HashMap<>();
		beans.put("infoWatch", "start");
		beans.put("methodExecutionSample", "loadInitData");
		
		processor.setBeans(beans);
		return processor;
	}
 * </pre>
 * @author kamoru
 *
 */
@Slf4j
public class MethodExecutionBeanPostProcessor implements BeanPostProcessor {

	private Map<String, String> beans;

	private static int count = 0;

	/**
	 * set bean infomation. {key = beanName, value = methodName}
	 * 
	 * @param beans
	 */
	public void setBeans(Map<String, String> beans) {
		Assert.notNull(beans, "'beans' must not be null");
		this.beans = beans;
		log.info("BeanPostProcess set beans {}", beans);
	}

	@Override
	public Object postProcessBeforeInitialization(Object bean, String beanName) {
		// Nothing to do
		return bean;
	}

	@Override
	public Object postProcessAfterInitialization(Object bean, String beanName) {
		if (beans == null)
			return bean;
		if (beans.keySet().contains(beanName)) {
			String methodName = beans.get(beanName);
			log.info("BeanPostProcess {}   attempt to invoke {}.{}", ++count, beanName, methodName);

			try {
				Method method = bean.getClass().getDeclaredMethod(methodName);
				method.invoke(bean);
			} catch (NoSuchMethodException | SecurityException | IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
				log.error("BeanPostProcess error", e);
			}
			
			log.info("BeanPostProcess {} completed to invoke {}.{}", count, beanName, methodName);
		}
		return bean;
	}

}
