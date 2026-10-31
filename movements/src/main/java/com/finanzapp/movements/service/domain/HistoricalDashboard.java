package com.finanzapp.movements.service.domain;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class HistoricalDashboard {

    Integer year;

    Double idealAmount;

    Double realAmount;
}
