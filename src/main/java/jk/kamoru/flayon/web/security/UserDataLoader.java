package jk.kamoru.flayon.base.security;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UserDataLoader {

	@Autowired private UserRepository userRepository;

	@PostConstruct
	public void loadInitData() {
		
		User admin = new User();
		admin.setName("admin");
		admin.setPassword("6969");
		admin.setRole(User.Role.ADMIN.name());
		userRepository.save(admin);

		User kamoru = new User();
		kamoru.setName("kamoru");
		kamoru.setPassword("crazyjk");
		kamoru.setRole(User.Role.USER.name());
		userRepository.save(kamoru);
	}
}
