package com.finanzapp.user.service;

import com.finanzapp.user.service.domain.BooleanResponse;
import com.finanzapp.user.service.domain.CreateUserRequest;

public interface UserService {

    /**
     * Checks if a user with the given email has completed the onboarding process.
     *
     * @param email the email of the user to check
     * @return a BooleanResponse indicating whether the user has onboarded
     */
    BooleanResponse hasOnBoarded(String email);

    /**
     * Creates a new user based on the provided request data.
     *
     * @param request the request containing user details
     */
    void createUser(CreateUserRequest request);
}
