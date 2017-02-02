package jk.kamoru.flayon.base.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.userdetails.UserDetailsService;

import jk.kamoru.flayon.base.security.UserDetailsServiceImpl;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		// for using h2 console, turn off csrf(Cross Site Request Forgery), X-Frame-Options
		http.csrf().disable();
		http.headers().frameOptions().disable();
		
		http
			.authorizeRequests()
				.antMatchers("/", "/error", "/webjars/**", "/css/**", "/img/**", "/js/**", "/fonts/**", "/user/profile", "/h2console/**", "/jquery-ui/**").permitAll()
				.antMatchers("/user/**").hasAuthority("ADMIN")
				.anyRequest().authenticated()
				.and()
			.formLogin()
				.loginPage("/login")
				.permitAll()
				.and()
			.rememberMe()
//				.rememberMeParameter("")
				.and()
			.logout()
				.logoutSuccessUrl("/")
				.permitAll();
		super.configure(http);
	}

	@Override
	protected void configure(AuthenticationManagerBuilder auth) throws Exception {
		auth.userDetailsService(userDetailsService());
	}

	@Bean
	@Override
	protected UserDetailsService userDetailsService() {
		return new UserDetailsServiceImpl();
	}

	
}
