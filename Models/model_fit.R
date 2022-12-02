install.packages("remotes")
remotes::install_github("avehtari/BDA_course_Aalto",
                        subdir = "rpackage", upgrade="never")
library(cmdstanr)
# If running in Aalto JupyterHub
set_cmdstan_path('/coursedata/cmdstan')
options(mc.cores = 1)
library(posterior)
library(loo)
library(tidyr)
library(dplyr)
options(pillar.neg=FALSE)
library(ggplot2)
library(gridExtra)
library(bayesplot)
theme_set(bayesplot::theme_default(base_family = "sans"))
library(rprojroot)
SEED <- 48927

data_pooled <- readRDS(file='~/notebooks/BDA/Project/data_pooled.Rda')
data_hx <- readRDS(file='~/notebooks/BDA/Project/data_hierarchical_x.Rda')
data_hy <- readRDS(file='~/notebooks/BDA/Project/data_hierarchical_y.Rda')

pooled_model <- cmdstan_model(stan_file = "~/notebooks/BDA/Project/pooled_linear_model.stan")
stan_data <- list(
  N = nrow(data_pooled),
  x = data_pooled$x,
  y = data_pooled$y,
  pmualpha = 0,
  psalpha = 100,
  pmubeta = 0,
  psbeta = 1000
)
fit_pooled <- pooled_model$sample(data = stan_data, refresh=1000)
fit_pooled$loo()

hierarchical_model <- cmdstan_model(stan_file = "~/notebooks/BDA/Project/hierarchical_linear_model.stan")
stan_data <- list(
  N = nrow(data_hy),
  J = ncol(data_hy),
  x = data_hx,
  y = data_hy,
  pmualpha = 0,
  psalpha = 100,
  pmubeta = 0,
  psbeta = 1000
)
fit_hierarchical <- hierarchical_model$sample(data = stan_data, refresh=1000)
fit_hierarchical$loo()

draws_lin <- as_draws_df(fit_pooled$draws())
mu <- draws_lin %>%
  as_draws_df() %>%
  as_tibble() %>%
  select(starts_with("mu")) %>%
  apply(2, quantile, c(0.05, 0.5, 0.95)) %>%
  t() %>% 
  data.frame(x = data_pooled$x, .)  %>% 
  gather(pct, y, -x)

ggplot() +
  geom_point(aes(x, y), data = data.frame(data_pooled)) +
  geom_line(aes(x, y, linetype = pct), data = mu, color = 'red') +
  scale_linetype_manual(values = c(2,1,2)) +
  labs(y = 'Injuries', x= "Magnitude") +
  guides(linetype = "none")

