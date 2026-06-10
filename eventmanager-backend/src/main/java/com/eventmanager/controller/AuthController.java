package com.eventmanager.controller;

import com.eventmanager.model.User;
import com.eventmanager.repository.UserRepository;
import com.eventmanager.security.JwtUtil;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthController(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest req) {
        if (userRepository.existsByEmail(req.email)) {
            return ResponseEntity.badRequest().body("E-mail já cadastrado.");
        }
        User user = new User();
        user.setName(req.name);
        user.setEmail(req.email);
        user.setPassword(passwordEncoder.encode(req.password));
        userRepository.save(user);
        String token = jwtUtil.generateToken(user.getEmail());
        return ResponseEntity.ok(new AuthResponse(token, user.getName(), user.getEmail(), user.getId()));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest req) {
        return userRepository.findByEmail(req.email)
                .filter(u -> passwordEncoder.matches(req.password, u.getPassword()))
                .map(u -> {
                    String token = jwtUtil.generateToken(u.getEmail());
                    return ResponseEntity.ok(new AuthResponse(token, u.getName(), u.getEmail(), u.getId()));
                })
                .orElse(ResponseEntity.status(401).build());
    }

    @Data static class RegisterRequest {
        @NotBlank public String name;
        @Email @NotBlank public String email;
        @NotBlank public String password;
    }
    @Data static class LoginRequest {
        @Email @NotBlank public String email;
        @NotBlank public String password;
    }
    static class AuthResponse {
        public String token, name, email; public Long userId;
        AuthResponse(String t, String n, String e, Long id) { token=t; name=n; email=e; userId=id; }
    }
}
