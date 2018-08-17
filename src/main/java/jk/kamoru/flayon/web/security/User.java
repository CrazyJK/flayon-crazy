package jk.kamoru.flayon.web.security;

import java.util.Arrays;
import java.util.Collection;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import jk.kamoru.flayon.FLAYON;
import lombok.Data;

@Entity
@Data
public class User implements UserDetails {

	private static final long serialVersionUID = FLAYON.SERIAL_VERSION_UID;

	@Id @GeneratedValue(strategy = GenerationType.AUTO)
	private Long id;
	
	@Column(name = "name", nullable = false) @Size(min=2, max=30)
	private String name;
		
	@NotEmpty
	private String password;
	
	@NotNull
	private Role role;
	
	public String toNameCard() {
		return name + "(" + id + ")";
	}

	@Override
	public String toString() {
		return String.format("User [id=%s, name=%s, password=[PROTECTED], role=%s]", id, name, role);
	}

	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return Arrays.asList(new SimpleGrantedAuthority(role.name()));
	}

	@Override
	public String getPassword() {
		return password;
	}

	@Override
	public String getUsername() {
		return name;
	}

	@Override
	public boolean isAccountNonExpired() {
		return true;
	}

	@Override
	public boolean isAccountNonLocked() {
		return true;
	}

	@Override
	public boolean isCredentialsNonExpired() {
		return true;
	}

	@Override
	public boolean isEnabled() {
		return true;
	}

}
