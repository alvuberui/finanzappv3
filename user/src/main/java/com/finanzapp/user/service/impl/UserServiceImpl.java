package com.finanzapp.user.service.impl;

import com.finanzapp.user.repository.UserRepository;
import com.finanzapp.user.repository.mapper.UserEntityMapper;
import com.finanzapp.user.service.UserService;
import com.finanzapp.user.service.domain.BooleanResponse;
import com.finanzapp.user.service.domain.CreateUserRequest;
import lombok.Builder;
import org.springframework.stereotype.Service;

@Builder
@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    private final UserEntityMapper userEntityMapper;

    @Override
    public BooleanResponse hasOnBoarded(String email) {
        boolean isOnBoarded = userRepository.findByEmail(email).isPresent();
        return BooleanResponse.builder().result(isOnBoarded).build();
    }

    @Override
    public void createUser(CreateUserRequest request) {
        if (hasOnBoarded(request.getEmail()).getResult()) {
            throw new IllegalArgumentException("El usuario con email " + request.getEmail() + " ya existe.");
        }

        userRepository.save(userEntityMapper.toUserEntity(request));
        return;
    }

}
