package com.finanzapp.user.controller.dto;

import jakarta.persistence.Column;
import lombok.*;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class IdealPercentageResponseDto {

    private Double monthlySavingPercentage;

    private Double monthlyNecessaryExpensesPercentage;

    private Double monthlyDiscretionaryExpensesPercentage;

    private Double monthlyInvestmentPercentage;
}
