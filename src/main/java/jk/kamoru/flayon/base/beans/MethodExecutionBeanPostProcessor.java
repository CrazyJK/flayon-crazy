package jk.kamoru.flayon.base.beans;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.util.Assert;

import lombok.extern.slf4j.Slf4j;

/**
 * Method execution BeanPostProcessor
 * <p>빈 생성후 설정에의해 채택된 메서드를 수행한다.
 * <pre>
    <code>@Bean
    public BeanPostProcessor methodExecutionBeanPostProcessor() {
        MethodExecutionBeanPostProcessor processor = new MethodExecutionBeanPostProcessor();
        Map<String, String> beans = new HashMap<>();
        beans.put("infoWatch", "start");
        processor.setBeans(beans);
        return processor;
    }</code>
 * </pre>
 * @author kamoru
 *
 */
@Slf4j
public class MethodExecutionBeanPostProcessor implements BeanPostProcessor {

	private Map<String, String> beans;

	private AtomicInteger count;

	/**
	 * set bean properties. {key = beanName, value = methodName}
	 * @param beans
	 */
	public void setBeans(Map<String, String> beans) {
		Assert.notNull(beans, "'beans' must not be null");
		this.beans = beans;
		this.count = new AtomicInteger(0);
		log.info("BeanPostProcess set beans {}", beans);
	}
	
	@Override
	public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
		// Nothing to do
		return bean;
	}

	@Override
	public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
		if (beans == null)
			return bean;
		if (beans.keySet().contains(beanName)) {
			String methodName = beans.get(beanName);
			log.info("BeanPostProcess {}   attempt to invoke : {}.{}", count.incrementAndGet(), beanName, methodName);
			try {
				Method method = bean.getClass().getDeclaredMethod(methodName);
				method.invoke(bean);
			} catch (NoSuchMethodException | SecurityException | IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
				log.error("BeanPostProcess error", e);
			}
			log.info("BeanPostProcess {} completed to invoke : {}.{}", count.get(), beanName, methodName);
		}
		return bean;
	}

}
