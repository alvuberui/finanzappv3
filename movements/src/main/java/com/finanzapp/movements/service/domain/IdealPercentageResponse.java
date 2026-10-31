package com.finanzapp.movements.service.domain;

import lombok.*;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class IdealPercentageResponse {

    private Double monthlySavingPercentage;

    private Double monthlyNecessaryExpensesPercentage;

    private Double monthlyDiscretionaryExpensesPercentage;

    private Double monthlyInvestmentPercentage;
}
