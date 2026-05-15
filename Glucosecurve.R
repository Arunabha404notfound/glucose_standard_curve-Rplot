# =============================================================================
# Glucose Standard Curve — Linear Regression Analysis
# =============================================================================
# Description : Fits a linear regression to glucose standard curve data,
#               visualises the curve, and back-calculates unknown sample
#               concentrations from measured optical densities (OD).
# Output      : ggplot2 figure + printed regression summary + unknown results
# =============================================================================

library(ggplot2)


# ── 1. Standard Data ──────────────────────────────────────────────────────────

data <- data.frame(
  glucose = c(0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0),
  od      = c(0.000, 0.27, 0.64, 0.765, 0.930, 1.08, 1.13)
)


# ── 2. Linear Regression ──────────────────────────────────────────────────────

model     <- lm(od ~ glucose, data = data)
slope     <- coef(model)[2]
intercept <- coef(model)[1]
r_squared <- summary(model)$r.squared


# ── 3. Unknown Sample Back-Calculation ────────────────────────────────────────

unknown_ods     <- c(0.04, 0.76)
unknown_glucose <- (unknown_ods - intercept) / slope

unknowns <- data.frame(
  glucose = unknown_glucose,
  od      = unknown_ods
)


# ── 4. Plot ───────────────────────────────────────────────────────────────────

ggplot(data, aes(x = glucose, y = od)) +
  
  # Standard curve points
  geom_point(color = "blue", size = 3) +
  
  # Regression line
  geom_smooth(method = "lm", se = FALSE, color = "red", linewidth = 1) +
  
  # Unknown sample points
  geom_point(data = unknowns, aes(x = glucose, y = od),
             color = "darkgreen", size = 4, shape = 18) +
  
  # Vertical dotted drop-lines
  geom_segment(data = unknowns,
               aes(x = glucose, y = 0, xend = glucose, yend = od),
               linetype = "dotted", color = "darkgreen") +
  
  # Horizontal dotted drop-lines
  geom_segment(data = unknowns,
               aes(x = 0, y = od, xend = glucose, yend = od),
               linetype = "dotted", color = "darkgreen") +
  
  # Concentration labels for unknowns
  annotate("text",
           x     = unknowns$glucose + 0.05,
           y     = unknowns$od,
           label = paste("Conc:", round(unknowns$glucose, 3)),
           color = "darkgreen", fontface = "bold", hjust = 0) +
  
  # Regression equation and R²
  annotate("text",
           x     = 0.05,
           y     = 1.15,
           label = paste0("y = ", round(slope, 4), "x + ", round(intercept, 4),
                          "\nR\u00B2 = ", round(r_squared, 4)),
           hjust = 0, size = 5) +
  
  coord_cartesian(xlim = c(0, 1.1), ylim = c(0, 1.3)) +
  
  labs(
    title    = "Glucose Standard Curve with Linear Regression",
    subtitle = "Quantitative prediction of unknown glucose samples",
    x        = "Glucose Concentration (mg/mL)",
    y        = "Optical Density (OD)"
  ) +
  
  theme_minimal(base_size = 14)


# ── 5. Printed Results ────────────────────────────────────────────────────────

cat("\n===== LINEAR REGRESSION SUMMARY =====\n")
print(summary(model))

cat("\n===== UNKNOWN SAMPLE RESULTS =====\n")
for (i in seq_along(unknown_ods)) {
  predicted <- max(round(unknown_glucose[i], 3), 0)   # floor at 0
  cat(sprintf(
    "Unknown Sample %d : Measured OD = %.3f  -->  Estimated Glucose = %.3f mg/mL\n",
    i, unknown_ods[i], predicted
  ))
}

cat("\nModel Equation :\n")
cat(sprintf("  OD = %.4f + %.4f * Glucose\n", intercept, slope))
cat(sprintf("  R\u00B2 = %.4f\n\n", r_squared))