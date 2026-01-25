package com.finanzapp.movements.service.impl;

import com.finanzapp.movements.repository.MovementRepository;
import com.finanzapp.movements.repository.entities.MovementEntity;
import com.finanzapp.movements.repository.entities.MovementType;
import com.finanzapp.movements.repository.mapper.MovementEntityMapper;
import com.finanzapp.movements.service.MovementService;
import com.finanzapp.movements.service.domain.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MovementServiceImpl implements MovementService {

    private final MovementRepository movementRepository;
    private final MovementEntityMapper movementMapper;
    private final UsersClientImpl usersClient;
    private final TagsClientImpl tagsClient;

    @Override
    public List<Integer> getYearsFromMovements(String userEmail) {
        return movementRepository.findDistinctYearsByUserEmail(userEmail);
    }

    @Override
    public List<Movement> getMovementsByUserEmailAndDateBetweenOrderByDate(String userEmail, LocalDate from, LocalDate to) {
        return movementMapper.toDomainList(
                movementRepository.findByUserEmailAndDateBetweenOrderByDate(userEmail, from, to)
        );
    }

    @Override
    public List<Movement> getMovementsByUserEmailAndDateBetweenOrderByDateFilterByTagId(String userEmail, LocalDate from, LocalDate to, Long tagId) {
        return movementMapper.toDomainList(
                movementRepository.findByUserEmailAndTagIdAndDateBetweenOrderByDate(userEmail, tagId, from, to)
        );
    }

    @Override
    public AnualMovementResponse getAnualMovementDashboard(
            String userEmail,
            String metric,
            LocalDate from,
            LocalDate to,
            String tokenValue
    ) {
        validateSameYear(from, to);

        Metric metricEnum = Metric.valueOf(metric);

        // Siempre cargamos BENEFIT porque:
        // - lo necesitas como base para calcular IDEAL (ideal = benefits * %)
        // - lo necesitas para SAVINGS (benefit - expenses - investment)
        List<Movement> benefit = loadMovements(userEmail, MovementType.BENEFIT, from, to, false, null);

        IdealPercentageResponse idealPercentResponse = usersClient.getIdealPercent(tokenValue);
        Double idealPercent = getIdealPercent(idealPercentResponse, metricEnum);

        return switch (metricEnum) {
            case BENEFIT -> movementMapper.toAnualMovementResponse(benefit, idealPercent, benefit);

            case INVESTMENTS -> {
                List<Movement> investment = loadMovements(userEmail, MovementType.INVESTMENT, from, to, false, null);
                yield movementMapper.toAnualMovementResponse(investment, idealPercent, benefit);
            }

            case DISCRETIONARY_EXPENSES -> {
                List<Movement> notEssential = loadMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, from, to, false, null);
                yield movementMapper.toAnualMovementResponse(notEssential, idealPercent, benefit);
            }

            case NECESSARY_EXPENSES -> {
                List<Movement> essential = loadMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, from, to, false, null);
                yield movementMapper.toAnualMovementResponse(essential, idealPercent, benefit);
            }

            case TOTAL_EXPENSES -> {
                List<Movement> essential = loadMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, from, to, false, null);
                List<Movement> notEssential = loadMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, from, to, false, null);

                Map<Integer, Double> totalExpensesByMonth = addMaps(sumByMonth(essential), sumByMonth(notEssential));

                List<Movement> synthetic = buildMonthlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.ESSENTIAL_EXPENSE, // placeholder
                        from.getYear(),
                        totalExpensesByMonth,
                        "SYNTHETIC_TOTAL_EXPENSES"
                );

                yield movementMapper.toAnualMovementResponse(synthetic, idealPercent, benefit);
            }

            case SAVINGS -> {
                List<Movement> essential = loadMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, from, to, false, null);
                List<Movement> notEssential = loadMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, from, to, false, null);
                List<Movement> investment = loadMovements(userEmail, MovementType.INVESTMENT, from, to, false, null);

                Map<Integer, Double> expensesByMonth = addMaps(sumByMonth(essential), sumByMonth(notEssential));
                Map<Integer, Double> savingsByMonth = subtractMaps(
                        subtractMaps(sumByMonth(benefit), expensesByMonth),
                        sumByMonth(investment)
                );

                List<Movement> synthetic = buildMonthlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.BENEFIT, // placeholder
                        from.getYear(),
                        savingsByMonth,
                        "SYNTHETIC_SAVINGS"
                );

                yield movementMapper.toAnualMovementResponse(synthetic, idealPercent, benefit);
            }
        };
    }

    @Override
    public AnualMovementResponse getAnualMovementDashboardFilterByTagId(String userEmail, String metric, LocalDate from, LocalDate to, String tokenValue, Long tagId) {
        validateSameYear(from, to);

        Metric metricEnum = Metric.valueOf(metric);

        // Siempre cargamos BENEFIT porque:
        // - lo necesitas como base para calcular IDEAL (ideal = benefits * %)
        // - lo necesitas para SAVINGS (benefit - expenses - investment)
        List<Movement> benefit = loadMovements(userEmail, MovementType.BENEFIT, from, to, true, tagId);

        IdealPercentageResponse idealPercentResponse = usersClient.getIdealPercent(tokenValue);
        Double idealPercent = getIdealPercent(idealPercentResponse, metricEnum);

        return switch (metricEnum) {
            case BENEFIT -> movementMapper.toAnualMovementResponse(benefit, idealPercent, benefit);

            case INVESTMENTS -> {
                List<Movement> investment = loadMovements(userEmail, MovementType.INVESTMENT, from, to, true, tagId);
                yield movementMapper.toAnualMovementResponse(investment, idealPercent, benefit);
            }

            case DISCRETIONARY_EXPENSES -> {
                List<Movement> notEssential = loadMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, from, to, true, tagId);
                yield movementMapper.toAnualMovementResponse(notEssential, idealPercent, benefit);
            }

            case NECESSARY_EXPENSES -> {
                List<Movement> essential = loadMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, from, to, true, tagId);
                yield movementMapper.toAnualMovementResponse(essential, idealPercent, benefit);
            }

            case TOTAL_EXPENSES -> {
                List<Movement> essential = loadMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, from, to, true, tagId);
                List<Movement> notEssential = loadMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, from, to, true, tagId);

                Map<Integer, Double> totalExpensesByMonth = addMaps(sumByMonth(essential), sumByMonth(notEssential));

                List<Movement> synthetic = buildMonthlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.ESSENTIAL_EXPENSE, // placeholder
                        from.getYear(),
                        totalExpensesByMonth,
                        "SYNTHETIC_TOTAL_EXPENSES"
                );

                yield movementMapper.toAnualMovementResponse(synthetic, idealPercent, benefit);
            }

            case SAVINGS -> {
                List<Movement> essential = loadMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, from, to, true, tagId);
                List<Movement> notEssential = loadMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, from, to, true, tagId);
                List<Movement> investment = loadMovements(userEmail, MovementType.INVESTMENT, from, to, true, tagId);

                Map<Integer, Double> expensesByMonth = addMaps(sumByMonth(essential), sumByMonth(notEssential));
                Map<Integer, Double> savingsByMonth = subtractMaps(
                        subtractMaps(sumByMonth(benefit), expensesByMonth),
                        sumByMonth(investment)
                );

                List<Movement> synthetic = buildMonthlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.BENEFIT, // placeholder
                        from.getYear(),
                        savingsByMonth,
                        "SYNTHETIC_SAVINGS"
                );

                yield movementMapper.toAnualMovementResponse(synthetic, idealPercent, benefit);
            }
        };
    }

    @Override
    public HistoricalMovementResponse getHistoricalMovements(String userEmail, String metric, String tokenValue) {
        Metric metricEnum = Metric.valueOf(metric);

        // Siempre cargamos BENEFIT porque:
        // - IDEAL se calcula como (beneficios del año * porcentaje)
        // - SAVINGS se calcula con benefits - expenses - investments
        List<Movement> benefit = loadHistoricalMovements(userEmail, MovementType.BENEFIT, false, null);

        IdealPercentageResponse idealPercentResponse = usersClient.getIdealPercent(tokenValue);
        Double idealPercent = getIdealPercent(idealPercentResponse, metricEnum);

        return switch (metricEnum) {
            case BENEFIT -> movementMapper.toHistoricalMovementResponse(benefit, idealPercent, benefit);

            case INVESTMENTS -> {
                List<Movement> investment = loadHistoricalMovements(userEmail, MovementType.INVESTMENT, false, null);
                yield movementMapper.toHistoricalMovementResponse(investment, idealPercent, benefit);
            }

            case DISCRETIONARY_EXPENSES -> {
                List<Movement> notEssential = loadHistoricalMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, false, null);
                yield movementMapper.toHistoricalMovementResponse(notEssential, idealPercent, benefit);
            }

            case NECESSARY_EXPENSES -> {
                List<Movement> essential = loadHistoricalMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, false, null);
                yield movementMapper.toHistoricalMovementResponse(essential, idealPercent, benefit);
            }

            case TOTAL_EXPENSES -> {
                List<Movement> essential = loadHistoricalMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, false, null);
                List<Movement> notEssential = loadHistoricalMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, false, null);

                Map<Integer, Double> totalExpensesByYear = addYearMaps(sumByYear(essential), sumByYear(notEssential));

                List<Movement> synthetic = buildYearlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.ESSENTIAL_EXPENSE, // placeholder
                        totalExpensesByYear,
                        "SYNTHETIC_TOTAL_EXPENSES"
                );

                yield movementMapper.toHistoricalMovementResponse(synthetic, idealPercent, benefit);
            }

            case SAVINGS -> {
                List<Movement> essential = loadHistoricalMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, false, null);
                List<Movement> notEssential = loadHistoricalMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, false, null);
                List<Movement> investment = loadHistoricalMovements(userEmail, MovementType.INVESTMENT, false, null);

                Map<Integer, Double> expensesByYear = addYearMaps(sumByYear(essential), sumByYear(notEssential));

                Map<Integer, Double> savingsByYear = subtractYearMaps(
                        subtractYearMaps(sumByYear(benefit), expensesByYear),
                        sumByYear(investment)
                );

                List<Movement> synthetic = buildYearlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.BENEFIT, // placeholder
                        savingsByYear,
                        "SYNTHETIC_SAVINGS"
                );

                yield movementMapper.toHistoricalMovementResponse(synthetic, idealPercent, benefit);
            }
        };
    }

    @Override
    public HistoricalMovementResponse getHistoricalMovementsFilterByTagId(String userEmail, String metric, String tokenValue, Long tagId) {
        Metric metricEnum = Metric.valueOf(metric);

        // Siempre cargamos BENEFIT porque:
        // - IDEAL se calcula como (beneficios del año * porcentaje)
        // - SAVINGS se calcula con benefits - expenses - investments
        List<Movement> benefit = loadHistoricalMovements(userEmail, MovementType.BENEFIT, true, tagId);

        IdealPercentageResponse idealPercentResponse = usersClient.getIdealPercent(tokenValue);
        Double idealPercent = getIdealPercent(idealPercentResponse, metricEnum);

        return switch (metricEnum) {
            case BENEFIT -> movementMapper.toHistoricalMovementResponse(benefit, idealPercent, benefit);

            case INVESTMENTS -> {
                List<Movement> investment = loadHistoricalMovements(userEmail, MovementType.INVESTMENT, true, tagId);
                yield movementMapper.toHistoricalMovementResponse(investment, idealPercent, benefit);
            }

            case DISCRETIONARY_EXPENSES -> {
                List<Movement> notEssential = loadHistoricalMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, true, tagId);
                yield movementMapper.toHistoricalMovementResponse(notEssential, idealPercent, benefit);
            }

            case NECESSARY_EXPENSES -> {
                List<Movement> essential = loadHistoricalMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, true, tagId);
                yield movementMapper.toHistoricalMovementResponse(essential, idealPercent, benefit);
            }

            case TOTAL_EXPENSES -> {
                List<Movement> essential = loadHistoricalMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, true, tagId);
                List<Movement> notEssential = loadHistoricalMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, true, tagId);

                Map<Integer, Double> totalExpensesByYear = addYearMaps(sumByYear(essential), sumByYear(notEssential));

                List<Movement> synthetic = buildYearlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.ESSENTIAL_EXPENSE, // placeholder
                        totalExpensesByYear,
                        "SYNTHETIC_TOTAL_EXPENSES"
                );

                yield movementMapper.toHistoricalMovementResponse(synthetic, idealPercent, benefit);
            }

            case SAVINGS -> {
                List<Movement> essential = loadHistoricalMovements(userEmail, MovementType.ESSENTIAL_EXPENSE, true, tagId);
                List<Movement> notEssential = loadHistoricalMovements(userEmail, MovementType.NOT_ESSENTIAL_EXPENSE, true, tagId);
                List<Movement> investment = loadHistoricalMovements(userEmail, MovementType.INVESTMENT, true, tagId);

                Map<Integer, Double> expensesByYear = addYearMaps(sumByYear(essential), sumByYear(notEssential));

                Map<Integer, Double> savingsByYear = subtractYearMaps(
                        subtractYearMaps(sumByYear(benefit), expensesByYear),
                        sumByYear(investment)
                );

                List<Movement> synthetic = buildYearlySyntheticMovements(
                        userEmail,
                        com.finanzapp.movements.service.domain.MovementType.BENEFIT, // placeholder
                        savingsByYear,
                        "SYNTHETIC_SAVINGS"
                );

                yield movementMapper.toHistoricalMovementResponse(synthetic, idealPercent, benefit);
            }
        };
    }

    @Override
    public Movement createMovement(CreateMovementRequest movement, String userEmail, String bearerToken) {
        if(movement.getAmount() < 0 ) {
            throw new IllegalArgumentException("La cantidad debe de ser mayor o igual a 0");
        }
        if(movement.getTagId() != null) {
            if(tagsClient.existsByIdAndUserEmail( movement.getTagId(), bearerToken ) == Boolean.FALSE) {
                throw new IllegalArgumentException("La etiqueta indicada no existe");
            }
        }
        return this.movementMapper.toDomain( this.movementRepository.save(this.movementMapper.toEntity(movement, userEmail)));
    }

    @Override
    public Movement updateMovement(Long movementId, UpdateMovementRequest movement, String userEmail, String bearerToken) {
        MovementEntity existingMovement = this.movementRepository.findByIdAndUserEmail(movementId, userEmail)
                .orElseThrow(() -> new IllegalArgumentException("Movimiento no encontrado"));

        if(movement.getAmount() != null && movement.getAmount() < 0 ) {
            throw new IllegalArgumentException("La cantidad debe de ser mayor o igual a 0");
        }

        if(movement.getTagId() != null) {
            if(tagsClient.existsByIdAndUserEmail( movement.getTagId(), bearerToken ) == Boolean.FALSE) {
                throw new IllegalArgumentException("La etiqueta indicada no existe");
            }
        }

        if (movement.getAmount() != null) {
            existingMovement.setAmount(movement.getAmount());
        }
        if (movement.getDate() != null) {
            existingMovement.setDate(movement.getDate());
        }
        if (movement.getTagId() != null) {
            existingMovement.setTagId(movement.getTagId());
        }
        if (movement.getDescription() != null) {
            existingMovement.setDescription(movement.getDescription());
        }
        if (movement.getMovementType() != null) {
            existingMovement.setMovementType( MovementType.valueOf( movement.getMovementType().name() ) );
        }

        MovementEntity updatedMovement = this.movementRepository.save(existingMovement);
        return this.movementMapper.toDomain(updatedMovement);
    }

    @Override
    public Movement getMovementById(Long movementId, String userEmail) {
        MovementEntity movementEntity = this.movementRepository.findByIdAndUserEmail(movementId, userEmail)
                .orElseThrow(() -> new IllegalArgumentException("Movimiento no encontrado"));
        return this.movementMapper.toDomain(movementEntity);
    }

    @Override
    public void deleteMovementById(Long movementId, String userEmail) {
        MovementEntity movementEntity = this.movementRepository.findByIdAndUserEmail(movementId, userEmail)
                .orElseThrow(() -> new IllegalArgumentException("Movimiento no encontrado"));
        this.movementRepository.delete(movementEntity);
    }

    @Override
    public void updateMovementsWhenTagIsDeleted(String userEmail, Long tagId) {
        List<Movement> movements = movementMapper.toDomainList(
                movementRepository.findByUserEmailAndTagId(userEmail, tagId)
        );
        for (Movement movement : movements) {
            movement.setTagId(null);
            MovementEntity entityToUpdate = movementMapper.toEntity(movement, userEmail);
            movementRepository.save(entityToUpdate);
        }
    }

    @Override
    public Double getActualTotalSavings(String userEmail, String tokenValue) {
        User user = usersClient.getUser(tokenValue);
        if (user == null) {
            throw new IllegalArgumentException("Usuario no encontrado");
        }
        List<Movement> allMovements = movementMapper.toDomainList(
                movementRepository.findByUserEmail(userEmail)
        );
        double totalBenefits = allMovements.stream()
                .filter(m -> m.getMovementType() == com.finanzapp.movements.service.domain.MovementType.BENEFIT)
                .mapToDouble(m -> m.getAmount() == null ? 0.0 : m.getAmount())
                .sum();
        double totalExpenses = allMovements.stream()
                .filter(m -> m.getMovementType() == com.finanzapp.movements.service.domain.MovementType.ESSENTIAL_EXPENSE
                        || m.getMovementType() == com.finanzapp.movements.service.domain.MovementType.NOT_ESSENTIAL_EXPENSE)
                .mapToDouble(m -> m.getAmount() == null ? 0.0 : m.getAmount())
                .sum();
        return totalBenefits - totalExpenses;
    }


    // -----------------------
    // Helpers
    // -----------------------

    private Map<Integer, Double> sumByYear(List<Movement> movements) {
        if (movements == null) return Map.of();

        return movements.stream()
                .filter(m -> m.getDate() != null)
                .collect(java.util.stream.Collectors.groupingBy(
                        m -> m.getDate().getYear(),
                        java.util.stream.Collectors.summingDouble(m -> m.getAmount() == null ? 0.0 : m.getAmount())
                ));
    }

    private Map<Integer, Double> addYearMaps(Map<Integer, Double> a, Map<Integer, Double> b) {
        Map<Integer, Double> out = new HashMap<>();
        java.util.Set<Integer> years = new java.util.HashSet<>();
        years.addAll(a.keySet());
        years.addAll(b.keySet());

        for (Integer y : years) {
            out.put(y, a.getOrDefault(y, 0.0) + b.getOrDefault(y, 0.0));
        }
        return out;
    }

    private Map<Integer, Double> subtractYearMaps(Map<Integer, Double> base, Map<Integer, Double> minus) {
        Map<Integer, Double> out = new HashMap<>();
        java.util.Set<Integer> years = new java.util.HashSet<>();
        years.addAll(base.keySet());
        years.addAll(minus.keySet());

        for (Integer y : years) {
            out.put(y, base.getOrDefault(y, 0.0) - minus.getOrDefault(y, 0.0));
        }
        return out;
    }

    private List<Movement> buildYearlySyntheticMovements(
            String userEmail,
            com.finanzapp.movements.service.domain.MovementType type,
            Map<Integer, Double> amountByYear,
            String description
    ) {
        List<Movement> out = new java.util.ArrayList<>(amountByYear.size());

        // Ordenados por año ascendente
        List<Integer> years = amountByYear.keySet().stream().sorted().toList();

        for (Integer year : years) {
            double amount = amountByYear.getOrDefault(year, 0.0);

            out.add(Movement.builder()
                    .id(null)
                    .userEmail(userEmail)
                    .movementType(type)
                    .amount(amount)
                    .date(LocalDate.of(year, 1, 1)) // marcador del año
                    .tagId(null)
                    .description(description)
                    .build());
        }

        return out;
    }

    private void validateSameYear(LocalDate from, LocalDate to) {
        if (from == null || to == null) {
            throw new IllegalArgumentException("from/to no pueden ser null");
        }
        if (from.getYear() != to.getYear()) {
            throw new IllegalArgumentException("from/to deben estar en el mismo año");
        }
    }

    private List<Movement> loadMovements(String userEmail, MovementType type, LocalDate from, LocalDate to, Boolean filerByTag, Long tagId) {
        if (filerByTag) {
            return movementMapper.toDomainList(
                    movementRepository.findByUserEmailAndMovementTypeAndTagIdAndDateBetweenOrderByDateAsc(userEmail, type, tagId, from, to)
            );
        }
        return movementMapper.toDomainList(
                movementRepository.findByUserEmailAndMovementTypeAndDateBetweenOrderByDateAsc(userEmail, type, from, to)
        );
    }

    private List<Movement> loadHistoricalMovements(String userEmail, MovementType type, Boolean filerByTag, Long tagId) {
        if (filerByTag) {
            return movementMapper.toDomainList(
                    movementRepository.findByUserEmailAndMovementTypeAndTagIdOrderByDateAsc(userEmail, type, tagId)
            );
        }
        return movementMapper.toDomainList(
                movementRepository.findByUserEmailAndMovementTypeOrderByDateAsc(userEmail, type)
        );
    }

    private Map<Integer, Double> sumByMonth(List<Movement> movements) {
        if (movements == null) return Map.of();

        return movements.stream()
                .filter(m -> m.getDate() != null)
                .collect(java.util.stream.Collectors.groupingBy(
                        m -> m.getDate().getMonthValue(),
                        java.util.stream.Collectors.summingDouble(m -> m.getAmount() == null ? 0.0 : m.getAmount())
                ));
    }

    private Map<Integer, Double> addMaps(Map<Integer, Double> a, Map<Integer, Double> b) {
        Map<Integer, Double> out = new HashMap<>();
        for (int m = 1; m <= 12; m++) {
            out.put(m, a.getOrDefault(m, 0.0) + b.getOrDefault(m, 0.0));
        }
        return out;
    }

    private Map<Integer, Double> subtractMaps(Map<Integer, Double> base, Map<Integer, Double> minus) {
        Map<Integer, Double> out = new HashMap<>();
        for (int m = 1; m <= 12; m++) {
            out.put(m, base.getOrDefault(m, 0.0) - minus.getOrDefault(m, 0.0));
        }
        return out;
    }

    private List<Movement> buildMonthlySyntheticMovements(
            String userEmail,
            com.finanzapp.movements.service.domain.MovementType type,
            int year,
            Map<Integer, Double> amountByMonth,
            String description
    ) {
        List<Movement> out = new java.util.ArrayList<>(12);

        for (int month = 1; month <= 12; month++) {
            double amount = amountByMonth.getOrDefault(month, 0.0);

            out.add(Movement.builder()
                    .id(null)
                    .userEmail(userEmail)
                    .movementType(type)
                    .amount(amount)
                    .date(LocalDate.of(year, month, 1))
                    .tagId(null)
                    .description(description)
                    .build());
        }
        return out;
    }

    private Double getIdealPercent(IdealPercentageResponse idealPercentageResponse, Metric metric) {
        if (idealPercentageResponse == null) {
            // fallback defensivo
            return metric == Metric.BENEFIT ? 100.0 : 0.0;
        }

        return switch (metric) {
            case BENEFIT -> 100.0;
            case SAVINGS -> idealPercentageResponse.getMonthlySavingPercentage();
            case TOTAL_EXPENSES ->
                    idealPercentageResponse.getMonthlyNecessaryExpensesPercentage()
                            + idealPercentageResponse.getMonthlyDiscretionaryExpensesPercentage();
            case DISCRETIONARY_EXPENSES -> idealPercentageResponse.getMonthlyDiscretionaryExpensesPercentage();
            case NECESSARY_EXPENSES -> idealPercentageResponse.getMonthlyNecessaryExpensesPercentage();
            case INVESTMENTS -> idealPercentageResponse.getMonthlyInvestmentPercentage();
        };
    }
}
