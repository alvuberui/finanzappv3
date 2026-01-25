package com.finanzapp.user.controller.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UpdateUserRequestDto {

    @NotBlank(message = "Obligatorio")
    @Size(min = 2, message = "El nombre es muy corto")
    private String name;

    @NotBlank(message = "Obligatorio")
    @Size(min = 2, message = "El apellido es muy corto")
    private String lastname;

    @NotNull(message = "Obligatorio")
    @Past(message = "La fecha debe ser anterior a hoy")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate birthdate;

    @NotNull(message = "Obligatorio")
    @DecimalMin(value = "0.0", message = "Debe estar entre 0 y 100")
    @DecimalMax(value = "100.0", message = "El porcentaje debe estar entre 0 y 100")
    private Double monthlySavingPercentage;

    @NotNull(message = "Obligatorio")
    @DecimalMin(value = "0.0", message = "Debe estar entre 0 y 100")
    @DecimalMax(value = "100.0", message = "El porcentaje debe estar entre 0 y 100")
    private Double monthlyNecessaryExpensesPercentage;

    @NotNull(message = "Obligatorio")
    @DecimalMin(value = "0.0", message = "Debe estar entre 0 y 100")
    @DecimalMax(value = "100.0", message = "El porcentaje debe estar entre 0 y 100")
    private Double monthlyDiscretionaryExpensesPercentage;

    @NotNull(message = "Obligatorio")
    @DecimalMin(value = "0.0", message = "Debe estar entre 0 y 100")
    @DecimalMax(value = "100.0", message = "El porcentaje debe estar entre 0 y 100")
    private Double monthlyInvestmentPercentage;

    @AssertTrue(message = "La suma de porcentajes debe ser 100%")
    public boolean isPercentagesSum100() {
        if (monthlySavingPercentage == null ||
                monthlyNecessaryExpensesPercentage == null ||
                monthlyDiscretionaryExpensesPercentage == null ||
                monthlyInvestmentPercentage == null) {
            return false;
        }

        BigDecimal sum = BigDecimal.valueOf(monthlySavingPercentage)
                .add(BigDecimal.valueOf(monthlyNecessaryExpensesPercentage))
                .add(BigDecimal.valueOf(monthlyDiscretionaryExpensesPercentage))
                .add(BigDecimal.valueOf(monthlyInvestmentPercentage));

        // equivalente a Math.round(sum*100)/100 en JS
        BigDecimal rounded = sum.setScale(2, RoundingMode.HALF_UP);

        return rounded.compareTo(BigDecimal.valueOf(100.00).setScale(2, RoundingMode.HALF_UP)) == 0;
    }


}
