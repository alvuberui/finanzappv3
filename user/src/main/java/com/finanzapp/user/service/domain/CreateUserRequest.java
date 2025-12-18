package com.finanzapp.user.service.domain;

import lombok.*;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CreateUserRequest {

    private String email;

    private String name;

    private String lastname;

    private String birthdate;

    private Double initialWealth;

    private Double monthlySavingPercentage;

    private Double monthlyNecessaryExpensesPercentage;

    private Double monthlyDiscretionaryExpensesPercentage;

    private Double monthlyInvestmentPercentage;
}
